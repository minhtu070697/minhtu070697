extends Node

class_name EnemyManager

var enemy_generator: EnemyGenerator
var enemy_info: EnemyInfo


func _init():
	enemy_info = EnemyInfo.new(self)
	enemy_generator = EnemyGenerator.new(self)


func generate_enemies() -> void:
	enemy_generator.generate_enemy()
