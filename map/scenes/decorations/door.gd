extends FarmDecorations


func _init():
	sprite_names = {
		"door": Vector2(3, 1),
	}
	sprite_build_positions = {
		"door": Vector2(0, -45),
	}
	sprite_spawn_positions = {
		"door": Vector2(0, -45),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	texture_file = "res://map/textures/objects/doors/%s.png"
	sprite.texture = load(texture_file % sprite_name)
	sprite.position = sprite_build_positions[sprite_name]


func load_sprite_position():
	if is_reload:
		sprite.position = sprite_build_positions[sprite_name]
	else:
		sprite.position = sprite_spawn_positions[sprite_name]


func re_load(sprite_name, is_build):
	if is_reload:
		if is_build:
			self.sprite_name = sprite_name
		else:
			self.sprite_name = sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()


func fade(body, is_out: bool):
	if body.get_name() == "Character":
		if is_out:
			Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.4, 0.15)
		else:
			Utils.transparent_object_between_camera_and_player(sprite, tween, 0.4, 1, 0.15)


func _on_Area2D_body_entered(body):
	fade(body, true)


func _on_Area2D_body_exited(body):
	fade(body, false)
