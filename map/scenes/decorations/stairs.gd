extends Node2D

onready var sprite:Sprite = $Sprite
onready var group_btn_remove = $GroupButtonRemove
onready var btn_remove = $GroupButtonRemove/ButtonRemove

var texture_file
var sprite_name
var sprite_names = {
	"stairs": Vector2(2, 4),
}
var sprite_build_positions = {
	"stairs": Vector2(0, -7)
}
var sprite_spawn_positions = {
	"stairs": Vector2(0, -7)
}
var size = Vector2(1, 1)
var is_reload:bool

func _init():
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]

func _ready():
	load_texture()
	load_sprite_position()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")
	
func load_texture():
	texture_file = "res://map/textures/objects/stairs/%s.png"
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

func visible_button_remove(_visible: bool):
	btn_remove.visible = _visible

func rotate_button_remove(is_build):
	if is_build:
		group_btn_remove.scale.x = -group_btn_remove.scale.x
	else:
		if scale.x == 1:
			group_btn_remove.scale.x = group_btn_remove.scale.x
		else:
			group_btn_remove.scale.x = -group_btn_remove.scale.x

func on_click_button_remove_local():
	Utils.get_current_character().ui_manager.on_click_button_remove_general(self)
