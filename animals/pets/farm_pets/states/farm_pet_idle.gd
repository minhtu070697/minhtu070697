extends AnimalsIdle
class_name FarmPetIdle


func connect_to_behavior_signals():
	.connect_to_behavior_signals()
	if !character.is_connected("play_around", self, "_play_around"):
		character.connect("play_around", self, "_play_around")


func _play_around(_target_position: Vector2, _action_name: String):
	if state_machine.state != self:
		return
	state_machine.transition_to("play_around_seek", 
			{"target_position": _target_position, "action_name": _action_name})
