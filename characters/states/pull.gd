extends CharacterState


func _ready():
	SignalManager.connect("fishing_pull_finished", self, "_on_fishing_pull_animation_finished")


func enter(_msg := {}) -> void:
	character.set_state_label("fishing_pull")
	character.play_animation("fishing_pull")

	# sfx
	play_fishing_pull_sound()


func exit():
	pass

	
func _on_fishing_pull_animation_finished(_character_name = ""):
	var max_loop = 5
	if !GameManager.resource_item_manager.resource_item_calculator.is_fishing_max_loop(max_loop):
		if GameManager.resource_item_manager.resource_item_calculator.is_fishing_loop():
			state_machine.transition_to("fishing/pull")
		else:
			state_machine.transition_to("fishing/catch")
	else:
		state_machine.transition_to("fishing/catch")


func play_fishing_pull_sound():
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.fishing_pull)
