extends Node2D

onready var skillbar_slots = $SkillbarSlots
onready var active_item_label = $ActiveItemLabel
onready var slots = skillbar_slots.get_children()
onready var ui_manager = get_parent()

var character: Character
var skill_item_list: Dictionary = {}


func _unhandled_input(event):
	if event is InputEventKey:
		var skill_number = Utils.check_skill_active(event)
		if skill_number > 0:
			check_and_active_skill_slot(slots[skill_number - 1])


func _ready():
	SignalManager.connect("skill_slot_actived", self, "_on_skill_slot_actived")
	character = ui_manager.get_parent()
	yield(character,"ready")

	if not GameManager.is_outside_map_features():
		set_process_unhandled_input(false)
		visible = false
	
	for i in range(slots.size()):
		slots[i].connect("pressed", self, "slot_gui_input", [slots[i]])
		slots[i].skill_bar = self
	
	SignalManager.connect("skill_create", self, "_on_skill_item_create")
	SignalManager.connect("skill_remove", self, "_on_skill_item_remove")


func initialize_skill_item(_skill: Skill):
	var _skill_item = GameResourcesLibrary.SKILL_ITEM_SCENE.instance()
	add_child(_skill_item)
	_skill_item.set_item(_skill)
	skill_item_list[_skill.skill_name] = _skill_item


func remove_skill_item(_skill: Skill):
	skill_item_list[_skill.skill_name].queue_free()
	skill_item_list.erase(_skill.skill_name)


func slot_gui_input(_slot: SkillSlot):
	check_and_active_skill_slot(_slot)


func check_and_active_skill_slot(_slot: SkillSlot):
	if !Utils.node_exists(_slot.skill):
		_slot.skill = null
		return
	else:
		if _slot.skill.active:
			SignalManager.emit_signal("skill_slot_actived", _slot)


func _on_skill_slot_actived(_slot: SkillSlot):
	_slot.skill.skill_active()


func put_skill_into_skill_slot(_slot_num: int, _skill: Skill):
	if _slot_num >= slots.size() or !skill_item_list.has(_skill.skill_name):
		return
	
	if skill_item_list[_skill.skill_name].get_parent() is SkillSlot:
		skill_item_list[_skill.skill_name].get_parent().remove_skill_item()
	
	slots[_slot_num].add_skill_item(skill_item_list[_skill.skill_name])


func remove_all_skill_slots():
	for _slot in slots:
		_slot.remove_skill_item()

	
func _on_skill_item_create(_skill: Skill, _character):
	if character != _character:
		return
	
	initialize_skill_item(_skill)


func _on_skill_item_remove(_skill: Skill, _character):
	if character != _character:
		return
	
	remove_skill_item(_skill)
