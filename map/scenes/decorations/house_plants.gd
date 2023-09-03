extends BaseDecorations


func _init():
	sprite_names = {
		"house_plants": Vector2(1, 1),
	}
	sprite_positions = {
		"house_plants": Vector2(0, -17),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]

func _ready():
	load_texture()
	append_collisions()
	enable_collisions()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")
	
func load_texture():
	texture_file = "res://map/textures/objects/decors/%s.png"
	sprite.texture = load(texture_file % sprite_name)
	sprite.position = sprite_positions[sprite_name]

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

func _on_Area2D_body_exited(body:Node):
	fade(body, false)

func _on_Area2D_body_entered(body:Node):
	fade(body, true)
