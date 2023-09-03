extends Node2D

onready var sprite:Sprite = $Sprite
onready var animation_player:AnimationPlayer = $AnimationPlayer
onready var efx:Particles2D = $Particle

var size = Vector2(2, 2)

func _ready():
	set_random_scale()
	var delay: float = Utils.random_from_array(range((0.0 * 4), (6.0 * 4), (0.25 * 4))) / 4.0
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("water_bubble")

	# efx
	show_efx()

func show_efx():
	var delay_time = 2.25
	yield(Utils.start_coroutine(delay_time), "completed")
	efx.visible = true

func set_random_scale():
	var random = Utils.random_int(0, 1)
	if random == 0:
		self.scale = Vector2(0.4, 0.4)
	else:
		self.scale = Vector2(0.6, 0.6)
