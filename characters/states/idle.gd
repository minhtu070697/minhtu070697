extends CharacterState

onready var attack_button = owner.owner.get_node("ui/Skillbar/AttackButton")


func unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		SignalManager.emit_signal("mouse_left_clicked")
		if Utils.is_in_buildable_map(character.map_manager.map_type): character.map_manager.check_disable_remove_item_choosing() 
		if  Utils.moving_click_is_valid():
			character.attacking = false
			character.skill_activating = null
			character.free_attack_target()
			state_machine.transition_to(
					"seek", 
					{"target_position": character.get_global_mouse_position()})
	check_key_input(event)
	if (event is InputEventKey and GameManager.is_outside_map() 
		and not GameManager.build_manager.holding_object 
		and not character.ui_manager.is_group_build_farming_visible()
		and not GameManager.save_load_manager.remove_object_mode):
		if Input.is_action_just_released("basic_attack"):
			state_machine.transition_to("basic_melee_attack")
		elif Input.is_action_just_released("heavy_attack"):
			state_machine.transition_to("basic_melee_attack", {
				"atk": "heavy",
			})


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()
	if (character.get_input_direction() != Vector2.ZERO 
		and not GameManager.build_manager.holding_object 
		and not character.ui_manager.is_group_build_farming_visible()
		and not GameManager.save_load_manager.remove_object_mode):
		character.attacking = false
		character.skill_activating = null
		character.free_attack_target()
		state_machine.transition_to("walk")
	if character.current_target != null:
		if character.current_target.resource_type == Constants.ResourceType.EMPTY_PLOT:
			state_machine.transition_to("basic_action/seeding", {"seeding_plot" : character.current_target.resource})
			return
		elif character.current_target.resource_type == Constants.ResourceType.YOUNG_PLANT:
			state_machine.transition_to("basic_action/young_plant_interact", {"young_plant" : character.current_target.resource})
			return
		elif character.current_target.resource_type == Constants.ResourceType.PLANT:
			state_machine.transition_to("basic_action/plant_interact", {"grown_plant" : character.current_target.resource})
			return
		elif character.current_target.resource_type == Constants.ResourceType.LIVESTOCK_BARN:
			state_machine.transition_to("basic_action/livestock_barn_interact", {"livestock_barn" : character.current_target.resource})
			return
		elif character.current_target.resource_type == Constants.ResourceType.ANIMAL_DEAD_BODY:
#			print("oke, animal dead body")
			state_machine.transition_to("basic_action/animal_dead_body_interact", {"animal_dead_body" : character.current_target.resource})
			return
		state_machine.transition_to("basic_action")
	if character.water_target:
		state_machine.transition_to("fishing")
	
	#=====Check and trans to casting state====
	check_and_transition_to_casting_state()
	
 
func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	
	if !attack_button.is_connected("button_up", self, "_on_AttackButton_button_up"):
		attack_button.connect("button_up", self, "_on_AttackButton_button_up")
	character.set_state_label("idle")
	character.play_animation("idle")
	SignalManager.emit_signal("character_arrived", character.name)

	character.ui_manager.visible_hud(true)

func exit() -> void:
	pass
	
			
func check_and_transition_to_casting_state():
	if character.skill_activating == null:
		return
	
	state_machine.transition_to("casting", {"skill": character.skill_activating})


func _on_AttackButton_button_up() -> void:
	if state_machine.state == self:
		character.basic_attack()
