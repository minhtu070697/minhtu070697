extends StaticObjects


func _init():
	sprite_names = {
		"thuja_1": Vector2(1, 1),
		"thuja_2": Vector2(1, 1),
		"thuja_3": Vector2(1, 1),
		"thuja_4": Vector2(1, 1),
		"thuja_5": Vector2(1, 1),
		"thuja_6": Vector2(1, 1),
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
	# ex: set y = 40% texture's height
	sprite.position = Utils.cal_object_sprite_generate_position(sprite, 40)
	shadow_sprite.position = sprite.position

func _on_Area2D_body_entered(body):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)

func _on_Area2D_body_exited(body):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)
