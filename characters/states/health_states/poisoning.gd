extends HealthState
class_name Poisoning

var poison_dmg_per_tick: float = 0
var tick_per_second: int = 1 / Constants.POISON_TICK_TIME
onready var poison_timer := $PoisonTimer
var dmg_faction: String = ""

func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	dmg_receive_calculator.connect("poisoning", self, "_on_poisoning")
	timer.connect("timeout", self, "_on_poison_time_out")
	poison_timer.connect("timeout", self, "_get_poison_hit")
 

func _on_poisoning(_poison_dmg_per_tick: float, _poison_length: float, faction: String) -> void:
	dmg_faction = faction
	if timer.is_stopped() or _poison_dmg_per_tick == 0:
		poison(_poison_dmg_per_tick, _poison_length)
		return
	
	update_poison(_poison_dmg_per_tick, _poison_length)


func update_poison(_poison_dmg_per_tick: float, _poison_length: float) -> void:
	poison((poison_dmg_per_tick * remain_poison_tick() + _poison_dmg_per_tick * tick_per_second * _poison_length) / tick_per_second / max(_poison_length, timer.time_left), max(_poison_length, timer.time_left))


func remain_poison_tick() -> int:
	return int(timer.time_left * tick_per_second)


func poison(_poison_dmg_per_tick: float, _poison_length: float) -> void:
	poison_dmg_per_tick = _poison_dmg_per_tick
	start_timer(_poison_length)
	
	set_poison_color()
	check_and_start_poison()


func set_poison_color() -> void:
	if host.body_parts_node.get_modulate() != Constants.POISON_EFFECT_COLOR:
		stats_manager.status_color = Constants.POISON_EFFECT_COLOR
		if tween.is_inside_tree():
			Utils.start_tween(tween, host.body_parts_node, "modulate", host.body_parts_node.get_modulate(), Constants.POISON_EFFECT_COLOR, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		else:
			host.body_parts_node.modulate = Constants.POISON_EFFECT_COLOR


func check_and_start_poison() -> void:
	if !poison_timer.is_stopped():
		return
		
	poison_timer.start(Constants.POISON_TICK_TIME)


func _on_poison_time_out() -> void:
	poison_over()


func poison_over() -> void:
	poison_dmg_per_tick = 0
	poison_timer.stop()
	stats_manager.status_color = Constants.NORMAL_COLOR
	if tween.is_inside_tree():
		Utils.start_tween(tween, host.body_parts_node, "modulate", host.body_parts_node.get_modulate(), Constants.NORMAL_COLOR, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		yield(tween, "tween_completed")
	else:
		host.body_parts_node.modulate = Constants.NORMAL_COLOR
	emit_signal("effect_over", self)
	

func update_effect():
	set_poison_color()


func _get_poison_hit():
	dmg_receive_manager.receive_dmg_packed(Utils.create_direct_dmg_packed(poison_dmg_per_tick, dmg_faction))


func antidote():
	timer.stop()
	poison_over()
