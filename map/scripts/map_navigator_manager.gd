extends Node
class_name MapNavigatorManager

var map_manager
var map_info
var map_size: Vector2
var tile: TileManager
var land_navigator: MapNavigator
var water_navigator: MapNavigator
var combined_navigator: MapNavigator #Linked navigator combine all walkable tiles 

var navigator: Dictionary

var max_size: int # vd: 144
var size: int # vd: 48
var map_position: Vector2 # (0,0) , (1,1)


func _init(_map_manager, _max_size, _size, _map_position):
	map_manager = _map_manager
	max_size = _max_size
	size = _size
	map_position = _map_position
	tile = map_manager.earth_tile
	map_info = map_manager.map_info
	map_size = Vector2(max_size, max_size)
	land_navigator = MapNavigator.new(_map_manager, self, Constants.NavigatorType.LAND, _max_size, _size, _map_position)
	water_navigator = MapNavigator.new(_map_manager, self, Constants.NavigatorType.WATER, _max_size, _size, _map_position)
	combined_navigator = MapNavigator.new(_map_manager, self, Constants.NavigatorType.COMBINED, _max_size, _size, _map_position)
	navigator = {
		Constants.NavigatorType.LAND: land_navigator,
		Constants.NavigatorType.WATER: water_navigator,
		Constants.NavigatorType.COMBINED: combined_navigator
	}


func _add_walkable_points_land(points: Array):
	return (land_navigator._add_walkable_points_custom(points))


func _add_walkable_points_water(points: Array):
	return (water_navigator._add_walkable_points_custom(points))


func _add_walkable_points_combined(points: Array):
	return (combined_navigator._add_walkable_points_custom(points))


func _connect_walkable_points_custom(land_points, water_points, combined_points):
	land_navigator._connect_walkable_points_custom(land_points)
	water_navigator._connect_walkable_points_custom(water_points)
	combined_navigator._connect_walkable_points_custom(combined_points)


func _add_disabled_points_custom(points: Array):
	land_navigator._add_disabled_points_custom(points)
	water_navigator._add_disabled_points_custom(points)
	combined_navigator._add_disabled_points_custom(points) 


func _add_disabled_points():
	land_navigator._add_disabled_points()
	water_navigator._add_disabled_points()
	combined_navigator._add_disabled_points()


func _add_build_disabled_points(_size, _pos, _navigator_type: int = Constants.NavigatorType.LAND):
	for _navigator in select_navigators(_navigator_type):
		_navigator._add_build_disabled_points(_size, _pos)


func _add_build_enabled_points(_size, _pos, _navigator_type: int = Constants.NavigatorType.LAND):
	for _navigator in select_navigators(_navigator_type):
		_navigator._add_build_enabled_points(_size, _pos)


func get_path_by_world_positions(_from: Vector2, _to: Vector2, _navigator_type: int = Constants.NavigatorType.LAND) -> PoolVector2Array:
	return navigator[_navigator_type].get_path_by_world_positions(_from, _to)


func get_path_by_between_navigators_world_position(from: Vector2, to: Vector2, _from_navigator_type: int, _to_navigator_type: int) -> PoolVector2Array:
	if _from_navigator_type == _to_navigator_type:
		return get_path_by_world_positions(from, to, _from_navigator_type)

	return navigator[_from_navigator_type].get_path_by_between_navigators_world_position(from, to, navigator[_to_navigator_type])


func point_to_index(point:Vector2):
	return point.x + point.y * map_size.x


func index_to_point(index:int) -> Vector2:
	var y = int(index / map_size.x)
	var x = index % int(map_size.x)
	return Vector2(x, y)


func point_to_world(_point: Vector2):
	var point = tile.tile_map.map_to_world(_point)
	return Vector2(point.x, point.y + map_manager.cell_size.y / 2)


func world_to_point(pos:Vector2):
	return tile.tile_map.world_to_map(pos)


func path_to_world(path) -> PoolVector2Array:
	var world_path: PoolVector2Array = []
	for p in path:
		world_path.append(point_to_world(Vector2(p.x, p.y)))
	return world_path


func get_direction_from_world(from_world, to_world):
	var from = world_to_point(from_world)
	var to = world_to_point(to_world)
	var point = to - from

	if point.x > 1: point.x = 1
	if point.x < -1: point.x = -1
	if point.y > 1: point.y = 1
	if point.y < -1: point.y = -1

	if point in [Constants.DisplacementMap[2], Constants.DisplacementMap[4]]:
		return Constants.Direction.UP    
	if point in [Constants.DisplacementMap[1], Constants.DisplacementMap[5]]:
		return Constants.Direction.UP_SIDE
	if point in [Constants.DisplacementMap[0], Constants.DisplacementMap[8]]:
		return Constants.Direction.SIDE    
	if point in [Constants.DisplacementMap[3], Constants.DisplacementMap[7]]:
		return Constants.Direction.DOWN_SIDE
	if point == Constants.DisplacementMap[6]:
		return Constants.Direction.DOWN


func set_point_disabled(_id: int, _disabled: bool = true, _navigator_type: int = Constants.NavigatorType.LAND):
	for _navigator in select_navigators(_navigator_type):
		if not _navigator.has_point(_id):
			return
			
		_navigator.set_point_disabled(_id, _disabled)


func is_point_disabled(_id: int, _navigator_type: int = Constants.NavigatorType.LAND) -> bool:
	if not navigator[_navigator_type].has_point(_id):
		return false
	
	return navigator[_navigator_type].is_point_disabled(_id)


func is_map_position_disabled(_map_position: Vector2, _navigator_type: int = Constants.NavigatorType.LAND) -> bool:
	return is_point_disabled(point_to_index(_map_position), _navigator_type)


func set_map_position_disabled(_map_position: Vector2, _navigator_type: int = Constants.NavigatorType.LAND) -> void:
	set_point_disabled(point_to_index(_map_position), _navigator_type)


func select_navigators(_navigator_type: int) -> Array:
	var _navigators: Array = []
	_navigators.append(navigator[_navigator_type])
	_navigators.append(combined_navigator)
	return _navigators


func get_path_from_combined_navigator(_from: Vector2, _to: Vector2) -> PoolVector2Array:
	return combined_navigator.get_path_by_world_positions(_from, _to)


func tile_next_to_other_navigator(_tile_index: int, _navigator: MapNavigator, _other_navigator: MapNavigator) -> bool:
	var _neighbor_tiles: Array = _navigator.get_point_connections(_tile_index)
	for _neighbor_tile_index in _neighbor_tiles:
		if _navigator.is_point_disabled(_neighbor_tile_index) and !_other_navigator.is_point_disabled(_neighbor_tile_index):
			return true
	
	return false
