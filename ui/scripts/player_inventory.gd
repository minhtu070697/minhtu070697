extends Node

signal active_item_updated

const ItemClass = preload("res://ui/scenes/item.gd")
const SlotClass = preload("res://ui/scenes/slot.gd")
const NUM_INVENTORY_SLOTS = 20
const NUM_HOTBAR_SLOTS = 8

var active_item_slot = 0
var character


var hotbar = {
	# 0: ["iron_sword", 1],  #--> slot_index: [item_name, item_amount]
}

var inventory = {
	# 0: ["wood", 10], #--> slot_index: [item_name, item_amount]
	# 1: ["stone", 10], 
	# 2: ["rope", 10],
	# 3: ["gold", 10],
	# 4: ["fish", 10],  
	# 5: ["potion", 10],
	# 7: ["carrot_seed", 10],
	# 8: ["chilly_seed", 10],
	# 11: ["peach_seed", 10]
}

var equips: Dictionary = {}


#NUYG: to add special energy item that hold energy for cooking
func add_energy_item(_item_name: String, _energy: int) -> void:
	var item_slot_id: int = get_item_slot_in_inventory(_item_name)
	if item_slot_id >= 0:
		#already in inventory
		var item: InventoryItem = get_slot_item(item_slot_id)
		item.cooking_energy += _energy
	else:
		#not in inventory yet, create a new one
		var empty_slot_id: int = get_inv_first_empty_slot()
		inventory[empty_slot_id] = [_item_name, 1, {}]
		var slot: ItemSlot = update_slot_visual(empty_slot_id, _item_name, 1)
		slot.item.cooking_energy = _energy
	
	
func get_inv_first_empty_slot() -> int:
	for i in range(NUM_INVENTORY_SLOTS):
		if not inventory.has(i):
			return i
	
	return -1


func get_slot_item(_slot_id: int) -> InventoryItem:
	var slot = get_tree().root.get_node("/root/MapManager/YSort/Character/ui/Inventory/GridContainer/Slot" + str(_slot_id + 1))
	if slot.item != null:
		return slot.item
	else:
		return null


func get_item_slot_in_inventory(_item_name: String) -> int:
	for _slot_number in inventory.keys():
		if inventory[_slot_number][0] == _item_name:
			return int(_slot_number)
	
	return -1


func add_item(item_name, item_amount):
	var slot_indices: Array = inventory.keys()
	slot_indices.sort()
	for item in slot_indices:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_amount:
				inventory[item][1] += item_amount
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_amount = item_amount - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			update_slot_visual(i, item_name, item_amount)
			return


func update_slot_visual(slot_index, item_name, new_amount):
	var slot = get_tree().root.get_node("/root/MapManager/YSort/Character/ui/Inventory/GridContainer/Slot" + str(slot_index + 1))
	#get character
	if !Utils.node_exists(character):
		character = Utils.get_current_character()

	if slot.item != null:
		slot.item.set_item(item_name, new_amount)
	else:
		slot.initialize_item(item_name, new_amount)
	inventory[slot_index] = [slot.item.item_name, slot.item.item_amount, slot.item.get_item_stats()]
	GameManager.save_load_manager.character_save.character_save(character)
	return slot


func remove_item(slot: SlotClass):
	if slot.slotType == Constants.SlotType.HOTBAR:
		hotbar.erase(slot.slot_index)
	elif slot.slotType == Constants.SlotType.INVENTORY:
		inventory.erase(slot.slot_index)
	elif slot.get_parent().name == "EquipSlots":
		equips.erase(slot.slot_index)
	emit_signal("active_item_updated", slot)


func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
	if slot.slotType == Constants.SlotType.HOTBAR:
		hotbar[slot.slot_index] = [item.item_name, item.item_amount]
	elif slot.slotType == Constants.SlotType.INVENTORY:
		inventory[slot.slot_index] = [item.item_name, item.item_amount, item.get_item_stats()]
	elif slot.get_parent().name == "EquipSlots":
		equips[slot.slot_index] = [item.item_name, item.item_amount, item.get_item_stats()]
	emit_signal("active_item_updated", slot)


func add_item_amount(slot: SlotClass, amount_to_add: int):
	if slot.slotType == Constants.SlotType.HOTBAR:
		hotbar[slot.slot_index][1] += amount_to_add
	elif slot.slotType == Constants.SlotType.INVENTORY:
		inventory[slot.slot_index][1] += amount_to_add
	elif slot.get_parent().name == "EquipSlots":
		equips[slot.slot_index][1] += amount_to_add
	emit_signal("active_item_updated", slot)


func update_item(slot: SlotClass, stats: Dictionary) -> void:
	if slot.slotType == Constants.SlotType.INVENTORY:
		inventory[slot.slot_index][2] = stats
	elif slot.get_parent().name == "EquipSlots":
		equips[slot.slot_index][2] = stats
	emit_signal("active_item_updated", slot)


func load_inventory_from_save(_save_data: Dictionary):
	inventory.clear()
	for _key in _save_data.inventory:
		inventory[int(_key)] = _save_data.inventory[_key]
	equips.clear()
	for _key in _save_data.equipments:
		equips[int(_key)] = _save_data.equipments[_key]
