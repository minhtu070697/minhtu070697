extends Node2D
class_name SeedInventory

const SlotClass = preload("res://ui/scenes/slot.gd")
onready var seed_slots_holder = $ScrollContainer/VBoxContainer
onready var ui_manager = get_parent()
onready var inventory = ui_manager.get_node("Inventory")
onready var inventory_slots = inventory.get_node("GridContainer").get_children()
onready var seed_slots = seed_slots_holder.get_children()
onready var tween = $Tween

onready var character
var livestock_barn_inventory: LivestockBarnInventory

var selecting_plot: EmptyPlotController = null

var hiding_inventory: bool = false

func _ready():
	for i in range(seed_slots.size()):
		seed_slots[i].connect("gui_input", self, "slot_gui_input", [seed_slots[i]])
		seed_slots[i].slotType = Constants.SlotType.INVENTORY
		seed_slots[i].enable_tooltip = false
		
	#NUYG: add character for easy access, use yield to wait for character stats calculate before create equipment
	character = ui_manager.get_parent()
	livestock_barn_inventory = character.get_node_or_null("ui/LivestockBarnInventory")
	PlayerInventory.connect("active_item_updated", self, "_on_player_inventory_updated")
	SignalManager.connect("mouse_left_clicked", self, "_on_mouse_left_clicked_outside")


func initialize_seeds():
	var _select_seed_slot: int = 0
	for _item_slot in PlayerInventory.inventory:
		if GameResourcesLibrary.item_resources_list_json[JsonData.item_data[PlayerInventory.inventory[_item_slot][0]]["ItemInfo"]].item_class == Constants.ItemClass.SEED:
			if _select_seed_slot == seed_slots.size():
				initialize_seed_slot()
			
			seed_slots[_select_seed_slot].initialize_item(PlayerInventory.inventory[_item_slot][0], PlayerInventory.inventory[_item_slot][1])
			seed_slots[_select_seed_slot].slot_index = _item_slot
			seed_slots[_select_seed_slot].visible = true
			_select_seed_slot += 1
	var _empty_seed_slot: int = seed_slots.size() - _select_seed_slot
	if _empty_seed_slot > 0:
		for _empty_slot_num in _empty_seed_slot:
			seed_slots[_empty_slot_num + _select_seed_slot].visible = false


func initialize_seed_slot():
	var _new_seed_slot = seed_slots[-1].duplicate()
	_new_seed_slot.item = _new_seed_slot.get_child(0)
	seed_slots_holder.add_child(_new_seed_slot)
	seed_slots.append(_new_seed_slot)
	_new_seed_slot.connect("gui_input", self, "slot_gui_input", [_new_seed_slot])
	_new_seed_slot.enable_tooltip = false


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if ui_manager.holding_item != null or slot.item == null:
				return
			
			seeding(slot)
			hide_seed_inventory()
			character.map_manager.is_click_on_removable_object = false
			character.map_manager.show_remove_button()


func seeding(_slot: SlotClass):
	var _young_plant_name: String = _slot.item.item_info.item_info.young_tree_name
	if _young_plant_name != "":
		selecting_plot.young_plant_seed(_young_plant_name)
	consume_seed(_slot)


func consume_seed(_slot: SlotClass):
	var _consume_slot = inventory_slots[_slot.slot_index]
	inventory.change_slot_item_amount(_consume_slot, -1)


func show_seed_inventory():
	check_and_hide_livestock_barn_inventory()

	visible = true
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	#logic
	initialize_seeds()


func hide_seed_inventory():
	if hiding_inventory or !visible:
		return
	hiding_inventory = true
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	yield(tween, "tween_completed")
	visible = false
	hiding_inventory = false

func _on_player_inventory_updated(_slot: SlotClass):
	initialize_seeds()


func _on_mouse_left_clicked_outside() -> void:
	hide_seed_inventory()


func check_and_hide_livestock_barn_inventory() -> void:
	if !livestock_barn_inventory:
		return
	if livestock_barn_inventory.visible:
		livestock_barn_inventory.hide_barn_inventory()
