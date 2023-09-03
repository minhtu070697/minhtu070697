extends FarmDecorations

var direction: int
var default_sprite_name


func _init():
	sprite_names = {
		"edge": Vector2(1, 1),
		"edge_r": Vector2(1, 1),
		"edge_r_1": Vector2(1, 1),

		"edge_1": Vector2(1, 1),
		"edge_1_r": Vector2(1, 1),
		"edge_1_r_1": Vector2(1, 1),
	}
	sprite_build_positions = {
		"edge": Vector2(0, -14),
		"edge_r": Vector2(0, -14),
		"edge_r_1": Vector2(0, -14),

		"edge_1": Vector2(0, -14),
		"edge_1_r": Vector2(0, -14),
		"edge_1_r_1": Vector2(0, -14),
	}
	sprite_spawn_positions = {
		"edge": Vector2(0, -14),
		"edge_r": Vector2(0, -14),
		"edge_r_1": Vector2(0, -14),
		
		"edge_1": Vector2(0, -14),
		"edge_1_r": Vector2(0, -14),
		"edge_1_r_1": Vector2(0, -14),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	texture_file = "res://map/textures/objects/edge/%s.png"
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
		default_sprite_name = self.sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()
	else:
		if is_build:
			self.sprite_name = sprite_name
		else:
			self.sprite_name = sprite_name
		load_texture()
		load_sprite_position()


func rotate_all_directions(sprite_name):
	direction += 1
	if direction > 5:
		direction = 0
	match direction:
		0:
			self.sprite_name = sprite_name
			scale = Vector2.ONE
		1:
			self.sprite_name = sprite_name
			scale = Vector2(-1, 1)
		2:
			self.sprite_name = sprite_name + "_r_1"
			scale = Vector2.ONE
		3:
			self.sprite_name = sprite_name + "_r_1"
			scale = Vector2(-1, 1)
		4:
			self.sprite_name = sprite_name + "_r"
			scale = Vector2.ONE
		5:
			self.sprite_name = sprite_name + "_r"
			scale = Vector2(-1, 1)

	is_reload = false
	set_size()
	re_load(self.sprite_name, true)


func set_size():
	size = sprite_names[sprite_name]
