extends AnimalsSeek
class_name LivestocksSeek


func play_on_ground_moving_animation() -> void:
	if character.running:
		if character.fleeing:
			character.play_animation("flee", character.action_speed)
		else:
			character.play_animation("run", character.action_speed)
	else:
		character.play_animation("walk", character.action_speed)


func play_on_water_moving_animation() -> void:
	if character.running:
		if character.fleeing:
			character.play_animation("flee", character.action_speed)
		else:
			character.play_animation("fast_swim", character.action_speed)
	else:
		character.play_animation("swim", character.action_speed)
