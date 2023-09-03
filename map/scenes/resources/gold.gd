extends ExploitResources

onready var efx = $Particle

var sprite_build_positions = {
	"gold_1": Vector2(0, -65),
}
var sprite_spawn_positions = {
	"gold_1": Vector2(0, -53),
}

#sprite height is the height from bottom of sprite go to the top of sprite texture
#sprite width is cal from middle of sprite to farthest left point of sprite texture
var sprite_sizes = {
	"gold_1": Vector2(0, 59),
}

var is_building:bool


func _init():
	sprite_names = {
		"gold_1" : Vector2(2, 2),
	}
	resource_name_by_sprite = {
		"gold_1" : "gold",
	}
	texture_file = "res://map/textures/objects/mine/%s.png"
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]
	sprite_size = sprite_sizes[self.sprite_name]
	resource_type = Constants.ResourceType.GOLD

func _ready():
	load_texture()
	load_sprite_position()
	check_show_efx()

func load_texture():
	texture_file = "res://map/textures/objects/mine/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "gold_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]
	shadow_sprite.texture = Utils.load_resource(texture_file % shadow_sprite_name, "gold_sd", shadow_sprite_name)
	scale = Utils.random_resource_scale_x(sprite_names[sprite_name])

func load_sprite_position():
	if is_reload:
		sprite.position = sprite_build_positions[sprite_name]
		shadow_sprite.position = sprite.position
	else:
		sprite.position = sprite_spawn_positions[sprite_name]
		shadow_sprite.position = sprite.position

func re_load(sprite_name, is_build):
	if is_reload:
		if is_build:
			self.sprite_name = Utils.random_from_dict(sprite_names)
		else:
			self.sprite_name = sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()
		sprite_size = sprite_sizes[self.sprite_name]
		resource_name = get_resource_name_by_sprite()

func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 5, 0)


# update: yield -> connect
func check_show_efx():
	if not is_building:
		var delay_time = 2.25
		yield(Utils.start_coroutine(delay_time), "completed")
		show_efx()

# update: yield -> connect
func show_efx():
	if self != null:
		efx.visible = true

func _on_Area2D_body_entered(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)

func _on_Area2D_body_exited(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)
