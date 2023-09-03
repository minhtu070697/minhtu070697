extends Node2D

const SlotClass = preload("res://ui/scenes/slot.gd")
onready var hotbar_slots = $HotbarSlots
onready var active_item_label = $ActiveItemLabel
onready var slots = hotbar_slots.get_children()
onready var ui_manager = get_parent()


func _ready():
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slotType = Constants.SlotType.HOTBAR
		slots[i].slot_index = i
	initialize_hotbar()
	update_active_item_label()

func update_active_item_label():
	if slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
	else:
		active_item_label.text = ""

func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])

func _input(_event):
	if ui_manager.holding_item:
		ui_manager.holding_item.global_position = get_global_mouse_position()

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
						left_click_same_item(slot)
			elif slot.item:
				left_click_not_holding(slot)
			update_active_item_label()

			# sfx
			GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
			ui_manager.show_where_holding_item_belong_to()

func left_click_empty_slot(slot: SlotClass):
	PlayerInventory.add_item_to_empty_slot(ui_manager.holding_item, slot)
	slot.putIntoSlot(ui_manager.holding_item)
	ui_manager.holding_item = null

	# ui
	ui_manager.crafting.disable_input_amount_panel()
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(ui_manager.holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(ui_manager.holding_item)
	ui_manager.holding_item = temp_item

	# ui
	ui_manager.crafting.disable_input_amount_panel()

func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
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

	# ui
	ui_manager.crafting.disable_input_amount_panel()
		
func left_click_not_holding(slot: SlotClass):
	PlayerInventory.remove_item(slot)
	ui_manager.holding_item = slot.item
	ui_manager.holding_slot = slot
	slot.pickFromSlot()
	ui_manager.holding_item.global_position = get_global_mouse_position()
