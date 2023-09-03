extends AStar2D
class_name MapNavigator

var map_manager
var map_info
var map_size: Vector2
var tile: TileManager
var map_navigator_manager
var navigator_type: int = Constants.NavigatorType.LAND

var max_size: int # vd: 144
var size: int # vd: 48
var map_position: Vector2 # (0,0) , (1,1)

func _init(_map_manager, _map_navigator_manager, _navigator_type: int, _max_size, _size, _map_position):
	map_manager = _map_manager
	map_navigator_manager = _map_navigator_manager
	map_info = Utils.get_current_map_info(map_manager)
	navigator_type = _navigator_type
	tile = map_manager.earth_tile
	max_size = _max_size
	size = _size
	map_position = _map_position
	map_size = Vector2(map_manager.map_width, map_manager.map_height)
	var walkable_points = _add_walkable_points()
	_connect_walkable_points(walkable_points)
	_add_disabled_points()


func _add_walkable_points():
	var points = []
	var list_map_positions = map_manager.list_map_positions
	for i in list_map_positions.size():
		var xrange_temp = Utils.cal_xrange(list_map_positions[i], size)
		var yrange_temp = Utils.cal_yrange(list_map_positions[i], size)
		for x in range(xrange_temp.x, xrange_temp.y):
			for y in range(yrange_temp.x, yrange_temp.y):
				var point = Vector2(x, y)
				points.append(point)
				add_point(map_navigator_manager.point_to_index(point), point)
	return points


func _add_walkable_points_custom(_points):
	var points = []
	for point in _points:
		points.append(point)
		add_point(map_navigator_manager.point_to_index(point), point)
	return points


func _connect_walkable_points(points):
	for point in points:
		var point_index = map_navigator_manager.point_to_index(point)
		
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = map_navigator_manager.point_to_index(point_relative)
				if point_relative == point or Utils.is_outside_of_map(map_manager.list_map_positions, size, point_relative):
					continue
				if not has_point(point_relative_index):
					continue
				connect_points(point_index, point_relative_index, true)


func _connect_walkable_points_custom(points):
	for point in points:
		var point_index = map_navigator_manager.point_to_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = map_navigator_manager.point_to_index(point_relative)
				if point_relative == point:
					continue
				if not has_point(point_relative_index):
					continue
				connect_points(point_index, point_relative_index, true)


func _add_disabled_points():
	var map_info = Utils.get_current_map_info(map_manager)
	var list_map_positions = map_manager.list_map_positions
	for i in list_map_positions.size():
		var xrange_temp = Utils.cal_xrange(list_map_positions[i], size)
		var yrange_temp = Utils.cal_yrange(list_map_positions[i], size)
		for x in range(xrange_temp.x, xrange_temp.y):
			for y in range(yrange_temp.x, yrange_temp.y):
				var point = Vector2(x, y)
				if not map_info.is_walkable(point, navigator_type):
					set_point_disabled(map_navigator_manager.point_to_index(point))
				else:
					set_point_disabled(map_navigator_manager.point_to_index(point), false)


func _add_disabled_points_custom(_points):
	var map_info = Utils.get_current_map_info(map_manager)
	for point in _points:
		var idx: int = map_navigator_manager.point_to_index(point)
		if not has_point(idx):
			continue
		
		if not map_info.is_walkable(point, navigator_type):
			set_point_disabled(idx)
		else:
			set_point_disabled(idx, false)


func _add_build_disabled_points(size, pos):
	var map_info = Utils.get_current_map_info(map_manager)
	for x in range(size.x):
		for y in range(size.y):
			var point = pos + Vector2(x, y)
			var idx: int = map_navigator_manager.point_to_index(point)
			if not has_point(idx):
				continue
			
			if not map_info.is_walkable(point, navigator_type):
				set_point_disabled(idx)
			else:
				set_point_disabled(idx, false)


func get_path_by_world_positions(from: Vector2, to: Vector2) -> PoolVector2Array:
	var from_point = map_navigator_manager.world_to_point(from)
	var to_point = map_navigator_manager.world_to_point(to)
	var from_index = map_navigator_manager.point_to_index(from_point)
	var to_index = map_navigator_manager.point_to_index(to_point)
	
	if not has_point(to_index) or not has_point(from_index):
		return PoolVector2Array()
	
	
	if is_point_disabled(to_index):
		to_index = get_closest_point_between(from_index, to_index)
		if to_index == null:
			to_index = get_closest_point(to_point)
	return map_navigator_manager.path_to_world(test_astar(from_index, to_index))


func test_astar(f_idx, t_idx):
	return get_point_path(f_idx, t_idx)


func get_closest_point_between(from_index, to_index):
	var closest_neighbor = null
	var min_distance = 1000000
	var neighbors = get_point_connections(to_index)
	for neighbor in neighbors:
		if is_point_disabled(neighbor):
			continue
		var distance = len(test_astar(from_index, neighbor))
		if distance < min_distance:
			min_distance = distance
			closest_neighbor = neighbor
	return closest_neighbor


func path_to_world(path) -> PoolVector2Array:
	return map_navigator_manager.path_to_world(path)


func get_closest_point_between_navigators(_from: Vector2, _to: Vector2, _other_navigator):
	var _temp_path: PoolVector2Array = map_navigator_manager.get_path_from_combined_navigator(_from, _to)
	# print(_temp_path.size())
	for i in _temp_path.size():
		var _tile_index: int = map_navigator_manager.point_to_index(map_navigator_manager.world_to_point(_temp_path[i]))
		if is_point_disabled(_tile_index) and !_other_navigator.is_point_disabled(_tile_index):
			var _passed_tile_index: int = map_navigator_manager.point_to_index(map_navigator_manager.world_to_point(_temp_path[i-1]))
			return _passed_tile_index
	return null


func get_path_by_between_navigators_world_position(_from: Vector2, _to: Vector2, _other_navigator) -> PoolVector2Array:
	var from_point = map_navigator_manager.world_to_point(_from)
	var to_point = map_navigator_manager.world_to_point(_to)
	var from_index = map_navigator_manager.point_to_index(from_point)
	var to_index = map_navigator_manager.point_to_index(to_point)
	
	if not has_point(to_index) or not has_point(from_index):
		return PoolVector2Array()
	
	if is_point_disabled(to_index):
		to_index = get_closest_point_between(from_index, to_index)
		if to_index == null:
			to_index = get_closest_point(to_point)
		if !map_navigator_manager.tile_next_to_other_navigator(to_index, self, _other_navigator):
			to_index = get_closest_point_between_navigators(_from, _to, _other_navigator)
		if to_index == null:
			to_index = get_closest_point(to_point)

	return map_navigator_manager.path_to_world(get_point_path(from_index, to_index)) 
