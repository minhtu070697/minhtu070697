extends Node2D
class_name InventorySlotController

var ui_manager
var character


#Use can you this class on any UI script that has item slots to control how item can be put into slot, pick up, swap item
#How to use this class on any UI that have item slot:
#1: Create an init of this class and pass ui_manager, character to init func
#2: You just has to use put_item_into_slot func with parameters as below when any slot clicked (_slot para: slot was clicked)
#To work with input amount panel, just get putting amount from the panel and putting slot (slot you want to put item in) and use them as parameter for func put_item_into_slot

func _init(_ui_manager, _character) -> void:
	ui_manager = _ui_manager
	character = _character

#use this func
func put_item_into_slot(_slot: ItemSlot, _putting_item_amount: int = 1):
	if ui_manager.holding_item != null and _slot.item != null:
		if ui_manager.holding_item.item_name == _slot.item.item_name:
			var stack_size = int(JsonData.item_data[_slot.item.item_name]["StackSize"])
			var _max_add_number = stack_size - _slot.item.item_amount
			if _max_add_number > 0:
				add_item_stack(_slot, _max_add_number, _putting_item_amount)
				return

	slot_item_swap(_slot, _putting_item_amount)


func add_item_stack(_slot: ItemSlot, _max_add_number: int, _putting_item_amount: int):
	PlayerInventory.add_item_amount(_slot, min(_max_add_number, _putting_item_amount))
	_slot.item.add_item_amount(min(_max_add_number, _putting_item_amount))
	ui_manager.holding_item.decrease_item_amount(min(_max_add_number, _putting_item_amount))
	if ui_manager.holding_item.item_amount <= 0:
		ui_manager.holding_item.queue_free()
		ui_manager.holding_item = null


func slot_item_swap(_slot: ItemSlot, _putting_item_amount: int):
	var _putting_item = pick_item_out_of_slot(_slot)
	put_to_empty_slot(_slot, _putting_item_amount)
	set_hold_item(_putting_item)
	_putting_item = null


func pick_item(_slot: ItemSlot):
	if ui_manager.holding_item != null:
		return
	var _putting_item = pick_item_out_of_slot(_slot)
	set_hold_item(_putting_item)
	ui_manager.holding_slot = _slot
	_putting_item = null


func pick_item_out_of_slot(_slot: ItemSlot):
	if _slot.item == null:
		return null
	
	var _temp_item = _slot.item
	_slot.hide_item_tooltip()
	_slot.remove_child(_slot.item)
	_slot.item = null
	_slot.refresh_style()
	PlayerInventory.remove_item(_slot)
	ui_manager.character.show_equipments()
	return _temp_item


func set_hold_item(_putting_item):
	if _putting_item == null:
		return
	
	ui_manager.add_child(_putting_item)
	ui_manager.holding_item = _putting_item
	ui_manager.holding_item.global_position = ui_manager.holding_item.get_global_mouse_position()


func put_to_empty_slot(slot: ItemSlot, _putting_item_amount: int):
	if ui_manager.holding_item == null:
		return
	
	var amount_left = ui_manager.holding_item.item_amount - _putting_item_amount
	var amount_add = 0
	
	amount_add = min(_putting_item_amount,ui_manager.holding_item.item_amount)
	if amount_left > 0:
		PlayerInventory.add_item(ui_manager.holding_item.item_name, amount_left)

	ui_manager.holding_item.set_item_amount(amount_add)
	slot.putIntoSlot(ui_manager.holding_item)
	ui_manager.holding_item = null
	ui_manager.character.show_equipments()
