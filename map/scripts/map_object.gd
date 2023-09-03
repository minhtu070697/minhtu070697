extends Node

class_name MapObject

var resource: Resource
var spawnable_tiles: Array
var spawn_rate: float
var max_count: int
var current_count = 0
var cell_size: Vector2
var map_manager
var map_info
var origin
var biome


func _init(
	_resource: Resource,
	_spawnable_tiles: Array,
	_spawn_rate: float,
	_max_count: int,
	_map_manager,
	_biome = null
):
	resource = _resource
	spawnable_tiles = _spawnable_tiles
	spawn_rate = _spawn_rate
	max_count = _max_count
	map_manager = _map_manager
	cell_size = map_manager.cell_size
	map_info = map_manager.map_info
	biome = _biome


func spawn(info: MapInfoItem, is_unlock) -> Node:
	var node = resource.instance()
	var size = node.size
	var spawnable = true

	for x in range(size.x):
		for y in range(size.y):
			var p = map_info.top_item(info.point + Vector2(x, y))
			if p == null:
				return null
			spawnable = spawnable and is_spawnable(p)

	if spawnable:
		var map_pos = info.tile.tile_map.map_to_world(info.point)
		node.global_position = cal_node_global_position(size.x, size.y, map_pos.x, map_pos.y)
		map_manager.ysort.add_child(node)
		current_count += 1
		if is_unlock:
			unlock_spawn_vfx(node)

		return node

	return null


func cal_node_global_position(size_x, size_y, x_0, y_0) -> Vector2:
	var d_x = cell_size.x / 2
	var d_y = cell_size.y / 2

	var z_1
	if size_x != size_y:
		z_1 = (max(size_x, size_y) * 2) - 1
	else:
		z_1 = max(size_x, size_y) * 2

	var x_1 = x_0 + (d_x * (size_x - size_y))
	var y_1 = y_0 + (d_y * z_1)

	var x = (x_1 + x_0) / 2
	var y = (y_1 + y_0) / 2

	return Vector2(x, y)


func is_spawnable(item: MapInfoItem):
	if item == null:
		return false
	var cond = (
		current_count < max_count
		and item.is_tile()
		and item.tile in spawnable_tiles
		and Utils.random_int(0, 100) <= spawn_rate * 100
	)
	if biome == null:
		return cond
	else:
		return cond and biome["noise_map"][item.point.x][item.point.y] > biome["threshold"]


func is_spawnable_without_rate(item: MapInfoItem):
	return current_count < max_count and item.is_tile() and item.tile in spawnable_tiles


func unlock_spawn_vfx(node):
	var tween = map_manager.fog_tween
	var duration = map_manager.map_unlock_vfx_duration
	var sprite = node.get_node_or_null("Sprite")
	if sprite != null:
		Utils.start_tween(
			tween,
			sprite,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			duration,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
