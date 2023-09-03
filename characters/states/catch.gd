extends CharacterState


var is_catch_success : bool


func _ready():
	SignalManager.connect("fishing_catch_finished", self, "_on_fishing_catch_animation_finished")

func enter(_msg := {}) -> void:
	character.set_state_label("fishing_catch")
	character.play_animation("fishing_catch")

	is_catch_success = GameManager.resource_item_manager.resource_item_calculator.is_catch_success()
	if is_catch_success:
		# animate
		GameManager.resource_item_manager.item.spawn(Constants.FISH_ITEM)
		GameManager.resource_item_manager.item.spawn_water_splash(character.global_position, character.current_direction, character.is_left())
		GameManager.resource_item_manager.item.resource_item.position = GameManager.resource_item_manager.item.fish_spawn_pos(character.global_position, character.current_direction, character.is_left())
		GameManager.resource_item_manager.item.fish_animate(character.global_position, character.current_direction, character.is_left())

	# sfx
	play_fishing_catch_sound()

func exit():
	character.hide_tool()

func _on_fishing_catch_animation_finished(_character_name = ""):
	if is_catch_success:
		state_machine.transition_to("fishing/jump")
	else:
		character.water_target = false
		state_machine.transition_to("idle")

func play_fishing_catch_sound():
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.fishing_biting)
