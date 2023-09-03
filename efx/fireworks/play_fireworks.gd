extends Node2D


var random_next_fountain_timer = 0
var orchestration_array = []
var orchestration_index = 0
var count = 0
export(int) var max_count = 5
export(float) var delay = 0.1


onready var timer = $Timer
onready var xrange = Utils.random_int(-300, 300)
onready var yrange = get_viewport().size.y / 2


func _ready():
	timer.wait_time = 0.1
	play()


func _on_Timer_timeout():
	play()


func play():
	if count < max_count:
		var new_rocket = load("res://efx/fireworks/fireworks/Rocket.tscn").instance()
		xrange = Utils.random_int(-300, 300)
		new_rocket.position = Vector2(rand_range(xrange / 10, xrange * 9 / 10), yrange)
		add_child(new_rocket)
		count += 1

		timer.wait_time = delay
		timer.start()
