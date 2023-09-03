extends EnemyState


func enter(_msg := {}) -> void:
	character.set_state_label("dying")
	character.die()


func exit() -> void:
	pass
