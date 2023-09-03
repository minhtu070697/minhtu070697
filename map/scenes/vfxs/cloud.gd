extends Node2D

onready var sprite = $Sprite
onready var tween = $Tween

var left = Vector2.ZERO
var right = Vector2.ZERO

func _ready():
	left = GameManager.map_manager.map_navigator.point_to_world(Utils.cal_xrange(Vector2(0, 2), GameManager.map_manager.size)).x
	right = GameManager.map_manager.map_navigator.point_to_world(Utils.cal_xrange(Vector2(2, 0), GameManager.map_manager.size)).y
	on_tweening()


func on_tweening():
	if tween.is_inside_tree():
		Utils.start_tween(tween, self, "position", self.position, get_destination(), get_duration(), Tween.TRANS_LINEAR)
		yield(tween, "tween_completed")
		on_tweening()
	

func get_duration() -> int:
	return Utils.random_int(90, 120)


func get_destination() -> Vector2:
	if self.position.x > 0:
		return Vector2(left, self.position.y)
	else: 
		return Vector2(right, self.position.y)
