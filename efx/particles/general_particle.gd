extends Node2D

onready var particle = $Particles
onready var particle_1 = $Particles_1
onready var timer = $Timer
onready var tween = $Tween

var particles = []

func _ready():
	particles.append(particle)
	particles.append(particle_1)

func auto_emitting(index):
	particles[index].visible = true
	particles[index].emitting = true

func auto_queuefree(index):
	var delay = particles[index].lifetime
	timer.start(delay)
	yield(timer, "timeout")
	self.queue_free()
