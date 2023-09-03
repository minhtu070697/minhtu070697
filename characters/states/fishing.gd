extends CharacterState


func unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if(!character.map_manager.is_click_outside_map_bounds()):
			state_machine.transition_to(
				"seek", {"target_position": character.get_global_mouse_position()}
			)


#NUYG: update get_tool -> tool_eqquiped
func enter(_msg := {}) -> void:
	set_fishing_yield()
	if character.tool_equipped("fishing") and GameManager.resource_item_manager.is_resource_item_available():
		start_fishing()
	else:
		end_fishing()


func start_fishing():
	state_machine.transition_to("fishing/throw")


func end_fishing():
	character.water_target = false
	state_machine.transition_to("idle")


func set_fishing_yield() -> void:
	GameManager.resource_item_manager.get_current_resource_item(Constants.FISH_ITEM)