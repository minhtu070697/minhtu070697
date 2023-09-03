extends Node2D

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

var size = Vector2(1, 1)


func _ready():
	play_animation()


func play_animation():
	var delay: float = Utils.random_from_array(range(0.0 * 4, 6.0 * 4, 0.25 * 4)) / 4.0
	yield(Utils.start_coroutine(delay), "completed")
	animation_player.play("water_bubble")
