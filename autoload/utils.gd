extends Node

const FLOAT_EPSILON = 0.0001
const EPSILON = PI * 0.01


func node_exists(node):
	return is_instance_valid(node) and node != null and node is Node and node.is_inside_tree()


func value_between(value, boundary: Vector2):
	return value >= boundary.x and value <= boundary.y


func floats_equal(a, b, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon


func clamp_int(_a: int, _min: int, _max: int) -> int:  #value, min, max
	if _a < _min:
		return _min
	elif _a > _max:
		return _max
	return _a


func make_2d_array(width, height):
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append([])
	return array


func swap(a, b) -> void:
	var temp = a
	a = b
	b = temp


func random_int_with_seed(_min, _max, rng_seed):
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	return rng.randi() % (_max - _min + 1) + _min


func random_int(_min: int, _max: int) -> int:
	if _min > _max:
		var temp = _min
		_min = _max
		_max = temp

	return randi() % (_max - _min + 1) + _min


# Randomly return -1 or 1
func random_neg_pos() -> int:
	return random_int(0, 1) * 2 - 1


func random_percent(_min: int, _max: int) -> float:
	return random_int(_min, _max) * 0.01


func random_from_array(array):
	return array[randi() % array.size()]


func random_from_dict(dict):
	var a = dict.keys()
	a = a[randi() % a.size()]
	return a


func rotate_vector_to_deg(vec: Vector2, to_angle: float, from_angle: float = 999999999) -> Vector2:
	var current_angle: float
	if from_angle == 999999999:
		current_angle = rad2deg(vec.angle())
	else:
		current_angle = from_angle
	var rotate_deg: float = to_angle - current_angle
	return vec.rotated(deg2rad(rotate_deg))


func angle_to_direction(angle):
	var direction
	if (
		value_between(angle, Constants.QUARTER_ANGLE_SIDE_RIGHT)
		or value_between(angle, Constants.QUARTER_ANGLE_SIDE_LEFT)
		or value_between(angle, Constants.QUARTER_ANGLE_NEGATIVE_SIDE_LEFT)
	):
		direction = Constants.Direction.SIDE
	elif value_between(angle, Constants.QUARTER_ANGLE_DOWN):
		direction = Constants.Direction.DOWN
	elif value_between(angle, Constants.QUARTER_ANGLE_UP):
		direction = Constants.Direction.UP
	elif value_between(angle, Vector2(0, PI)):
		direction = Constants.Direction.DOWN_SIDE
	elif value_between(angle, Vector2(-PI, 0)):
		direction = Constants.Direction.UP_SIDE
	return direction


func convert_to_iso_vector(v: Vector2) -> Vector2:
	v.y = v.y * cos(deg2rad(60))
	return v


func get_current_map_position(list_map_positions: Array, size: int, point: Vector2):
	var map_position: Vector2 = Vector2.ZERO
	for i in list_map_positions.size():
		var xrange = cal_xrange(list_map_positions[i], size)
		var yrange = cal_yrange(list_map_positions[i], size)
		if not is_outside_of_map_range(point, xrange, yrange):
			map_position = list_map_positions[i]
			break
	return map_position


func is_outside_of_map(list_map_positions: Array, size: int, point: Vector2):
	var is_outside: bool = false
	for i in list_map_positions.size():
		var xrange = cal_xrange(list_map_positions[i], size)
		var yrange = cal_yrange(list_map_positions[i], size)
		if not is_outside_of_map_range(point, xrange, yrange):
			is_outside = false
			break
		else:
			is_outside = true
	return is_outside


func is_outside_of_map_range(point: Vector2, xrange, yrange):
	return point.x < xrange.x or point.y < yrange.x or point.x >= xrange.y or point.y >= yrange.y


func is_at_edge_of_map(list_map_positions: Array, size: int, point: Vector2):
	var is_at_edge: bool = false
	for i in list_map_positions.size():
		var xrange = cal_xrange(list_map_positions[i], size)
		var yrange = cal_yrange(list_map_positions[i], size)
		if is_at_edge_of_map_range(point, xrange, yrange):
			is_at_edge = true
			break
		else:
			is_at_edge = false
	return is_at_edge


func is_at_edge_of_map_range(point: Vector2, xrange, yrange):
	return point.x == xrange.x or point.y == yrange.x or point.x == xrange.y or point.y == yrange.y


func cal_xrange(map_position: Vector2, size: int):
	return Vector2(map_position.x * size, map_position.x * size + size)


func cal_yrange(map_position: Vector2, size: int):
	return Vector2(map_position.y * size, map_position.y * size + size)


func can_resource_scale_x(point: Vector2) -> bool:
	if point.x == point.y:
		return true
	else:
		return false


func random_resource_scale_x(point: Vector2) -> Vector2:
	if !can_resource_scale_x(point):
		return Vector2(1, 1)
	var random = random_int(0, 1)
	if random == 0:
		return Vector2(1, 1)
	else:
		return Vector2(-1, 1)


func on_resource_animation_finished(node, animation_name, vfx_hit = null):
	if animation_name == "die":
		node.call_deferred("free")
	if animation_name == "hit":
		vfx_hit.visible = false


func on_resource_shake(shake, duration, frequency, amplitude, prioirty):
	shake.start(duration, frequency, amplitude, prioirty)


func _print_debug(msg = "", msg2 = "", msg3 = "", msg4 = ""):
	if Constants.DEBUG:
		print(msg, msg2, msg3, msg4)


func has_stats_manager(_host):
	return _host.has_node("StatsManager")


func coroutine(delay_time):
	var timer: Timer = Timer.new()
	GameManager.add_child(timer)
	timer.start(delay_time)
	return timer


# main coroutine function
func start_coroutine(delay_time):
	var timer = coroutine(delay_time)
	GameManager.coroutine_manager.append_coroutine(timer)
	yield(timer, "timeout")
	GameManager.coroutine_manager.pop_coroutine(timer)


func stop_all_coroutines() -> void:
	GameManager.coroutine_manager.stop_all_coroutines()


func start_tween(
	tween: Tween,
	obj: Object,
	property: NodePath,
	start_val,
	end_val,
	duration: float,
	transition: int = 0,
	easing: int = 2,
	delay = 0.0
):
	tween.interpolate_property(
		obj, property, start_val, end_val, duration, transition, easing, delay
	)
	tween.start()
	GameManager.tween_manager.append_tween(tween)
	yield(tween, "tween_completed")
	GameManager.tween_manager.pop_tween(tween)


func stop_all_tweens() -> void:
	GameManager.tween_manager.stop_all_tweens()


# region: objects checking
func transparent_object_between_camera_and_player(sprite, tween, alpha_1st, alpha_2nd, duration):
	if node_exists(tween):
		start_tween(
			tween,
			sprite,
			"modulate",
			Color(1, 1, 1, alpha_1st),
			Color(1, 1, 1, alpha_2nd),
			duration,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)


func cal_object_sprite_generate_position(object_sprite, expect_percent) -> Vector2:
	var sprite_height = object_sprite.texture.get_height()
	var height_percent = (sprite_height * expect_percent) / 100
	return Vector2(0, -height_percent)

#endregion


func create_dmg_packed(_dmg_modifier, _original_dmg_packed) -> DamagePacked:
	var _temp_dmg_packed = dmg_packed_clone(_original_dmg_packed)
	_temp_dmg_packed.p_dmg *= _dmg_modifier
	_temp_dmg_packed.m_dmg *= _dmg_modifier

	_temp_dmg_packed.fire_dmg *= _dmg_modifier
	_temp_dmg_packed.cold_dmg *= _dmg_modifier
	_temp_dmg_packed.poison_dmg_per_tick *= _dmg_modifier
	_temp_dmg_packed.lightning_dmg *= _dmg_modifier
	return _temp_dmg_packed


func dmg_packed_clone(original_dmg_packed) -> DamagePacked:
	var _temp_dmg_packed = DamagePacked.new()
	_temp_dmg_packed.atk_owner = original_dmg_packed.atk_owner
	_temp_dmg_packed.faction = original_dmg_packed.faction
	_temp_dmg_packed.p_dmg = original_dmg_packed.p_dmg
	_temp_dmg_packed.m_dmg = original_dmg_packed.m_dmg
	_temp_dmg_packed.accuracy_rate = original_dmg_packed.accuracy_rate
	_temp_dmg_packed.crit_rate = original_dmg_packed.crit_rate
	_temp_dmg_packed.crit_dmg = original_dmg_packed.crit_dmg
	_temp_dmg_packed.lvl = original_dmg_packed.lvl
	_temp_dmg_packed.target_force_to_state = original_dmg_packed.target_force_to_state

	_temp_dmg_packed.fire_dmg = original_dmg_packed.fire_dmg
	_temp_dmg_packed.cold_dmg = original_dmg_packed.cold_dmg
	_temp_dmg_packed.poison_dmg_per_tick = original_dmg_packed.poison_dmg_per_tick
	_temp_dmg_packed.lightning_dmg = original_dmg_packed.lightning_dmg

	_temp_dmg_packed.fire_dmg_buff = original_dmg_packed.fire_dmg_buff
	_temp_dmg_packed.cold_dmg_buff = original_dmg_packed.cold_dmg_buff
	_temp_dmg_packed.poison_dmg_buff = original_dmg_packed.poison_dmg_buff
	_temp_dmg_packed.lightning_dmg_buff = original_dmg_packed.lightning_dmg_buff

	_temp_dmg_packed.freeze_length = original_dmg_packed.freeze_length
	_temp_dmg_packed.freeze_length_buff = original_dmg_packed.freeze_length_buff
	_temp_dmg_packed.freeze_strength = original_dmg_packed.freeze_strength
	_temp_dmg_packed.poison_length = original_dmg_packed.poison_length
	_temp_dmg_packed.poison_length_buff = original_dmg_packed.poison_length_buff
	return _temp_dmg_packed


func create_custom_dmg_packed(dmg_info: Dictionary, _original_dmg_packed: DamagePacked) -> DamagePacked:
	var _temp_dmg_packed = dmg_packed_clone(_original_dmg_packed)
	
	# weapon dmg - % dmg of weapon
	var dmg_diff: float = 0.0
	if dmg_info.has("weapon_dmg_diff"):
		dmg_diff = dmg_info.weapon_dmg_diff
	
	if dmg_info.has("weapon_dmg"):
		_temp_dmg_packed.p_dmg = _temp_dmg_packed.p_dmg * random_dmg(dmg_info.weapon_dmg, dmg_diff)
		_temp_dmg_packed.m_dmg = _temp_dmg_packed.m_dmg * random_dmg(dmg_info.weapon_dmg, dmg_diff)
	
	# physic dmg
	dmg_diff = 0.0
	if dmg_info.has("p_dmg_diff"):
		dmg_diff = dmg_info.p_dmg_diff
	
	if dmg_info.has("p_dmg"):
		_temp_dmg_packed.p_dmg += random_dmg(dmg_info.p_dmg, dmg_diff)
	
	# magic dmg
	dmg_diff = 0.0
	if dmg_info.has("m_dmg_diff"):
		dmg_diff = dmg_info.m_dmg_diff
	
	if dmg_info.has("m_dmg"):
		_temp_dmg_packed.m_dmg += random_dmg(dmg_info.m_dmg, dmg_diff)
	
	# fire dmg
	dmg_diff = 0.0
	if dmg_info.has("fire_dmg_diff"):
		dmg_diff = dmg_info.fire_dmg_diff
	
	var e_dmg: float = 0.0
	if dmg_info.has("fire_dmg") and dmg_info.fire_dmg > 0:
		e_dmg += random_dmg(dmg_info.fire_dmg, dmg_diff)
	
	if dmg_info.has("fire_wp_dmg") and dmg_info.fire_wp_dmg > 0:
		e_dmg += (_temp_dmg_packed.p_dmg + _temp_dmg_packed.m_dmg) * random_dmg(dmg_info.fire_wp_dmg, dmg_diff)
	
	if e_dmg == 0.0:
		_temp_dmg_packed.fire_dmg = 0.0
	else:
		_temp_dmg_packed.fire_dmg += e_dmg
	
	# cold dmg
	dmg_diff = 0.0
	e_dmg = 0.0
	if dmg_info.has("cold_dmg_diff"):
		dmg_diff = dmg_info.cold_dmg_diff
	
	if dmg_info.has("cold_dmg") and dmg_info.cold_dmg > 0:
		e_dmg += random_dmg(dmg_info.cold_dmg, dmg_diff)
	
	if dmg_info.has("cold_wp_dmg") and dmg_info.cold_wp_dmg > 0:
		e_dmg += (_temp_dmg_packed.p_dmg + _temp_dmg_packed.m_dmg) * random_dmg(dmg_info.cold_wp_dmg, dmg_diff)
	
	if e_dmg == 0.0:
		_temp_dmg_packed.cold_dmg = 0.0
	else:
		_temp_dmg_packed.cold_dmg += e_dmg
	
	# lightning dmg
	dmg_diff = 0.0
	e_dmg = 0.0
	if dmg_info.has("lightning_dmg_diff"):
		dmg_diff = dmg_info.lightning_dmg_diff
	
	if dmg_info.has("lightning_dmg") and dmg_info.lightning_dmg > 0:
		e_dmg += random_dmg(dmg_info.lightning_dmg, dmg_diff)
	
	if dmg_info.has("lightning_wp_dmg") and dmg_info.lightning_wp_dmg > 0:
		e_dmg += (_temp_dmg_packed.p_dmg + _temp_dmg_packed.m_dmg) * random_dmg(dmg_info.lightning_wp_dmg, dmg_diff)
	
	if e_dmg == 0.0:
		_temp_dmg_packed.lightning_dmg = 0.0
	else:
		_temp_dmg_packed.lightning_dmg += e_dmg
	
	# poison dmg
	dmg_diff = 0.0
	e_dmg = 0.0
	if dmg_info.has("poison_dmg_diff"):
		dmg_diff = dmg_info.poison_dmg_diff
	
	if (dmg_info.has("poison_dmg")
		and dmg_info.poison_dmg > 0
		and dmg_info.has("poison_length")
		and dmg_info.poison_length != 0
		):
		e_dmg += random_dmg(dmg_info.poison_dmg, dmg_diff) * Constants.POISON_TICK_TIME / dmg_info.poison_length
	
	if (dmg_info.has("poison_wp_dmg")
		and dmg_info.poison_wp_dmg > 0
		and dmg_info.has("poison_length")
		and dmg_info.poison_length != 0
		):
		e_dmg += (_temp_dmg_packed.p_dmg + _temp_dmg_packed.m_dmg) * random_dmg(dmg_info.poison_wp_dmg, dmg_diff) * Constants.POISON_TICK_TIME / dmg_info.poison_length
	
	if e_dmg == 0.0:
		_temp_dmg_packed.poison_dmg_per_tick = 0.0
	else:
		_temp_dmg_packed.poison_dmg_per_tick += e_dmg
	
	# elemental effects
	if dmg_info.has("freeze_length"):
		_temp_dmg_packed.freeze_length = dmg_info.freeze_length
	
	if dmg_info.has("freeze_strength"):
		_temp_dmg_packed.freeze_strength = dmg_info.freeze_strength
	
	if dmg_info.has("poison_length"):
		_temp_dmg_packed.poison_length = dmg_info.poison_length

	return _temp_dmg_packed


func random_dmg(_atk: float, _dmg_diff: float) -> float:
	return rand_range(_atk * (1 - _dmg_diff), _atk * (1 + _dmg_diff))


func create_direct_dmg_packed(_direct_dmg: float, faction: String) -> DamagePacked:
	var _packed_content = {}
	_packed_content["direct_dmg"] = _direct_dmg
	_packed_content["faction"] = faction
	return DamagePacked.new(_packed_content)


func load_all_items(_path, _host) -> Array:  #load all resources in directory as Class, have to has func load_file_as_class if call this func
	var files = []
	var dir = Directory.new()
	dir.open(_path)
	dir.list_dir_begin()

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif not file_name.begins_with("."):
			var temp_stat = _host.load_file_as_class(_path + file_name)
			files.append(temp_stat)

	dir.list_dir_end()
	return files


func check_skill_active(_event: InputEvent) -> int:
	if Input.is_action_just_released("skill1"):
		return 1
	if Input.is_action_just_released("skill2"):
		return 2
	if Input.is_action_just_released("skill3"):
		return 3
	if Input.is_action_just_released("basic_attack"):
		return 0

	return -1


func projectiles_spawn_angle(_proj_num: int = 1) -> float:
	var _angle: float = 0
	var _density: int = Constants.SPAWN_PROJECTILES_FIELD_DENSITY

	return Constants.SPAWN_PROJECTILES_FIELD_ANGLE / max(_density, _proj_num)


# region: ui animation
func button_click_scale(btn, init, final, duration):
	var tween = btn.get_node_or_null("Tween")
	if Utils.node_exists(tween):
		Utils.start_tween(
			tween, btn, "rect_scale", init, final, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR
		)


# endregion
func play_sound(_audio_player, _sound: Resource, _amplify: int = 0):
	if !_sound or !_audio_player:
		return
	_audio_player.stream = _sound
	_audio_player.volume_db = _amplify
	_audio_player.play()


func convert_json_data_to_godot_var(_data):
	match typeof(_data):
		TYPE_ARRAY:
			for i in _data.size():
				_data[i] = convert_json_data_to_godot_var(_data[i])
			return _data

		TYPE_DICTIONARY:
			match _data.size():
				2:
					if _data.has("x") and _data.has("y"):
						return Vector2(_data.x, _data.y)
				4:
					if _data.has("r") and _data.has("g") and _data.has("b") and _data.has("a"):
						return Color(_data.r, _data.g, _data.b, _data.a)

			for _var in _data:
				_data[_var] = convert_json_data_to_godot_var(_data[_var])
			return _data

		_:
			return _data


func to_text(_number: float) -> String:
	return str(int(_number))


func to_text_percent(_number: float) -> String:
	return to_text(_number * 100) + "%"


func to_text_float(_number: float, _number_of_decimal: int):
	return str(stepify(_number, 1 / pow(10, _number_of_decimal)))


func to_text_second(_number: float):
	return to_text_float(_number, 2) + " seconds"


func is_equipment(_item_category: String) -> bool:
	return _item_category in Constants.EQUIPMENT_ITEM_CATEGORY


func get_current_map_info(map_manager):
	if (
		map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				return map_manager.map_info
			Constants.FloorType.FIRST_FLOOR:
				return map_manager.map_info_1st
			Constants.FloorType.SECOND_FLOOR:
				return map_manager.map_info_2nd
	else:
		return map_manager.map_info


#region: save build data
func get_scene_name_from_node(node_name):
	return str(node_name.replace("@", "").replace(str(int(node_name)), ""))


func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string.erase(0, 1)
		new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector2(array[0], array[1])

	return Vector2.ZERO


func get_current_character():
	var map_manager = get_node_or_null("/root/MapManager")
	if map_manager != null:
		return map_manager.ysort.get_node_or_null("Character")
	else:
		return null


func is_character_enter_collision(body):
	return body.name == "Character"


func is_in_buildable_map(map_type):
	return (
		map_type == Constants.MapSceneType.FARM_MAP
		or map_type == Constants.MapSceneType.BATTLE_MAP
		or map_type == Constants.MapSceneType.BASE_MAP
		or map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	)

#endregion


enum BasicTimeFormat { HOURS = 1 << 0, MINUTES = 1 << 1, SECONDS = 1 << 2, MICRO_SECONDS = 1 << 3 }

enum TimeFormats {
	MINUTES_SECONDS = BasicTimeFormat.MINUTES | BasicTimeFormat.SECONDS,
	HOURS_MINUTES = BasicTimeFormat.HOURS | BasicTimeFormat.MINUTES,
	DEFAULT = BasicTimeFormat.HOURS | BasicTimeFormat.MINUTES | BasicTimeFormat.SECONDS,
	FULL_TIME = BasicTimeFormat.HOURS | BasicTimeFormat.MINUTES | BasicTimeFormat.SECONDS | BasicTimeFormat.MICRO_SECONDS
}


func float_to_time_format(
	_time: float,
	_dynamic_time: bool = false,
	_second_text: bool = false,
	_time_format: int = TimeFormats.DEFAULT,
	_digit_format: String = "%02d",
	_seperator: String = ":"
) -> String:
	var _time_member: Array = []
	if _time_format & BasicTimeFormat.HOURS:
		var _digit = _digit_format % int(_time / 3600)
		_time_member.append(_digit)
	if _time_format & BasicTimeFormat.MINUTES:
		var _digit = _digit_format % ((int(_time) % 3600) / 60)
		_time_member.append(_digit)
	if _time_format & BasicTimeFormat.SECONDS:
		var _digit = _digit_format % (int(_time) % 60)
		_time_member.append(_digit)
	if _time_format & BasicTimeFormat.MICRO_SECONDS:
		var _digit = _digit_format % (stepify(fmod(_time, 1), 0.01) * 100.0)
		_time_member.append(_digit)

	var _converted_time: String = ""
	for _time_digit in _time_member:
		if _dynamic_time and int(_time_digit) <= 0:
			continue
		_converted_time += _time_digit + " " + _seperator + " "
		_dynamic_time = false

	_converted_time = (
		_converted_time.rstrip(" " + _seperator + " ")
		if !_converted_time.empty()
		else _converted_time
	)

	if _second_text and _time <= 60.0 and !_converted_time.empty():
		_converted_time += "s"

	return _converted_time


func load_resource(
	_resource_path: String, key_word1: String, key_word2: String
) -> Resource:
	if not (GameResourcesLibrary.ResouceLibrary.has(key_word1)):
		GameResourcesLibrary.ResouceLibrary[key_word1] = {}
	
	if not GameResourcesLibrary.ResouceLibrary[key_word1].has(key_word2):
		if not ResourceLoader.exists(_resource_path):
			return null
		GameResourcesLibrary.ResouceLibrary[key_word1][key_word2] = load(_resource_path)
		GameResourcesLibrary.ResouceLibrary[key_word1][key_word2].set_name(key_word2)

	return GameResourcesLibrary.ResouceLibrary[key_word1][key_word2]


func activate_timer(_timer: Timer, _time_amount: int, _force: bool = false):
	if _timer == null or (not _force and not _timer.is_stopped()):
		return
	_timer.start(_time_amount)


func deactivate_timer(_timer: Timer):
	if _timer == null or _timer.is_stopped():
		return

	_timer.stop()


func tiles_next_to_each_other(_map_position_1: Vector2, _map_position_2: Vector2):
	return (
		_map_position_1 != _map_position_2
		and abs(_map_position_1.x - _map_position_2.x) <= 1
		and abs(_map_position_1.y - _map_position_2.y) <= 1
	)


func facing_vector(_current_direction: int, is_left: bool) -> Vector2:
	if _current_direction == Constants.Direction.UP:
		return Constants.DisplacementMap[2]
	elif _current_direction == Constants.Direction.UP_SIDE:
		return Constants.DisplacementMap[1] if is_left else Constants.DisplacementMap[5]
	elif _current_direction == Constants.Direction.SIDE:
		return Constants.DisplacementMap[0] if is_left else Constants.DisplacementMap[8]
	elif _current_direction == Constants.Direction.DOWN_SIDE:
		return Constants.DisplacementMap[3] if is_left else Constants.DisplacementMap[7]
	else:
		return Constants.DisplacementMap[6]


func out_of_range(_position: Vector2, _range_center_position: Vector2, _range: Vector2) -> bool:
	var _distance: Vector2 = _position - _range_center_position
	return abs(_distance.x) > _range.x or abs(_distance.y) > _range.y


func random_with_chance_from_dictionary_list(_dict_list: Array, _total_weight: int = 0) -> String:
	return Constants.random_event_with_chance.random_with_chance_from_dictionary_list(
		_dict_list, _total_weight
	)


func random_with_chance_from_dictionary(_dict: Dictionary, _total_weight: int = 0) -> String:
	return random_with_chance_from_dictionary_list([_dict], _total_weight)


func calculate_total_weight_from_dictionary_list(_dict_list: Array) -> int:
	return Constants.random_event_with_chance.calculate_total_weight_from_dictionary_list(
		_dict_list
	)


func calculate_total_weight_from_dictionary(_dict: Dictionary) -> int:
	return calculate_total_weight_from_dictionary_list([_dict])


func pick_random_sound_from_collection(
	_collection_path: String,
	_collection_name: String,
	_random_number_max: int,
	_random_number_min: int = 1
) -> Resource:
	var _random: int = pick_random_from_collection_path(_random_number_max, _random_number_min)
	return Utils.load_resource(
		_collection_path % _random, _collection_name + "s", _collection_name + "_" + String(_random)
	)


func pick_random_from_collection_path(_random_number_max: int, _random_number_min: int = 1) -> int:
	return Utils.random_int(_random_number_min, _random_number_max)


func play_animation(
	_animation_player: AnimationPlayer,
	_animation_name: String,
	_speed: float = 1.0,
	_blend: float = -1.0
):
	if not _animation_player.has_animation(_animation_name):
		return
	_animation_player.stop()
	_animation_player.play(_animation_name, _blend, _speed)


func flip_vector2(_vector2: Vector2) -> Vector2:
	return Vector2(_vector2.y, _vector2.x)


func get_node_origin_from_current_cursor_if_inside_area2d(map_manager):
	# get the Physics2DDirectSpaceState object
	var space = map_manager.get_world_2d().direct_space_state
	# Get the mouse's position
	var mousePos = map_manager.get_global_mouse_position()
	# Check if there is a collision at the mouse position
	var return_value = space.intersect_point(mousePos, 1, [], 1, true, true)
	var colliding_bodies = []
	for dictionary in return_value:
		if typeof(dictionary.collider) == TYPE_OBJECT:
			colliding_bodies.push_back(dictionary.collider)
			var node = dictionary.collider.get_parent().get_parent()
			if "origin" in node:
				return node.origin


func is_able_to_checking_cursor() -> bool:
	var character = get_current_character()
	return (
		character != null
		and	not GameManager.build_manager.holding_object
		and not character.ui_manager.inventory.is_enable_inventory()
		and not character.ui_manager.is_enable_group_build()
		and not character.ui_manager.is_enable_group_farming()
		and not character.ui_manager.is_enable_group_stats()
	)


func moving_click_is_valid():
	var character = get_current_character()
	return (
		character != null
		and	not character.map_manager.is_click_outside_map_bounds() 
		and not GameManager.build_manager.holding_object
		and not character.ui_manager.inventory.is_enable_inventory()
		and not character.ui_manager.is_enable_group_build()
		and not character.ui_manager.is_enable_group_farming()
		and not character.ui_manager.is_enable_group_stats()
	)


func is_able_to_remove_click():
	var character = get_current_character()
	return (
		character != null
		and not GameManager.build_manager.holding_object
		and not character.ui_manager.inventory.is_enable_inventory()
		and not character.ui_manager.is_enable_group_build()
		and not character.ui_manager.is_enable_group_farming()
		and not character.ui_manager.is_enable_group_stats()
	)


func obj_click_is_valid():
	var character = get_current_character()
	return (
		character != null
		and not GameManager.build_manager.holding_object
		and not character.ui_manager.inventory.is_enable_inventory()
		and not character.ui_manager.is_enable_group_build()
		and not character.ui_manager.is_enable_group_farming()
		and not character.ui_manager.is_enable_group_stats()
	)


func get_current_daytime() -> int:
	if not GameManager.daytime_manager:
		return Constants.DayTime.DAY
	
	return GameManager.daytime_manager.current_daytime


func target_is_enemy(host: FighterActor, tg: FighterActor) -> bool:
	return tg != null and tg != host and String(tg.faction) != String(host.faction)


func target_in_area(host_angle: int, host_facing_left: bool, host_pos: Vector2, tg_pos: Vector2, arc: int, radius: float = 0.0) -> bool:
	if host_facing_left:
		host_angle = -180 - host_angle
	var to_tg_dir: Vector2 = host_pos.direction_to(tg_pos)
	var to_tg_angle: int = rad2deg(to_tg_dir.angle())
	
	var host_tg_angle: int = int(to_tg_angle - host_angle) % 360
	if host_tg_angle < -180:
		host_tg_angle += 360
	elif host_tg_angle > 180:
		host_tg_angle -= 360
	host_tg_angle = abs(host_tg_angle)
	
	var in_area_arc: bool = host_tg_angle <= arc/2
	var in_area_radius: bool = (tg_pos - host_pos).length() <= radius if radius != 0.0 else true
	return in_area_arc and in_area_radius


# Return 2 vector parallel with tilemap edges, 1 left, 1 right cal from input vector, get left vector and right vector with key "r_l", "r_r"
func get_slide_velocity_vectors(current_v: Vector2) -> Dictionary:
	var dir2Vec: Dictionary = {
		"up_l": -150,
		"up_r": -30,
		"down_r": 30,
		"down_l": 150 
	}

	var slide_vectors: Dictionary = {}
	var c_angle: float = rad2deg(current_v.angle())
	if c_angle >= dir2Vec.up_r and c_angle <= dir2Vec.down_r:
		slide_vectors = get_slide_vectors(current_v, dir2Vec.up_r, dir2Vec.down_r, c_angle)
	elif c_angle >= dir2Vec.up_l and c_angle <= dir2Vec.up_r:
		slide_vectors = get_slide_vectors(current_v, dir2Vec.up_l, dir2Vec.up_r, c_angle)
	elif c_angle >= dir2Vec.down_r and c_angle <= dir2Vec.down_l:
		slide_vectors = get_slide_vectors(current_v, dir2Vec.down_r, dir2Vec.down_l, c_angle)
	else:
		slide_vectors = get_slide_vectors(current_v, dir2Vec.down_l, dir2Vec.up_l, c_angle)
	
	return slide_vectors


func get_slide_vectors(v: Vector2, l_angle: float, r_angle: float, c_angle: float = 999999999) -> Dictionary:
	var r_l_l: Vector2 = rotate_vector_to_deg(v, l_angle - 3, c_angle)
	var r_l_r: Vector2 = rotate_vector_to_deg(v, l_angle + 3, c_angle)
	var r_r_r: Vector2 = rotate_vector_to_deg(v, r_angle + 3, c_angle)
	var r_r_l: Vector2 = rotate_vector_to_deg(v, r_angle - 3, c_angle)
	return {
		"r_l_l": r_l_l,
		"r_l_r": r_l_r,
		"r_r_r": r_r_r,
		"r_r_l": r_r_l,
	}


func get_nearest_obj(objs: Array, from_pos: Vector2):
	var nearest_distance: float = Constants.A_VERY_LARGE_NUMBER
	var nearest_obj = null
	
	for tg in objs:
		var dt: float = from_pos.distance_to(tg.global_position)
		if dt < nearest_distance:
			nearest_obj = tg
			nearest_distance = dt
	
	return nearest_obj
