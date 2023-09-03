extends FarmDecorations

onready var yellow_light = $Sprite/YellowLight
onready var green_light = $Sprite/GreenLight
onready var blue_light = $Sprite/BlueLight
onready var pink_light = $Sprite/PinkLight
onready var purple_light = $Sprite/PurpleLight


func _init():
	sprite_names = {
		"torch": Vector2(1, 1),
		"torch_1": Vector2(1, 1),
		"torch_2": Vector2(1, 1),
		"torch_3": Vector2(1, 1),
		"torch_4": Vector2(1, 1),
	}
	sprite_build_positions = {
		"torch": Vector2(0, -17),
		"torch_1": Vector2(0, -17),
		"torch_2": Vector2(0, -17),
		"torch_3": Vector2(0, -17),
		"torch_4": Vector2(0, -17),
	}
	sprite_spawn_positions = {
		"torch": Vector2(0, -17),
		"torch_1": Vector2(0, -17),
		"torch_2": Vector2(0, -17),
		"torch_3": Vector2(0, -17),
		"torch_4": Vector2(0, -17),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	texture_file = "res://map/textures/objects/decors/%s.png"
	sprite.texture = load(texture_file % sprite_name)
	sprite.position = sprite_build_positions[sprite_name]
	disable_lights()
	enable_lights()


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


func disable_lights():
	yellow_light.visible = false
	green_light.visible = false
	blue_light.visible = false
	pink_light.visible = false
	purple_light.visible = false


func enable_lights():
	if sprite_name == "torch":
		yellow_light.visible = true
	elif sprite_name == "torch_1":
		green_light.visible = true
	elif sprite_name == "torch_2":
		blue_light.visible = true
	elif sprite_name == "torch_3":
		pink_light.visible = true
	elif sprite_name == "torch_4":
		purple_light.visible = true
