extends Node2D

const SlotClass = preload("res://ui/scenes/slot.gd")
onready var ingredient_slots_holder := $ReforgeIngredientSlots
onready var ingredient_slots = ingredient_slots_holder.get_children()
onready var item_slot_holder = $ReforgeItemSlot
onready var item_slot = $ReforgeItemSlot/ItemSlot
onready var ingredient_slots_guide = $ReforgeIngredientSlotsGuide

onready var loading_bar = $LoadingBar
onready var reforge_button = $ReforgeButton

onready var input_amount_panel = $InputAmount
onready var amount_label = $InputAmount/AmountLabel
onready var btn_plus_amount = $InputAmount/ButtonPlus
onready var btn_minus_amount = $InputAmount/ButtonMinus
onready var btn_max_amount = $InputAmount/ButtonMax
onready var btn_min_amount = $InputAmount/ButtonMin
onready var btn_yes = $InputAmount/ButtonYes
onready var btn_no = $InputAmount/ButtonNo

onready var general_particle = Utils.load_resource("res://efx/particles/GeneralParticle.tscn", "slot_particle", "general_particle")

onready var ui_manager = get_parent()
var character

var player_inventory = PlayerInventory
var putting_slot: SlotClass
var putting_item_amount: int = 1
onready var reforge_item_controller: ReforgeItemController = ReforgeItemController.new()
var inventory_slot_controller: InventorySlotController

func _ready():
	character = ui_manager.get_parent()
	for i in range(ingredient_slots.size()):
		ingredient_slots[i].connect("gui_input", self, "slot_gui_input", [ingredient_slots[i]])
		ingredient_slots[i].slot_index = i
		ingredient_slots[i].slotType = Constants.SlotType.REFORGE_INGREDIENT

	item_slot.connect("gui_input", self, "slot_gui_input", [item_slot])
	item_slot.slot_index = 0
	item_slot.slotType = Constants.SlotType.REFORGE_ITEM

	reforge_button.connect("pressed", self, "_on_reforge_button_clicked")
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
				putting_slot = _slot
				# ui
				enable_input_amount_panel()
				return
			
		inventory_slot_controller.put_item_into_slot(_slot, putting_item_amount)


func able_to_put_into_slot(slot: SlotClass):
	var holding_item = ui_manager.holding_item
	if holding_item == null:
		return true

	var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
	if slot.slotType == Constants.SlotType.REFORGE_ITEM:
		return Utils.is_equipment(holding_item_category)
	elif slot.slotType == Constants.SlotType.REFORGE_INGREDIENT:
		return !Utils.is_equipment(holding_item_category)

	return true


#endregion

#region: input recipe amount
func is_enable_input_amount_panel():
	return input_amount_panel.visible

func enable_input_amount_panel():
	if !is_enable_input_amount_panel():
		putting_item_amount = 1
		input_amount_panel.visible = true

func disable_input_amount_panel():
	if is_enable_input_amount_panel():
		reset_recipe_amount()
		input_amount_panel.visible = false

func set_input_amount_label():
	amount_label.text = String(putting_item_amount)
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

func plus_recipe_amount():
	# logic
	var max_amount = ui_manager.holding_item.item_amount
	if putting_item_amount < max_amount:
		putting_item_amount += 1
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_plus_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)

func minus_recipe_amount():
	# logic
	var min_amount = 1
	if putting_item_amount > min_amount:
		putting_item_amount -= 1
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_minus_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)

func max_recipe_amount():
	# logic
	var max_amount = ui_manager.holding_item.item_amount
	putting_item_amount = max_amount
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_max_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)

func min_recipe_amount():
	# logic
	var min_amount = 1
	putting_item_amount = min_amount
	set_input_amount_label()

	# ui
	Utils.button_click_scale(btn_min_amount, Vector2(.9, .9), Vector2(1, 1), 0.1)

func reset_recipe_amount():
	putting_item_amount = 1
	set_input_amount_label()

func button_yes():
	# logic
	inventory_slot_controller.put_item_into_slot(putting_slot, putting_item_amount)
	putting_slot = null

	# ui
	disable_input_amount_panel()
	Utils.button_click_scale(btn_yes, Vector2(.7, .7), Vector2(.8, .8), 0.1)
	ui_manager.show_where_holding_item_belong_to()

func button_no():
	# ui
	disable_input_amount_panel()
	Utils.button_click_scale(btn_yes, Vector2(.7, .7), Vector2(.8, .8), 0.1)
	ui_manager.show_where_holding_item_belong_to()

#endregion

#reforge button clicked
func _on_reforge_button_clicked():
	if !meet_reforge_requirement():
		return
	
	reforge()
	# efx
	efx_slots_having_item()
	enable_loading_bar(true)
	tween_loading_bar()
	Utils.button_click_scale(reforge_button, Vector2(0.7, 0.7), Vector2(0.8, 0.8),  0.1)
	# sfx
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.crafting)
	# ui
	disable_input_amount_panel()


func reforge() -> void:
	var _reforge_result: Dictionary = reforge_item_controller.reforge_item(item_slot, ingredient_slots)
	var _reforged_ingredient: Array = _reforge_result.reforged_ingredient
	var _not_reforged_ingredient: Array = _reforge_result.not_reforged_ingredient
	if _reforged_ingredient.size() > 0:
		remove_all_ingredients(_reforged_ingredient)
	if _not_reforged_ingredient.size() > 0:
		return_all_not_forged_ingredients(_not_reforged_ingredient)


func return_all_not_forged_ingredients(_ingredients: Array):
	for _ingredient in _ingredients:
		PlayerInventory.add_item(_ingredient.item.item_name, _ingredient.item.item_amount)
		_ingredient.removeSlotItem()


func item_slot_has_item() -> bool:
	return item_slot.get_child_count() > 0

func has_reforge_ingredient() -> bool:
	var _return = false
	for _ingredient_slot in ingredient_slots:
		_return = _return or _ingredient_slot.get_child_count() > 0
	return _return

func meet_reforge_requirement() -> bool:
	return item_slot_has_item() and has_reforge_ingredient()

func remove_all_ingredients(_reforged_ingredients: Array):
	for _reforged_ingredient in _reforged_ingredients:
		_reforged_ingredient.removeSlotItem()


#endregion

# region: crafting efx
func efx_slots_having_item():
	for i in range(ingredient_slots.size()):
		if ingredient_slots[i].get_child_count() > 0:
			spawn_efx_slots_having_item(0, ingredient_slots[i])

	spawn_efx_slots_having_item(1, item_slot)

	item_slot.get_child(0).modulate.a = 0
	var tween = item_slot.get_child(0).get_node("Tween")
	Utils.start_tween(tween, item_slot.get_child(0), "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
	disable_button_while_tweening(tween)


func spawn_efx_slots_having_item(index, parent):
	# spawn
	var particle = general_particle.instance()
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
	reforge_button.disabled = true
	item_slot.disconnect("gui_input", self, "slot_gui_input")

	yield(tween, "tween_completed")
	reforge_button.disabled = false
	item_slot.connect("gui_input", self, "slot_gui_input", [item_slot])


func enable_loading_bar(enable):
	loading_bar.visible = enable


func tween_loading_bar():
	var tween = loading_bar.get_node("Tween")
	Utils.start_tween(tween, loading_bar, "value", 0, 100, 0.85, Tween.TRANS_EXPO, Tween.EASE_OUT)
	yield(tween, "tween_completed")
	enable_loading_bar(false)

#endregion
