extends ExploitResources

onready var particle_2d := $Sprite/Particles2D
onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

const TREE_SPRITE_ANIMATION_PATH: String = "res://map/textures/objects/trees/animations/%s-%s.png"  #sprite_name, animation_name

var sprite_build_positions = {
	"tree_common-big": Vector2(0, -67),
	"tree_common-medium": Vector2(0, -68),
	"tree_common-small": Vector2(0, -68),
	"tree_2": Vector2(0, -78),
	"tree_3": Vector2(0, -45),
	"tree_4": Vector2(0, -66),
	"small_bush": Vector2(0, -15),
	"small_bush_red": Vector2(0, -15),
	"pine_green-big": Vector2(0, -66),
	"pine_green-medium": Vector2(0, -66),
	"pine_green-small": Vector2(0, -66),
	"pine_dark_green-big": Vector2(0, -66),
	"pine_dark_green-medium": Vector2(0, -66),
	"pine_dark_green-small": Vector2(0, -66),
	"pine_orange-big": Vector2(0, -66),
	"pine_orange-medium": Vector2(0, -66),
	"pine_orange-small": Vector2(0, -66),
	"birch-big": Vector2(0, -81),
	"birch-medium": Vector2(0, -81),
	"birch-small": Vector2(0, -81),
	"birch_2": Vector2(0, -54),
}

var sprite_spawn_positions = {
	"tree_common-big": Vector2(0, -67),
	"tree_common-medium": Vector2(0, -68),
	"tree_common-small": Vector2(0, -68),
	"tree_2": Vector2(0, -78),
	"tree_3": Vector2(0, -45),
	"tree_4": Vector2(0, -66),
	"small_bush": Vector2(0, -15),
	"small_bush_red": Vector2(0, -15),
	"pine_green-big": Vector2(0, -66),
	"pine_green-medium": Vector2(0, -66),
	"pine_green-small": Vector2(0, -66),
	"pine_dark_green-big": Vector2(0, -66),
	"pine_dark_green-medium": Vector2(0, -66),
	"pine_dark_green-small": Vector2(0, -66),
	"pine_orange-big": Vector2(0, -66),
	"pine_orange-medium": Vector2(0, -66),
	"pine_orange-small": Vector2(0, -66),
	"birch-big": Vector2(0, -81),
	"birch-medium": Vector2(0, -81),
	"birch-small": Vector2(0, -81),
	"birch_2": Vector2(0, -54),
}

#sprite height is the height from bottom of sprite go to the top of sprite texture
#sprite width is cal from middle of sprite to farthest left point of sprite texture
var sprite_sizes := {
	"tree_common-big": Vector2(0, 140),
	"tree_common-medium": Vector2(0, 130),
	"tree_common-small": Vector2(0, 100),
	"tree_2": Vector2(0, 170),
	"tree_3": Vector2(0, 135),
	"tree_4": Vector2(0, 170),
	"small_bush": Vector2(0, 50),
	"small_bush_red": Vector2(0, 50),
	"pine_green-big": Vector2(0, 175),
	"pine_green-medium": Vector2(0, 165),
	"pine_green-small": Vector2(0, 108),
	"pine_dark_green-big": Vector2(0, 175),
	"pine_dark_green-medium": Vector2(0, 165),
	"pine_dark_green-small": Vector2(0, 108),
	"pine_orange-big": Vector2(0, 175),
	"pine_orange-medium": Vector2(0, 165),
	"pine_orange-small": Vector2(0, 108),
	"birch-big": Vector2(0, 180),
	"birch-medium": Vector2(0, 145),
	"birch-small": Vector2(0, 120),
	"birch_2": Vector2(0, 135),
}


func _init():
	sprite_names = {
		"tree_common-big": Vector2(1, 1),
		"tree_common-medium": Vector2(1, 1),
		"tree_common-small": Vector2(1, 1),
		"tree_2": Vector2(1, 1),
		"tree_3": Vector2(1, 1),
		"tree_4": Vector2(1, 1),
		"small_bush": Vector2(1, 1),
		"small_bush_red": Vector2(1, 1),
		"pine_green-big": Vector2(1, 1),
		"pine_green-medium": Vector2(1, 1),
		"pine_green-small": Vector2(1, 1),
		"pine_dark_green-big": Vector2(1, 1),
		"pine_dark_green-medium": Vector2(1, 1),
		"pine_dark_green-small": Vector2(1, 1),
		"pine_orange-big": Vector2(1, 1),
		"pine_orange-medium": Vector2(1, 1),
		"pine_orange-small": Vector2(1, 1),
		"birch-big": Vector2(1, 1),
		"birch-medium": Vector2(1, 1),
		"birch-small": Vector2(1, 1),
		"birch_2": Vector2(1, 1),
	}

	resource_name_by_sprite = {
		"tree_common-big": "tree",
		"tree_common-medium": "tree",
		"tree_common-small": "tree",
		"tree_2": "tree",
		"tree_3": "tree",
		"tree_4": "tree",
		"small_bush": "tree",
		"small_bush_red": "tree",
		"pine_green-big": "tree",
		"pine_green-medium": "tree",
		"pine_green-small": "tree",
		"pine_dark_green-big": "tree",
		"pine_dark_green-medium": "tree",
		"pine_dark_green-small": "tree",
		"pine_orange-big": "tree",
		"pine_orange-medium": "tree",
		"pine_orange-small": "tree",
		"birch-big": "tree",
		"birch-medium": "tree",
		"birch-small": "tree",
		"birch_2": "tree",
	}
	texture_file = "res://map/textures/objects/trees/%s.png"
	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]
	sprite_size = sprite_sizes[sprite_name]
	resource_type = Constants.ResourceType.TREE


func _ready():
	wind_react_timer = $Timers/WindReactTimer
	event_timer = $Timers/SoundTimer
	load_texture()
	load_sprite_position()
	particle_2d.emitting = false
	set_react_with_environment(true)
	set_active_random_event(true)
	update_animation_sprites(sprite_name)


func load_texture():
	texture_file = "res://map/textures/objects/trees/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "tree_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]
	scale = Utils.random_resource_scale_x(sprite_names[sprite_name])


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
		sprite_size = sprite_sizes[self.sprite_name]
		update_animation_sprites(self.sprite_name)
		resource_name = get_resource_name_by_sprite()


func update_animation_sprites(_sprite_name: String) -> void:
	for animation_name in animation_player.get_animation_list():
		if animation_name == "RESET":
			continue
		var animation: Animation = animation_player.get_animation(animation_name)
		var track_index = animation.find_track("Sprite:texture")
		if track_index > -1:
			animation.track_set_key_value(
				track_index,
				0,
				Utils.load_resource(
					TREE_SPRITE_ANIMATION_PATH % [_sprite_name, animation_name],
					"tree",
					"%s-%s" % [_sprite_name, animation_name]
				)
			)


func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 30, 5, 0)
	on_efx()


func on_efx():
	if stats_manager.stats.hp > 0:
		particle_2d.emitting = true
		$AnimationStopper.start(0.3)


func _on_AnimationStopper_timeout():
	particle_2d.emitting = false


func _on_Area2D_body_entered(body):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.35, 0.15)


func _on_Area2D_body_exited(body):
	if body.get_name() == "Character":
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.35, 1, 0.15)


func activate_random_event() -> float:
	if Utils.get_current_daytime() == Constants.DayTime.NIGHT:
		return night_events()
	else:
		return day_events()


func day_events() -> float:
	var _event: String = Constants.random_event_with_chance.random_with_chance_from_dictionary(
		Constants.random_event_with_chance.TreeEventListWithChance,
		Constants.random_event_with_chance.tree_event_total_weight
	)
	match _event:
		"bird_sing":
			return play_bird_sound()
		"bird_fly_away":
			return bird_fly_away()
	return 0.0


func night_events() -> float:
	var _event: String = Constants.random_event_with_chance.random_with_chance_from_dictionary_list(
		[
			Constants.random_event_with_chance.TreeEventListWithChance,
			Constants.random_event_with_chance.InsectsSoundsWChance,
			Constants.random_event_with_chance.TreeNightEventListWithChance
		],
		(
			Constants.random_event_with_chance.tree_event_total_weight
			+ Constants.random_event_with_chance.insects_sounds_tt_weight
			+ Constants.random_event_with_chance.tree_night_event_total_weight
		),
		name
	)
	# print(name, " ", _event)
	match _event:
		"bird_sing":
			return play_bird_sound()
		"bird_fly_away":
			return bird_fly_away()
		"insects_sound":
			return insects_sound()
		"insects_sleep":
			return insects_sleep()
		"spawn_fireflies":
			return spawn_fireflies()
	return 0.0


func spawn_fireflies() -> float:
	var e: float = 4.0
	var max_fire_flies: int = 6
	var rn: int = Utils.random_int(1, pow(max_fire_flies + 1, e) - 1)
	for i in (max_fire_flies + 1 - int(pow(rn, 1.0/e))):
		var firefly: FireFlies = Utils.load_resource("res://map/scenes/decorations/FireFlies.tscn", "fire_fly", "scene").instance()
		firefly.global_position = global_position - Vector2(0, Utils.random_int(2, sprite_size.y - 10))
		var f_scale: float = rand_range(0.2, 0.7)
		firefly.scale = Vector2(f_scale, f_scale)
		GameManager.map_manager.add_child(firefly)
	return rand_range(2,3)


func insects_sound() -> float:
	Utils.play_sound(audio_player, Utils.pick_random_sound_from_collection(AudioLibrary.GRASS_INSECTS_SOUNDS, "g_insects_sound", AudioLibrary.NUM_OF_GRASS_INSECTS_SOUND), 5)
	return rand_range(4,10)


func insects_sleep() -> float:
	return rand_range(5,15)


func bird_fly_away() -> float:
	return rand_range(40, 120)


func play_bird_sound() -> float:
	Utils.play_sound(
		audio_player,
		Utils.pick_random_sound_from_collection(
			AudioLibrary.BIRD_SOUNDS, "bird_sound", AudioLibrary.NUMBER_OF_BIRD_SOUND
		),
		8
	)
	return rand_range(6, 30)


#override
func wind_react() -> void:
	Utils.play_sound(
		audio_player,
		Utils.load_resource(AudioLibrary.LEAF_SOUND_ON_WIND_BLOW, "tree", "tree_on_wind"),
		8
	)
	if !is_dying():
		Utils.play_animation(animation_player, "shake")


func _on_animation_finished(_animation_name: String):
	._on_animation_finished(_animation_name)


func is_dying() -> bool:
	return animation_player.current_animation == "die"
