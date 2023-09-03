extends CharacterState


func _ready():
	SignalManager.connect("fishing_waiting_finished", self, "_on_fishing_waiting_animation_finished")


func unhandled_input(event):
	GameManager.audio_manager.main_sound.stop()
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if(!character.map_manager.is_click_outside_map_bounds()):
			state_machine.transition_to(
				"seek", {"target_position": character.get_global_mouse_position()}
			)


func enter(_msg := {}) -> void:
	character.show_tool()
	character.set_state_label("fishing_waiting")
	character.play_animation("fishing_waiting")


func exit():
	character.hide_tool()

	
func _on_fishing_waiting_animation_finished(_character_name = ""):
	var max_loop = 5
	if !GameManager.resource_item_manager.resource_item_calculator.is_fishing_max_loop(max_loop):
		if GameManager.resource_item_manager.resource_item_calculator.is_fishing_loop():
			state_machine.transition_to("fishing/waiting")
		else:
			state_machine.transition_to("fishing/biting")
	else:
		state_machine.transition_to("fishing/biting")
