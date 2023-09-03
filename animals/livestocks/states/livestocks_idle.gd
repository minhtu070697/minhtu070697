extends AnimalsIdle
class_name LivestocksIdle


func start_idle_timer():
	if character.fleeing:
		character.start_idle_timer(1)
	else:
		character.start_idle_timer()
