extends CharacterState

var seeding_plot: EmptyPlotController = null
var seed_inventory: SeedInventory = null

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
#	print("seeding")
	if !seed_inventory:
		seed_inventory = character.get_node_or_null("ui/SeedInventory")
	seeding_plot = _msg.seeding_plot.get_node_or_null("EmptyPlotController") if Utils.node_exists(_msg.seeding_plot) else null
	if seeding_plot == null:
		idle()
		return
	
	select_young_plant()


func idle() -> void:
	character.free_current_target()
	state_machine.transition_to("idle")


func exit() -> void:
	seed_inventory.hide_seed_inventory()
	seed_inventory.selecting_plot = null


func select_young_plant() -> void:
	seed_inventory.show_seed_inventory()
	seed_inventory.selecting_plot = seeding_plot
