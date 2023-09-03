extends Node

class_name BuildManager

var game_manager
var map_manager
var build_condition

var decorations_path = "res://map/scenes/decorations/%s.tscn"
var resources_path = "res://map/scenes/resources/%s.tscn"
var young_plant_scene_path = "res://young_plants/scene/young_plant.tscn"
const LIVESTOCK_BARN_SCENE_PATH: String = "res://animals/livestocks/buildings/scenes/LivestockBarn.tscn"

var list_resources = {
	Constants.ResourceType.TREE: load(resources_path % "Tree"),
	Constants.ResourceType.STONE: load(resources_path % "Stone"),
	Constants.ResourceType.GOLD: load(resources_path % "Gold"),
	Constants.ResourceType.OTHER: load(resources_path % "Other"),
	Constants.ResourceType.YOUNG_PLANT: load(young_plant_scene_path),
	Constants.ResourceType.EMPTY_PLOT: load(resources_path % "EmptyPlot"),
	Constants.ResourceType.LIVESTOCK_BARN:
	Utils.load_resource(resources_path % "LivestockBarn", "livestock_barn", "scene")
}

var list_decorations = {
	Constants.DecorationType.HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.FARM_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.MEDIUM_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.WINDMILL_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.GREEN_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.STORAGE_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.DOCK_HOUSE: load(decorations_path % "House"),
	Constants.DecorationType.PET_HOUSE: load(decorations_path % "PetHouse"),
	Constants.DecorationType.EDGE: load(decorations_path % "Edge"),
	Constants.DecorationType.EDGE_1: load(decorations_path % "Edge"),
	Constants.DecorationType.CORNER: load(decorations_path % "Corner"),
	Constants.DecorationType.CORNER_1: load(decorations_path % "Corner"),
	Constants.DecorationType.BRIDGE: load(decorations_path % "Bridge"),
	Constants.DecorationType.BRIDGE_1: load(decorations_path % "BridgeFullyRotate"),
	Constants.DecorationType.BRIDGE_2: load(decorations_path % "BridgeFullyRotate"),
	Constants.DecorationType.TABLE: load(decorations_path % "Table"),
	Constants.DecorationType.TABLE_1: load(decorations_path % "Table"),
	Constants.DecorationType.TABLE_2: load(decorations_path % "Table"),
	Constants.DecorationType.TABLE_BILLIARDS: load(decorations_path % "Table"),
	Constants.DecorationType.CHAIR: load(decorations_path % "Chair"),
	Constants.DecorationType.SOFA: load(decorations_path % "Chair"),
	Constants.DecorationType.SOFA_1: load(decorations_path % "Chair"),
	Constants.DecorationType.BED: load(decorations_path % "Bed"),
	Constants.DecorationType.BED_1: load(decorations_path % "Bed"),
	Constants.DecorationType.BOOK_CASE: load(decorations_path % "Bookcase"),
	Constants.DecorationType.BOOK_CASE_1: load(decorations_path % "Bookcase"),
	Constants.DecorationType.BOOK_CASE_2: load(decorations_path % "Bookcase"),
	Constants.DecorationType.WALL: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_1: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_2: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_3: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_4: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_5: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_6: load(decorations_path % "Wall"),
	Constants.DecorationType.WALL_7: load(decorations_path % "Wall"),
	Constants.DecorationType.DOOR: load(decorations_path % "Door"),
	Constants.DecorationType.BOOK: load(decorations_path % "Book"),
	Constants.DecorationType.BOOK_1: load(decorations_path % "Book"),
	Constants.DecorationType.BOOK_2: load(decorations_path % "Book"),
	Constants.DecorationType.FOOD: load(decorations_path % "Food"),
	Constants.DecorationType.FOOD_1: load(decorations_path % "Food"),
	Constants.DecorationType.FOOD_2: load(decorations_path % "Food"),
	Constants.DecorationType.CHESS: load(decorations_path % "Chess"),
	Constants.DecorationType.PICTURE: load(decorations_path % "Picture"),
	Constants.DecorationType.TV: load(decorations_path % "Picture"),
	Constants.DecorationType.HOUSE_PLANTS: load(decorations_path % "HousePlants"),
	Constants.DecorationType.SCARECROW: load(decorations_path % "Scarecrow"),
	Constants.DecorationType.WELL: load(decorations_path % "Well"),
	Constants.DecorationType.WATERING_CAN: load(decorations_path % "WateringCan"),
	Constants.DecorationType.FLOWER: load(decorations_path % "Flower"),
	Constants.DecorationType.GRASS: load(decorations_path % "Grass"),
	Constants.DecorationType.WHEAT: load(decorations_path % "Wheat"),
	Constants.DecorationType.TELEPORT: load(decorations_path % "Teleport"),
	Constants.DecorationType.MINING_CAVE: load(decorations_path % "MiningCave"),
	Constants.DecorationType.STAIRS: load(decorations_path % "Stairs"),
	Constants.DecorationType.TORCH: load(decorations_path % "Torch"),
	Constants.DecorationType.TORCH_1: load(decorations_path % "Torch"),
	Constants.DecorationType.TORCH_2: load(decorations_path % "Torch"),
	Constants.DecorationType.TORCH_3: load(decorations_path % "Torch"),
	Constants.DecorationType.TORCH_4: load(decorations_path % "Torch"),
}

var green_color = Color(.4, 1, .4, .65)
var red_color = Color(1, 0.3, 0.3, .65)

var earth_buildable_tiles
var water_buildable_tiles
var building_type: int
var object_type: int
var is_append: bool

var show_grid_build: bool

var holding_object = null
var holding_object_origin_temp = null
var holding_object_material = null

var tile_highlights = []
var build_direction_arrows = []
var current_camera = null
var is_isometric: bool = true


func _init(_game_manager, _map_manager, _map_type):
	game_manager = _game_manager
	map_manager = _map_manager
	build_condition = BuildCondition.new(self)
	match _map_type:
		Constants.MapSceneType.FARM_MAP, Constants.MapSceneType.BATTLE_MAP:
			earth_buildable_tiles = [
				map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile
			]
			water_buildable_tiles = [
				map_manager.earth_tile,
				map_manager.dark_grass_tile,
				map_manager.ground_tile,
				map_manager.water_tile
			]
		Constants.MapSceneType.BASE_MAP, Constants.MapSceneType.BASE_UPGRADE_MAP:
			earth_buildable_tiles = [
				map_manager.floor_tile,
				map_manager.wall_tile,
				map_manager.floor_1_tile,
				map_manager.wall_1_tile,
				map_manager.floor_2_tile,
				map_manager.wall_2_tile
			]
	show_grid_build = game_manager.show_grid_build


# region: building input
func build_object_by_key():
	if Input.is_action_just_pressed("build_object") and holding_object:
		build_object()


func move_object_by_key():
	if holding_object:
		var up = Input.is_action_pressed("ui_up")
		var down = Input.is_action_pressed("ui_down")
		var left = Input.is_action_pressed("ui_left")
		var right = Input.is_action_pressed("ui_right")
		var direction = Vector2.ZERO

		if up:
			if is_isometric:
				direction = Vector2(
					holding_object.global_position.x + map_manager.cell_size.x / 2,
					holding_object.global_position.y - map_manager.cell_size.y / 2
				)
			else:
				direction = Vector2(
					holding_object.global_position.x,
					holding_object.global_position.y - map_manager.cell_size.y
				)

			holding_object.global_position = direction
			button_pressed_vfx(0, build_direction_arrows[0])
		elif down:
			if is_isometric:
				direction = Vector2(
					holding_object.global_position.x - map_manager.cell_size.x / 2,
					holding_object.global_position.y + map_manager.cell_size.y / 2
				)
			else:
				direction = Vector2(
					holding_object.global_position.x,
					holding_object.global_position.y + map_manager.cell_size.y
				)

			holding_object.global_position = direction
			button_pressed_vfx(1, build_direction_arrows[1])
		elif left:
			if is_isometric:
				direction = Vector2(
					holding_object.global_position.x - map_manager.cell_size.x / 2,
					holding_object.global_position.y - map_manager.cell_size.y / 2
				)
			else:
				direction = Vector2(
					holding_object.global_position.x - map_manager.cell_size.x,
					holding_object.global_position.y
				)

			holding_object.global_position = direction
			button_pressed_vfx(2, build_direction_arrows[2])
		elif right:
			if is_isometric:
				direction = Vector2(
					holding_object.global_position.x + map_manager.cell_size.x / 2,
					holding_object.global_position.y + map_manager.cell_size.y / 2
				)
			else:
				direction = Vector2(
					holding_object.global_position.x + map_manager.cell_size.x,
					holding_object.global_position.y
				)

			holding_object.global_position = direction
			button_pressed_vfx(3, build_direction_arrows[3])

		update_tile_highlight_color()
		update_build_direction_arrow_color()


func change_build_move_type():
	if holding_object and Input.is_action_just_pressed("change_build_move_type"):
		if is_isometric:
			is_isometric = false
		else:
			is_isometric = true


# endregion


# region: building logic
func show_object(building_type, object_type, is_append, next_build, next_build_point):
	# logic
	init_object(building_type, object_type, is_append)
	spawn_object()

	# init new fake origin
	var spawn_pos = Vector2.ZERO
	if next_build:
		spawn_pos = next_build_point
	else:
		spawn_pos = map_manager.map_navigator.world_to_point(
			Utils.get_current_character().global_position
		)
	update_object_global_position(spawn_pos)
	init_object_origin_temp(spawn_pos)

	# vfx
	visible_grid_build(true)
	set_object_vfx(0.5, true)
	load_outline_shader(holding_object)
	visible_outline_shader(holding_object, true)
	initial_object_tile_highlight()
	initial_build_direction_arrow()
	update_tile_highlight_color()
	change_camera_from_player_to_holding_object(next_build)


func init_object(building_type, object_type, is_append):
	self.building_type = building_type
	self.object_type = object_type
	self.is_append = is_append


func spawn_object():
	var object_name
	if building_type == Constants.BuildingType.RESOURCE:
		holding_object = list_resources[object_type].instance()
		object_name = Constants.ResourceType.keys()[object_type].to_lower()
	elif (
		building_type == Constants.BuildingType.DECORATION
		or building_type == Constants.BuildingType.WALKABLE_DECORATION
		or building_type == Constants.BuildingType.BUILDABLE_DECORATION
		or building_type == Constants.BuildingType.ABOVE_DECORATION
		or building_type == Constants.BuildingType.BELOW_DECORATION
		or building_type == Constants.BuildingType.TALL_DECORATION
		or building_type == Constants.BuildingType.WALL_DECORATION
	):
		holding_object = list_decorations[object_type].instance()
		object_name = Constants.DecorationType.keys()[object_type].to_lower()
	if "is_building" in holding_object:
		holding_object.is_building = true
	map_manager.ysort.add_child(holding_object)
	if "is_reload" in holding_object:
		holding_object.is_reload = true
		holding_object.re_load(object_name, true)


func build_object():
	if is_buildable_object():
		var character = Utils.get_current_character()
		var holding_object_build_point_temp = map_manager.map_navigator.world_to_point(
			holding_object.global_position
		)

		# vfx
		change_camera_from_holding_object_to_map()
		set_object_vfx(1, false)
		set_object_color_vfx(Color.white)
		destroy_object_tile_highlight()
		destroy_build_direction_arrow()
		visible_outline_shader(holding_object, false)
		map_manager.tile_highlight.visible = false

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.mining)

		# logic
		if (
			map_manager.map_type == Constants.MapSceneType.BASE_MAP
			or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
		):
			map_manager.append_floor_object(holding_object)
		append_object()

		# save data
		var scene_name = Utils.get_scene_name_from_node(holding_object.name)
		var origin = cal_origin_build_point()
		GameManager.save_load_manager.append_build_data(
			building_type,
			object_type,
			scene_name,
			holding_object.sprite_name,
			holding_object.scale,
			holding_object.position,
			origin,
			is_append
		)
		GameManager.save_load_manager.save_build_data()

		# add to new y-sort
		holding_object.created(true)
		if building_type == Constants.BuildingType.ABOVE_DECORATION:
			map_manager.ysort.nogias_insert(holding_object, true)
			if character:
				character.update_sort_position()
		else:
			map_manager.ysort.nogias_insert(holding_object)

			holding_object.update_sort_position()
			if character:
				character.update_sort_position()

		# inventory items remove
		build_condition.cal_items_left_in_player_inventory()
		build_condition.clear_temp_data()

		destroy_object_origin_temp()
		holding_object = null
		holding_object_material = null

		# ex: fast build => respawn builed object => players dont have to open Build Menu!!
		if build_condition.is_reachable_build_conditions():
			show_object(
				building_type, object_type, is_append, true, holding_object_build_point_temp
			)
		else:
			character.ui_manager.hide_group_building_custom()
			change_camera_from_holding_object_to_player(false)
			visible_grid_build(false)


func append_object():
	var map_info = Utils.get_current_map_info(map_manager)
	var origin = cal_origin_build_point()
	match building_type:
		Constants.BuildingType.RESOURCE:
			map_info.append_resource(holding_object, object_type, origin)
		Constants.BuildingType.DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.DECORATION, is_append
			)
		Constants.BuildingType.WALKABLE_DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.WALKABLE_DECORATION, is_append
			)
		Constants.BuildingType.BUILDABLE_DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.BUILDABLE_DECORATION, is_append
			)
		Constants.BuildingType.ABOVE_DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.ABOVE_DECORATION, is_append
			)
		Constants.BuildingType.BELOW_DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.BELOW_DECORATION, is_append
			)
		Constants.BuildingType.TALL_DECORATION:
			map_info.append_decoration(
				holding_object, origin, Constants.MapInfoType.TALL_DECORATION, is_append
			)
		Constants.BuildingType.WALL_DECORATION:
			var wall_decor_index = map_info.get_final_tile_index() + 1
			map_info.insert_decoration(
				holding_object,
				origin,
				Constants.MapInfoType.WALL_DECORATION,
				is_append,
				wall_decor_index
			)
	map_manager.map_navigator._add_build_disabled_points(holding_object.size, origin)
	map_manager.map_navigator._add_build_disabled_points(
		holding_object.size, origin, Constants.NavigatorType.WATER
	)


func init_object_origin_temp(previous_position: Vector2):
	var point = previous_position
	var origin_highlight = Utils.load_resource("res://map/scenes/vfxs/TileHighlight.tscn", "tile_highlight", "scene").instance()
	var world_position = map_manager.map_navigator.point_to_world(point)

	holding_object.add_child(origin_highlight)
	origin_highlight.global_position = world_position
	holding_object_origin_temp = origin_highlight
	origin_highlight.modulate.a = 0


func destroy_object_origin_temp():
	if holding_object_origin_temp:
		holding_object_origin_temp.queue_free()
		holding_object_origin_temp = null


func update_object_global_position(_previous_point: Vector2):
	var map_pos = map_manager.map_navigator.point_to_world(_previous_point)
	holding_object.global_position = cal_holding_global_position(
		holding_object.size.x, holding_object.size.y, map_pos.x, map_pos.y
	)


func cal_holding_global_position(size_x, size_y, x_0, y_0) -> Vector2:
	var d_x = map_manager.cell_size.x / 2
	var d_y = map_manager.cell_size.y / 2

	var z_1
	if size_x != size_y:
		z_1 = (max(size_x, size_y) * 2) - 1
	else:
		z_1 = max(size_x, size_y) * 2

	var x_1 = x_0 + (d_x * (size_x - size_y))
	var y_1 = y_0 + (d_y * z_1)

	var x = (x_1 + x_0) / 2
	var y = (y_1 + y_0) / 2

	return Vector2(x, y - map_manager.cell_size.y / 2)


func cal_origin_build_point():
	if holding_object_origin_temp:
		var local_point = map_manager.map_navigator.world_to_point(
			holding_object_origin_temp.global_position
		)
		var mid_point = map_manager.map_navigator.point_to_world(local_point)
		var final_point = map_manager.map_navigator.world_to_point(mid_point)
		return final_point
	else:
		return Vector2.ZERO


func is_buildable_object():
	var map_info = Utils.get_current_map_info(map_manager)
	var size = holding_object.size
	var origin = cal_origin_build_point()
	var buildable = true
	for x in range(size.x):
		for y in range(size.y):
			var point = origin + Vector2(x, y)
			var last_item = map_info.last_item(point)
			if last_item == null:
				return null
			if Utils.is_outside_of_map(map_manager.list_map_positions, map_manager.size, point):
				return null
			buildable = (
				buildable
				and is_buildable_tile(last_item, point)
				and not is_character_colliding(point)
			)
	return buildable


func is_buildable_tile(item: MapInfoItem, point: Vector2):
	var map_info = Utils.get_current_map_info(map_manager)
	if building_type == Constants.BuildingType.WALL_DECORATION:
		return (
			(
				map_manager.map_type == Constants.MapSceneType.BASE_MAP
				or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
			)
			and not map_info.is_wall_decorated(point)
			and not item.is_tall_decoration()
			and is_on_wall_object(point)
		)
	elif building_type == Constants.BuildingType.ABOVE_DECORATION:
		return item.is_below_decoration()
	else:
		if not is_on_water_object():
			return (
				(item.is_tile() and item.tile in earth_buildable_tiles)
				or item.is_buildable_decoraion()
				or item.is_wall_decoration()
			)
		else:
			return item.is_tile() and item.tile in water_buildable_tiles


func is_character_colliding(object_point):
	var character = map_manager.ysort.get_node_or_null("Character")
	var character_point = map_manager.map_navigator.world_to_point(character.global_position)
	return object_point == character_point


func is_on_water_object():
	if building_type == Constants.BuildingType.BUILDABLE_DECORATION:
		return (
			object_type == Constants.DecorationType.BRIDGE
			or object_type == Constants.DecorationType.BRIDGE_1
			or object_type == Constants.DecorationType.BRIDGE_2
			or object_type == Constants.DecorationType.DOCK_HOUSE
		)
	elif building_type == Constants.BuildingType.WALKABLE_DECORATION:
		return object_type == Constants.DecorationType.STAIRS
	elif building_type == Constants.BuildingType.DECORATION:
		return object_type == Constants.DecorationType.DOCK_HOUSE


func is_on_wall_object(point: Vector2):
	if (point.x == point.y) and (point.x or point.y == 0) and (point.x and point.y != 1):
		return true
	elif point.x == 0 or point.y == 0:
		return true


func rotate_object():
	if not holding_object.has_method("rotate_all_directions"):
		if holding_object.scale.x == 1:
			holding_object.scale.x = -1
		else:
			holding_object.scale.x = 1
		if holding_object.has_method("rotate_button_remove"):
			holding_object.rotate_button_remove(true)
	else:
		holding_object.rotate_all_directions(holding_object.default_sprite_name)
		if holding_object.has_method("rotate_button_remove"):
			holding_object.rotate_button_remove(false)

	if is_object_balance():
		destroy_build_direction_arrow()
		initial_build_direction_arrow()


func rotate_imbalance_object():
	# logic
	var previous_point = cal_origin_build_point()

	# rotate object
	rotate_object()
	destroy_object_tile_highlight()
	destroy_build_direction_arrow()

	# resize imbalance object
	if not holding_object.has_method("rotate_all_directions"):
		holding_object.size = Vector2(holding_object.size.y, holding_object.size.x)

	# re-calculate object object global position + origin temp
	update_object_global_position(previous_point)
	destroy_object_origin_temp()
	init_object_origin_temp(previous_point)

	# vfx
	set_object_vfx(0.35, true)
	initial_object_tile_highlight()
	initial_build_direction_arrow()
	update_tile_highlight_color()


func is_object_balance():
	return holding_object.size.x == holding_object.size.y


func build_cancel():
	# clear hover right click detect
	GameManager.object_hover_manager.hovering_objects.erase(holding_object.name)
	change_camera_from_holding_object_to_player(true)
	visible_outline_shader(holding_object, false)
	destroy_object_origin_temp()
	holding_object.queue_free()
	holding_object = null
	holding_object_material = null
	destroy_object_tile_highlight()
	destroy_build_direction_arrow()
	visible_grid_build(false)


#endregion


# region: building vfx
func visible_grid_build(_visible):
	if map_manager.grid_build != null and show_grid_build:
		map_manager.grid_build.visible = _visible


func set_object_vfx(alpha, disabled):
	set_object_alpha(alpha)
	set_object_detect_collision(disabled)


func set_object_alpha(alpha):
	var sprite = holding_object.get_node_or_null("Sprite")
	var animate_sprite = holding_object.get_node_or_null("AnimateSprite")
	if sprite != null:
		sprite.modulate.a = alpha
	if animate_sprite != null:
		animate_sprite.modulate.a = alpha


func set_object_color_vfx(color: Color):
	if holding_object != null:
		if holding_object.has_method("get_sprite"):
			holding_object.get_sprite().modulate = color
		else:
			holding_object.get_node_or_null("Sprite").modulate = color


func load_outline_shader(object):
	if object.has_method("get_sprite"):
		object.get_sprite().material = Utils.load_resource(
			"res://efx/shader/outline_object.tres", "outline_obj_shader", "shader"
		)
		holding_object_material = object.get_sprite().material
	else:
		object.get_node_or_null("Sprite").material = Utils.load_resource(
			"res://efx/shader/outline_object.tres", "outline_obj_shader", "shader"
		)
		holding_object_material = object.get_node_or_null("Sprite").material


func visible_outline_shader(object, visible):
	if visible:
		holding_object_material.set_shader_param("line_thickness", .8)
	else:
		holding_object_material.set_shader_param("line_thickness", 0)
		if object.has_method("get_sprite"):
			object.get_sprite().material = null
		else:
			object.get_node_or_null("Sprite").material = null


func color_outline_shader(color: Color):
	holding_object_material.set_shader_param("line_color", color)


func set_object_detect_collision(disabled):
	var area2d_out = holding_object.get_node_or_null("Area2D")
	if area2d_out != null:
		for i in range(area2d_out.get_child_count()):
			var collision = area2d_out.get_child(i)
			collision.disabled = disabled
	var area2d_in = holding_object.sprite.get_node_or_null("Area2D")
	if area2d_in != null:
		for i in range(area2d_in.get_child_count()):
			var collision = area2d_in.get_child(i)
			collision.disabled = disabled
	elif "collisions" in holding_object:
		if disabled:
			holding_object.disable_collisions()
		else:
			holding_object.enable_collisions()


func initial_object_tile_highlight():
	if show_grid_build:
		var size = holding_object.size
		var origin = cal_origin_build_point()

		for x in range(size.x):
			for y in range(size.y):
				var point = origin + Vector2(x, y)
				var tile_highlight = Utils.load_resource("res://map/scenes/vfxs/TileHighlight.tscn", "tile_highlight", "scene").instance()
				var world_position = map_manager.map_navigator.point_to_world(point)

				holding_object.add_child(tile_highlight)
				tile_highlights.append(tile_highlight)
				tile_highlight.global_position = (
					world_position
					+ Vector2(0, map_manager.cell_size.y / 2)
				)


func destroy_object_tile_highlight():
	if tile_highlights.size() > 0:
		for i in range(tile_highlights.size()):
			tile_highlights[i].queue_free()
		tile_highlights.clear()


func update_tile_highlight_color():
	if tile_highlights.size() > 0:
		if is_buildable_object():
			for i in range(tile_highlights.size()):
				tile_highlights[i].modulate = green_color
		else:
			for i in range(tile_highlights.size()):
				tile_highlights[i].modulate = red_color
	
	if is_buildable_object():
		color_outline_shader(green_color)
		set_object_color_vfx(green_color)
	else:
		color_outline_shader(red_color)
		set_object_color_vfx(red_color)


func initial_build_direction_arrow():
	var size = holding_object.size
	var origin = cal_origin_build_point()
	var total = 4

	for i in total:
		var build_direction_arrow = Utils.load_resource("res://map/scenes/vfxs/BuildDirectionArrow.tscn", "build_direction_arrow", "scene").instance()
		holding_object.add_child(build_direction_arrow)
		build_direction_arrows.append(build_direction_arrow)
		build_direction_arrow.get_node_or_null("Sprite").modulate = green_color
		match i:
			0:
				# up_right
				build_direction_arrow.scale = cal_build_direction_arrow_scale(0)
				build_direction_arrow.global_position = cal_build_direction_arrrow_position_and_direction(
					0, origin, size
				)
				build_direction_arrow.get_node_or_null("Button").scale = Vector2(1.25, 1.25)
			1:
				# down_left
				build_direction_arrow.scale = cal_build_direction_arrow_scale(1)
				build_direction_arrow.global_position = cal_build_direction_arrrow_position_and_direction(
					1, origin, size
				)
				build_direction_arrow.get_node_or_null("Button").texture = load(
					"res://ui/textures/buttons/btn_s.png"
				)
				build_direction_arrow.get_node_or_null("Button").scale = Vector2(-1.25, -1.25)
				build_direction_arrow.get_node_or_null("Button").position = Vector2(50, -45)
			2:
				# up_left
				build_direction_arrow.scale = cal_build_direction_arrow_scale(2)
				build_direction_arrow.global_position = cal_build_direction_arrrow_position_and_direction(
					2, origin, size
				)
				build_direction_arrow.get_node_or_null("Button").texture = load(
					"res://ui/textures/buttons/btn_a.png"
				)
				build_direction_arrow.get_node_or_null("Button").scale = Vector2(1.25, 1.25)
			3:
				# down_right
				build_direction_arrow.scale = cal_build_direction_arrow_scale(3)
				build_direction_arrow.global_position = cal_build_direction_arrrow_position_and_direction(
					3, origin, size
				)
				build_direction_arrow.get_node_or_null("Button").texture = load(
					"res://ui/textures/buttons/btn_d.png"
				)
				build_direction_arrow.get_node_or_null("Button").scale = Vector2(1.25, -1.25)
				build_direction_arrow.get_node_or_null("Button").position = Vector2(50, -45)

	update_build_direction_arrow_color()

func destroy_build_direction_arrow():
	if build_direction_arrows.size() > 0:
		for i in range(build_direction_arrows.size()):
			build_direction_arrows[i].queue_free()
		build_direction_arrows.clear()


func update_build_direction_arrow_color():
	if build_direction_arrows.size() > 0:
		if is_buildable_object():
			for i in range(build_direction_arrows.size()):
				build_direction_arrows[i].get_node_or_null("Sprite").modulate = green_color
		else:
			for i in range(build_direction_arrows.size()):
				build_direction_arrows[i].get_node_or_null("Sprite").modulate = red_color


func cal_up_right_point_build_direction_arrow(
	_holding_object_origin: Vector2, _holding_object_size: Vector2
):
	return map_manager.map_navigator.point_to_world(
		Vector2(_holding_object_origin.x + _holding_object_size.x / 2, _holding_object_origin.y + 0)
	)


func cal_up_left_point_build_direction_arrow(
	_holding_object_origin: Vector2, _holding_object_size: Vector2
):
	return map_manager.map_navigator.point_to_world(
		Vector2(_holding_object_origin.x + 0, _holding_object_origin.y + _holding_object_size.y / 2)
	)


func cal_down_left_point_build_direction_arrow(
	_holding_object_origin: Vector2, _holding_object_size: Vector2
):
	return map_manager.map_navigator.point_to_world(
		Vector2(
			_holding_object_origin.x + _holding_object_size.x / 2,
			_holding_object_origin.y + _holding_object_size.y
		)
	)


func cal_down_right_point_build_direction_arrow(
	_holding_object_origin: Vector2, _holding_object_size: Vector2
):
	return map_manager.map_navigator.point_to_world(
		Vector2(
			_holding_object_origin.x + _holding_object_size.x,
			_holding_object_origin.y + _holding_object_size.y / 2
		)
	)


func cal_build_direction_arrrow_position_and_direction(
	_direction: int, _origin: Vector2, _size: Vector2
):
	match _direction:
		0:
			var up_right_point = cal_up_right_point_build_direction_arrow(_origin, _size)
			if int(_size.x) % 2 != 0:
				return Vector2(
					(
						up_right_point
						- Vector2(-map_manager.cell_size.x / 1.5, map_manager.cell_size.y / 1.5)
					)
				)
			else:
				return Vector2(
					up_right_point - Vector2(-map_manager.cell_size.x / 2, map_manager.cell_size.y)
				)
		1:
			var down_left_point = cal_down_left_point_build_direction_arrow(_origin, _size)
			if int(_size.x) % 2 != 0:
				return Vector2(
					(
						down_left_point
						- Vector2(map_manager.cell_size.x / 4, -map_manager.cell_size.y / 4)
					)
				)
			else:
				return Vector2(down_left_point - Vector2(map_manager.cell_size.x / 2, 0))
		2:
			var up_left_point = cal_up_left_point_build_direction_arrow(_origin, _size)
			if int(_size.y) % 2 != 0:
				return Vector2(
					(
						up_left_point
						- Vector2(map_manager.cell_size.x / 1.5, map_manager.cell_size.y / 1.5)
					)
				)
			else:
				return Vector2(
					up_left_point - Vector2(map_manager.cell_size.x / 2, map_manager.cell_size.y)
				)
		3:
			var down_right_point = cal_down_right_point_build_direction_arrow(_origin, _size)
			if int(_size.y) % 2 != 0:
				return Vector2(
					(
						down_right_point
						- Vector2(-map_manager.cell_size.x / 4, -map_manager.cell_size.y / 4)
					)
				)
			else:
				return Vector2(down_right_point - Vector2(-map_manager.cell_size.x / 2, 0))


func cal_build_direction_arrow_scale(_direction: int):
	match _direction:
		0:
			if holding_object.scale.x == 1:
				return Vector2(1.2, 1.2)
			else:
				return Vector2(-1.2, 1.2)
		1:
			if holding_object.scale.x == 1:
				return Vector2(-1.2, -1.2)
			else:
				return Vector2(1.2, -1.2)
		2:
			if holding_object.scale.x == 1:
				return Vector2(-1.2, 1.2)
			else:
				return Vector2(1.2, 1.2)
		3:
			if holding_object.scale.x == 1:
				return Vector2(1.2, -1.2)
			else:
				return Vector2(-1.2, -1.2)


func change_camera_from_player_to_holding_object(next_build):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if not next_build:
		var character = Utils.get_current_character()
		current_camera = character.camera
		current_camera.current = false
		character.remove_child(current_camera)
		holding_object.add_child(current_camera)
		current_camera.current = true
		current_camera.smoothing_enabled = true
		current_camera.zoom = Vector2(.6, .6)
	else:
		current_camera.current = false
		map_manager.remove_child(current_camera)
		holding_object.add_child(current_camera)
		current_camera.current = true
		current_camera.smoothing_enabled = true
		current_camera.zoom = Vector2(.6, .6)


func change_camera_from_holding_object_to_player(is_cancel):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var character = Utils.get_current_character()
	current_camera.current = false
	if is_cancel:
		holding_object.remove_child(current_camera)
	else:
		map_manager.remove_child(current_camera)
	character.add_child(current_camera)
	current_camera.current = true
	current_camera.smoothing_enabled = false
	current_camera.zoom = Vector2(.5, .5)


func change_camera_from_holding_object_to_map():
	holding_object.remove_child(current_camera)
	map_manager.add_child(current_camera)


func button_pressed_vfx(_direction: int, _direction_arrow: Node2D):
	var vfx_duration = 0.075
	var btn = _direction_arrow.get_node_or_null("Button")
	var tween = _direction_arrow.get_node_or_null("Tween")
	var scale_x = 0
	var scale_y = 0

	if _direction == 0 or _direction == 2:
		scale_y = btn.scale.y - 0.6
	else:
		scale_y = btn.scale.y + 0.6

	Utils.start_tween(
		tween,
		btn,
		"scale",
		btn.scale,
		Vector2(btn.scale.x, scale_y),
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	btn.modulate = green_color

	yield(tween, "tween_completed")

	if _direction == 0 or _direction == 2:
		scale_y = 1.25
		scale_x = scale_y
	else:
		if _direction == 1:
			scale_x = -1.25
		else:
			scale_x = 1.25
		scale_y = -1.25

	Utils.start_tween(
		tween,
		btn,
		"scale",
		btn.scale,
		Vector2(scale_x, scale_y),
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	btn.modulate = Color.white

#endregion
