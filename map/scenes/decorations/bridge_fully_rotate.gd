extends FarmDecorations

var collisions = []
var direction:int
var default_sprite_name


func _init():
	sprite_names = {
		"bridge_1": Vector2(2, 4),
		"bridge_1_r": Vector2(2, 4),
		"bridge_2": Vector2(2, 4),
		"bridge_2_r": Vector2(2, 4),
	}
	sprite_build_positions = {
		"bridge_1": Vector2(0, 2),
		"bridge_1_r": Vector2(0, 2),
		"bridge_2": Vector2(0, 0),
		"bridge_2_r": Vector2(0, 0),
	}
	sprite_spawn_positions = {
		"bridge_1": Vector2(0, 2),
		"bridge_1_r": Vector2(0, 2),
		"bridge_2": Vector2(0, 0),
		"bridge_2_r": Vector2(0, 0),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]
	direction = 0

func _ready():
	load_texture()
	load_sprite_position()
	append_collisions()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")

func append_collisions():
	collisions.append(collision)

func disable_collisions():
	for i in range(collisions.size()):
		collisions[i].disabled = true

func enable_collisions():
	for i in range(collisions.size()):
		collisions[i].disabled = false

func load_texture():
	texture_file = "res://map/textures/objects/bridge/%s.png"
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
			scale = Vector2.ONE
		3: 
			self.sprite_name = sprite_name + "_r"
			scale = Vector2(-1, 1)
		
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
		2:	size = size_temp
		3:	
			size_temp = sprite_names[sprite_name]
			size = Vector2(size_temp.y, size_temp.x)
