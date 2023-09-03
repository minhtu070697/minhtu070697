extends CharacterState

var interacting_plant: GrownPlant = null

func _ready() -> void:
	pass


func enter(_msg := {}) -> void:
#	print("plant_interacting")
	interacting_plant = _msg.grown_plant
	if interacting_plant == null:
		idle()
		return
	interact_with_plant()


func idle() -> void:
	character.free_current_target()
	state_machine.transition_to("idle")


func exit() -> void:
	pass


func interact_with_plant():
	if interacting_plant.is_dead():
		interacting_plant.plant_remove()
	else:
		if interacting_plant.harvest_time_remain <= 0:
			state_machine.transition_to("basic_action")
			return
		else:
			interacting_plant.harvest()
	idle()
