extends Node2D
const SlotClass = preload("res://ui/scenes/slot.gd")
onready var crafting_slots_main = $CraftingSlotsMain
onready var crafting_slots_sub = $CraftingSlotsSub
onready var crafting_slot_release = $CraftingSlotRelease
onready var crafting_slot_main_guide = $CraftingSlotsMainGuide
onready var crafting_slot_sub_guide = $CraftingSlotsSubGuide

onready var loading_bar = $LoadingBar
onready var btn_craft = $ButtonCraft

onready var input_amount_panel = $InputAmount
onready var amount_label = $InputAmount/AmountLabel
onready var btn_plus_amount = $InputAmount/ButtonPlus
onready var btn_minus_amount = $InputAmount/ButtonMinus
onready var btn_max_amount = $InputAmount/ButtonMax
onready var btn_min_amount = $InputAmount/ButtonMin
onready var btn_yes = $InputAmount/ButtonYes
onready var btn_no = $InputAmount/ButtonNo

onready var ui_manager = get_parent()
var character

var player_inventory = PlayerInventory
var empty_slot: SlotClass

var recipe_amount:int = 1
var recipes_having = {}
var recipes_need = {}
var recipes_left = {}
var inventory_slot_controller: InventorySlotController

func _ready():
	character = ui_manager.get_parent()
	var slots_main = crafting_slots_main.get_children()
	for i in range(slots_main.size()):
		slots_main[i].connect("gui_input", self, "slot_gui_input", [slots_main[i]])
		slots_main[i].slot_index = i
		slots_main[i].slotType = Constants.SlotType.CRAFTING_MAIN

	var slots_sub = crafting_slots_sub.get_children()
	for i in range(slots_sub.size()):
		slots_sub[i].connect("gui_input", self, "slot_gui_input", [slots_sub[i]])
		slots_sub[i].slot_index = i
		slots_sub[i].slotType = Constants.SlotType.CRAFTING_SUB

	var slot_release: SlotClass = crafting_slot_release.get_child(0)
	slot_release.connect("gui_input", self, "slot_gui_input", [slot_release])
	slot_release.slot_index = 0
	slot_release.slotType = Constants.SlotType.CRAFTING_RELEASE
	slot_release.enable_tooltip = false

	btn_craft.connect("pressed", self, "craft")
	btn_plus_amount.connect("pressed", self, "plus_recipe_amount")
	btn_max_amount.connect("pressed", self, "max_recipe_amount")
	btn_minus_amount.connect("pressed", self, "minus_recipe_amount")
	btn_min_amount.connect("pressed", self, "min_recipe_amount")
	btn_yes.connect("pressed", self, "button_yes")
	btn_no.connect("pressed", self, "button_no")
	inventory_slot_controller = InventorySlotController.new(ui_manager, character)


# region: move recipes
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			slot_left_clicked(slot)
			# sfx
			GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
			ui_manager.show_where_holding_item_belong_to()


func slot_left_clicked(_slot: SlotClass):
	if able_to_put_into_slot(_slot):
		if ui_manager.holding_item != null:
			if ui_manager.holding_item.item_amount > 1:
				empty_slot = _slot
				# ui
				enable_input_amount_panel()
				return
			
		inventory_slot_controller.put_item_into_slot(_slot, recipe_amount)
	else:
		inventory_slot_controller.pick_item(_slot)


func _input(_event):
	if ui_manager.holding_item:
		ui_manager.holding_item.global_position = get_global_mouse_position()


func able_to_put_into_slot(slot: SlotClass):
	if slot.slotType == Constants.SlotType.CRAFTING_RELEASE:
		return false
	var holding_item = ui_manager.holding_item
	if holding_item == null:
		return true

	var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
	var holding_item_crafting_category = JsonData.item_data[holding_item.item_name]["CraftingCategory"]

	if slot.slotType == Constants.SlotType.CRAFTING_MAIN:
		return holding_item_crafting_category == "Main"
	elif slot.slotType == Constants.SlotType.CRAFTING_SUB:
		return holding_item_crafting_category == "Sub"

	return holding_item_category == "Resource" and holding_item_crafting_category != ""


func left_click_empty_slot(slot: SlotClass):
	if able_to_put_into_slot(slot):
		if ui_manager.holding_item.item_amount > 1:
			# logic
			empty_slot = slot

			# ui
			enable_input_amount_panel()
		else:
			put_to_empty_slot(slot)


func put_to_empty_slot(slot: SlotClass):
	var amount_left = ui_manager.holding_item.item_amount - recipe_amount
	var amount_add = 0
	
	if amount_left >= 0:
		amount_add = recipe_amount
		ui_manager.holding_item.item_amount = amount_add
		if amount_left > 0:
			player_inventory.add_item(ui_manager.holding_item.item_name, amount_left)
	else:
		amount_add = ui_manager.holding_item.item_amount
		ui_manager.holding_item.item_amount = ui_manager.holding_item.item_amount

	ui_manager.holding_item.set_item_amount(amount_add)
	slot.putIntoSlot(ui_manager.holding_item)
	ui_manager.holding_item = null
	ui_manager.character.show_equipments()


func left_click_not_holding(slot: SlotClass):
	PlayerInventory.remove_item(slot)
	ui_manager.holding_item = slot.item
	ui_manager.holding_slot = slot
	slot.pickFromSlot()
	ui_manager.holding_item.global_position = get_global_mouse_position()
	ui_manager.character.show_equipments()

#endregion


#region: input recipe amount
func is_enable_input_amount_panel():
	return input_amount_panel.visible


func enable_input_amount_panel():
	if !is_enable_input_amount_panel():
		# logic
		recipe_amount = 1

		# ui
		input_amount_panel.visible = true


func disable_input_amount_panel():
	if is_enable_input_amount_panel():
		# logic
		reset_recipe_amount()

		# ui
		input_amount_panel.visible = false


func set_input_amount_label():
	# logic
	amount_label.text = String(recipe_amount)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)


func plus_recipe_amount():
	# logic
	var max_amount = ui_manager.holding_item.item_amount
	if recipe_amount < max_amount:
		recipe_amount += 1
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_plus_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)


func minus_recipe_amount():
	# logic
	var min_amount = 1
	if recipe_amount > min_amount:
		recipe_amount -= 1
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_minus_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)


func max_recipe_amount():
	# logic
	var max_amount = ui_manager.holding_item.item_amount
	recipe_amount = max_amount
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_max_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)


func min_recipe_amount():
	# logic
	var min_amount = 1
	recipe_amount = min_amount
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_min_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)


func reset_recipe_amount():
	recipe_amount = 1
	set_input_amount_label()


func button_yes():
	# logic
	inventory_slot_controller.put_item_into_slot(empty_slot, recipe_amount)
	empty_slot = null

	# ui
	disable_input_amount_panel()
	Utils.button_click_scale(btn_yes, Vector2(.7, .7), Vector2(.8, .8), 0.1)
	ui_manager.show_where_holding_item_belong_to()


func button_no():
	# ui
	disable_input_amount_panel()
	Utils.button_click_scale(btn_no, Vector2(.7, .7), Vector2(.8, .8), 0.1)
	ui_manager.show_where_holding_item_belong_to()

#endregion


# region: crafting logic
func craft():
	# logic: get a list of crafting items
	var crafting_items = crafting_items()
	if crafting_items.size() > 0:
		# get random item from list
		var crafting_item = Utils.random_from_array(crafting_items)
		# output: new crafting item
		add_item(crafting_item, 1)
		# calculate: recipe left = recipe having - recipe need
		cal_recipe_item_left_slots_main(crafting_item)
		# refund: add to inventory recipe left => calculated
		refund_recipe_item_left_slots_main() 
		# remove all recipes in crafting slots
		remove_slots_main_having_item()
		remove_slots_sub_having_item()

		# efx
		efx_slots_having_item()
		enable_loading_bar(true)
		tween_loading_bar()
		Utils.button_click_scale(btn_craft, Vector2(0.7, 0.7), Vector2(0.8, 0.8),  0.1)
		# sfx
		GameManager.audio_manager.play_main_sound(GameManager.audio_manager.crafting)
		# ui
		disable_input_amount_panel()


func crafting_items():
	var total = total_slots_main_having_item()
	var crafting_data = JsonData.crafting_data
	var crafting_items = []

	for key in crafting_data:
		var recipe = crafting_data[key]
		var matched = false
		var matched_count = 0
		for item in recipe:
			var item_name = item
			var item_amount = recipe[item_name]
			matched = find_recipe_item_in_slots_main(item_name, item_amount)
			if matched:
				matched_count += 1
			else:
				break
		if matched and matched_count == total:
			crafting_items.append(key)
	return crafting_items


func total_slots_main_having_item():
	var count = 0
	var slots_main = crafting_slots_main.get_children()
	for i in slots_main.size():
		if slots_main[i].get_child_count() > 0:
			count += 1
			recipes_having[slots_main[i].item.item_name] = slots_main[i].item.item_amount
	return count


func find_recipe_item_in_slots_main(recipe_item_name, recipe_item_quantity):
	var slots_main = crafting_slots_main.get_children()
	for i in slots_main.size():
		if slots_main[i].get_child_count() > 0 and slots_main[i].item.item_name == recipe_item_name and slots_main[i].item.item_amount >= recipe_item_quantity:
			return true
	return false


func cal_recipe_item_left_slots_main(crafting_item):
	var crafting_data = JsonData.crafting_data
	recipes_need = crafting_data[crafting_item]
	for i in recipes_need:
		var recipe_left_name = i
		var recipe_left_amount = recipes_having[i] - recipes_need[i]
		if recipe_left_amount > 0:
			recipes_left[recipe_left_name] = recipe_left_amount
	recipes_need = {}
	recipes_having = {}


func refund_recipe_item_left_slots_main():
	for i in recipes_left:
		player_inventory.add_item(i, refund_percent() * recipes_left[i])
	recipes_left = {}


func refund_percent():
	return 1


func remove_slots_main_having_item():
	var slots_main = crafting_slots_main.get_children()
	for i in range(slots_main.size()):
		if slots_main[i].get_child_count() > 0:
			slots_main[i].removeFromCraftingSlot(slots_main[i])


func remove_slots_sub_having_item():
	var slots_sub = crafting_slots_sub.get_children()
	for i in range(slots_sub.size()):
		if slots_sub[i].get_child_count() > 0:
			slots_sub[i].removeFromCraftingSlot(slots_sub[i]) 


func set_item_rarity():
	var rarity = Utils.random_int(0, Constants.Rarity.size() - 1)
	return rarity


func add_item(item_name, new_amount):
	var slot_release = crafting_slot_release.get_child(0)
	if slot_release.item != null:
		#NUYG: add item lvl = character current lvl, for testing only, will change later
		slot_release.item.set_item(item_name, new_amount, {}, character.stats_manager.stats.lvl)
	else:
		#NUYG: add item lvl = character current lvl, for testing only, will change later
		slot_release.initialize_item(item_name, new_amount, {}, character.stats_manager.stats.lvl)

#endregion


# region: crafting efx
func efx_slots_having_item():
	var slots_main = crafting_slots_main.get_children()
	for i in range(slots_main.size()):
		if slots_main[i].get_child_count() > 0:
			spawn_efx_slots_having_item(0, slots_main[i])

	var slot_release = crafting_slot_release.get_child(0)
	spawn_efx_slots_having_item(1, slot_release)

	slot_release.get_child(0).modulate.a = 0
	var tween = slot_release.get_child(0).get_node("Tween")
	Utils.start_tween(tween, slot_release.get_child(0), "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
	disable_button_while_tweening(tween)


func spawn_efx_slots_having_item(index, parent):
	# spawn
	var particle = Utils.load_resource("res://efx/particles/GeneralParticle.tscn", "slot_particle", "general_particle").instance()
	particle.scale = Vector2(0.5, 0.5)
	parent.add_child(particle)
	particle.position = Vector2(10, 10)
	particle.auto_emitting(index)
	particle.auto_queuefree(index)

	# tween - scale
	if index == 1:
		var tween = particle.tween
		Utils.start_tween(tween, particle, "scale", Vector2(0.5, 0.5), Vector2(0.15, 0.15), 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func disable_button_while_tweening(tween):
	var slot_release = crafting_slot_release.get_child(0)
	btn_craft.disabled = true
	slot_release.disconnect("gui_input", self, "slot_gui_input")

	yield(tween, "tween_completed")
	btn_craft.disabled = false
	slot_release.connect("gui_input", self, "slot_gui_input", [slot_release])


func enable_loading_bar(enable):
	loading_bar.visible = enable


func tween_loading_bar():
	var tween = loading_bar.get_node("Tween")
	Utils.start_tween(tween, loading_bar, "value", 0, 100, 0.85, Tween.TRANS_EXPO, Tween.EASE_OUT)
	yield(tween, "tween_completed")
	enable_loading_bar(false)

#endregion
