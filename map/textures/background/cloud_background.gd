extends Node2D

export var clound_speed = 50

func _process(delta):
	position.x -= delta * clound_speed
	if position.x <= -5000:
		position.x = 5000
