extends Node2D
class_name CookingTab

const SlotClass = preload("res://ui/scenes/slot.gd")
onready var ingredient_slots_holder := $SlotsHolder/IngredientSlots
onready var ingredient_slots = ingredient_slots_holder.get_children()

onready var slots_holder := $SlotsHolder
onready var energy_slots_holder := $SlotsHolder/EnergySlots
onready var energy_slots: Array = energy_slots_holder.get_children()

onready var item_slot_holder = $SlotsHolder/FinalItemSlot
onready var item_slot: SlotClass = $SlotsHolder/FinalItemSlot/ItemSlot
onready var ingredient_slots_guide = $SlotsHolder/IngredientSlotsGuide
onready var energy_slots_guide := $SlotsHolder/EnergySlotsGuide

onready var loading_bar = $LoadingBar
onready var cooking_button = $CookingButton
onready var cooking_button_label: Label = $CookingButton/Label

onready var input_amount_panel = $InputAmount
onready var amount_label = $InputAmount/AmountLabel
onready var btn_plus_amount = $InputAmount/ButtonPlus
onready var btn_minus_amount = $InputAmount/ButtonMinus
onready var btn_max_amount = $InputAmount/ButtonMax
onready var btn_min_amount = $InputAmount/ButtonMin
onready var btn_yes = $InputAmount/ButtonYes
onready var btn_no = $InputAmount/ButtonNo

onready var cooking_progress: TextureProgress = $CookingProgress
onready var cooking_progress_label: Label = $CookingProgress/CookingProgressLabel
onready var cooking_timer: Timer = $CookingTimer
onready var cooking_fire: TextureRect = $CookingFire

onready var general_particle = Utils.load_resource("res://efx/particles/GeneralParticle.tscn", "slot_particle", "general_particle")

onready var ui_manager = get_parent()
var character

var player_inventory = PlayerInventory
var putting_slot: SlotClass
var putting_item_amount: int = 1
onready var cooking_controller: CookingController = CookingController.new(self)
var inventory_slot_controller: InventorySlotController

var is_cooking: bool = false

func _ready():
	character = ui_manager.get_parent()
	for i in range(ingredient_slots.size()):
		ingredient_slots[i].connect("gui_input", self, "slot_gui_input", [ingredient_slots[i]])
		ingredient_slots[i].slot_index = i
		ingredient_slots[i].slotType = Constants.SlotType.COOKING_INGREDIENT
	
	for i in range(energy_slots.size()):
		energy_slots[i].connect("gui_input", self, "slot_gui_input", [energy_slots[i]])
		energy_slots[i].slot_index = i
		energy_slots[i].slotType = Constants.SlotType.COOKING_ENERGY

	item_slot.connect("gui_input", self, "slot_gui_input", [item_slot])
	item_slot.slot_index = 0
	item_slot.slotType = Constants.SlotType.CRAFTING_RELEASE
	item_slot.enable_tooltip = false

	cooking_button.connect("pressed", self, "_on_cooking_button_clicked")
	btn_plus_amount.connect("pressed", self, "plus_recipe_amount")
	btn_max_amount.connect("pressed", self, "max_recipe_amount")
	btn_minus_amount.connect("pressed", self, "minus_recipe_amount")
	btn_min_amount.connect("pressed", self, "min_recipe_amount")
	btn_yes.connect("pressed", self, "button_yes")
	btn_no.connect("pressed", self, "button_no")
	inventory_slot_controller = InventorySlotController.new(ui_manager, character)

	cooking_timer.connect("timeout", self, "_on_cooking_timer_timeout")


func _physics_process(delta: float) -> void:
	if cooking_progress.visible:
		update_cooking_progress()


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
	else:
		inventory_slot_controller.pick_item(_slot)


func able_to_put_into_slot(slot: SlotClass) -> bool:
	if slot.slotType == Constants.SlotType.CRAFTING_RELEASE:
		return false
	
	var holding_item = ui_manager.holding_item
	if holding_item == null:
		return true
		
	var _h_item_data: Dictionary = JsonData.item_data[holding_item.item_name]
	var _can_be_cooked: bool = _h_item_data["Cook"] if _h_item_data.has("Cook") else false
	
	if slot.slotType == Constants.SlotType.COOKING_INGREDIENT:
		return _can_be_cooked
	elif slot.slotType == Constants.SlotType.COOKING_ENERGY:
		var _energy: int = _h_item_data["CookingEnergy"] if _h_item_data.has("CookingEnergy") else 0
		return _energy > 0

	return false


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


#cooking timer timeout
func _on_cooking_timer_timeout() -> void:
	release_food()


#cooking button clicked
func _on_cooking_button_clicked() -> void:
	if not is_cooking:
		var cooked = cook()
		# efx
		if not cooked:
			return
		efx_slots_having_item()
		Utils.button_click_scale(cooking_button, Vector2(0.7, 0.7), Vector2(0.8, 0.8),  0.1)
		# sfx
		GameManager.audio_manager.play_main_sound(GameManager.audio_manager.crafting)
		# ui
		disable_input_amount_panel()
		switch_state_to_cooking(true)
	else:
		release_food()


func release_food() -> void:
	switch_state_to_cooking(false)
	var food: Dictionary = cooking_controller.release_food()
	if food.cooked:
		var food_name: String = food.food_name
		var dish_amount: int = food.dish_amount
		
		put_item_into_slot(item_slot, food_name, dish_amount)
	else:
		cooking_controller.return_cooking_ingredients()

	var unused_energy: int = food.unused_energy
	return_unused_energy(unused_energy)
	cooking_controller.clean_kitchen()


func return_unused_energy(_unused_energy: int) -> void:
	if _unused_energy <= 0:
		return
	
	PlayerInventory.add_energy_item("gas", _unused_energy)


func put_item_into_slot(_slot: SlotClass, _item_name: String, _item_amount: int = 1) -> void:
	if _slot.item != null:
		_slot.item.set_item(_item_name, _item_amount, {}, character.stats_manager.stats.lvl)
	else:
		_slot.initialize_item(_item_name, _item_amount, {}, character.stats_manager.stats.lvl)


func cook() -> bool:
	var cook_result: Dictionary = cooking_controller.cook(ingredient_slots, energy_slots)

	if not cook_result.empty():
		var not_cooked_ingredients: Dictionary = cook_result.not_cooked_ingredients
		var keep_energy: bool = cook_result.keep_energy
		remove_all_item_in_slots(ingredient_slots)
		if not keep_energy:
			remove_all_item_in_slots(energy_slots)
		return_all_not_cooked_ingredients(not_cooked_ingredients)
		return true
	else:
		return false


func return_all_not_cooked_ingredients(_not_cooked_ingredients: Dictionary):
	for _ingredient in _not_cooked_ingredients:
		PlayerInventory.add_item(_ingredient, _not_cooked_ingredients[_ingredient])


func remove_all_item_in_slots(_slots: Array):
	for _slot in _slots:
		remove_slot_item(_slot)


func remove_slot_item(_slot: SlotClass) -> void:
	if _slot.item == null:
		return
	_slot.removeSlotItem()


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
	cooking_button.disabled = true
	item_slot.disconnect("gui_input", self, "slot_gui_input")

	yield(tween, "tween_completed")
	cooking_button.disabled = false
	item_slot.connect("gui_input", self, "slot_gui_input", [item_slot])


func enable_loading_bar(enable):
	loading_bar.visible = enable


func tween_loading_bar():
	var tween = loading_bar.get_node("Tween")
	Utils.start_tween(tween, loading_bar, "value", 0, 100, 0.85, Tween.TRANS_EXPO, Tween.EASE_OUT)
	yield(tween, "tween_completed")
	enable_loading_bar(false)

#endregion

func get_cooking_timer_timeleft() -> float:
	return cooking_timer.get_time_left()


#region: switch slots and progress
func set_slots_visible(_visible: bool = true) -> void:
	slots_holder.visible = _visible


func set_c_progress_visible(_visible: bool = true) -> void:
	cooking_progress.visible = _visible


func switch_slots_progress(_slots_to_progress: bool = true) -> void:
	set_slots_visible(!_slots_to_progress)
	set_c_progress_visible(_slots_to_progress)


func switch_state_to_cooking(_to_cooking: bool = true) -> void:
	is_cooking = _to_cooking
	switch_slots_progress(_to_cooking)
	set_cooking_fire_visible(_to_cooking)
	change_text_cooking_button(_to_cooking)


func set_cooking_fire_visible(_visible: bool = true) -> void:
	cooking_fire.visible = _visible


func change_text_cooking_button(_is_cooking: bool = true) -> void:
	cooking_button_label.text = "GET FOOD" if _is_cooking else "COOK"

#endregion


#region: cooking progress controller
func update_cooking_progress() -> void:
	var cooked_time_stats: Dictionary = cooking_controller.get_cooked_time_stats()
	var progress_percent: float = cooked_time_stats.cooked_time_percent
	var quality_percent: float = cooked_time_stats.quality_percent
	var current_food_quality: String = cooking_controller.time_percent_to_cooking_quality(quality_percent)
	var quality_text: String = cooking_controller.get_quality_full_text(current_food_quality)

	cooking_progress.tint_progress = cooking_controller.QualityProgressColor[current_food_quality]
	cooking_progress.value = progress_percent
	cooking_progress_label.text = Utils.float_to_time_format(get_cooking_timer_timeleft(), true, true) + " - " + quality_text

#endregion

