extends StaticObjects

onready var efx:Particles2D = $ParticleRare


func _init():
	sprite_names = {
		"bones_1": Vector2(1, 1),
		"bones_2": Vector2(1, 1),
		"bones_3": Vector2(4, 2),
		"bones_4": Vector2(4, 2),
		"bones_5": Vector2(2, 2),
		"bones_6": Vector2(1, 1),
		"bones_7": Vector2(1, 1),
		"bones_8": Vector2(1, 1),

		"broken_1": Vector2(1, 1),
		"broken_2": Vector2(1, 1),

		"cart_1": Vector2(4, 3) ,
		"cart_2": Vector2(2, 2),
		"cart_3": Vector2(2, 2),
		"cartwheel_1": Vector2(1, 1),
		"cartwheel_2": Vector2(1, 1),

		"statue_1": Vector2(1, 1),
		"statue_2": Vector2(1, 1),
		"statue_3": Vector2(1, 1),
		"statue_4": Vector2(1, 1),

		"stone_1": Vector2(2, 2),
		"stone_2": Vector2(2, 2),
		"stone_3": Vector2(2, 2),
		"stone_4": Vector2(1, 1),
		"stone_5": Vector2(1, 1),
		"stone_6": Vector2(1, 1),
		"stone_7": Vector2(1, 1),
		"stone_8": Vector2(1, 1),
		"stone_9": Vector2(1, 1),

		"torch_default": Vector2(1, 1),

		"mushrooms_1": Vector2(1, 1),
		"mushrooms_2": Vector2(1, 1),
		"mushrooms_3": Vector2(1, 1),
		"mushrooms_4": Vector2(1, 1),
	}
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]

func _ready():
	# load
	texture_file = "res://map/textures/battlefield/%s.png"

	sprite.texture = load(texture_file % sprite_name)
	shadow_sprite.texture = load(texture_file % shadow_sprite_name)

	# set generate position
	# ex: set y = 35% texture's height
	sprite.position = Utils.cal_object_sprite_generate_position(sprite, 35)
	shadow_sprite.position = sprite.position
	efx.position = sprite.position

	# efx
	check_show_efx()

# update: yield -> connect
func check_show_efx():
	var delay_time = 2.25
	yield(Utils.start_coroutine(delay_time), "completed")
	show_efx()
	
# update: yield -> connect
func show_efx():
	var real_sprite_name = sprite_name
	real_sprite_name.erase(real_sprite_name.length() - 2, 2)
	if real_sprite_name == "stone" or real_sprite_name == "torch" or real_sprite_name == "statue":
		efx.visible = true
