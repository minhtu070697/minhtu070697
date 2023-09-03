extends ExploitResources

onready var other_detect = $Area2D/OtherDetect
onready var log_detect = $Area2D/LogDetect

var sprite_build_positions = {
	"barrel_1": Vector2(0, -10),
	"barrel_2": Vector2(0, -10),
	"chest": Vector2(0, -10),
	"crate_1": Vector2(0, -10),
	"crate_2": Vector2(0, -10),
	"crate_3": Vector2(0, -10),
	"big_stump": Vector2(0, -22),
	"stump": Vector2(0, -7),
	"log": Vector2(0, -15),
}
var sprite_spawn_positions = {
	"barrel_1": Vector2(0, -10),
	"barrel_2": Vector2(0, -10),
	"chest": Vector2(0, -10),
	"crate_1": Vector2(0, -10),
	"crate_2": Vector2(0, -10),
	"crate_3": Vector2(0, -10),
	"big_stump": Vector2(0, -10),
	"stump": Vector2(0, -7),
	"log": Vector2(0, -10),
}


func _init():
	sprite_names = {
		"barrel_1": Vector2(1, 1),
		"barrel_2": Vector2(1, 1),
		"chest": Vector2(1, 1),
		"crate_1": Vector2(1, 1),
		"crate_2": Vector2(1, 1),
		"crate_3": Vector2(1, 1),
		"big_stump": Vector2(2, 2),
		"stump": Vector2(1, 1),
		"log": Vector2(3, 1),
	}
	resource_name_by_sprite = {
		"barrel_1": "barrel",
		"barrel_2": "barrel",
		"chest": "chest",
		"crate_1": "chest",
		"crate_2": "chest",
		"crate_3": "chest",
		"big_stump": "tree",
		"stump": "tree",
		"log": "tree",
	}
	
	texture_file = "res://map/textures/objects/other/%s.png"
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]
	resource_type = Constants.ResourceType.OTHER

func _ready():
	load_texture()
	load_sprite_position()
	enable_transparent_dectect()

func load_texture():
	texture_file = "res://map/textures/objects/other/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "other_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]
	shadow_sprite.texture = Utils.load_resource(texture_file % shadow_sprite_name, "other_sd", shadow_sprite_name)
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
		shadow_sprite_name = self.sprite_name + "_sh"
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()
		enable_transparent_dectect()
		resource_name = get_resource_name_by_sprite()

func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 10, 0)


func enable_transparent_dectect():
	if sprite_name == "log":
		log_detect.disabled = false
		set_obj_main_collision(log_detect)
		other_detect.disabled = true
	else:
		other_detect.disabled = false
		set_obj_main_collision(other_detect)
		log_detect.disabled = true

func _on_Area2D_body_entered(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)

func _on_Area2D_body_exited(body:Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)
