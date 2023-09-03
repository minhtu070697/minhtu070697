extends CharacterState


func _ready():
	SignalManager.connect("fishing_jump_finished", self, "_on_fishing_jump_animation_finished")

func enter(_msg := {}) -> void:
	character.set_state_label("fishing_jump")
	character.play_animation("fishing_jump")

	# sfx
	play_fishing_jump_sound()
 
func exit():
	# animate
	GameManager.resource_item_manager.item.destroy_object()
	GameManager.resource_item_manager.item.destroy_water_splash()

	# logic: add item to inventory
	var name = GameManager.resource_item_manager.current_resource_item.item_name
	var amount = GameManager.resource_item_manager.current_resource_item.amount
	character.player_inventory.add_item(name, amount)

	# logic: remove item from total resources in map
	character.show_item_label()
	character.set_item_label("+", amount)
	GameManager.resource_item_manager.remove_resource_item(Constants.FISH_ITEM)

func _on_fishing_jump_animation_finished(_character_name = ""):
	character.water_target = false
	state_machine.transition_to("idle")


func play_fishing_jump_sound():
	var random = Utils.random_int(0, 1)
	if random == 0:
		GameManager.audio_manager.play_main_sound(GameManager.audio_manager.collect)
	else:
		GameManager.audio_manager.play_main_sound(GameManager.audio_manager.collect_1)
