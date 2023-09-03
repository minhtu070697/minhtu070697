extends BaseDecorations

onready var collision_beds = $Sprite/Area2D/CollisionPolygon2D

var direction:int
var default_sprite_name


func _init():
	sprite_names = {
		"bed": Vector2(2, 3),
		"bed_r": Vector2(3, 2),
		"bed_1": Vector2(3, 3),
		"bed_1_r": Vector2(3, 3)
	}
	sprite_positions = {
		"bed": Vector2(0, -16),
		"bed_r": Vector2(0, -11),
		"bed_1": Vector2(0, -16),
		"bed_1_r": Vector2(0, -12)
	}
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]
	direction = 0

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
		default_sprite_name = self.sprite_name
		load_texture()
		disable_collisions()
		enable_collisions()
	else:
		if is_build:
			self.sprite_name = sprite_name
		else:
			self.sprite_name = sprite_name
		load_texture()
		disable_collisions()
		enable_collisions()

func rotate_all_directions(sprite_name):
	direction += 1
	if direction > 3: direction = 0
	match direction:
		0: 
			self.sprite_name = sprite_name
			scale = Vector2.ONE
		1: 
			self.sprite_name = sprite_name 
			scale = Vector2(-1, 1)
		2: 
			self.sprite_name = sprite_name + "_r"
			scale = Vector2(-1, 1)
		3: 
			self.sprite_name = sprite_name + "_r"
			scale = Vector2.ONE
		
	is_reload = false
	set_size()
	re_load(self.sprite_name, true)

func set_size():
	var size_temp = sprite_names[sprite_name] 
	if size_temp == Vector2.ONE: return size == size_temp
	match direction: 
		0:	size = size_temp 
		1: 
			size_temp = sprite_names[sprite_name]
			size = Vector2(size_temp.y, size_temp.x)
		2: 
			size_temp = sprite_names[sprite_name]
			size = Vector2(size_temp.y, size_temp.x)
		3:	size = size_temp

func append_collisions():
	collisions.append(collision_beds)
		
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
