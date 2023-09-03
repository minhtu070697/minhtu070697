extends Node
class_name MapManagerUtils

var map_manager


func _init(_map_manager) -> void:
	map_manager = _map_manager


func global_to_map_position(_global_position: Vector2) -> Vector2:
	if !map_manager:
		return Vector2.INF
	
	var map_pos: Vector2 = map_manager.earth_tile.tile_map.world_to_map(_global_position)
	return map_pos


func map_to_global_position(_map_position: Vector2) -> Vector2:
	if !map_manager:
		return Vector2.INF
	
	var global_pos: Vector2 = map_manager.earth_tile.tile_map.map_to_world(_map_position)
	return Vector2(global_pos.x, global_pos.y + map_manager.cell_size.y / 2)


func position_out_side_of_map(_global_position: Vector2) -> bool:
	return map_position_out_side_of_map(global_to_map_position(_global_position))


func map_position_out_side_of_map(_map_position: Vector2) -> bool:
	return Utils.is_outside_of_map(map_manager.list_map_positions, map_manager.size, _map_position)


func convert_out_side_to_map(_global_position: Vector2, map_id: Vector2 = Vector2(1, 1)) -> Vector2:
	if position_out_side_of_map(_global_position):
		var _map_position: Vector2 = global_to_map_position(_global_position)
		if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
			var xrange: Vector2 = Utils.cal_xrange(map_id, map_manager.size)
			var yrange: Vector2 = Utils.cal_yrange(map_id, map_manager.size)
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		else:
			var xrange: Vector2 = map_manager.xrange
			var yrange: Vector2 = map_manager.yrange
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		return map_to_global_position(_map_position)
	else:
		return _global_position


func convert_out_side_to_map_map_position(_map_position: Vector2, map_id: Vector2 = Vector2(1, 1)) -> Vector2:
	if map_position_out_side_of_map(_map_position):
		if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
			var xrange: Vector2 = Utils.cal_xrange(map_id, map_manager.size)
			var yrange: Vector2 = Utils.cal_yrange(map_id, map_manager.size)
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		else:
			var xrange: Vector2 = map_manager.xrange
			var yrange: Vector2 = map_manager.yrange
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		return _map_position
	else:
		return _map_position

