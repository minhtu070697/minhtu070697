extends Node

class_name EnemyGenerator

var enemy_manager  # EnemyManager
var enemy_info: EnemyInfo
var enemy_object: MapEnemyObject
var spawn_freq: float = 0.0


func _init(_enemy_manager):
	enemy_manager = _enemy_manager
	enemy_info = enemy_manager.enemy_info
	spawn_freq = cal_spawn_frequency()

	#load enemy object
	enemy_object = MapEnemyObject.new(
		load(Constants.ENEMY_SCENE_PATH),
		[GameManager.map_manager.earth_tile, GameManager.map_manager.dark_grass_tile, GameManager.map_manager.ground_tile],
		0.004,
		20,
		enemy_info,
		spawn_freq
	)


func generate_enemy():
	fill_enemies()


# demo fil enemies (fill at farm map)
func fill_enemies():
	var list_map_positions = GameManager.map_manager.list_map_positions
	for i in list_map_positions.size():
		if i != 0:
			fill_enemies_in_land(i)


func fill_enemies_in_land(land_id: int) -> void:
	var list_map_positions = GameManager.map_manager.list_map_positions
	var map_pos: Vector2 = list_map_positions[land_id]
	fill_enemies_in_land_pos(map_pos)


func fill_enemies_in_land_pos(land_pos: Vector2) -> void:
	enemy_object.update_monsters_max_quantity()
	enemy_object.update_monsters_max_count()
	var xrange_temp = Utils.cal_xrange(land_pos, GameManager.map_manager.size)
	var yrange_temp = Utils.cal_yrange(land_pos, GameManager.map_manager.size)
	for x in range(xrange_temp.x, xrange_temp.y):
		for y in range(yrange_temp.x, yrange_temp.y):
			if enemy_info.monster_total_count >= enemy_info.monster_max_count:
				return
			var info = GameManager.map_manager.map_info.last_item(Vector2(x, y))
			if enemy_object.is_spawnable():
				var spawned_enemies: Array = fill_rate(info)
				for enemy in spawned_enemies:
					GameManager.map_manager.ysort.nogias_insert(enemy)
					# enemy.update_sort_position(true)


func fill_rate(info) -> Array:
	var spawned_enemies: Array = enemy_object.spawn(info, GameManager.get_current_char_lvl() + 5)
	enemy_info.append_enemy(spawned_enemies)
	return spawned_enemies


func spawn_monsters(_monster_name: String, _spawn_map_position: Vector2, _monster_lvl: int = 1, _spawn_num: int = 0) -> Array:
	var spawned_enemies: Array = enemy_object.spawn_monsters_at_position(_monster_name, _spawn_map_position, _monster_lvl, _spawn_num)
	enemy_info.append_enemy(spawned_enemies)

	for enemy in spawned_enemies:
		GameManager.map_manager.ysort.nogias_insert(enemy)
		enemy.update_sort_position(true)
	
	return spawned_enemies


func cal_spawn_frequency() -> float:
	var _size: float = GameManager.map_manager.size # ex: 48
	var default_size: float = 16.0 # ex: 48 / 3 = 16
	return pow(_size / default_size, 1.5) * GameManager.map_manager.list_map_positions.size()
