extends AboveDecorations


func _init():
	sprite_names = {
		"chess": Vector2(2, 2),
	}
	sprite_positions = {
		"chess": Vector2(0, -22),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]
	height_point = 5

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

func _on_Area2D_body_entered(body):
	fade(body, true)

func _on_Area2D_body_exited(body):
	fade(body, false)
