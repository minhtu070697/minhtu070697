extends Node2D
class_name LivestockBarnInventory


const LIVESTOCK_ICON_PATH = "res://animals/livestocks/buildings/livestock_icon/%s_icon.png"
onready var livestock_slots_holder = $ScrollContainer/VBoxContainer
onready var ui_manager = get_parent()
onready var livestock_slots = livestock_slots_holder.get_children()
onready var tween = $Tween
onready var bell_ring_button = $BellRingButton

onready var character

var seed_inventory

var selecting_barn = null
var farm_bell_ring_sound

var hiding_inventory: bool = false


func _ready():
	for i in range(livestock_slots.size()):
		livestock_slots[i].connect("gui_input", self, "slot_gui_input", [livestock_slots[i]])
	
	bell_ring_button.connect("button_up", self, "_on_bell_ring_button_clicked")
	#NUYG: add character for easy access, use yield to wait for character stats calculate before create equipment
	character = ui_manager.get_parent()
	seed_inventory = character.get_node_or_null("ui/SeedInventory")
	farm_bell_ring_sound = Utils.load_resource("res://animals/livestocks/buildings/sounds/farm_bell.mp3", "livestock_barn", "bell_sound")
	SignalManager.connect("mouse_left_clicked", self, "_on_mouse_left_clicked_outside")


func initialize_livestocks():
	for i in selecting_barn.barn_info.livestock_inside.size():
		var _livestock_name: String = selecting_barn.barn_info.livestock_inside[i]
		if i >= livestock_slots.size():
			initialize_livestock_slot()
		
		livestock_slots[i].livestock_icon.texture = Utils.load_resource(LIVESTOCK_ICON_PATH % _livestock_name, _livestock_name, "icon")
		livestock_slots[i].livestock_name = _livestock_name
		livestock_slots[i].name_label.text = _livestock_name
		livestock_slots[i].amount_left_label.text = String(selecting_barn.livestock_amount_left(_livestock_name))
		livestock_slots[i].visible = true
	var _empty_livestock_slot: int = livestock_slots.size() - selecting_barn.barn_info.livestock_inside.size()
	if _empty_livestock_slot > 0:
		for _empty_slot_num in _empty_livestock_slot:
			livestock_slots[_empty_slot_num + selecting_barn.barn_info.livestock_inside.size()].visible = false


func initialize_livestock_slot():
	var _new_animal_slot = livestock_slots[-1].duplicate()
	livestock_slots_holder.add_child(_new_animal_slot)
	livestock_slots.append(_new_animal_slot)
	_new_animal_slot.connect("gui_input", self, "slot_gui_input", [_new_animal_slot])


func slot_gui_input(event: InputEvent, slot: BarnInventorySlot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			# logic
			create_livestock(slot)

			# efx + sfx
			GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)


func create_livestock(_slot: BarnInventorySlot):
	if _slot.livestock_name != "":
		selecting_barn.create_livestock(_slot.livestock_name)


func show_barn_inventory():
	connect_barn_signal()
	check_and_hide_seed_inventory()

	visible = true
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	#logic
	initialize_livestocks()


func hide_barn_inventory():
	if hiding_inventory or !visible:
		return
	disconnect_barn_signal()
	hiding_inventory = true
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	yield(tween, "tween_completed")
	visible = false
	hiding_inventory = false


func _on_bell_ring_button_clicked():
	Utils.play_sound(character.audio_player, farm_bell_ring_sound, 16)
	if selecting_barn.is_calling:
		return
	selecting_barn.return_to_barn_call()


func _on_mouse_left_clicked_outside() -> void:
	hide_barn_inventory()


func check_and_hide_seed_inventory() -> void:
	if not seed_inventory:
		return
	if seed_inventory.visible:
		seed_inventory.hide_seed_inventory()


func connect_barn_signal() -> void:
	if !selecting_barn.is_connected("update_barn_inventory", self, "update_barn_inventory"):
		selecting_barn.connect("update_barn_inventory", self, "update_barn_inventory")


func disconnect_barn_signal() -> void:
	if selecting_barn.is_connected("update_barn_inventory", self, "update_barn_inventory"):	
		selecting_barn.disconnect("update_barn_inventory", self, "update_barn_inventory")


func update_barn_inventory() -> void:
	if not Utils.node_exists(selecting_barn):
		return
	for i in selecting_barn.barn_info.livestock_inside.size():
		var _livestock_name: String = selecting_barn.barn_info.livestock_inside[i]
		livestock_slots[i].amount_left_label.text = String(selecting_barn.livestock_amount_left(_livestock_name))

