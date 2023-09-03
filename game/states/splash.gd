extends GameState

func physics_process(_delta):
	state_machine.transition_to('login')

func enter(_msg := {}) -> void:
	print("Enter Splash Screen")

func exit() -> void:
	pass
