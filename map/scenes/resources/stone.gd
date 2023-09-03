extends ExploitResources

onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var sprite_build_positions = {
	"stone_1": Vector2(0, -65),
	"stone_2": Vector2(0, -61),
}
var sprite_spawn_positions = {
	"stone_1": Vector2(0, -53),
	"stone_2": Vector2(0, -61),
}

#sprite height is the height from bottom of sprite go to the top of sprite texture
#sprite width is cal from middle of sprite to farthest left point of sprite texture
var sprite_sizes = {
	"stone_1": Vector2(0, 58),
	"stone_2": Vector2(0, 67),
}


func _init():
	sprite_names = {
		"stone_1": Vector2(2, 2),
		"stone_2": Vector2(1, 1),
	}
	resource_name_by_sprite = {
		"stone_1": "stone",
		"stone_2": "stone",
	}
	texture_file = "res://map/textures/objects/mine/%s.png"
	sprite_name = Utils.random_from_dict(sprite_names)
	shadow_sprite_name = sprite_name + "_sh"
	size = sprite_names[sprite_name]
	sprite_size = sprite_sizes[sprite_name]
	resource_type = Constants.ResourceType.STONE


func _ready():
	load_texture()
	load_sprite_position()
	set_active_random_event(true)


func load_texture():
	texture_file = "res://map/textures/objects/mine/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "stone_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]
	shadow_sprite.texture = Utils.load_resource(
		texture_file % shadow_sprite_name, "stone_sd", shadow_sprite_name
	)
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
		sprite_size = sprite_sizes[self.sprite_name]
		resource_name = get_resource_name_by_sprite()


func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 5, 0)


func _on_Area2D_body_entered(body: Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)


func _on_Area2D_body_exited(body: Node):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)


func activate_random_event() -> float:
	if Utils.get_current_daytime() == Constants.DayTime.NIGHT:
		return night_events()
	else:
		return wait_to_next_daytime_period()


func night_events() -> float:
	var _event: String = Constants.random_event_with_chance.random_with_chance_from_dictionary(
		Constants.random_event_with_chance.InsectsSoundsWChance,
		Constants.random_event_with_chance.insects_sounds_tt_weight
	)
	# print(name, " ", _event)
	match _event:
		"insects_sound":
			return insects_sound()
		"insects_sleep":
			return insects_sleep()
	return 0.0


func insects_sound() -> float:
	Utils.play_sound(
		audio_player,
		Utils.pick_random_sound_from_collection(
			AudioLibrary.GRASS_INSECTS_SOUNDS,
			"g_insects_sound",
			AudioLibrary.NUM_OF_GRASS_INSECTS_SOUND
		),
		5
	)
	return rand_range(4, 10)


func insects_sleep() -> float:
	return rand_range(20, 60)
