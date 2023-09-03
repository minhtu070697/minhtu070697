extends ExploitResources


func _init():
	sprite_names = {
		"vase_1": Vector2(1, 1),
		"vase_2": Vector2(1, 1),
		"vase_3": Vector2(1, 1),
		"vase_4": Vector2(1, 1),
		"vase_5": Vector2(1, 1),
		"vase_6": Vector2(1, 1),
		"vase_7": Vector2(1, 1),
	}
	
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]
	texture_file = "res://map/textures/battlefield/%s.png"
	add_to_group("interactable_object")
	resource_type = Constants.ResourceType.BATTLE_VASE

func _ready():
	# load
	shadow_sprite.texture = Utils.load_resource(texture_file % shadow_sprite_name, "battle_vase_sd", shadow_sprite_name)

	# set generate position
	# ex: set y = 30% texture's height
	sprite.position = Utils.cal_object_sprite_generate_position(sprite, 30)
	shadow_sprite.position = sprite.position

	load_init_shader()

func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 5, 0)

func _on_animation_finished(animation_name):
	Utils.on_resource_animation_finished(get_node("."), animation_name, vfx_hit)

func _on_death(_host_name):
	if _host_name == name:
		animation_player.play("die")

# update: yield -> connect
func load_init_shader():
	sprite.material = load("res://efx/shader/dissolve_battle.tres")
	shadow_sprite.material = load("res://efx/shader/dissolve_battle.tres")

	var delay_time = 2.0
	yield(Utils.start_coroutine(delay_time), "completed")
	load_living_shader()

# update: yield -> connect
func load_living_shader():
	sprite.material = load("res://efx/shader/shining.tres")
	shadow_sprite.material = load("res://efx/shader/shining.tres")
