extends CharacterState

var interacting_young_plant: YoungPlant = null

func _ready() -> void:
	SignalManager.connect("water_finished", self, "_on_water_animation_finished")


func enter(_msg := {}) -> void:
#	print("young_plant_interacting")
	interacting_young_plant = _msg.young_plant
	if interacting_young_plant == null:
		idle()
		return
	interact_with_young_plant()


func idle() -> void:
	character.free_current_target()
	state_machine.transition_to("idle")


func exit() -> void:
	character.hide_tool()


func interact_with_young_plant():
	var current_target = character.current_target
	if current_target != null and Utils.node_exists(current_target.resource):
		var direction_to_target = character.map_manager.map_navigator.get_direction_from_world(character.global_position, current_target.resource.global_position)
		if direction_to_target != null:
			character.update_direction(direction_to_target)
		character.show_tool()
		character.check_flip_character(current_target.resource.global_position)
		if interacting_young_plant.is_dead():
			#check_tool_have_hoe
			interacting_young_plant.young_plant_remove()
			idle()
		else:
			interacting_young_plant.player_take_care()
			character.play_animation("water")


func _on_water_animation_finished(_character_name = ""):
	if character.name != _character_name:
		return
	idle()


func start_play_water_sound() -> void:
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.START_WATER_SOUND_PATH, "character", "water_start_sound"), 5)


func play_water_loop_sound() -> void:
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.LOOP_WATER_SOUND_PATH, "character", "water_loop_sound"), 5)


func end_play_water_sound() -> void:
	Utils.play_sound(character.audio_player, Utils.load_resource(AudioLibrary.END_WATER_SOUND_PATH, "character", "water_end_sound"), 5)
