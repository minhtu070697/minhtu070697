extends CharacterState


func enter(_msg := {}) -> void:
	var _range = _msg.range
	character.set_state_label(name)
	if !Utils.node_exists(character.attack_target):
		state_machine.transition_to('idle')
		return
		
	character.update_attack_position()
			
	var _direction_to_target: Vector2 = character.direction_to_target_on_map(character.attack_position)
	
	state_machine.transition_to(
			"seek", {"target_position": character.map_manager.map_navigator.point_to_world(character.attack_position - _direction_to_target * _range)}
		)


func exit() -> void:
	pass



