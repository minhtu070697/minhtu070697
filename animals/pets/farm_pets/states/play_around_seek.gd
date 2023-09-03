extends AnimalsSeek
class_name PlayAroundSeek

var pet_owner
var pet_owner_last_position: Vector2


func enter(_msg := {}) -> void:  #msg: target_position, action_name
	pet_owner = character.pet_owner
	target_position = msg.target_position
	var _action_name: String = msg.action_name

	if character.dead:
		state_machine.transition_to("die")
		return
	character.set_state_label(name)
	play_around(target_position, _action_name)


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	if pet_owner_last_position != character.get_owner_map_pos():
		idle()


func play_around(_target_position: Vector2, _action_name: String):
	if _action_name == "run_around":
		jump_around(_target_position)
		return

	if _action_name == "run_around_owner":
		run_around_owner()
		return

	if _action_name == "belly_up":
		belly_up()
		return


func jump_around(_target_position: Vector2):
	var _temp_paths: PoolVector2Array = []
	var _target_global_position: Vector2 = character.map_to_global_position(_target_position)
	var _target_position_2: Vector2 = character.check_and_fix_position(
		(
			character.global_position
			+ (character.global_position - _target_global_position).rotated(deg2rad(90))
		)
	)
	var _target_position_3: Vector2 = character.check_and_fix_position(
		_target_position_2 + (_target_position_2 - character.global_position).rotated(deg2rad(90))
	)
	play_moving_animation()
	for i in Utils.random_int(4, 12):
		if i % 4 == 2:
			_temp_paths.append(_target_global_position)
		elif i % 4 == 3:
			_temp_paths.append(character.global_position)
		elif i % 4 == 0:
			_temp_paths.append(_target_position_2)
		elif i % 4 == 1:
			_temp_paths.append(_target_position_3)
	paths = _temp_paths


#override
func set_up_paths(_target_pos: Vector2 = Vector2.INF, _core_pos: Vector2 = Vector2.INF, _tried: int = 0, _continous_find: bool = false):
	pass


# new version but not perfect atm
func run_around_owner() -> void:
	var _temp_paths: PoolVector2Array = []
	pet_owner_last_position = character.get_owner_map_pos()
	if pet_owner_last_position == Vector2.INF:
		paths = _temp_paths
		return
	
	character.play_animation("run", character.action_speed)

	var _start_position_number: int = choose_run_around_owner_start_position()
	var _last_position: Vector2 = character.global_position
	for i in Utils.random_int(4, 12):
		var _move_position: Vector2 = run_around_owner_position(
			i, pet_owner_last_position, _start_position_number
		)
		var _path_to_position: PoolVector2Array = character.get_path_from_position_to_target(
			_last_position, _move_position
		)
		if !_path_to_position.empty():
			_move_position = _path_to_position[-1]

		_temp_paths.append_array(_path_to_position)
		_last_position = _move_position

	paths = _temp_paths


func run_around_owner_position(
	_position_number: int, _pet_owner_last_position: Vector2, _start_position_number: int
) -> Vector2:
	return character.map_to_global_position(
		(
			_pet_owner_last_position
			+ Vector2(
				(((_position_number + _start_position_number) / 2 + 1) % 2) * 2 - 1,
				(((_position_number + 1 + _start_position_number) / 2 + 1) % 2) * 2 - 1
			)
		)
	)


func choose_run_around_owner_start_position() -> int:
	if character.get_map_position().x > pet_owner_last_position.x:
		if character.get_map_position().y > pet_owner_last_position.y:
			return 0
		else:
			return 1
	else:
		if character.get_map_position().y > pet_owner_last_position.y:
			return 3
		else:
			return 2


func belly_up() -> void:
	pass


func play_moving_animation() -> void:
	if character.on_ground():
		play_on_ground_moving_animation()
	elif character.on_water():
		play_on_water_moving_animation()


func play_on_ground_moving_animation() -> void:
	character.play_animation("run", character.action_speed)


func play_on_water_moving_animation() -> void:
	character.play_animation("fast_swim", character.action_speed)
