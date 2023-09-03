extends Node

class_name MapEnemyObject

# Constants
const MAX_TRY: int = 100

var resource: Resource
var spawnable_tiles: Array
var spawn_rate: float
var cell_size: Vector2
var map_info: MapInfo
var origin
var enemy_info: EnemyInfo
var base_max_count: int

# private vars
var _tried: int = 0


func _init(_resource: Resource, _spawnable_tiles: Array, _spawn_rate: float, _max_count: int, _enemy_info, spawn_freq: float = 1.0):
	resource = _resource
	spawnable_tiles = _spawnable_tiles
	spawn_rate = _spawn_rate
	cell_size = GameManager.map_manager.cell_size
	map_info = GameManager.map_manager.map_info
	enemy_info = _enemy_info
	base_max_count = _max_count
	enemy_info.monster_max_count = base_max_count * spawn_freq
	create_monster_list(spawn_freq)


func create_monster_list(spawn_freq: float = 1.0):
	for _monster_name in GameResourcesLibrary.monster_resources_list_json:
		var _monster = GameResourcesLibrary.monster_resources_list_json[_monster_name]
		var _monster_scene_path = Constants.MONSTER_SCENES_PATH % _monster.monster_name
		enemy_info.monster_count_list[_monster.monster_name] = [0, _monster.max_number_in_map * spawn_freq]
		enemy_info.monster_scene_list[_monster.monster_name] = load(_monster_scene_path) if ResourceLoader.exists(_monster_scene_path) else null


func update_monsters_max_quantity() -> void:
	for _monster_name in GameResourcesLibrary.monster_resources_list_json:
		var _monster = GameResourcesLibrary.monster_resources_list_json[_monster_name]
		enemy_info.monster_count_list[_monster.monster_name][1] = _monster.max_number_in_map * GameManager.enemy_manager.enemy_generator.cal_spawn_frequency()


func update_monsters_max_count() -> void:
	enemy_info.monster_max_count = base_max_count * GameManager.enemy_manager.enemy_generator.cal_spawn_frequency()


func select_monster_to_spawn() -> MonsterResources:
	return MonsterResources.new(GameResourcesLibrary.monster_resources_list_json[GameResourcesLibrary.monster_name_list[Utils.random_int(0, GameResourcesLibrary.monster_resources_list_json.size() - 1)]])
	

func spawn(info: MapInfoItem, _monster_lvl: int = 1) -> Array:
	#select monster info to be spawned
	var selected_monster: MonsterResources = select_monster_to_spawn()
	if enemy_info.monster_count_list[selected_monster.monster_name][0] >= enemy_info.monster_count_list[selected_monster.monster_name][1]:
		return []

	if enemy_info.monster_scene_list[selected_monster.monster_name] == null:
		return []

	return spawn_group_of_monster(selected_monster, info, _monster_lvl)


func spawn_group_of_monster(_selected_monster: MonsterResources, _info: MapInfoItem, _monster_lvl: int = 1) -> Array:
	var _monster_list: Array = []
	var size = _selected_monster.size
	spawn_monsters(_selected_monster, _info, _monster_list, size, _monster_lvl)
	return _monster_list


func spawn_monsters(_selected_monster: MonsterResources, _info: MapInfoItem, _monster_list: Array, _monster_size: Vector2, _monster_lvl: int = 1, _is_generate: bool = true, _spawn_num: int = 0, _spawned_num: int = 0) -> Array:
	var spawnable: bool = true
	
	if _info != null:
		for x in range(_monster_size.x):
			for y in range(_monster_size.y):
				var p = map_info.top_item(_info.point + Vector2(x, y))
				if p == null:
					return []
				spawnable = spawnable and is_spawnable_without_rate(p)
	else:
		spawnable = false
		
	if spawnable:
		#spawn monster
		if enemy_info.monster_count_list[_selected_monster.monster_name][0] >= enemy_info.monster_count_list[_selected_monster.monster_name][1] and _is_generate:
			return _monster_list

		_monster_list.append(spawn_monster(_selected_monster, _info, _monster_size, _monster_lvl))

		enemy_info.monster_count_list[_selected_monster.monster_name][0] += 1
		enemy_info.monster_total_count += 1
		_spawned_num += 1
		_tried = 0

		return _monster_list if _spawned_num == (_selected_monster.num_in_group if _spawn_num <= 0 else _spawn_num) else spawn_monsters(_selected_monster, pick_random_nearby_tile(_info), _monster_list, _monster_size, _monster_lvl, _is_generate, _spawn_num, _spawned_num)
	else:
		_tried += 1
		if _tried > MAX_TRY:
			_tried = 0
			return _monster_list
	
	return _monster_list if _spawned_num < (1 if _is_generate else -1) else spawn_monsters(_selected_monster, pick_random_nearby_tile(_info), _monster_list, _monster_size, _monster_lvl, _is_generate, _spawn_num, _spawned_num)


func spawn_monster(_selected_monster: MonsterResources, _info: MapInfoItem, _monster_size: Vector2, _monster_lvl: int = 1) -> Node:
	var node = enemy_info.monster_scene_list[_selected_monster.monster_name].instance()
	var map_pos = _info.tile.tile_map.map_to_world(_info.point)
	node.global_position = cal_node_global_position(_monster_size.x, _monster_size.y, map_pos.x, map_pos.y)
	node.lvl = _monster_lvl
	node.monster_name = _selected_monster.monster_name
	add_monster_to_map(node)

	return node


func spawn_monsters_at_position(_monster_name: String, _spawn_map_position: Vector2, _monster_lvl: int = 1, _spawn_num: int = 0) -> Array:
	var _tile_info: MapInfoItem = map_info.last_item(_spawn_map_position)
	var _monster_info: MonsterResources = MonsterGenerator.new(_monster_name).monster_info
	var _spawned_monsters: Array = []
	_spawned_monsters = spawn_monsters(_monster_info, _tile_info, _spawned_monsters, _monster_info.size, _monster_lvl, false, _spawn_num)

	return _spawned_monsters


func add_monster_to_map(_node) -> void:
	_node.visible = false
	GameManager.map_manager.ysort.add_child(_node)
	_node.visible = true


func pick_random_nearby_tile(_info: MapInfoItem) -> MapInfoItem:
	return map_info.last_item(Vector2(
		Utils.clamp_int(_info.point.x + Utils.random_int(-2,2), GameManager.map_manager.xrange.x, GameManager.map_manager.xrange.y - 1),
		Utils.clamp_int(_info.point.y + Utils.random_int(-2,2), GameManager.map_manager.yrange.x, GameManager.map_manager.yrange.y - 1)
		))


func cal_node_global_position(size_x, size_y, x_0, y_0) -> Vector2:
	var d_x = cell_size.x / 2
	var d_y = cell_size.y / 2

	var z_1
	if (size_x != size_y):
		z_1 = (max(size_x, size_y) * 2) - 1
	else:
		z_1 = max(size_x, size_y) * 2

	var x_1 = x_0 + (d_x * (size_x - size_y))
	var y_1 = y_0 + (d_y * z_1)

	var x = (x_1 + x_0) / 2
	var y = (y_1 + y_0) / 2

	return Vector2(x, y)


func spawn_multiple_tile():
	pass


func is_spawnable():
	return (
		Utils.random_int(0, 1000) <= spawn_rate * 1000
	)


func is_spawnable_without_rate(item: MapInfoItem):
	return (
		#check if this monster has exceed max_count?
		item.is_tile()
		and item.tile in spawnable_tiles
	)


