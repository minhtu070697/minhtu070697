extends BaseDecorations

onready var collision_wall = $Sprite/Area2D/CollisionPolygon2D
onready var blue_light = $Sprite/BlueLight

var sprite_rotate: Dictionary = {}
var direction: int = 0

func _init():
	sprite_names = {
		"wall": Vector2(2, 1),
		"wall_1": Vector2(1, 1),
		"wall_2": Vector2(2, 1),
		"wall_3": Vector2(2, 1),
		"wall_4": Vector2(1, 1),
		"wall_5": Vector2(2, 1),
		"wall_6": Vector2(2, 1),
		"wall_7": Vector2(1, 1),
	}
	sprite_positions = {
		"wall": Vector2(0, -25),
		"wall_1": Vector2(0, -32),
		"wall_2": Vector2(0, -30),
		"wall_3": Vector2(0, -25),
		"wall_4": Vector2(0, -32),
		"wall_5": Vector2(0, -30),
		"wall_6": Vector2(0, -25),
		"wall_7": Vector2(0, -32),
	}
	sprite_rotate = {
		"wall_6": ["_2_r", "_2_d", "_2_u", "_3_dr", "_3_ur", "_4"]
	}
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	append_collisions()
	enable_collisions()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture(_sprite_name: String = sprite_name):
	texture_file = "res://map/textures/objects/walls/%s.png"
	sprite.texture = Utils.load_resource(texture_file % _sprite_name, "wall_texture", _sprite_name)
	sprite.position = sprite_positions[_sprite_name]

	disable_efx()
	enable_efx()


func re_load(sprite_name, is_build):
	if is_reload:
		if is_build:
			self.sprite_name = sprite_name
		else:
			self.sprite_name = sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		disable_collisions()
		enable_collisions()


func append_collisions():
	collisions.append(collision)


func enable_collisions():
	for i in range(collisions.size()):
		if i == 0:
			collisions[i].disabled = false
		else:
			collisions[i].disabled = true


func _on_Area2D_body_entered(body):
	fade(body, true)


func _on_Area2D_body_exited(body):
	fade(body, false)


func disable_efx():
	blue_light.visible = false


func enable_efx():
	if sprite_name == "wall_7":
		blue_light.visible = true


#region: obj rotation
#lam tiep tai day, xoay theo array
# func rotate_all_direction(_sprite_name) -> void:
# 	pass


# func get_next_rotated_sprite() -> String:
# 	return ""


# func get_next_rotated_scale(_sprite_name: String, _scale: Vector2) -> Vector2:
# 	if _sprite_name.ends_with("r"):
# 		pass
# 	return Vector2.ZERO
#endregion
