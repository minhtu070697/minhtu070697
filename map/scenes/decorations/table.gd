extends BelowDecorations

onready var collision_table = $Sprite/Area2D_Table/CollisionPolygon2D
onready var collision_table_1 = $Sprite/Area2D_Table_1/CollisionPolygon2D


func _init():
	sprite_names = {
		"table": Vector2(1, 1),
		"table_1": Vector2(2, 3),
		"table_2": Vector2(2, 3),
		"table_billiards": Vector2(2, 3)
	}
	sprite_positions = {
		"table": Vector2(0, -11),
		"table_1": Vector2(0, -8),
		"table_2": Vector2(0, -8),
		"table_billiards": Vector2(0, -10),
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
	collisions.append_array([collision_table, collision_table_1])
		
func enable_collisions():
	if sprite_name == "table":
		for i in range(collisions.size()):
			if i == 0:
				collisions[i].disabled = false
				set_obj_main_collision(collisions[i])
			else:
				collisions[i].disabled = true
		return
	else:
		for i in range(collisions.size()):
			if i == 1:
				collisions[i].disabled = false
				set_obj_main_collision(collisions[i])
			else:
				collisions[i].disabled = true
		return

func _on_Area2D_Table_body_entered(body):
	fade(body, true)

func _on_Area2D_Table_body_exited(body):
	fade(body, false)

func _on_Area2D_Table_1_body_entered(body):
	fade(body, true)

func _on_Area2D_Table_1_body_exited(body):
	fade(body, false)
