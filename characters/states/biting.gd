extends CharacterState


func _ready():
	SignalManager.connect("fishing_biting_finished", self, "_on_fishing_biting_animation_finished")


func enter(_msg := {}) -> void:
	character.show_status()
	character.play_status_animation()
	character.show_tool()
	character.set_state_label("fishing_biting")
	character.play_animation("fishing_biting")

	# sfx
	play_fishing_biting_sound()


func exit():
	character.hide_status()


func _on_fishing_biting_animation_finished(_character_name = ""):
	var max_loop = 0
	if !GameManager.resource_item_manager.resource_item_calculator.is_fishing_max_loop(max_loop):
		if GameManager.resource_item_manager.resource_item_calculator.is_fishing_loop():
			state_machine.transition_to("fishing/biting")
		else:
			state_machine.transition_to("fishing/pull")
	else:
		state_machine.transition_to("fishing/pull")


func play_fishing_biting_sound():
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.fishing_biting)
