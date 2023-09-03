extends AnimalsState


func _ready() -> void:
	pass
	
func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	
	var _jump_result: Dictionary = set_jump_position(_msg.jump_position, _msg.into_water)
#	print(character.name, " jump: ", _jump_result)
	if !_jump_result.can_jump:
		idle()
		character.land_returning = !_msg.into_water
		character.water_returning = _msg.into_water
		character.water_target = false
		character.ground_target = false
		character.emit_signal("moving")
		return
	var _jump_position: Vector2 = _jump_result.jump_position
	if !_msg.into_water:
		character.jumped_out_of_water()
		character.ground_target = false
	character.set_state_label("jump_into_and_out_of_water")
	character.play_animation("jump")
	var _character_tween = character.tween
	
	if _character_tween.is_inside_tree():
		Utils.start_tween(_character_tween, character, "global_position", character.global_position, _jump_position, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		yield(_character_tween,"tween_completed")
	else:
		character.global_position = _jump_position

	if _msg.into_water:
		character.swimming()
		character.water_target = false
	idle()


func exit() -> void:
	pass


func idle():
	state_machine.transition_to("idle")


func set_jump_position(_jump_position: Vector2, _into_water: bool) -> Dictionary:
	var _next_navigator_type: int = Constants.NavigatorType.WATER if _into_water else Constants.NavigatorType.LAND
#	print(character.name, ": jump at: ", character.get_map_position(_jump_position))
	var _jump_distance: Vector2 = character.distance_to_target_on_map(character.get_map_position(_jump_position))
#	print(character.name, ": jump_dist: ", _jump_distance)
	var _new_jump_distance: Vector2 = _jump_distance / max(abs(_jump_distance.x), abs(_jump_distance.y)) * (character.jump_into_water_max_distance if max(abs(_jump_distance.x), abs(_jump_distance.y)) >= character.jump_into_water_max_distance else 1)
	_new_jump_distance.x = int(_new_jump_distance.x)
	_new_jump_distance.y = int(_new_jump_distance.y)
#	print(character.name, ": new jump_dist: ", _new_jump_distance)
	var _new_jump_position: Vector2 = character.get_map_position() + _new_jump_distance
#	var _result: Dictionary = check_jump_position(_new_jump_position, _next_navigator_type)
	var _result: Dictionary = {"jump_position": _new_jump_position, "can_jump": can_jump(_new_jump_position, _next_navigator_type)}
	return {"jump_position": character.map_to_global_position(_result.jump_position), "can_jump": _result.can_jump}


func can_jump(_jump_position: Vector2, _next_navigator_type: int) -> bool:
	if not Utils.is_outside_of_map(character.map_manager.list_map_positions, character.map_manager.size, _jump_position):
		return !character.map_manager.map_navigator.is_map_position_disabled(_jump_position, _next_navigator_type)
	
	return false
