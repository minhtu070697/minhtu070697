extends Node2D

#const
const skill_slot_scene := preload("res://ui/scenes/character_skill_tab_skill_icon.tscn")

#var
onready var ui_manager = get_parent().get_parent()
onready var character = ui_manager.get_parent()
onready var skill_bar
onready var stats_button = ui_manager.get_node_or_null("GroupHUD").get_node_or_null("StatsButton")
var stats_manager: StatsManager

onready var skillbar_slots = $VBoxContainer2/SkillGridSlot
onready var slots: Array = []

onready var available_skill_point_value = $VBoxContainer2/VBoxContainer/AvailableSkillPoint/AvailableSkillPointValue
onready var available_skill_point_box = $VBoxContainer2/VBoxContainer/AvailableSkillPoint

onready var cancel_button = $VBoxContainer2/Buttons/Cancel/CancelButton
onready var ok_button = $VBoxContainer2/Buttons/Cancel/OKButton

onready var select_skill_buttons_holder = $VBoxContainer/SelectSkillButtons
onready var select_skill_buttons: Array = $VBoxContainer/SelectSkillButtons.get_children()

onready var remove_all_skill_slots_button = $VBoxContainer/RemoveAllSkillSlotsButton/RemoveAllSkillSlotsButton

var host_skill_list: Dictionary

var refundable_spended_skill_points: Dictionary = {}


var selecting_skill: Skill = null


func _ready():
	SignalManager.connect("update_character_skill_tab", self, "_on_update_character_skill_tab")
	SignalManager.connect("init_character_skill_tab", self, "_on_init_character_skill_tab")
	cancel_button.connect("button_up", self, "_on_cancel_button_clicked")
	ok_button.connect("button_up", self, "_on_ok_button_clicked")
	yield(character,"ready")
	stats_manager = character.get_node_or_null("StatsManager")
	if Utils.node_exists(stats_manager): host_skill_list = stats_manager.skill_manager.skill_list
	initialize_skill_bar()
	for i in select_skill_buttons.size():
		select_skill_buttons[i].connect("button_up", self, "_on_select_skill_buttons_clicked", [i])
	remove_all_skill_slots_button.connect("button_up", self, "_on_remove_all_skill_slots_button_clicked")
	skill_bar = ui_manager.get_node_or_null("Skillbar")
	if Utils.node_exists(stats_manager): stats_button.connect("button_up", self, "_on_stats_button_clicked")


func initialize_skill_bar():
	for i in host_skill_list.size():
		if i >= slots.size():
			add_skill_slot(host_skill_list.values()[i])
		else:
			change_skill_slot(host_skill_list.values()[i], slots[i])
	
	var _empty_skill_slot: int = slots.size() - host_skill_list.size()
	if _empty_skill_slot > 0:
		for _empty_slot_num in _empty_skill_slot:
			slots[_empty_slot_num + host_skill_list.size()].visible = false


func change_skill_slot(_skill: Skill, _skill_slot: CharacterSkillTabSkillIcon):
	_skill_slot.init(_skill, character, self)


func add_skill_slot(_skill: Skill):
	var _skill_slot = skill_slot_scene.instance()
	skillbar_slots.add_child(_skill_slot)
	_skill_slot.init(_skill, character, self)
	slots.append(_skill_slot)


func update_character_skills(_update_all_skill_icon: bool = true):
	update_available_stat_points()
	if _update_all_skill_icon:
		for _skill_icon in slots:
			_skill_icon.update_skill_icon()


func _on_stats_button_clicked() -> void:
	# visible = !visible
	if visible:
		update_character_skills()


func _on_update_character_skill_tab(_character_name, _update_all_skill_icon: bool = true):
	if _character_name != character or !visible:
		return
		
	update_character_skills(_update_all_skill_icon)


func _on_init_character_skill_tab(_character_name):
	if _character_name != character:
		return
		
	initialize_skill_bar()


func update_available_stat_points():
	available_skill_point_box.visible = stats_manager.skill_manager.available_skill_point > 0
	available_skill_point_value.text = Utils.to_text(stats_manager.skill_manager.available_skill_point)


func _on_cancel_button_clicked():
	refund_skill_point()
	set_visible_cancel_ok_buttons(false)

func _on_ok_button_clicked():
	reset_refundable_skill_point()
	set_visible_cancel_ok_buttons(false)


func set_visible_cancel_ok_buttons(_visible: bool = true):
	cancel_button.visible = _visible
	ok_button.visible = _visible


func refund_skill_point():
	for _skill_name in refundable_spended_skill_points:
		stats_manager.skill_manager.refund_skill_point(_skill_name, refundable_spended_skill_points[_skill_name])
	reset_refundable_skill_point()


func reset_refundable_skill_point():
	refundable_spended_skill_points.clear()


func _on_select_skill_buttons_clicked(_skill_slot_num: int):
	#init skill slot with selecting skill
	skill_bar.put_skill_into_skill_slot(_skill_slot_num, selecting_skill)
	toggle_select_skill_buttons(false)
	unselect_a_skill()


func _on_remove_all_skill_slots_button_clicked():
	skill_bar.remove_all_skill_slots()


func toggle_select_skill_buttons(_enable: bool = true):
	select_skill_buttons_holder.visible = _enable


func select_a_skill(_skill: Skill):
	selecting_skill = _skill


func unselect_a_skill():
	selecting_skill = null
