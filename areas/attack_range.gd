extends Area2D

onready var host: Enemy = get_parent()

# Private vars
var _disable_get_enemies: bool = false


func _ready() -> void:
	if host == null:
		queue_free()


func _on_AttackRange_body_entered(body: Node) -> void:
	if not Utils.node_exists(host.attack_target) and Utils.target_is_enemy(host, body):
		host.target_enemy(body, body.get_map_position())


func get_near_enemies() -> Array:
	if _disable_get_enemies:
		return []
	
	_disable_get_enemies = true
	get_tree().create_timer(2).connect("timeout", self, "_enable_get_enemies")
	
	var objs: Array = get_overlapping_bodies()
	var enemies: Array = []
	for obj in objs:
		if Utils.target_is_enemy(host, obj):
			enemies.append(obj)
	return enemies


func _enable_get_enemies() -> void:
	_disable_get_enemies = false
