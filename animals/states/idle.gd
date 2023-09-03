extends AnimalsState
class_name AnimalsIdle

signal animal_arrived()


func _ready() -> void:
	pass
	
func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()
	if character.can_jump_into_water() and character.water_target:
#		print(character.name, " jump in water")
		state_machine.transition_to("jump_into_and_out_of_water", 
			{"jump_position": character.water_target_position, "into_water": true})
	if character.can_jump_out_of_water() and character.ground_target:
#		print(character.name, " jump out water")
		state_machine.transition_to("jump_into_and_out_of_water", 
			{"jump_position": character.ground_target_position, "into_water": false})


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	character.action_speed = 1.0
	connect_to_behavior_signals()
	character.set_state_label("idle")
	play_idle_animation()
	character.change_status_text("idle")
	SignalManager.emit_signal("character_arrived", character.name)
	emit_signal("animal_arrived")
	start_idle_timer()


func play_idle_animation() -> void:
	if character.on_ground():
		character.play_animation("idle")
	elif character.on_water():
		character.play_animation("idle_swim")


func start_idle_timer():
	character.start_idle_timer()


func connect_to_behavior_signals():
	if !character.is_connected("moving", self, "_moving"):
		character.connect("moving", self, "_moving")
	if !character.is_connected("eating", self, "_eating"):
		character.connect("eating", self, "_eating")
	if !character.is_connected("lying_down", self, "_lying_down"):
		character.connect("lying_down", self, "_lying_down")
	if !character.is_connected("sleeping", self, "_sleeping"):
		character.connect("sleeping", self, "_sleeping")


func exit() -> void:
	pass


#after x seconds, host move randomly in range (4,4)
func _moving() -> void:
	if state_machine.state != self:
		return
	if character.cry_sound != null:
		if Utils.random_int(1,100) < 16:
			Utils.play_sound(character.audio_player, character.cry_sound, character.animal_info.cry_sound_amplify)
	
	var _destination: Vector2 #local_position
	var force_find_path: bool = false
	
	if character.land_returning and character.current_navigator_use == Constants.NavigatorType.WATER and character.memory.has(character.MEMORIES.WATER_EDGE) and not character.land_water_need_disabled:
		_destination = find_land_position()
		if _destination == Vector2.INF:
			character.land_water_need_disabled = true
			character.refind_water_edge()
#		print("too wet!, return to land. wet meter: ", character.wet_meter)
	elif character.water_returning and character.current_navigator_use == Constants.NavigatorType.LAND and character.memory.has(character.MEMORIES.WATER_EDGE) and not character.land_water_need_disabled:
		_destination = find_water_position()
		if _destination == Vector2.INF:
			character.land_water_need_disabled = true
			character.refind_water_edge()
#		print("too dry!, return to water. wet meter: ", character.wet_meter)
	else:
		var _temp_x = Utils.random_int(-character.animal_info.max_walk_distance, character.animal_info.max_walk_distance)
		var _temp_y = Utils.random_int(-character.animal_info.max_walk_distance, character.animal_info.max_walk_distance)
		_destination = GameManager.map_manager_utils.convert_out_side_to_map_map_position(character.get_map_position() + Vector2(_temp_x, _temp_y))
		force_find_path = true

	state_machine.transition_to(
			"seek", 
			{
				"target_position": character.map_manager.map_navigator.point_to_world(_destination),
				"ffp": force_find_path
			}
		)


func _eating() -> void:
	if state_machine.state != self:
		return
	state_machine.transition_to("eat")


func _lying_down(_animation_name: String) -> void:
	if state_machine.state != self:
		return
	state_machine.transition_to("lie_down", {"animation": _animation_name})


func _sleeping() -> void:
	if state_machine.state != self:
		return
	state_machine.transition_to("sleep")


func find_land_position() -> Vector2:
	return find_tiles_around(Constants.NavigatorType.LAND, character.memory[character.MEMORIES.WATER_EDGE])


func find_water_position() -> Vector2:
	return find_tiles_around(Constants.NavigatorType.WATER, character.memory[character.MEMORIES.WATER_EDGE])


func find_tiles_around(_tiles_type: int, _start_pos: Vector2 = character.get_map_position()) -> Vector2:
	var _navigator = character.map_manager.map_navigator
	for k in character.map_manager.list_map_positions.size():
		if character.map_manager.list_map_positions[k] == character.inside_map_position:
			for i in range(3):
				if i == 0:
					continue
				for j in range(0, i + 1, min(i, 3)): # for i (0, i) with step of i, max 3
					for e in [-1, 1] :
						for f in [-1, 1]:
							var _checking_tile_position: Vector2 = _start_pos + Vector2(j * e, i * f)
							if not Utils.is_outside_of_map(character.map_manager.list_map_positions, character.map_manager.size, _checking_tile_position):
								if tile_is(_checking_tile_position, _tiles_type) and !_navigator.is_map_position_disabled(_checking_tile_position, _tiles_type):
									return _checking_tile_position
								
							_checking_tile_position = _start_pos + Vector2(i * e, j * f)
							if not Utils.is_outside_of_map(character.map_manager.list_map_positions, character.map_manager.size, _checking_tile_position):
								if tile_is(_checking_tile_position, _tiles_type) and !_navigator.is_map_position_disabled(_checking_tile_position, _tiles_type):
									return _checking_tile_position

	return Vector2.INF


func tile_is(_tile_position: Vector2, _tiles_type: int) -> bool:
	return character.map_manager.map_info.is_walkable(_tile_position, _tiles_type)
