extends Node2D

const SlotClass = preload("res://ui/scenes/slot.gd")
onready var inventory_slots = $GridContainer
onready var equip_slots = $EquipSlots.get_children()
onready var equip_slots_guide = $EquipSlotsGuide
onready var remove_slot = $RemoveSlot
onready var btn_crafting = $ButtonCrafting
onready var reforge_button = $ReforgeButton
onready var cooking_button := $CookingButton
onready var ui_manager = get_parent()

onready var character

func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slotType = Constants.SlotType.INVENTORY
		
	for i in range(equip_slots.size()):
		equip_slots[i].connect("gui_input", self, "slot_gui_input", [equip_slots[i]])
		equip_slots[i].slot_index = i

	remove_slot.connect("gui_input", self, "left_click_remove_item")

	equip_slots[0].slotType = Constants.SlotType.HAIR
	equip_slots[1].slotType = Constants.SlotType.SHIRT
	equip_slots[2].slotType = Constants.SlotType.PANTS
	equip_slots[3].slotType = Constants.SlotType.WEAPON

	equip_slots[4].slotType = Constants.SlotType.ROD
	equip_slots[5].slotType = Constants.SlotType.AXE
	equip_slots[6].slotType = Constants.SlotType.PICK
	equip_slots[7].slotType = Constants.SlotType.HOE

	#NUYG: add character for easy access, use yield to wait for character stats calculate before create equipment
	character = ui_manager.get_parent()


func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1], PlayerInventory.inventory[i][2])
			PlayerInventory.inventory[i][2] = slots[i].item.get_item_stats()
	GameManager.save_load_manager.character_save.character_save(character)
	

func initialize_equips():
	for i in range(equip_slots.size()):
		if PlayerInventory.equips.has(i):
			equip_slots[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1], PlayerInventory.equips[i][2])
			PlayerInventory.equips[i][2] = equip_slots[i].item.get_item_stats()
			#NUYG: link all equipment in inventory to character stats
			add_update_character_equipment(equip_slots[i])
	GameManager.save_load_manager.character_save.character_save(character)
	ui_manager.character.show_equipments()


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if ui_manager.holding_item != null:
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					if ui_manager.holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else:
						left_click_same_item(event, slot)
				GameManager.save_load_manager.character_save.character_save(character)
				
			elif slot.item:
				#NUYG: link all equipment in inventory to character stats when removing equipment
				if slot in equip_slots:
					remove_character_equipment(slot)
				
				left_click_not_holding(slot)
			
			# sfx
			GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
			ui_manager.show_where_holding_item_belong_to()

		
		if event.button_index == BUTTON_RIGHT && event.pressed:
			if slot.item:
				right_click_on_item(slot)
				GameManager.save_load_manager.character_save.character_save(character)


func _input(_event):
	if ui_manager.holding_item:
		ui_manager.holding_item.global_position = get_global_mouse_position()


func add_update_character_equipment(_slot: SlotClass):
	ui_manager.character.stats_manager.equipment_manager.add_update_equipment(JsonData.item_data[_slot.item.item_name]["ItemCategory"].to_lower(), _slot.item.item_info)


func remove_character_equipment(_slot: SlotClass):
	ui_manager.character.stats_manager.equipment_manager.remove_equipment(JsonData.item_data[_slot.item.item_name]["ItemCategory"].to_lower())

#NUYG: refactor, add item_lvl_require check before put into slot
func able_to_put_into_slot(slot: SlotClass):
	var holding_item = ui_manager.holding_item
	if holding_item == null or !(slot in equip_slots):
		return true
	var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
	var _result: bool = true
	var _meet_lvl_require: bool = true if (GameManager.free_equipment or holding_item.item_info == null) else (ui_manager.character.stats_manager.stats.lvl >= holding_item.item_info.lvl_require)
	if slot.slotType == Constants.SlotType.HAIR:
		_result = holding_item_category == "Hair"
	elif slot.slotType == Constants.SlotType.SHIRT:
		_result = holding_item_category == "Shirt"
	elif slot.slotType == Constants.SlotType.PANTS:
		_result = holding_item_category == "Pants"
	elif slot.slotType == Constants.SlotType.WEAPON:
		_result = holding_item_category == "Weapon"

	elif slot.slotType == Constants.SlotType.ROD:
		_result = holding_item_category == "Fishing_Rod"
	elif slot.slotType == Constants.SlotType.AXE:
		_result = holding_item_category == "Axe"
	elif slot.slotType == Constants.SlotType.PICK:
		_result = holding_item_category == "Pick"
	elif slot.slotType == Constants.SlotType.HOE:
		_result = holding_item_category == "Hoe"
	return _result and _meet_lvl_require


func left_click_empty_slot(slot: SlotClass):
	if able_to_put_into_slot(slot):
		drop_item_into_slot(slot)
		#NUYG: show tooltip when put item into slot
		slot.show_item_tooltip()


func drop_item_into_slot(slot: SlotClass) -> void:
	PlayerInventory.add_item_to_empty_slot(ui_manager.holding_item, slot)
	slot.putIntoSlot(ui_manager.holding_item)

	ui_manager.holding_item = null
	ui_manager.character.show_equipments()

	# ui
	ui_manager.crafting.disable_input_amount_panel()
	#NUYG: link all equipment in inventory to character stats when adding/changing equipment
	if slot in equip_slots:
		add_update_character_equipment(slot)
		

#NUYG: cut all function content to swap_item() at the end of this file
func left_click_different_item(_event: InputEvent, slot: SlotClass):
	if able_to_put_into_slot(slot):
		swap_item(slot)



#NUYG: add event for swap item (in case equipment, or item with stack size = 1)
func left_click_same_item(_event: InputEvent, slot: SlotClass):
	if able_to_put_into_slot(slot):
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		
		if stack_size > 1:
			var able_to_add = stack_size - slot.item.item_amount
			if able_to_add >= ui_manager.holding_item.item_amount:
				PlayerInventory.add_item_amount(slot, ui_manager.holding_item.item_amount)
				slot.item.add_item_amount(ui_manager.holding_item.item_amount)
				ui_manager.holding_item.queue_free()
				ui_manager.holding_item = null
			else:
				PlayerInventory.add_item_amount(slot, able_to_add)
				slot.item.add_item_amount(able_to_add)
				ui_manager.holding_item.decrease_item_amount(able_to_add)
		else:
			swap_item(slot)
		# ui
		ui_manager.crafting.disable_input_amount_panel()
		#NUYG: link all equipment in inventory to character stats when adding/changing equipment
		if slot in equip_slots:
			add_update_character_equipment(slot)


func left_click_not_holding(slot: SlotClass):
	PlayerInventory.remove_item(slot)
	ui_manager.holding_item = slot.item
	ui_manager.holding_slot = slot
	slot.pickFromSlot()
	ui_manager.holding_item.global_position = get_global_mouse_position()
	ui_manager.character.show_equipments()


func left_click_remove_item(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if ui_manager.holding_item != null:
				var scale_tween = ui_manager.holding_item.get_node("Tween")
				Utils.start_tween(scale_tween, ui_manager.holding_item, "scale", Vector2.ONE, Vector2.ZERO, 0.1, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
				yield(scale_tween, "tween_completed")
				ui_manager.holding_slot.removeFromSlot(ui_manager.holding_item)
				ui_manager.holding_slot = null
				ui_manager.holding_item = null

				# ui
				ui_manager.crafting.disable_input_amount_panel()
				ui_manager.show_where_holding_item_belong_to()
				GameManager.save_load_manager.character_save.character_save(character)

func is_enable_inventory():
	return self.visible

#NUYG: cut left_click_different_item -> swap_item for later use
func swap_item(slot: SlotClass):
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(ui_manager.holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = temp_item.get_global_mouse_position()
	slot.putIntoSlot(ui_manager.holding_item)
	#NUYG: show tooltip when put item into slot
	# slot.show_item_tooltip()
	ui_manager.holding_item = temp_item

	# ui
	ui_manager.crafting.disable_input_amount_panel()
	#NUYG: link all equipment in inventory to character stats when adding/changing equipment
	if slot in equip_slots:
		add_update_character_equipment(slot)


func right_click_on_item(_slot: SlotClass):
	if _slot.item.item_info != null:
		if _slot.item.item_info.item_class == Constants.ItemClass.CONSUMABLE:
			_slot.item.item_info.item_use(ui_manager.character)
		elif _slot.item.item_info.item_class in [Constants.ItemClass.ARMOR, Constants.ItemClass.WEAPON]:
			if ui_manager.holding_item:
				return
			equip_equipment(_slot)


func change_slot_item_amount(_slot: SlotClass, _amount_change: int) -> void:
	_slot.item.add_item_amount(_amount_change)


func equip_equipment(_slot: SlotClass) -> void:
	var _target_slot: SlotClass = find_equip_slot_for_equipment(_slot)
	if !_target_slot:
		return
	
	left_click_not_holding(_slot)
	if !_target_slot.item:
		drop_item_into_slot(_target_slot)
	else:
		swap_item(_target_slot)
		left_click_empty_slot(_slot)


func find_equip_slot_for_equipment(_slot: SlotClass) -> SlotClass:
	for _equip_slot in equip_slots:
		if _equip_slot.slotType == Constants.ItemCategoryToSlotTypeDict[JsonData.item_data[_slot.item.item_name]["ItemCategory"]]:
			return _equip_slot
	return null


func hide_all_tooltip() -> void:
	var _inv_slots = inventory_slots.get_children()
	for _slots in _inv_slots:
		_slots.hide_item_tooltip()
	for _slots in equip_slots:
		_slots.hide_item_tooltip()
