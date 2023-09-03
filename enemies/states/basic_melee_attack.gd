extends EnemyState


func _ready():
	SignalManager.connect("attack_finished", self, "_on_attack_animation_finished")
	SignalManager.connect("health_changed", self, "_on_attack_succeed")


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	character.set_state_label("melee_attack")
	if Utils.node_exists(character.attack_target) and Utils.has_stats_manager(character.attack_target):
		var direction_to_target = character.map_manager.map_navigator.get_direction_from_world(character.global_position, character.attack_target.global_position)
		character.update_direction(direction_to_target)
		character.check_flip_character(character.attack_target.global_position)
		character.play_animation("basic_melee_attack")
	else:
		character.attack_target = null
		state_machine.transition_to('idle')


func exit() -> void:
	pass


func _on_attack_animation_finished(_character_name = ""):	
	if character.name != _character_name:
		return
	state_machine.transition_to("idle")
	

func _attack_hit():
	if Utils.node_exists(character.attack_target):
		_on_target_hit()


# general using: tree, mine, other_resource
func _on_target_hit():
	character.stats_manager.attack_library.attack(character.attack_target)
	

func _on_attack_succeed(_target_name = "", _attack_owner_name = ""):
	if _attack_owner_name == "":
		return
		
	if character.name != _attack_owner_name or !Utils.node_exists(character.attack_target):
		return
		
	if character.attack_target.name == _target_name:
		if character.attack_target.stats_manager.stats.hp <= 0:
			_on_target_die()
		


func _on_target_die():
	#vfx
	state_machine.transition_to("idle")
	character.attack_target = null


