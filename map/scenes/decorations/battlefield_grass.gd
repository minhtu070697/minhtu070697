extends Node2D

onready var sprite:Sprite = $Sprite

var texture_file 
var sprite_name
var sprite_names = {
	"battle_long_grass_1": Vector2(1, 1),
	"battle_long_grass_2": Vector2(1, 1),
	"battle_long_grass_3": Vector2(1, 1),
	"battle_long_grass_4": Vector2(1, 1),
	"battle_long_grass_5": Vector2(1, 1),
	"battle_long_grass_6": Vector2(1, 1),
	"battle_long_grass_7": Vector2(1, 1),
	"battle_long_grass_8": Vector2(1, 1),
	"battle_long_grass_9": Vector2(1, 1)
}
var sprite_build_positions = {
	"battle_long_grass_1": Vector2(0, 0),
	"battle_long_grass_2": Vector2(0, 0),
	"battle_long_grass_3": Vector2(0, 0),
	"battle_long_grass_4": Vector2(0, 0),
	"battle_long_grass_5": Vector2(0, 0),
	"battle_long_grass_6": Vector2(0, 0),
	"battle_long_grass_7": Vector2(0, 0),
	"battle_long_grass_8": Vector2(0, 0),
	"battle_long_grass_9": Vector2(0, 0)
}
var sprite_spawn_positions = {
	"battle_long_grass_1": Vector2(0, 0),
	"battle_long_grass_2": Vector2(0, 0),
	"battle_long_grass_3": Vector2(0, 0),
	"battle_long_grass_4": Vector2(0, 0),
	"battle_long_grass_5": Vector2(0, 0),
	"battle_long_grass_6": Vector2(0, 0),
	"battle_long_grass_7": Vector2(0, 0),
	"battle_long_grass_8": Vector2(0, 0),
	"battle_long_grass_9": Vector2(0, 0)
}
var size = Vector2(1, 1)
var is_reload:bool

func _init():
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]

func _ready():
	load_texture()
	load_sprite_position()

func load_texture():
	texture_file = "res://map/textures/objects/long_grass/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "long_grass_texture", sprite_name)
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
