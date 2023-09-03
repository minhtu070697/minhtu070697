extends FarmDecorations


func _init():
	sprite_names = {
		"flower_1": Vector2(1, 1),
		"flower_2": Vector2(1, 1),
	}
	sprite_build_positions = {
		"flower_1": Vector2(0, 0),
		"flower_2": Vector2(0, -7),
	}
	sprite_spawn_positions = {
		"flower_1": Vector2(0, 0),
		"flower_2": Vector2(0, -7),
	}
	
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]

func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")
	
func load_texture():
	texture_file = "res://map/textures/objects/flowers/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "flower_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]

func load_sprite_position():
	if is_reload:
		sprite.position = sprite_build_positions[sprite_name]
	else:
		sprite.position = sprite_spawn_positions[sprite_name]

func re_load(sprite_name, is_build):
	if is_reload:
		if is_build:
			self.sprite_name = Utils.random_from_dict(sprite_names)
		else:
			self.sprite_name = sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()
