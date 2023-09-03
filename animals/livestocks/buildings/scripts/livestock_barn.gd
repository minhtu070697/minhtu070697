extends FarmDecorations
class_name LivestockBarn

onready var livestock_barn_controller: LivestockBarnController = $LivestockBarnController
onready var animation_player = $AnimationPlayer
onready var collision_livestockbarn = $Sprite/Area2D_LiveStockBarn/CollisionPolygon2D
onready var collision_area_livestockbarn = $Sprite/Area2D_LiveStockBarn

const LIVESTOCK_BARN_SPRITE_PATH: String = "res://animals/livestocks/buildings/textures/%s/%s.png"

var collisions = []
var resource_type: int = Constants.ResourceType.LIVESTOCK_BARN
var faded: bool = false


func _init():
	sprite_names = {
		"cow_barn": Vector2(6, 5),
	}
	sprite_build_positions = {
		"cow_barn": Vector2(0, -67),
	}
	sprite_spawn_positions = { 
		"cow_barn": Vector2(0, -67),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	# load_texture()
	load_sprite_position()
	append_collisions()
	enable_collisions()
	set_obj_main_collision(collision_livestockbarn)
	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	sprite.texture = Utils.load_resource(LIVESTOCK_BARN_SPRITE_PATH % [sprite_name, sprite_name], sprite_name, "sprite")
	sprite.position = sprite_build_positions[sprite_name]

func load_sprite_position():
	if is_reload:
		sprite.position = sprite_build_positions[sprite_name]
	else:
		sprite.position = sprite_spawn_positions[sprite_name]

func re_load(_barn_name: String, _is_build):
	if is_reload:
		sprite_name = Utils.random_from_dict(sprite_names)
		size = sprite_names[sprite_name]
		load_texture()
		load_sprite_position()
		disable_collisions()
		enable_collisions()

func append_collisions():
	collisions.append(collision_livestockbarn)

func enable_collisions():
	collisions[0].disabled = false

func disable_collisions():
	collisions[0].disabled = true

func fade(is_out:bool):
	if is_out:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)
	else:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)

	faded = is_out

func _on_Area2D_LiveStockBarn_body_entered(_body: Node) -> void:
	if not faded and Utils.is_character_enter_collision(_body):
		fade(true)

func _on_Area2D_LiveStockBarn_body_exited(_body: Node) -> void:
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)

func on_mouse_right_click() -> void:
	livestock_barn_controller.on_mouse_right_click()

func remove_barn() -> void:
	SignalManager.emit_signal("update_overlap_bodies", self)
	livestock_barn_controller.remove_barn()
