extends Navigation2D

class_name BaseUpgradeManager

export(int) var map_width = 10
export(int) var map_height = 10
export(int) var noise_seed = 0
export var is_battlefield: bool
export(int) var map_type = Constants.MapSceneType.BASE_UPGRADE_MAP

onready var water_tile = TileManager.new($WaterTileMap, TileDescriptions.water)
onready var earth_tile = TileManager.new(
	$EarthTileMap, TileDescriptions.earth, water_tile, Vector2(0.3, 1), TileDescriptions.earth_water
)
onready var floor_tile = TileManager.new($Floor/FloorTileMap, TileDescriptions.floors)
onready var wall_tile = TileManager.new($Floor/WallTileMap, TileDescriptions.wall, floor_tile)
onready var floor_1_tile = TileManager.new($Floor_1/Floor_1_TileMap, TileDescriptions.floors)
onready var wall_1_tile = TileManager.new($Floor_1/Wall_1_TileMap, TileDescriptions.wall, floor_tile)
onready var floor_2_tile = TileManager.new($Floor_2/Floor_2_TileMap, TileDescriptions.floors)
onready var wall_2_tile = TileManager.new($Floor_2/Wall_2_TileMap, TileDescriptions.wall, floor_tile)

onready var group_floor = $Floor
onready var group_floor_1 = $Floor_1
onready var group_floor_2 = $Floor_2

onready var floor_tween = $FloorTween

onready var grid_build = $GridBuild
onready var tile_highlight = $TileHightlight

onready var ysort = $YSort

var cell_size = Vector2(46, 24)
var base_upgrade_generator
var map_navigator: MapNavigatorManager
var map_info: MapInfo
var map_info_1st: MapInfo
var map_info_2nd: MapInfo
var show_ui_delay = 3
var player_ready: bool = false

var cur_floor
var is_floor_changable = true
var can_go_up_down_stairs = false
var is_changing_floor = false
var is_already_go_1st_floor = false
var is_already_go_2nd_floor = false
var objects_ground_floor = []
var objects_1st_floor = []
var objects_2nd_floor = []

var floor_height = 72
var floor_tween_duration = .25
var group_floor_pos
var group_floor_1_pos
var final_pos = Vector2.ZERO
var final_pos_1 = Vector2.ZERO
var darker_color = Color(.3, .3, .3, 1)
var fade_in_color = Color(1, 1, 1, 1)
var fade_out_color = Color(1, 1, 1, 0)

var environment_type: int = Constants.EnvironmentType.IN_HOUSE

export(int)var size: int = 12
export(Array, Vector2)var list_map_positions = [Vector2(0, 0)]
var max_size: int = size * 3
var map_position: Vector2 = Vector2(0, 0)
var xrange: Vector2
var yrange: Vector2

func _ready():
	# logic
	max_size = size * 3
	xrange = Vector2(map_position.x * size, map_position.x * size + size)
	yrange = Vector2(map_position.y * size, map_position.y * size + size)
	
	GameManager.set_map_manager(self)
	cur_floor = Constants.FloorType.GROUND_FLOOR
	map_info = MapInfo.new(self, map_type, max_size, size, map_position)
	map_info_1st = MapInfo.new(self, map_type, max_size, size, map_position)
	map_info_2nd = MapInfo.new(self, map_type, max_size, size, map_position)
	base_upgrade_generator = BaseUpgradeGenerator.new(self, noise_seed, max_size, size, map_position, xrange, yrange)
	base_upgrade_generator.generate_terrain()
	map_navigator = MapNavigatorManager.new(self, max_size, size, map_position)
	base_upgrade_generator.generate_objects()
	
	GameManager.save_load_manager.load_current_timing()
	GameManager.audio_manager.play_music(self)
	GameManager.scene_manager.open_scene(GameManager.scene_manager.base_upgrade_title)
	GameManager.scene_manager.spawn_blocking_input(self)
	SignalManager.connect("character_arrived", self, "_on_character_arrived")
	SignalManager.connect("player_ready", self, "_on_player_ready")
	
	if not is_battlefield: spawn_character_from_save_file()
	show_private_ui()


func _process(_delta: float) -> void:
	if GameManager.daytime_manager != null and not is_battlefield:
		GameManager.daytime_manager.set_current_timing(_delta)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if not is_click_outside_map_bounds():
			var point = $EarthTileMap.map_to_world(
				$EarthTileMap.world_to_map(get_global_mouse_position())
			)
			tile_highlight.global_position = Vector2(point.x, point.y + cell_size.y)
			tile_highlight.visible = true
			Utils.start_tween($Tween, tile_highlight, "modulate", Color("00ffffff"), Color("ffffffff"), 0.5)
	if event.is_action_pressed("go_up_stairs") and can_go_up_down_stairs and not is_changing_floor and cur_floor < 2:
		var character = Utils.get_current_character()
		go_up_down(character, true)
	if event.is_action_pressed("go_down_stairs") and can_go_up_down_stairs and not is_changing_floor and cur_floor >= 1:
		var character = Utils.get_current_character()
		go_up_down(character, false)


func _input(event):
	if event is InputEventKey and event.pressed:
		GameManager.build_manager.change_build_move_type()
		GameManager.build_manager.move_object_by_key()
		GameManager.build_manager.build_object_by_key()
		GameManager.save_load_manager.input_remove_object_mode()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		GameManager.save_load_manager.character_save.character_save(Utils.get_current_character())
		GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)


func _on_player_ready():
	player_ready = true
	GameManager.daytime_manager.run_timer()


func _on_character_arrived(_host_name):
	if _host_name == "Character":
		tile_highlight.visible = false
	

func is_click_outside_map_bounds() -> bool:
	var local_point = $EarthTileMap.world_to_map(get_global_mouse_position())
	if Utils.is_outside_of_map(list_map_positions, size, local_point):
		return true
	else:
		return false

		
func show_private_ui():
	yield(Utils.start_coroutine(show_ui_delay), "completed")
	var character = Utils.get_current_character()
	var ui_manager = character.get_node_or_null("ui")
	ui_manager.visible_button_farm(true)
	ui_manager.visible_buttons_in_private_scene()


# region: floors
func append_floor_object(object):
	match cur_floor:
		Constants.FloorType.GROUND_FLOOR: objects_ground_floor.append(object)
		Constants.FloorType.FIRST_FLOOR: objects_1st_floor.append(object)
		Constants.FloorType.SECOND_FLOOR: objects_2nd_floor.append(object)


func get_cur_floor_objs() -> Array:
	match cur_floor:
		Constants.FloorType.GROUND_FLOOR:
			return objects_ground_floor
		Constants.FloorType.FIRST_FLOOR: 
			return objects_1st_floor
		Constants.FloorType.SECOND_FLOOR: 
			return objects_2nd_floor
	return []


func pop_floor_object(object):
	match cur_floor:
		Constants.FloorType.GROUND_FLOOR: objects_ground_floor.erase(object)
		Constants.FloorType.FIRST_FLOOR: objects_1st_floor.erase(object)
		Constants.FloorType.SECOND_FLOOR: objects_2nd_floor.erase(object)


func show_go_up_down_ui():
	var character = Utils.get_current_character()
	if is_near_by_stairs():
		can_go_up_down_stairs = true
		character.ui_manager.visible_group_stairs(true)
		if cur_floor == Constants.FloorType.GROUND_FLOOR:
			character.ui_manager.group_stairs.get_child(1).visible = false
		elif cur_floor == Constants.FloorType.SECOND_FLOOR:
			character.ui_manager.group_stairs.get_child(0).visible = false
		else:
			character.ui_manager.group_stairs.get_child(0).visible = true
			character.ui_manager.group_stairs.get_child(1).visible = true
	else:
		can_go_up_down_stairs = false
		character.ui_manager.visible_group_stairs(false)


func is_near_by_stairs():
	var local_point = $EarthTileMap.world_to_map(Utils.get_current_character().position)
	return ((local_point.x == 0 and (local_point.y == xrange.y - 1 or local_point.y == xrange.y - 2))
			or (local_point.x == 1 and (local_point.y == xrange.y - 1 or local_point.y == xrange.y - 2))) 


func go_up_down(character, is_up):
	var total_floor_change_duration = 1
	if is_floor_changable:
		go_up_down_step_1(character)
		yield(Utils.start_coroutine(0.5), "completed")
		go_up_down_step_2(is_up)
		yield(Utils.start_coroutine(total_floor_change_duration), "completed")
		go_up_down_step_3(character)


func go_up_down_step_1(character):
	# logic
	is_changing_floor = true
	is_floor_changable = false

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

	# vfx
	go_up_down_character_vfx(character, true)
	character.ui_manager.visible_group_stairs(false)
	character.ui_manager.visible_button_farm(false)
	character.play_animation("run")
	character.camera.current = false
	GameManager.scene_manager.visible_background(true)


func go_up_down_step_2(is_up):
	# go up
	if is_up:
		if cur_floor == Constants.FloorType.GROUND_FLOOR:
			# logic
			cur_floor = Constants.FloorType.FIRST_FLOOR
			if not is_already_go_1st_floor:
				GameManager.save_load_manager.build_data_temp_1st = GameManager.save_load_manager.load_build_data()
				GameManager.save_load_manager.load_object_from_data()
				is_already_go_1st_floor = true
			# vfx
			floor_0_1_1_0_full_vfx(is_up)
		elif cur_floor == Constants.FloorType.FIRST_FLOOR:
			# logic
			cur_floor = Constants.FloorType.SECOND_FLOOR
			if not is_already_go_2nd_floor:
				GameManager.save_load_manager.build_data_temp_2nd = GameManager.save_load_manager.load_build_data()
				GameManager.save_load_manager.load_object_from_data()
				is_already_go_2nd_floor = true
			# vfx
			floor_1_2_2_1_full_vfx(is_up)
		elif cur_floor == Constants.FloorType.SECOND_FLOOR:
			return
	# go down
	else:
		if cur_floor == Constants.FloorType.GROUND_FLOOR:
			return
		elif cur_floor == Constants.FloorType.FIRST_FLOOR:
			# logic
			cur_floor = Constants.FloorType.GROUND_FLOOR
			GameManager.save_load_manager.build_data_temp = GameManager.save_load_manager.load_build_data()
			# vfx
			floor_0_1_1_0_full_vfx(is_up)
		elif cur_floor == Constants.FloorType.SECOND_FLOOR:
			# logic
			cur_floor = Constants.FloorType.FIRST_FLOOR
			GameManager.save_load_manager.build_data_temp_1st = GameManager.save_load_manager.load_build_data()
			# vfx
			floor_1_2_2_1_full_vfx(is_up)


func go_up_down_step_3(character):
	# logic
	is_floor_changable = true
	map_navigator._add_disabled_points()

	# vfx
	go_up_down_character_vfx(character, false)
	character.play_animation("run")
	
	yield(Utils.start_coroutine(0.6), "completed")
	is_changing_floor = false
	character.camera.current = true
	character.play_animation("idle")
	GameManager.scene_manager.visible_background(false)
	show_go_up_down_ui()
	character.ui_manager.visible_button_farm(true)


func floor_0_1_1_0_full_vfx(is_up):
	if is_up:
		group_floor_1.visible = true
		floor_0_1_1_0_private_vfx(true)
		floor_object_visible()
	else:
		floor_0_1_1_0_private_vfx(false)
		floor_object_visible()
		yield(floor_tween, "tween_completed")
		group_floor_1.visible = false


func floor_1_2_2_1_full_vfx(is_up):
	if is_up:
		group_floor_2.visible = true
		floor_object_visible()
		floor_1_2_2_1_private_vfx(is_up)
	else:
		floor_1_2_2_1_private_vfx(is_up)
		floor_object_visible()
		yield(floor_tween, "tween_completed")
		group_floor_2.visible = false
		

func floor_0_1_1_0_private_vfx(is_up):
	group_floor_pos = group_floor.position
	if is_up:
		final_pos = Vector2(group_floor_pos.x, group_floor_pos.y + floor_height)
		Utils.start_tween(floor_tween, group_floor, "modulate", fade_in_color, darker_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		Utils.start_tween(floor_tween, group_floor_1, "modulate", fade_out_color, fade_in_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	else:
		final_pos = Vector2(group_floor_pos.x, group_floor_pos.y - floor_height)
		Utils.start_tween(floor_tween, group_floor, "modulate", darker_color, fade_in_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		Utils.start_tween(floor_tween, group_floor_1, "modulate", fade_in_color, fade_out_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
	Utils.start_tween(floor_tween, group_floor, "position", group_floor_pos, final_pos, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func floor_1_2_2_1_private_vfx(is_up):
	group_floor_pos = group_floor.position
	group_floor_1_pos = group_floor_1.position
	if is_up:
		final_pos = Vector2(group_floor_pos.x, group_floor_pos.y + floor_height)
		final_pos_1 = Vector2(group_floor_1_pos.x, group_floor_1_pos.y + floor_height)
		Utils.start_tween(floor_tween, group_floor_1, "modulate", fade_in_color, darker_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		Utils.start_tween(floor_tween, group_floor_2, "modulate", fade_out_color, fade_in_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	else:
		final_pos = Vector2(group_floor_pos.x, group_floor_pos.y - floor_height)
		final_pos_1 = Vector2(group_floor_1_pos.x, group_floor_1_pos.y - floor_height)
		Utils.start_tween(floor_tween, group_floor_1, "modulate", darker_color, fade_in_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		Utils.start_tween(floor_tween, group_floor_2, "modulate", fade_in_color, fade_out_color, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)

	Utils.start_tween(floor_tween, group_floor, "position", group_floor_pos, final_pos, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(floor_tween, group_floor_1, "position", group_floor_1_pos, final_pos_1, floor_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func floor_object_visible():
	var duration = .15
	match cur_floor:
		Constants.FloorType.GROUND_FLOOR:
			GameManager.scene_manager.change_status_custom(GameManager.scene_manager.ground_floor_title, .25, .5)
			if objects_ground_floor.size() > 0: 
				for i in range(objects_ground_floor.size()):
					objects_ground_floor[i].visible = true
					Utils.start_tween(floor_tween, objects_ground_floor[i], "modulate", objects_ground_floor[i].modulate, fade_in_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			if objects_1st_floor.size() > 0: 
				for i in range(objects_1st_floor.size()):
					Utils.start_tween(floor_tween, objects_1st_floor[i], "modulate", objects_1st_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_1st_floor.size()):
					objects_1st_floor[i].visible = false
			if objects_2nd_floor.size() > 0: 
				for i in range(objects_2nd_floor.size()):
					Utils.start_tween(floor_tween, objects_2nd_floor[i], "modulate", objects_2nd_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_2nd_floor.size()):
					objects_2nd_floor[i].visible = false
		Constants.FloorType.FIRST_FLOOR:
			GameManager.scene_manager.change_status_custom(GameManager.scene_manager.first_floor_title, .25, .5)
			if objects_1st_floor.size() > 0: 
				for i in range(objects_1st_floor.size()):
					objects_1st_floor[i].visible = true
					Utils.start_tween(floor_tween, objects_1st_floor[i], "modulate", objects_1st_floor[i].modulate, fade_in_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			if objects_2nd_floor.size() > 0: 
				for i in range(objects_2nd_floor.size()):
					Utils.start_tween(floor_tween, objects_2nd_floor[i], "modulate", objects_2nd_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_2nd_floor.size()):
					objects_2nd_floor[i].visible = false
			if objects_ground_floor.size() > 0: 
				for i in range(objects_ground_floor.size()):
					Utils.start_tween(floor_tween, objects_ground_floor[i], "modulate", objects_ground_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_ground_floor.size()):
					objects_ground_floor[i].visible = false
		Constants.FloorType.SECOND_FLOOR:
			GameManager.scene_manager.change_status_custom(GameManager.scene_manager.second_floor_title, .25, .5)
			if objects_2nd_floor.size() > 0: 
				for i in range(objects_2nd_floor.size()):
					objects_2nd_floor[i].visible = true
					Utils.start_tween(floor_tween, objects_2nd_floor[i], "modulate", objects_2nd_floor[i].modulate, fade_in_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			if objects_1st_floor.size() > 0: 
				for i in range(objects_1st_floor.size()):
					Utils.start_tween(floor_tween, objects_1st_floor[i], "modulate", objects_1st_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_1st_floor.size()):
					objects_1st_floor[i].visible = false
			if objects_ground_floor.size() > 0: 
				for i in range(objects_ground_floor.size()):
					Utils.start_tween(floor_tween, objects_ground_floor[i], "modulate", objects_ground_floor[i].modulate, fade_out_color, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(Utils.start_coroutine(duration), "completed")
				for i in range(objects_ground_floor.size()):
					objects_ground_floor[i].visible = false


func go_up_down_character_vfx(character, is_fade_out):
	if is_fade_out:
		character.force_flip_h_sprite(true)
		character.update_direction(Constants.Direction.UP_SIDE)
		character.character_fade(false, 0.3)
		go_up_down_character_postion(character, true)
	else:
		character.update_direction(Constants.Direction.DOWN_SIDE)
		character.force_flip_h_sprite(false)
		character.character_fade(true, 0.3)
		go_up_down_character_postion(character, false)


func go_up_down_character_postion(character, is_in):
	var begin_pos = Vector2.ZERO
	var final_pos = Vector2.ZERO
	if is_in:
		begin_pos = character.position
		final_pos = Vector2(character.position.x - cell_size.x / 2, character.position.y - cell_size.y / 2)
	else:
		begin_pos = Vector2(character.position.x - cell_size.x / 2, character.position.y - cell_size.y / 2)
		final_pos = character.position
	
	Utils.start_tween(character.tween, character, "position", begin_pos, final_pos, .5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)

#endregion


# region: remove objects
var is_click_on_removable_object:bool = false
var item = null
var item_temp = null
var item_scene_name = null
var item_scene_name_temp = null
var item_index = null

func check_remove_item(target_position, target_name, target_node):
	assign_remove_item(target_position, target_name, target_node)
	detect_removable_item()
	show_remove_button()
	

func show_remove_button():
	if is_click_on_removable_object:
		visible_removable_object_efx(item, true)

		if item_temp == null:
			item_temp = item
			item_scene_name_temp = item_scene_name
		else:
			if item_temp.origin != item.origin:
				visible_removable_object_efx(item_temp, false)
				item_temp = item
				item_scene_name_temp = item_scene_name
				visible_removable_object_efx(item_temp, true)
			else:
				if item_scene_name_temp != item_scene_name:
					visible_removable_object_efx(item_temp, false)
					item_temp = item
					item_scene_name_temp = item_scene_name
					visible_removable_object_efx(item_temp, true)
	else:
		if item != null: visible_removable_object_efx(item, false)
		if item_temp != null: visible_removable_object_efx(item_temp, false)


func assign_remove_item(_target_position, _target_name, _target_node):
	var map_info = Utils.get_current_map_info(self)
	var build_data = GameManager.save_load_manager.load_build_data()
	var origin = Vector2.ZERO
	
	if build_data.size() <= 0:
		origin = _target_node.origin
		item_scene_name = _target_name
	else:
		for key in build_data:
			var values = build_data[key]
			var build_position_temp = values["build_position"]
			var build_postion = Vector2(Utils.string_to_vector2(build_position_temp))
			var scene_name = values["scene_name"]
			# remove in file save
			if build_postion == _target_position and scene_name == _target_name:
				origin = Vector2(Utils.string_to_vector2(build_data[key]["origin"]))
				item_scene_name = scene_name
				break
			# remove not in file save
			else:
				origin = _target_node.origin
				item_scene_name = _target_name

	var array_item = map_info.get_item(origin)
	var item_node_name = null
	for i in array_item.size():
		if not array_item[i].is_tile():
			if array_item[i].is_resource():
				item_node_name = Utils.get_scene_name_from_node(array_item[i].resource.name)	
				if item_node_name == item_scene_name:
					item = array_item[i]	
					item_index = i
					break
			else:
				item_node_name = Utils.get_scene_name_from_node(array_item[i].decoration.name)
				if item_node_name == item_scene_name:
					item = array_item[i]
					item_index = i
					break


func detect_removable_item():
	if item != null:
		if item.is_resource():
			if item.is_clickable_resource():
				is_click_on_removable_object = true
			else:
				is_click_on_removable_object = false
		elif item.is_tile():
			is_click_on_removable_object = false
		elif item.is_decoration():
			is_click_on_removable_object = true
		elif item.is_walkable_decoration():
			is_click_on_removable_object = true
		elif item.is_buildable_decoraion():
			var character = Utils.get_current_character()
			if not character.is_standing_on_buildable_object(item):
				is_click_on_removable_object = true
			else:
				is_click_on_removable_object = false
		elif item.is_above_decoration():
			is_click_on_removable_object = true
		elif item.is_below_decoration():
			is_click_on_removable_object = true
		elif item.is_tall_decoration():
			is_click_on_removable_object = true
		elif item.is_wall_decoration():
			is_click_on_removable_object = true 


func visible_removable_object_outline(object, visible):
	GameManager.build_manager.load_outline_shader(object)
	if visible:
		GameManager.build_manager.visible_outline_shader(object, true)
		GameManager.build_manager.color_outline_shader(Color.green)
	else:
		GameManager.build_manager.visible_outline_shader(object, false)


func visible_removable_object_efx(item, visible):
	if Utils.node_exists(item.resource) and item.is_resource():
		if item.resource.group_btn_remove.visible and not visible:
			item.resource.visible_button_remove(visible)
			visible_removable_object_outline(item.resource, visible)
			return
	if Utils.node_exists(item.resource) and item.is_clickable_resource():
		item.resource.visible_button_remove(visible)
		visible_removable_object_outline(item.resource, visible)
	elif Utils.node_exists(item.decoration):
		item.decoration.visible_button_remove(visible)
		visible_removable_object_outline(item.decoration, visible)


func check_disable_remove_item_choosing():
	is_click_on_removable_object = false
	show_remove_button()


#endregion


# region: load character from save file
func spawn_character_from_save_file():
	for i in 1:
		var _character_name: String = "1"
		var _character_data: Dictionary
		var _load_save_character: bool = false
		var _character_race: String = ""
		if !GameResourcesLibrary.character_save_test.has(_character_name):
			_character_race = choose_character_race()
		else:
			var _character_1_save_data = GameResourcesLibrary.character_save_test[_character_name]
			_character_data = _character_1_save_data
			_character_race = _character_data.information.race
			_load_save_character = true
			
		var _farmer_character: Node
		match _character_race:
			"human":
				_farmer_character = Utils.load_resource("res://characters/scenes/character.tscn", "farmer_character", "scene").instance()
			"elf":
				_farmer_character = Utils.load_resource("res://characters/scenes/elf.tscn", "elf_character", "scene").instance()
			"beast_man":
				_farmer_character = Utils.load_resource("res://characters/scenes/beast_man.tscn", "beast_man_character", "scene").instance()
				
				
		var character_spawn_point = Vector2((xrange.x + xrange.y) / 2, (yrange.x + yrange.y) / 2)
		_farmer_character.global_position = GameManager.map_manager_utils.map_to_global_position(character_spawn_point)
		ysort.add_child(_farmer_character)
		if _load_save_character:
			_farmer_character.stats_manager.load_character_stats_from_save(GameResourcesLibrary.character_save_test["4"])
		else:
			_farmer_character.stats_manager.load_new_character_inventory(GameResourcesLibrary.new_character_inventory[_character_race])


func choose_character_race() -> String:
	#when we have race selecting UI, we will update this func
	return "human"
# endregion
