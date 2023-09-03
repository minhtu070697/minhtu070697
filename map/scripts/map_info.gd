extends Node
class_name MapInfo

var data: Array = []
var land_walkable_tiles: Array = []
var water_walkable_tiles: Array = []
var land_walkable_tiles_name: Array = []
var water_walkable_tiles_name: Array = []
var combined_walkable_tiles: Array = []
var combined_walkable_tiles_name: Array = []
var walkable_tiles: Array = []
var map_manager

var max_size: int # vd: 144
var size: int # vd: 48
var map_position: Vector2 # (0,0) , (1,1)

func _init(_map_manager, _map_type, _max_size, _size, _map_position):
	map_manager = _map_manager
	max_size = _max_size
	size = _size
	map_position = _map_position
	append_walkable_tiles(_map_type)

func append_walkable_tiles(map_type):
	match map_type:
		Constants.MapSceneType.FARM_MAP, Constants.MapSceneType.BATTLE_MAP:
			land_walkable_tiles = [map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile]
		Constants.MapSceneType.BASE_MAP, Constants.MapSceneType.BASE_UPGRADE_MAP:
			land_walkable_tiles = [map_manager.floor_tile, map_manager.wall_tile, map_manager.floor_1_tile, map_manager.wall_1_tile, map_manager.floor_2_tile, map_manager.wall_2_tile]
		Constants.MapSceneType.MINING_MAP:
			land_walkable_tiles = [map_manager.mining_tile, map_manager.mining_ground_tile]
	
	water_walkable_tiles = [map_manager.water_tile]
	combined_walkable_tiles = land_walkable_tiles + water_walkable_tiles
	land_walkable_tiles_name = get_tiles_name_from_tiles_array(land_walkable_tiles)
	water_walkable_tiles_name = get_tiles_name_from_tiles_array(water_walkable_tiles)
	combined_walkable_tiles_name = get_tiles_name_from_tiles_array(combined_walkable_tiles)

func get_tiles_name_from_tiles_array(_tiles_array: Array) -> Array:
	var _temp_array: Array = []
	for _tile in _tiles_array:
		_temp_array.append(_tile.name)
	return _temp_array

func append_item(item: MapInfoItem, pos: Vector2):
	data[pos.x][pos.y].append(item)

func insert_item(item: MapInfoItem, pos: Vector2, index: int):
	data[pos.x][pos.y].insert(index, item)

func append_multiple_item(item: MapInfoItem, size: Vector2, pos: Vector2):
	for x in range(size.x):
		for y in range(size.y):
			item.point = pos + Vector2(x, y)
			append_item(item, item.point)

func insert_multiple_item(item: MapInfoItem, size: Vector2, pos: Vector2, index: int):
	for x in range(size.x):
		for y in range(size.y):
			item.point = pos + Vector2(x, y)
			insert_item(item, item.point, index)

func last_item(pos: Vector2) -> MapInfoItem:
	# this is basically the top-most item on the map
	if pos == Vector2.INF:
		return null
	if pos.x >= max_size or pos.y >= max_size:
		return null
	if Utils.is_outside_of_map(map_manager.list_map_positions, size, pos):
		return null
	if data[pos.x][pos.y].size() > 0:
		return data[pos.x][pos.y][-1]
	return null

func top_item(pos: Vector2) -> MapInfoItem:
	# alias for last_item
	return last_item(pos)

func pop_item(pos: Vector2):
	data[pos.x][pos.y].pop_back()

func pop_item_by_index(pos: Vector2, index: int):
	data[pos.x][pos.y].pop_at(index)

func get_item(pos: Vector2) -> MapInfoItem:
	# get the full stack at position x,y
	return data[pos.x][pos.y]

func get_item_by_index(pos: Vector2, index: int):
	return data[pos.x][pos.y][index]

func append_tile(tile: TileManager, pos: Vector2):
	var item = MapInfoItem.new()
	item.type = Constants.MapInfoType.TILE_MAP
	item.tile = tile
	item.point = pos
	item.name = tile.tile_map.name
	append_item(item, pos)

func append_resource(node: Node, resource_type, pos: Vector2):
	if node == null:
		return
	var item = MapInfoItem.new()
	item.type = Constants.MapInfoType.RESOURCE
	item.resource_type = resource_type
	item.resource = node
	var size = node.size
	item.size = size
	item.origin = pos
	item.resource.origin = item.origin
	append_multiple_item(item, size, pos)

func append_decoration(node: Node, pos: Vector2, decoration_type: int, is_append_item: bool):
	if is_append_item:
		if node == null:
			return
		var item = MapInfoItem.new()
		item.type = decoration_type
		item.decoration = node
		var size = node.size
		item.size = size
		item.origin = pos
		item.decoration.origin = item.origin
		append_multiple_item(item, size, pos)

func insert_decoration(node: Node, pos: Vector2, decoration_type: int, is_insert: bool, index: int):
	if is_insert:
		if node == null:
			return
		var item = MapInfoItem.new()
		item.type = decoration_type
		item.decoration = node
		var size = node.size
		item.size = size
		item.origin = pos
		item.decoration.origin = item.origin
		insert_multiple_item(item, size, pos, index)

func remove_resource(item: MapInfoItem, size: Vector2, pos: Vector2):
	for x in range(size.x):
		for y in range(size.y):
			item.point = pos + Vector2(x, y)
			pop_item(item.point)
			var navigator = map_manager.map_navigator
			navigator.set_point_disabled(navigator.point_to_index(item.point), false)
		
func remove_decoration(item: MapInfoItem, item_scene_name: String, item_index: int):
	var size = item.size
	var origin = item.origin
	for x in range(size.x):
		for y in range(size.y):
			var point = origin + Vector2(x, y)
			remove_above_decoration(item, point, item_scene_name)
			if not item.is_wall_decoration(): pop_item(point)
			else: pop_item_by_index(point, item_index)
			var navigator = map_manager.map_navigator
			if not is_walkable(point):
				navigator.set_point_disabled(navigator.point_to_index(point))
			else:
				navigator.set_point_disabled(navigator.point_to_index(point), false)

	save_remove(item, item_scene_name, false)

func remove_above_decoration(item: MapInfoItem, point: Vector2, item_scene_name: String):
	if item.is_below_decoration():
		var top_item = top_item(point)
		if top_item.is_above_decoration():
			var size = top_item.size
			var origin = top_item.origin
			for x in range(size.x):
				for y in range(size.y):
					var top_item_point = origin + Vector2(x, y)
					pop_item(top_item_point)
					var navigator = map_manager.map_navigator
					if not is_walkable(top_item_point):
						navigator.set_point_disabled(navigator.point_to_index(top_item_point))
					else:
						navigator.set_point_disabled(navigator.point_to_index(top_item_point), false)

			save_remove(top_item, item_scene_name, true)

func save_remove(item: MapInfoItem, item_scene_name: String, is_above_decoration: bool):
	var character = Utils.get_current_character()
	if is_above_decoration:
		GameManager.save_load_manager.save_remove_above_objects(item.origin)
	else:
		GameManager.save_load_manager.save_remove_object(item.origin, item_scene_name)
	if character.map_manager.map_type == Constants.MapSceneType.BASE_MAP or character.map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP: 
		character.map_manager.pop_floor_object(item.decoration)
	if Utils.node_exists(item.decoration): 
		item.decoration.remove()
		var name = item.decoration.name
		item.decoration.queue_free()
		# we want to refactor this yield -> to another script
		yield(item.decoration, "tree_exited")
		GameManager.object_hover_manager.remove_hover_obj_from_list(name)
	if Utils.node_exists(item.resource): 
		var name = item.resource.name
		item.resource.queue_free()
		# we want to refactor this yield -> to another script
		yield(item.resource, "tree_exited")
		GameManager.object_hover_manager.remove_hover_obj_from_list(name)

func is_walkable(point:Vector2, _navigator_type: int = Constants.NavigatorType.LAND) -> bool:
	var item = last_item(point)
	if !item:
		return false
	if _navigator_type == Constants.NavigatorType.WATER:
		return (item.is_tile() and item.tile in water_walkable_tiles)
	if _navigator_type == Constants.NavigatorType.COMBINED:
		return (item.is_tile() and item.tile in combined_walkable_tiles
			or item.is_walkable_decoration() 
			or item.is_buildable_decoraion()
			or item.is_wall_decoration())
	return (item.is_tile() and item.tile in land_walkable_tiles
			or item.is_walkable_decoration() 
			or item.is_buildable_decoraion()
			or item.is_wall_decoration())

func is_wall_decorated(pos: Vector2):
	for i in data[pos.x][pos.y].size():
		if data[pos.x][pos.y][i].is_wall_decoration():
			return true

func get_final_tile_index():
	var final_index = -1
	for i in data[0][0].size():
		if data[0][0][i].is_tile():
			final_index += 1
	return final_index

func get_target_tile(_target_map_position: Vector2) -> String:
	var _position_data: Array = data[_target_map_position.x][_target_map_position.y]
	for i in _position_data.size():
		if !_position_data[-(i + 1)].is_tile():
			continue
		return _position_data[-(i+1)].name
	return ""
