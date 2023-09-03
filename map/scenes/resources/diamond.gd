extends ExploitResources


var is_building:bool

func _init():
	sprite_names = {
		"diamond_1" : Vector2(2, 2),
	}
	resource_name_by_sprite = {
		"diamond_1" : "diamond",
	}
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]
	texture_file = "res://map/textures/objects/mine/%s.png"

func _ready():
	shadow_sprite.texture = load("res://map/textures/objects/mine/" + shadow_sprite_name + ".png")
	scale = Utils.random_resource_scale_x(sprite_names[sprite_name])

func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 5, 0)

func _on_Area2D_body_entered(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)

func _on_Area2D_body_exited(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)
