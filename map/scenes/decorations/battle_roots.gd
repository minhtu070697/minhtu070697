extends StaticObjects


func _init():
	sprite_names = {
		"roots_1": Vector2(3, 2),
		"roots_2": Vector2(2, 1),
		"roots_3": Vector2(3, 2),
		"roots_4": Vector2(4, 2),
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
	# ex: set y = 20% texture's height
	sprite.position = Utils.cal_object_sprite_generate_position(sprite, 20)
	shadow_sprite.position = sprite.position
