extends CharacterState

var interacting_barn: LivestockBarnController = null
var livestock_barn_inventory: LivestockBarnInventory = null

func _ready() -> void:
	pass


func unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if not character.map_manager.is_click_outside_map_bounds() and not GameManager.build_manager.holding_object and not character.ui_manager.inventory.is_enable_inventory() and not character.ui_manager.is_enable_group_build():
			character.attacking = false
			character.skill_activating = null
			state_machine.transition_to(
				"seek", 
				{"target_position": character.get_global_mouse_position()})


func enter(_msg := {}) -> void:
#	print("barn_interacting")
	if !livestock_barn_inventory:
		livestock_barn_inventory = character.get_node_or_null("ui/LivestockBarnInventory")
	interacting_barn = _msg.livestock_barn.get_node_or_null("LivestockBarnController") if Utils.node_exists(_msg.livestock_barn) else null
	if interacting_barn == null:
		idle()
		return
	interact_with_barn()


func idle() -> void:
	character.free_current_target()
	state_machine.transition_to("idle")


func exit() -> void:
	livestock_barn_inventory.hide_barn_inventory()
	livestock_barn_inventory.selecting_barn = null


func interact_with_barn():
	livestock_barn_inventory.selecting_barn = interacting_barn
	livestock_barn_inventory.show_barn_inventory()
