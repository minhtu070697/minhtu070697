extends Node
class_name EnemyInfo

var data: Dictionary = {}
var enemy_manager

#dictionary of monsters_name : [current_count, max_count]
var monster_count_list = {}
var monster_scene_list = {}
var monster_total_count: int = 0
var monster_max_count: int = 0


func _init(_enemy_manager):
	enemy_manager = _enemy_manager


func append_item(_enemy: EnemyInfoItem):
	data[_enemy.name] = _enemy


func append_enemy(_enemies: Array):
	if _enemies == []:
		return
	
	for _enemy in _enemies:
		var _item = EnemyInfoItem.new(_enemy)
		append_item(_item)


func pop_item(_enemy_name):
	data.erase(_enemy_name)


func get_item(_enemy_name) -> EnemyInfoItem:
	# get the full stack at position x,y
	return data[_enemy_name] if data.has[_enemy_name] else null


func remove_enemy(_enemy_name: String, _size: Vector2, _position: Vector2):
	remove_disabled_points(_enemy_name, _size, _position)
	pop_item(_enemy_name)
	if data.size() == 0:
		# khi danh het quai tren map se kich hoat
		pass

	if data.empty():
		monster_total_count = 0
		for _monster_name in monster_count_list:
			monster_count_list[_monster_name][0] = 0
		# enemy_manager.enemy_generator.generate_enemy()


func remove_disabled_points(_enemy_name: String, _size: Vector2, _position: Vector2):
	var _enemy_point: Vector2
	for x in range(_size.x):
		for y in range(_size.y):
			_enemy_point = _position + Vector2(x, y)
			GameManager.map_manager.map_navigator.set_point_disabled(GameManager.map_manager.map_navigator.point_to_index(_enemy_point), false)
