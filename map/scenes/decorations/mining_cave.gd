extends FarmDecorations

onready var collision_area_mining_cave: Area2D = $Sprite/Area2D
onready var pointer = $Sprite/Pointer

var faded: bool = false


func _init():
	sprite_names = {
		"mining_cave": Vector2(9, 9),
	}
	sprite_build_positions = {
		"mining_cave": Vector2(0, -50),
	}
	sprite_spawn_positions = {
		"mining_cave": Vector2(0, -50)
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	texture_file = "res://map/textures/objects/caves/%s.png"
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


func fade(is_out:bool):
	if is_out:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.4, 0.15)
	else:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.4, 1, 0.15)
	faded = is_out


func _on_Area2D_body_entered(body):
	if Utils.is_character_enter_collision(body):
		if !faded:
			fade(true)
		# ex: show mining cave button
		body.ui_manager.visible_button_mining_cave(true)


func _on_Area2D_body_exited(body):
	if Utils.is_character_enter_collision(body):
		if !collision_area_mining_cave.get_overlapping_bodies().size():
			fade(false)
		# ex: hide mining cave button
		body.ui_manager.visible_button_mining_cave(false)
