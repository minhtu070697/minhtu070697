extends GameState

const LOGIN_REGISTER_TSCN = "res://game/scenes/LoginRegister.tscn"

func enter(_msg := {}) -> void:
	print("Enter Login Register")
#	game_manager.change_scene(LOGIN_REGISTER_TSCN)

func exit() -> void:
	pass
