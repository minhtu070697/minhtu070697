extends Navigation2D

class_name MapManager

export(int) var map_width: int = 48
export(int) var map_height: int = 48
export(int) var noise_seed = 0
export var is_battlefield: bool
export(int) var map_type = Constants.MapSceneType.FARM_MAP

onready var water_tile = TileManager.new($WaterTileMap, TileDescriptions.water)
onready var earth_tile = TileManager.new(
	$EarthTileMap, TileDescriptions.earth, water_tile, Vector2(0.2, 1), TileDescriptions.earth_water
)
onready var dark_grass_tile = TileManager.new(
	$DarkGrassTileMap, TileDescriptions.dark_grass, earth_tile, Vector2(0.3, .55)
)

onready var ground_tile = TileManager.new(
	$GroundTileMap, TileDescriptions.ground, earth_tile, Vector2(.55, .75)
)

onready var water_tile_map = $WaterTileMap
onready var tile_highlight = $TileHightlight
onready var target_highlight
onready var grid_build = $GridBuild
onready var ysort = $YSort
onready var group_bg = $GroupBackground

var cell_size = Vector2(46, 24)
var map_generator
var map_navigator: MapNavigatorManager
var map_info: MapInfo

var show_ui_delay = 3
var player_ready: bool = false
var wolf_boss_spawned: bool = false

var environment_type: int = Constants.EnvironmentType.FARM

export(int) var size: int = 48
export(Vector2) var map_position: Vector2 = Vector2(1, 1)
export(Array, Vector2) var list_map_positions = [Vector2(1, 1)]
var list_map_positions_default = Constants.list_map_positions_default
var max_size: int
var xrange: Vector2
var yrange: Vector2

onready var fog_tween: Tween = $FogTileMap/Tween
var fog_tiles = []
var fog_nodes = []
var list_line2ds = []
var list_land_labels = []
var map_unlock_vfx_duration = 4
var is_fog_tweening: bool


func _ready():
	max_size = size * 3
	xrange = Utils.cal_xrange(map_position, size)
	yrange = Utils.cal_yrange(map_position, size)
	append_fog_tiles_and_nodes()
	append_list_line_2ds()
	append_list_land_labels()
	map_info = MapInfo.new(self, map_type, max_size, size, map_position)
	GameManager.set_map_manager(self)
	GameManager.save_load_manager.load_daytime_data()
	GameManager.save_load_manager.load_current_timing()
	GameManager.save_load_manager.load_multiple_lands()
	map_generator = MapGenerator.new(self, noise_seed, max_size, size, map_position, xrange, yrange)
	map_generator.generate_terrain()
	map_navigator = MapNavigatorManager.new(self, max_size, size, map_position)
	map_generator.generate_objects()

	spawn_character_from_save_file()
	for zz in 1:
		spawn_dog(Utils.get_current_character().global_position)

	GameManager.enemy_manager.generate_enemies()
	GameManager.map_vfx_manager.spawn_cloud()
	GameManager.audio_manager.play_music(self)
	GameManager.scene_manager.open_scene(GameManager.scene_manager.farm_title)
	GameManager.scene_manager.spawn_blocking_input(self)
	GameManager.daytime_manager.run_timer()
	SignalManager.connect("character_arrived", self, "_on_character_arrived")
	SignalManager.connect("player_ready", self, "_on_player_ready")

	target_highlight = get_node_or_null("TargetHighlight")

	show_private_ui()

	# multiple lands only
	draw_lines(cal_draw_points())
	init_land_labels()
	remove_unlock_vfx()
	queue_free_all_multiple_lands_vfx_nodes()
	SignalManager.connect("character_dead", self, "_on_character_dead")


func _process(_delta):
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
			Utils.start_tween(
				$Tween, tile_highlight, "modulate", Color("00ffffff"), Color("ffffffff"), 0.5
			)

	GameManager.daytime_manager.daytime_input(event)
	

func _input(event):
	if event is InputEventKey and event.pressed:
		GameManager.build_manager.change_build_move_type()
		GameManager.build_manager.move_object_by_key()
		GameManager.build_manager.build_object_by_key()
		GameManager.save_load_manager.input_remove_object_mode()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		GameManager.save_load_manager.save_spawn_data()
		GameManager.save_load_manager.save_daytime_data()
		GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
		GameManager.save_load_manager.character_save.character_save(Utils.get_current_character())


func _on_player_ready():
	player_ready = true


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
	ui_manager.visible_buttons_in_private_scene()


# region: remove objects
var is_click_on_removable_object: bool = false
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
		if item != null:
			visible_removable_object_efx(item, false)
		if item_temp != null:
			visible_removable_object_efx(item_temp, false)


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
func _on_character_dead() -> void:
	yield(Utils.start_coroutine(3), "completed")
	spawn_character_from_save_file()
	show_private_ui()


func spawn_character_from_save_file():
	if Utils.node_exists(Utils.get_current_character()):
		return
	for i in 1:
		var _character_name: String = "7"
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

		var spawn_char: Character
		match _character_race:
			"human":
				spawn_char = Utils.load_resource("res://characters/scenes/character.tscn", "farmer_character", "scene").instance()
			"elf":
				spawn_char = Utils.load_resource("res://characters/scenes/elf.tscn", "elf_character", "scene").instance()
			"beast_man":
				spawn_char = Utils.load_resource("res://characters/scenes/beast_man.tscn", "beast_man_character", "scene").instance()

		var character_spawn_point = Vector2(xrange.x, yrange.x)
		spawn_char.global_position = GameManager.map_manager_utils.map_to_global_position(
			character_spawn_point
		)
		ysort.add_child(spawn_char)

		if _load_save_character:
			spawn_char.stats_manager.load_character_stats_from_save(
				GameResourcesLibrary.character_save_test["7"]
			)
		else:
			spawn_char.stats_manager.load_new_character_inventory(
				GameResourcesLibrary.new_character_inventory[_character_race]
			)
			spawn_char.stats_manager.demo_init_level()

		var load_spawn_position = GameManager.save_load_manager.load_spawn_data()
		if load_spawn_position != Vector2.ZERO:
			# spawn from save file
			spawn_char.global_position = load_spawn_position
		else:
			# spawn from teleportstation
			var map_build_data = JsonData.load_data(JsonData.map_build_data_path)
			var first_time_spawn_position = Utils.string_to_vector2(
				map_build_data["0"].build_position
			)
			spawn_char.global_position = first_time_spawn_position


func choose_character_race() -> String:
	#when we have race selecting UI, we will update this func
	return "human"


func spawn_dog(_global_position: Vector2) -> void:
	var dog: FarmDogs = Utils.load_resource("res://animals/pets/farm_pets/scenes/farm_dog.tscn", "farm_dog", "scene").instance()
	ysort.add_child(dog)
	dog.global_position = _global_position + Vector2(50, 50)
	GameManager.map_manager.ysort.nogias_insert(dog)


# endregion


# region: multiple lands
func append_fog_tiles_and_nodes():
	for i in $FogTileMap.get_child_count() - 1:
		fog_tiles.append(TileManager.new($FogTileMap.get_child(i), TileDescriptions.fog))
		fog_nodes.append($FogTileMap.get_child(i))


func append_list_line_2ds():
	for i in $Line2D.get_child_count():
		list_line2ds.append($Line2D.get_child(i))


func append_list_land_labels():
	for i in $LandLabels.get_child_count():
		list_land_labels.append($LandLabels.get_child(i))


func add_new_map_position(new_map_position: Vector2):
	list_map_positions.append(new_map_position)


func remove_fog(new_map_position):
	var index = 0
	for i in list_map_positions_default.size():
		if list_map_positions_default[i] == new_map_position:
			index = i
			is_fog_tweening = true
			Utils.start_tween(
				fog_tween,
				fog_nodes[i],
				"modulate",
				Color(1, 1, 1, 1),
				Color(1, 1, 1, 0),
				map_unlock_vfx_duration,
				Tween.TRANS_LINEAR,
				Tween.TRANS_LINEAR
			)

	yield(fog_tween, "tween_completed")
	is_fog_tweening = false
	fog_nodes[index].queue_free()


func cal_draw_points():
	var xrange_0_0 = Utils.cal_xrange(Vector2(0, 0), size)
	var yrange_0_0 = Utils.cal_yrange(Vector2(0, 0), size)

	var xrange_1_0 = Utils.cal_xrange(Vector2(1, 0), size)
	var yrange_1_0 = Utils.cal_yrange(Vector2(1, 0), size)

	var xrange_2_0 = Utils.cal_xrange(Vector2(2, 0), size)
	var yrange_2_0 = Utils.cal_yrange(Vector2(2, 0), size)

	var xrange_0_1 = Utils.cal_xrange(Vector2(0, 1), size)
	var yrange_0_1 = Utils.cal_yrange(Vector2(0, 1), size)

	var xrange_2_1 = Utils.cal_xrange(Vector2(2, 1), size)
	var yrange_2_1 = Utils.cal_yrange(Vector2(2, 1), size)

	var xrange_0_2 = Utils.cal_xrange(Vector2(0, 2), size)
	var yrange_0_2 = Utils.cal_yrange(Vector2(0, 2), size)

	var xrange_1_2 = Utils.cal_xrange(Vector2(1, 2), size)
	var yrange_1_2 = Utils.cal_yrange(Vector2(1, 2), size)

	var xrange_2_2 = Utils.cal_xrange(Vector2(2, 2), size)
	var yrange_2_2 = Utils.cal_yrange(Vector2(2, 2), size)

	var start_position_0_0 = convert_draw_point(xrange_0_0.y, yrange_0_0.x)
	var mid_position_0_0 = convert_draw_point(xrange_0_0.y, yrange_0_0.y)
	var end_position_0_0 = convert_draw_point(xrange_0_0.x, yrange_0_0.y)

	var start_position_1_0 = convert_draw_point(xrange_1_0.x, yrange_1_0.x)
	var mid_position_1_0 = convert_draw_point(xrange_1_0.x, yrange_1_0.y)
	var mid_1_position_1_0 = convert_draw_point(xrange_1_0.y, yrange_1_0.y)
	var end_position_1_0 = convert_draw_point(xrange_1_0.y, yrange_1_0.x)

	var start_position_2_0 = convert_draw_point(xrange_2_0.x, yrange_2_0.x)
	var mid_position_2_0 = convert_draw_point(xrange_2_0.x, yrange_2_0.y)
	var end_position_2_0 = convert_draw_point(xrange_2_0.y, yrange_2_0.y)

	var start_position_0_1 = convert_draw_point(xrange_0_1.x, yrange_0_1.x)
	var mid_position_0_1 = convert_draw_point(xrange_0_1.y, yrange_0_1.x)
	var mid_1_position_0_1 = convert_draw_point(xrange_0_1.y, yrange_0_1.y)
	var end_position_0_1 = convert_draw_point(xrange_0_1.x, yrange_0_1.y)

	var start_position_2_1 = convert_draw_point(xrange_2_1.y, yrange_2_1.x)
	var mid_position_2_1 = convert_draw_point(xrange_2_1.x, yrange_2_1.x)
	var mid_1_position_2_1 = convert_draw_point(xrange_2_1.x, yrange_2_1.y)
	var end_position_2_1 = convert_draw_point(xrange_2_1.y, yrange_2_1.y)

	var start_position_0_2 = convert_draw_point(xrange_0_2.x, yrange_0_2.x)
	var mid_position_0_2 = convert_draw_point(xrange_0_2.y, yrange_0_2.x)
	var end_position_0_2 = convert_draw_point(xrange_0_2.y, yrange_0_2.y)

	var start_position_1_2 = convert_draw_point(xrange_1_2.x, yrange_1_2.y)
	var mid_position_1_2 = convert_draw_point(xrange_1_2.x, yrange_1_2.x)
	var mid_1_position_1_2 = convert_draw_point(xrange_1_2.y, yrange_1_2.x)
	var end_position_1_2 = convert_draw_point(xrange_1_2.y, yrange_1_2.y)

	var start_position_2_2 = convert_draw_point(xrange_2_2.y, yrange_2_2.x)
	var mid_position_2_2 = convert_draw_point(xrange_2_2.x, yrange_2_2.x)
	var end_position_2_2 = convert_draw_point(xrange_2_2.x, yrange_2_2.y)

	return [
		cal_draw_point(start_position_0_0),
		cal_draw_point(mid_position_0_0),
		cal_draw_point(end_position_0_0),
		cal_draw_point(start_position_1_0),
		cal_draw_point(mid_position_1_0),
		cal_draw_point(mid_1_position_1_0),
		cal_draw_point(end_position_1_0),
		cal_draw_point(start_position_2_0),
		cal_draw_point(mid_position_2_0),
		cal_draw_point(end_position_2_0),
		cal_draw_point(start_position_0_1),
		cal_draw_point(mid_position_0_1),
		cal_draw_point(mid_1_position_0_1),
		cal_draw_point(end_position_0_1),
		cal_draw_point(start_position_2_1),
		cal_draw_point(mid_position_2_1),
		cal_draw_point(mid_1_position_2_1),
		cal_draw_point(end_position_2_1),
		cal_draw_point(start_position_0_2),
		cal_draw_point(mid_position_0_2),
		cal_draw_point(end_position_0_2),
		cal_draw_point(start_position_1_2),
		cal_draw_point(mid_position_1_2),
		cal_draw_point(mid_1_position_1_2),
		cal_draw_point(end_position_1_2),
		cal_draw_point(start_position_2_2),
		cal_draw_point(mid_position_2_2),
		cal_draw_point(end_position_2_2),
	]


func convert_draw_point(start, end) -> Vector2:
	return map_navigator.point_to_world(Vector2(start, end))


func cal_draw_point(point: Vector2) -> Vector2:
	return Vector2(point.x, point.y - cell_size.y / 2)


func draw_lines(draw_points):
	for i in draw_points.size():
		var point = draw_points[i]
		if i >= 0 and i < 3:
			list_line2ds[0].add_point(point)
		elif i >= 3 and i < 7:
			list_line2ds[1].add_point(point)
		elif i >= 7 and i < 10:
			list_line2ds[2].add_point(point)
		elif i >= 10 and i < 14:
			list_line2ds[3].add_point(point)
		elif i >= 14 and i < 18:
			list_line2ds[4].add_point(point)
		elif i >= 18 and i < 21:
			list_line2ds[5].add_point(point)
		elif i >= 21 and i < 25:
			list_line2ds[6].add_point(point)
		elif i >= 25 and i < 28:
			list_line2ds[7].add_point(point)


func remove_line(new_map_position: Vector2):
	for i in list_map_positions_default.size():
		if list_map_positions_default[i] == new_map_position:
			list_line2ds[i].clear_points()
			list_line2ds[i].queue_free()


func init_land_labels():
	if not GameManager.multiple_lands_manager:
		return
	for i in list_map_positions_default.size():
		var xrange_temp = Utils.cal_xrange(list_map_positions_default[i], size)
		var yrange_temp = Utils.cal_yrange(list_map_positions_default[i], size)
		var mid_point = Vector2(
			(xrange_temp.x + xrange_temp.y) / 2, (yrange_temp.x + yrange_temp.y) / 2
		)
		var mid_position = map_navigator.point_to_world(mid_point)
		set_land_labels(true, i, mid_position)


func set_land_labels(is_init: bool, i: int, mid_position):
	if not is_init:
		for i in list_land_labels.size():
			if Utils.node_exists(list_land_labels[i]):
				set_land_label(i)
	else:
		if Utils.node_exists(list_land_labels[i]):
			list_land_labels[i].global_position = mid_position
			set_land_label(i)


func set_land_label(i):
	var number = i + 1
	if GameManager.multiple_lands_manager.is_able_to_unlock(list_map_positions_default[i]):
		list_land_labels[i].get_child(0).text = (
			"LAND "
			+ str(number)
			+ "\n"
			+ "Ctrl + "
			+ str(number)
		)
		list_land_labels[i].get_child(0).modulate = Color(.95, .95, .65, 1)


func remove_land_label(new_map_position):
	for i in list_map_positions_default.size():
		if list_map_positions_default[i] == new_map_position:
			list_land_labels[i].queue_free()


func remove_unlock_vfx():
	for i in list_map_positions.size():
		remove_line(list_map_positions[i])
		remove_land_label(list_map_positions[i])


func queue_free_all_multiple_lands_vfx_nodes():
	if list_map_positions.size() >= 9:
		$FogTileMap.queue_free()
		$Line2D.queue_free()
		$LandLabels.queue_free()

		list_line2ds.clear()
		list_land_labels.clear()
		fog_tiles.clear()
		fog_nodes.clear()

#endregion
