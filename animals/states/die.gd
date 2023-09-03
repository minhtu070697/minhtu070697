extends AnimalsState

 
func enter(_msg := {}) -> void:
	state_machine.set_physics_process(false)
#	print(character.name, ": die")
	SignalManager.connect("die_finished", self, "_on_animation_die_finished")
	character.set_state_label("dying")
	character.play_animation("die")


func exit() -> void:
	pass


func _on_animation_die_finished(_character_name: String):
	if _character_name != character.name:
		return
	character.add_dead_body_to_map_info()
	character.delete_not_use_children_nodes()
