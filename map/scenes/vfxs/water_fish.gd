extends Node2D

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

var size = Vector2(2, 2)
var delays = [
	0.0,
	0.25,
	0.5,
	0.75,
	1.0,
	1.25,
	1.5,
	1.75,
	2.0,
	2.25,
	2.5,
	2.75,
	3.0,
	3.25,
	3.5,
	3.75,
	4.0,
	4.25,
	4.5,
	4.75,
	5.0,
	5.25,
	5.5,
	5.75
]


func _ready():
	play_animation()


func play_animation():
	var delay = cal_delay_animation()
	yield(Utils.start_coroutine(delay), "completed")
	animation_player.play("water_fish")


func cal_delay_animation() -> int:
	return Utils.random_from_array(delays)
