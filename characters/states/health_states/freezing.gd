extends HealthState
class_name Freezing

var freezing_strength: float = 0


func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	dmg_receive_calculator.connect("freezing", self, "_on_freezing")
	timer.connect("timeout", self, "_on_freezing_time_out")
 

func _on_freezing(_freeze_strength: float, _freeze_length: float) -> void:
	if timer.is_stopped() or freezing_strength == 0:
		freeze(_freeze_strength, _freeze_length)
		return
	update_freezing(_freeze_strength, _freeze_length)


func update_freezing(_freeze_strength: float, _freeze_length: float):
	var _freeze_strength_larger: bool = max(_freeze_strength, freezing_strength) == _freeze_strength
	var _new_freeze_length: float = timer.time_left * (abs(int(_freeze_strength_larger) - 1) + int(_freeze_strength_larger) * (_freeze_strength / freezing_strength * Constants.FREEZE_UPDATE_TIME_PERCENT)) + _freeze_length * (abs(int(!_freeze_strength_larger) - 1) + int(!_freeze_strength_larger) * (freezing_strength / _freeze_strength * Constants.FREEZE_UPDATE_TIME_PERCENT))
	freeze(max(_freeze_strength, freezing_strength), _new_freeze_length)


func freeze(_freeze_strength: float, _freeze_length: float):
	start_timer(_freeze_length)
	set_freeze_color()
	slow_down(_freeze_strength)
	freezing_strength = _freeze_strength


func set_freeze_color():
	if host.body_parts_node.get_modulate() != Constants.FREEZE_EFFECT_COLOR:
		stats_manager.status_color = Constants.FREEZE_EFFECT_COLOR
		if tween.is_inside_tree():
			Utils.start_tween(tween, host.body_parts_node, "modulate", host.body_parts_node.get_modulate(), Constants.FREEZE_EFFECT_COLOR, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			host.body_parts_node.modulate = Constants.FREEZE_EFFECT_COLOR


func slow_down(_freeze_strength: float):
	stats_manager.stats.speed_down_freeze = clamp(_freeze_strength, 0.0, 1.0)
	host.update_animation_speed(stats_manager.stats.total_speed)


func _on_freezing_time_out():
	unfreeze()


func unfreeze():
	freezing_strength = 0
	slow_down(0)
	stats_manager.status_color = Constants.NORMAL_COLOR
	if tween.is_inside_tree():
		Utils.start_tween(tween, host.body_parts_node, "modulate", host.body_parts_node.get_modulate(), Constants.NORMAL_COLOR, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		yield(tween, "tween_completed")
	else:
		host.body_parts_node.modulate = Constants.NORMAL_COLOR
	emit_signal("effect_over", self)


func unfreeze_on_burn():
	timer.stop()
	unfreeze()


func unfreezing():
	timer.stop()
	unfreeze()


func update_effect():
	set_freeze_color()
