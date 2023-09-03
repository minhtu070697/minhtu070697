extends CharacterState

var interacting_animal_body: Animals = null

func _ready() -> void:
	pass


func enter(_msg := {}) -> void:
#	print("animal_body_interacting")
	interacting_animal_body = _msg.animal_dead_body
	if interacting_animal_body == null:
		idle()
		return
	animal_dead_body_interact()


func idle() -> void:
	character.free_current_target()
	state_machine.transition_to("idle")


func exit() -> void:
	pass


func animal_dead_body_interact():
	if interacting_animal_body.live_status != interacting_animal_body.LiveStatus.DEAD:
		return
	interacting_animal_body.dead_body_harvest()
	idle()
