extends ActorState
class_name CharacterState



func _ready():
	yield(owner.owner, "ready")
	character = owner.owner as Character
	assert(character != null)
	SignalManager.connect("skill_active", self, "_on_skill_active")
	

func _on_skill_active(_skill):
	if self == state_machine.state:
		state_machine.transition_to("casting", {"skill": _skill})

func check_and_transition_to_attack_state():
	#in case attack_target die but doesn't completely freed
	if !is_instance_valid(character.attack_target):
		character.attack_target = null
	
	if character.attack_target != null:
		if character.get_attack_target_distance() <= character.stats_manager.equipment_manager.weapon_range:
			character.update_attack_position()
			state_machine.transition_to("basic_melee_attack")
		else:
			state_machine.transition_to("attack_target_seek", {"range": character.stats_manager.equipment_manager.weapon_range})


func check_key_input(event: InputEvent) -> void: 
	if event is InputEventKey:
		if Input.is_action_just_released("next_target"):
			character.get_another_atk_target(true)
		elif Input.is_action_just_released("prev_target"):
			character.get_another_atk_target(false)
