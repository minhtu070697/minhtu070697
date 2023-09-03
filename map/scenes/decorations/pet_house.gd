extends FarmDecorations


func _init():
	sprite_names = {
		"pet_house": Vector2(1, 1),
	}
	sprite_build_positions = {
		"pet_house": Vector2(0, -9),
	}
	sprite_spawn_positions = {
		"pet_house": Vector2(0, -9),
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
