extends Node

class_name SaveLoadManager

var game_manager
var map_manager

var decorations_path = "res://map/scenes/decorations/%s.tscn"
var resources_path = "res://map/scenes/resources/%s.tscn"

var build_data_temp = {}
var build_data_temp_1st = {}
var build_data_temp_2nd = {}

var save_models: SaveModels
var character_save: CharacterSave


func _init(_game_manager, _map_manager):
	game_manager = _game_manager
	map_manager = _map_manager
	save_models = SaveModels.new()
	character_save = CharacterSave.new(self)


# region build
func append_build_data(
	_building_type,
	_object_type,
	_scene_name,
	_sprite_name,
	_scale,
	_build_position,
	_origin,
	_is_append
):
	var build_data_format = {
		"scene_name": "",
		"sprite_name": "",
		"scale": "",
		"build_position": "",
		"origin": "",
		"building_type": "",
		"object_type": "",
		"is_append": ""
	}

	build_data_format.building_type = _building_type
	build_data_format.object_type = _object_type
	build_data_format.scene_name = _scene_name
	build_data_format.sprite_name = _sprite_name
	build_data_format.scale = _scale
	build_data_format.build_position = _build_position
	build_data_format.origin = _origin
	build_data_format.is_append = _is_append

	classify_build_data_temp(build_data_format)


func classify_build_data_temp(_build_data_format):
	if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
		append_build_data_temp(build_data_temp, _build_data_format)
	elif (
		map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				append_build_data_temp(build_data_temp, _build_data_format)
			Constants.FloorType.FIRST_FLOOR:
				append_build_data_temp(build_data_temp_1st, _build_data_format)
			Constants.FloorType.SECOND_FLOOR:
				append_build_data_temp(build_data_temp_2nd, _build_data_format)


func assign_build_data_temp(_build_data):
	if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
		build_data_temp = _build_data
	elif (
		map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				build_data_temp = _build_data
			Constants.FloorType.FIRST_FLOOR:
				build_data_temp_1st = _build_data
			Constants.FloorType.SECOND_FLOOR:
				build_data_temp_2nd = _build_data


func append_build_data_temp(_build_data_temp, _build_data_format):
	if _build_data_temp.size() > 0:
		var keys = []
		for i in _build_data_temp:
			var key = int(i)
			keys.append(key)

		var max_key = keys.max()
		var append_key = max_key + 1
		_build_data_temp[append_key] = _build_data_format
	else:
		_build_data_temp[0] = _build_data_format


func save_build_data():
	if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
		JsonData.save_data(JsonData.map_build_data_path, build_data_temp)
	elif map_manager.map_type == Constants.MapSceneType.BASE_MAP:
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				JsonData.save_data(JsonData.house_build_data_ground_floor_path, build_data_temp)
			Constants.FloorType.FIRST_FLOOR:
				JsonData.save_data(JsonData.house_build_data_1st_floor_path, build_data_temp_1st)
			Constants.FloorType.SECOND_FLOOR:
				JsonData.save_data(JsonData.house_build_data_2nd_floor_path, build_data_temp_2nd)
	elif map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP:
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				JsonData.save_data(
					JsonData.house_upgrade_build_data_ground_floor_path, build_data_temp
				)
			Constants.FloorType.FIRST_FLOOR:
				JsonData.save_data(
					JsonData.house_upgrade_build_data_1st_floor_path, build_data_temp_1st
				)
			Constants.FloorType.SECOND_FLOOR:
				JsonData.save_data(
					JsonData.house_upgrade_build_data_2nd_floor_path, build_data_temp_2nd
				)


func load_build_data():
	var build_data
	if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
		build_data = JsonData.map_build_data
		build_data = JsonData.load_data(JsonData.map_build_data_path)
	elif map_manager.map_type == Constants.MapSceneType.BASE_MAP:
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				build_data = JsonData.house_build_data_ground_floor
				build_data = JsonData.load_data(JsonData.house_build_data_ground_floor_path)
			Constants.FloorType.FIRST_FLOOR:
				build_data = JsonData.house_build_data_1st_floor
				build_data = JsonData.load_data(JsonData.house_build_data_1st_floor_path)
			Constants.FloorType.SECOND_FLOOR:
				build_data = JsonData.house_build_data_2nd_floor
				build_data = JsonData.load_data(JsonData.house_build_data_2nd_floor_path)
	elif map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP:
		match map_manager.cur_floor:
			Constants.FloorType.GROUND_FLOOR:
				build_data = JsonData.house_upgrade_build_data_ground_floor
				build_data = JsonData.load_data(JsonData.house_upgrade_build_data_ground_floor_path)
			Constants.FloorType.FIRST_FLOOR:
				build_data = JsonData.house_upgrade_build_data_1st_floor
				build_data = JsonData.load_data(JsonData.house_upgrade_build_data_1st_floor_path)
			Constants.FloorType.SECOND_FLOOR:
				build_data = JsonData.house_upgrade_build_data_2nd_floor
				build_data = JsonData.load_data(JsonData.house_upgrade_build_data_2nd_floor_path)
	return build_data


func load_object_from_data():
	# load json data
	var build_data = load_build_data()
	var map_info = Utils.get_current_map_info(map_manager)

	# assign data
	for i in build_data:
		var key = String(i)
		if build_data.has(key):
			#optimize suggest: create var ... = build_data.get(key)
			#2: change load -> Utils.load_resource(PATH, "obj_name", "resource_name / type")
			var build_object
			var build_object_data = build_data.get(key)
			var building_type = int(build_object_data.get("building_type"))
			var object_type = int(build_object_data.get("object_type"))
			var scene_name = build_object_data.get("scene_name")
			var sprite_name = build_object_data.get("sprite_name")
			var scale = Vector2(Utils.string_to_vector2(build_object_data.get("scale")))
			var build_position = Vector2(
				Utils.string_to_vector2(build_object_data.get("build_position"))
			)
			var origin = Vector2(Utils.string_to_vector2(build_object_data.get("origin")))
			var is_append = build_object_data.get("is_append")
			if building_type == Constants.BuildingType.RESOURCE:
				build_object = Utils.load_resource(resources_path % scene_name, "resource", scene_name).instance()
			else:
				build_object = Utils.load_resource(decorations_path % scene_name, "decoration", scene_name).instance()

			# spawn object => add to scene
			spawn_build_object(build_object, sprite_name, scale, build_position)

			# append build object to map_info
			append_build_object_info(
				building_type, object_type, build_object, origin, is_append, map_info
			)
			build_object.created(false)

			if building_type == Constants.BuildingType.ABOVE_DECORATION:
				map_manager.ysort.nogias_insert(
					build_object, true, map_manager.get_cur_floor_objs()
				)
			else:
				map_manager.ysort.nogias_insert(build_object)
				build_object.update_sort_position()


func spawn_build_object(build_object, sprite_name, scale, build_position):
	# add to current scene
	if "is_building" in build_object:
		build_object.is_building = true
	map_manager.ysort.add_child(build_object)
	build_object.position = build_position

	# floor's objects vfx
	if (
		map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		map_manager.append_floor_object(build_object)

	# ex: this "reload" is use for scene that having many objects inside => ex: Scene: House => small_house, farm_house, green_house,...
	if "is_reload" in build_object:
		build_object.is_reload = true
		build_object.re_load(sprite_name, false)

	rotate_object(build_object, scale)


func is_object_rotated(scale):
	return scale.x == -1


func is_object_imbalance(build_object):
	return build_object.size.x != build_object.size.y


func rotate_object(build_object, scale):
	# object already rotate
	if is_object_rotated(scale):
		# object is imbalance
		if is_object_imbalance(build_object):
			build_object.size = Vector2(build_object.size.y, build_object.size.x)

	build_object.scale = scale
	if build_object.has_method("rotate_button_remove"):
		build_object.rotate_button_remove(false)


func append_build_object_info(
	building_type, object_type, build_object, origin, is_append, map_info
):
	# append object data [][]
	match building_type:
		Constants.BuildingType.RESOURCE:
			map_info.append_resource(build_object, object_type, origin)
		Constants.BuildingType.DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.DECORATION, is_append
			)
		Constants.BuildingType.WALKABLE_DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.WALKABLE_DECORATION, is_append
			)
		Constants.BuildingType.BUILDABLE_DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.BUILDABLE_DECORATION, is_append
			)
		Constants.BuildingType.ABOVE_DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.ABOVE_DECORATION, is_append
			)
		Constants.BuildingType.BELOW_DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.BELOW_DECORATION, is_append
			)
		Constants.BuildingType.TALL_DECORATION:
			map_info.append_decoration(
				build_object, origin, Constants.MapInfoType.TALL_DECORATION, is_append
			)
		Constants.BuildingType.WALL_DECORATION:
			var wall_decor_index = map_info.get_final_tile_index() + 1
			map_info.insert_decoration(
				build_object,
				origin,
				Constants.MapInfoType.WALL_DECORATION,
				is_append,
				wall_decor_index
			)
	map_manager.map_navigator._add_build_disabled_points(build_object.size, origin)


func save_remove_above_objects(remove_origin):
	var build_data = load_build_data()
	for key in build_data:
		var values = build_data[key]
		var origin_temp = values["origin"]
		var origin = Vector2(Utils.string_to_vector2(origin_temp))
		var scene_name = values["scene_name"]
		if (
			origin == remove_origin
			and (scene_name == "Book" or scene_name == "Food" or scene_name == "Chess")
		):
			build_data.erase(key)
			assign_build_data_temp(build_data)
			save_build_data()
			break


func save_remove_object(remove_origin, remove_scene_name):
	var build_data = load_build_data()
	for key in build_data:
		var values = build_data[key]
		var origin_temp = values["origin"]
		var origin = Vector2(Utils.string_to_vector2(origin_temp))
		var scene_name = values["scene_name"]
		if origin == remove_origin and scene_name == remove_scene_name:
			build_data.erase(key)
			assign_build_data_temp(build_data)
			save_build_data()
			break


#endregion


# region character spawn
func save_spawn_data():
	var character = Utils.get_current_character()
	if not Utils.node_exists(character):
		return
	var spawn_data_format = {"spawn_position": ""}
	spawn_data_format.spawn_position = character.global_position
	var spawn_data_temp = spawn_data_format
	JsonData.save_data(JsonData.character_spawn_data_path, spawn_data_temp)


func load_spawn_data():
	var spawn_data = JsonData.character_spawn_data
	spawn_data = JsonData.load_data(JsonData.character_spawn_data_path)

	if spawn_data.has("spawn_position"):
		return Utils.string_to_vector2(spawn_data["spawn_position"])
	else:
		return Vector2.ZERO


#endregion


# region daytime
func save_daytime_data():
	var daytime_data_format = {"current_daytime": ""}
	daytime_data_format.current_daytime = GameManager.daytime_manager.current_daytime
	var daytime_data_temp = daytime_data_format
	JsonData.save_data(JsonData.map_daytime_data_path, daytime_data_temp)


func load_daytime_data():
	var daytime_data = JsonData.map_daytime_data
	daytime_data = JsonData.load_data(JsonData.map_daytime_data_path)

	if daytime_data.has("current_daytime"):
		GameManager.daytime_manager.current_daytime = int(daytime_data["current_daytime"])
	else:
		GameManager.daytime_manager.current_daytime = Constants.DayTime.DAY


func save_current_timing(current_time):
	var current_timing_data_format = {"current_timing": ""}
	current_timing_data_format.current_timing = current_time
	var current_timing_data_temp = current_timing_data_format
	JsonData.save_data(JsonData.current_timing_data_path, current_timing_data_temp)


func load_current_timing():
	var current_timing_data = JsonData.current_timing_data
	current_timing_data = JsonData.load_data(JsonData.current_timing_data_path)

	if current_timing_data.has("current_timing"):
		GameManager.daytime_manager.time = float(current_timing_data["current_timing"])
	else:
		GameManager.daytime_manager.time = GameManager.daytime_manager.day_delta_time


#endregion


#region multiple lands
func save_multiple_lands(new_map_position):
	var multiple_lands_data_temp = JsonData.load_data(JsonData.multiple_lands_data_path)
	if multiple_lands_data_temp.size() > 0:
		var keys = []
		for i in multiple_lands_data_temp:
			var key = int(i)
			keys.append(key)

		var max_key = keys.max()
		var append_key = max_key + 1
		multiple_lands_data_temp[append_key] = new_map_position
	else:
		multiple_lands_data_temp[0] = new_map_position
	JsonData.save_data(JsonData.multiple_lands_data_path, multiple_lands_data_temp)


func load_multiple_lands():
	var multiple_lands_data = JsonData.load_data(JsonData.multiple_lands_data_path)
	for i in multiple_lands_data:
		var key = String(i)
		var map_position = Vector2(Utils.string_to_vector2(multiple_lands_data.get(key)))
		if not map_manager.list_map_positions.has(map_position):
			map_manager.list_map_positions.append(map_position)


#endregion


#region first time open
func save_first_time_open():
	var first_time_open_data = {"first_time_open": ""}
	first_time_open_data.first_time_open = true
	JsonData.save_data(JsonData.first_time_open_data_path, first_time_open_data)


func load_first_time_open():
	var first_time_open_data = JsonData.first_time_open_data
	first_time_open_data = JsonData.load_data(JsonData.first_time_open_data_path)

	if first_time_open_data.has("first_time_open"):
		return first_time_open_data["first_time_open"]
	else:
		return false


func is_first_time_open():
	return not load_first_time_open()


func check_first_time_open():
	if is_first_time_open():
		save_first_time_open()


#endregion


#region remove object mode
var remove_object_mode: bool = false
var removing_object = null
var removing_object_material = null
var removing_object_z_index: int = 0
var current_camera: Camera2D = null
var finding_index: int = 0
var min_index: int = 0
var max_index: int = 0


func input_remove_object_mode():
	if (
		not GameManager.build_manager.holding_object
		and not Utils.get_current_character().ui_manager.is_group_build_farming_visible()
		and not Utils.get_current_character().ui_manager.is_open_map
		and not Utils.get_current_character().ui_manager.inventory.visible
		and not Utils.get_current_character().ui_manager.crafting.visible
		and not Utils.get_current_character().ui_manager.reforge_tab.visible
		and not Utils.get_current_character().ui_manager.cooking_tab.visible
	):
		if Input.is_action_just_pressed("remove_object_mode"):
			var character = Utils.get_current_character()
			if not remove_object_mode:
				character.ui_manager.show_group_remove_custom()
				character.ui_manager.visible_hud(false)
				find_object_to_remove(false)
			else:
				character.ui_manager.hide_group_remove_custom()
				character.ui_manager.visible_hud(true)
				reset_remove_object_mode(true)
		elif Input.is_action_just_pressed("ui_cancel") and remove_object_mode:
			var character = Utils.get_current_character()
			character.ui_manager.visible_hud(true)
			character.ui_manager.hide_group_remove_custom()
			reset_remove_object_mode(true)
		elif (
			(Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_left"))
			and remove_object_mode
		):
			find_prev_removing_object()
		elif (
			(Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_right"))
			and remove_object_mode
		):
			find_next_removing_object(false)
		elif Input.is_action_just_pressed("remove_object") and remove_object_mode:
			Utils.get_current_character().ui_manager.on_click_button_remove_general(removing_object)

			var build_data = load_build_data()
			var data_key = build_data.keys()
			if data_key.size() > 0:
				change_camera_from_holding_object_to_map()
				find_next_removing_object(true)
			else:
				var character = Utils.get_current_character()
				character.ui_manager.hide_group_remove_custom()
				character.ui_manager.visible_hud(true)
				reset_remove_object_mode(true)


func change_camera_from_player_to_removing_object():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var character = Utils.get_current_character()

	current_camera = character.camera
	current_camera.current = false
	character.remove_child(current_camera)
	removing_object.add_child(current_camera)
	current_camera.current = true
	current_camera.zoom = Vector2(.6, .6)


func change_camera_from_holding_object_to_map():
	removing_object.remove_child(current_camera)
	map_manager.add_child(current_camera)


func change_camera_from_removing_object_to_player(is_cancel):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var character = Utils.get_current_character()

	current_camera.current = false
	if is_cancel:
		removing_object.remove_child(current_camera)
	else:
		map_manager.remove_child(current_camera)
	character.add_child(current_camera)
	current_camera.current = true
	current_camera.zoom = Vector2(.5, .5)


func change_camera_from_map_to_removing_object():
	var character = Utils.get_current_character()

	current_camera = character.camera
	current_camera.current = false
	map_manager.remove_child(current_camera)
	removing_object.add_child(current_camera)
	current_camera.current = true
	current_camera.zoom = Vector2(.6, .6)


func change_camera_from_removing_object_to_next(is_removed):
	if not is_removed:
		removing_object.remove_child(current_camera)
		map_manager.add_child(current_camera)

	find_object_to_remove(true)


func find_object_to_remove(is_next: bool):
	var build_data = load_build_data()
	var data_key: String = ""
	var data_scene_name: String = ""
	var data_global_position: Vector2 = Vector2.ZERO

	if build_data != null and build_data.keys().size() > 0:
		remove_object_mode = true
		data_key = build_data.keys()[finding_index]
		data_scene_name = build_data[data_key]["scene_name"]
		data_global_position = Utils.string_to_vector2(build_data[data_key]["build_position"])

		var map_manager_ysort = GameManager.map_manager.ysort
		for i in map_manager_ysort.get_children():
			var scene_name = Utils.get_scene_name_from_node(i.name)
			var global_position = i.global_position

			if scene_name == data_scene_name and global_position == data_global_position:
				removing_object = i
				removing_object_z_index = removing_object.z_index
				removing_object.z_index = 20

		if not is_next:
			change_camera_from_player_to_removing_object()
		else:
			change_camera_from_map_to_removing_object()

		GameManager.map_manager.check_remove_item(
			data_global_position, data_scene_name, removing_object
		)


func find_next_removing_object(is_removed: bool):
	min_index = 0
	max_index = get_max_index()

	if removing_object != null: removing_object.z_index = removing_object_z_index

	if finding_index < max_index - 1:
		finding_index += 1
	else:
		finding_index = min_index

	change_camera_from_removing_object_to_next(is_removed)


func find_prev_removing_object():
	min_index = 0
	max_index = get_max_index()

	if removing_object != null: removing_object.z_index = removing_object_z_index

	if finding_index > min_index:
		finding_index -= 1
	else:
		finding_index = (max_index - 1)

	change_camera_from_removing_object_to_next(false)


func get_max_index():
	return load_build_data().keys().size()


func reset_remove_object_mode(done: bool):
	remove_object_mode = false
	finding_index = 0

	if removing_object != null: removing_object.z_index = removing_object_z_index

	if done:
		change_camera_from_removing_object_to_player(true)
	else:
		GameManager.map_manager.visible_removable_object_outline(removing_object, false)
	GameManager.map_manager.check_disable_remove_item_choosing()

#endregion
