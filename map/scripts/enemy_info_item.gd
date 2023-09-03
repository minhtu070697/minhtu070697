class_name EnemyInfoItem


var name: String
var position: Vector2
var enemy: Node
var size = Vector2(1, 1)
var point


func _init(_enemy) -> void:
	enemy = _enemy
	name = enemy.name
		


