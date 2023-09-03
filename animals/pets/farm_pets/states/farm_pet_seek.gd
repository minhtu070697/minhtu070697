extends AnimalsSeek
class_name FarmPetSeek


func play_on_ground_moving_animation() -> void:
	if character.running:
		if character.is_guiding:
			character.play_animation("livestock_guide", character.action_speed)
		else:
			character.play_animation("run", character.action_speed)
	else:
		character.play_animation("walk", character.action_speed)
