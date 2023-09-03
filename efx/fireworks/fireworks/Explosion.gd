extends Node2D


export var color_set = -1 # -1 == random


onready var particles = $Particles


func _ready():
	particles.one_shot = true
	$AudioStreamPlayer.play()


func _process(_delta):
	if not particles.is_emitting():
		queue_free()
