extends Button
class_name SkillSlot

var skill = null
var skill_bar

enum SlotType {
	NORMAL,
	AURA
}


func _ready():
	pass


func remove_skill_item():
	if !Utils.node_exists(skill):
		skill = null
		return
	remove_child(skill)
	skill_bar.add_child(skill)
	skill = null


func add_skill_item(_skill_item: SkillItem):
	if skill == _skill_item:
		return
	
	remove_skill_item()
	skill = _skill_item
	skill_bar.remove_child(skill)
	add_child(skill)
	move_child(skill, 0)
