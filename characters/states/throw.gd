extends CharacterState


func _ready():
	SignalManager.connect("fishing_throw_finished", self, "_on_fishing_throw_animation_finished")


func unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		GameManager.audio_manager.main_sound.stop()
		if (!character.map_manager.is_click_outside_map_bounds()):
			state_machine.transition_to(
				"seek", {"target_position": character.get_global_mouse_position()}
			)

#TODO: check bug update_direction
func enter(_msg := {}) -> void:
	var target_global_position = character.water_target_position
	var direction_to_target = Utils.angle_to_direction(character.distance_to_target(target_global_position).angle())
	if direction_to_target != null: character.update_direction(direction_to_target)
	character.check_flip_character(target_global_position)

	character.show_tool()
	character.set_state_label("fishing_throw")
	character.play_animation("fishing_throw")
	play_fishing_pre_throw_sound()

func exit() -> void:
	character.hide_tool()

	
func _on_fishing_throw_animation_finished(_character_name = ""):
	state_machine.transition_to("fishing/waiting")
	
	# sfx
	if Utils.random_int(0,10) < 4:
		play_fishing_waiting_sound()


func play_fishing_pre_throw_sound():
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.FISHING_ROD_CAST_SOUND_PATH, "character", "fishing_cast"), -18)


func play_fishing_throw_sound():
#	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.fishing_throw)
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.FISHING_ROD_CAST_SOUND_PATH, "character", "fishing_cast"), -3)


func play_fishing_waiting_sound():
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.fishing_waiting)


func play_hit_water_sound():
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.FISHING_ROD_HIT_WATER_SOUND_PATH, "character", "fishing_hit_water"), 20)
