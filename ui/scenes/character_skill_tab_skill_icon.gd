extends TextureButton
class_name CharacterSkillTabSkillIcon

onready var skill_level = $SkillLevel/SkillLevel
onready var skill_level_up_button = $SkillLvlUpButton
var skill_name: String
var skill: Skill
var character: Character
var character_skill_tab

enum TooltipStatType{NUMBER, PERCENT, SECOND}
#tooltip
onready var tooltip := $Tooltip
onready var tt_skill_name := $Tooltip/VBoxContainer/VBoxContainer/SkillName
onready var tt_skill_desc := $Tooltip/VBoxContainer/VBoxContainer/SkillDesc
onready var tt_skill_lvl := $Tooltip/VBoxContainer/VBoxContainer/SkillLvl

onready var tt_skill_stats_box := $Tooltip/VBoxContainer/SkillStatsBox

onready var tt_skill_range := $Tooltip/VBoxContainer/VBoxContainer2/SkillRange
onready var tt_skill_mana_cost := $Tooltip/VBoxContainer/VBoxContainer2/SkillManaCostText
onready var tt_skill_cooldown := $Tooltip/VBoxContainer/VBoxContainer2/SkillCooldown
onready var tt_skill_prerequisite := $Tooltip/VBoxContainer/VBoxContainer2/SkillPrerequisite
onready var tt_skill_lvl_require := $Tooltip/VBoxContainer/VBoxContainer2/SkillLvlRequire

onready var tooltip_container := $Tooltip/VBoxContainer

var tt_buff_length_label: Label


var skill_stats: Dictionary = {}
var skill_stat_labels: Dictionary = {}
var skill_buff_labels: Dictionary = {}

func _ready() -> void:
	connect("button_up", self, "on_skill_icon_clicked")
	skill_level_up_button.connect("button_up", self, "_on_skill_lvl_up_button_clicked")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	tooltip.rect_size.y = 10


func update_skill_level():
	skill_level.text = Utils.to_text(skill.lvl)


func init(_skill: Skill, _character: Character, _character_skill_tab):
	skill = _skill
	skill_name = skill.skill_name
	character = _character
	texture_normal = load(skill.skill_info.icon_image)
	character_skill_tab = _character_skill_tab
	set_skill_stats_dictionary()
	create_tooltip_skill_stats()
	create_tooltip_buff_stats()
	update_tooltip()


func set_tooltip_position():
	tooltip.rect_position.y = -15 - tooltip_container.rect_size.y


func set_skill_stats_dictionary():
	skill_stats = {
	"p_dmg": [skill.p_dmg, TooltipStatType.NUMBER],
	"m_dmg": [skill.m_dmg, TooltipStatType.NUMBER],
	"weapon_dmg": [skill.weapon_dmg, TooltipStatType.PERCENT],
	"fire_dmg": [skill.fire_dmg, TooltipStatType.NUMBER],
	"cold_dmg": [skill.cold_dmg, TooltipStatType.NUMBER],
	"lightning_dmg": [skill.lightning_dmg, TooltipStatType.NUMBER],
	"poison_dmg": [skill.poison_dmg, TooltipStatType.NUMBER]
	}


func update_skill_stats_dictionary():
	for _stat_label_name in skill_stat_labels:
		skill_stat_labels[_stat_label_name][1] = skill.get(_stat_label_name)


func _on_skill_lvl_up_button_clicked() -> void:
	if character.stats_manager.skill_manager.available_skill_point <= 0:
		return
		
	character.stats_manager.skill_manager.use_skill_point(skill_name)
	update_skill_icon()
	add_refundable_spended_skill_point()
	set_visible_cancel_ok_buttons()


func update_skill_icon():
	update_skill_level()
	skill_level_up_button.visible = check_and_enable_skill_icon()


func add_refundable_spended_skill_point():
	character_skill_tab.refundable_spended_skill_points[skill_name] = (character_skill_tab.refundable_spended_skill_points[skill_name] + 1) if character_skill_tab.refundable_spended_skill_points.has(skill_name) else 1


func check_and_enable_skill_icon() -> bool:
	if character.stats_manager.skill_manager.available_skill_point <= 0:
		return false
	
	var _enable: bool = character_meet_lvl_req()
	_enable = _enable and character_has_all_prereq_skills()
	return _enable


func character_meet_lvl_req() -> bool:
	var _max_skill_lvl_at_character_current_lvl = character.stats_manager.stats.lvl - skill.skill_info.require_lvl + 1
	return skill.lvl < min(Constants.MAX_SKILL_LVL, _max_skill_lvl_at_character_current_lvl)


func character_has_all_prereq_skills() -> bool:
	var result: bool = true
	for _prerequisite_skill_name in skill.skill_info.prerequisite_skills:
		result = result and character_skill_tab.host_skill_list[_prerequisite_skill_name].lvl > 0
	return result


func set_visible_cancel_ok_buttons(_visible: bool = true):
	character_skill_tab.cancel_button.visible = _visible
	character_skill_tab.ok_button.visible = _visible


func _on_mouse_entered():
	update_tooltip()
	tooltip.visible = true


func _on_mouse_exited():
	tooltip.visible = false


func update_tooltip():
	tt_skill_name.text = skill.skill_name.capitalize() + " (%s)" %Constants.SkillTypeString[skill.skill_info.skill_type]
	tt_skill_desc.text = skill.skill_info.desc
	
	tt_skill_lvl.text = "Level: " + Utils.to_text(skill.lvl)
	tt_skill_lvl.text += " (MAX LEVEL)" if skill.lvl >= Constants.MAX_SKILL_LVL else ""
	
	
	if skill.skill_info.skill_type == Constants.SkillType.PASSIVE:
		tt_skill_range.visible = false
		tt_skill_mana_cost.visible = false
		tt_skill_cooldown.visible = false
	else:
		tt_skill_range.text = "Skill Range: " + Utils.to_text(skill.range_of_skill) 
		tt_skill_mana_cost.text = "Mana cost: " + Utils.to_text(skill.mana_req)
		tt_skill_cooldown.text = "Cooldown: " + Utils.to_text(skill.cooldown)
	
	tt_skill_prerequisite.text = "Prerequisite: "
	for _prerequisite_skill in skill.skill_info.prerequisite_skills:
		tt_skill_prerequisite.text += _prerequisite_skill.capitalize() + ", "
	if tt_skill_prerequisite.text != "Prerequisite: ":
		tt_skill_prerequisite.visible = true
		tt_skill_prerequisite.text = tt_skill_prerequisite.text.trim_suffix(", ")
		if not character_has_all_prereq_skills():
			tt_skill_prerequisite.set("custom_colors/font_color", Constants.RED_PROGRESS_COLOR)
		else:
			tt_skill_prerequisite.set("custom_colors/font_color", Constants.NORMAL_COLOR)
	else:
		tt_skill_prerequisite.visible = false

	tt_skill_lvl_require.text = "Lvl require: "+ Utils.to_text(skill.skill_info.require_lvl + skill.lvl)
	if not character_meet_lvl_req():
		tt_skill_lvl_require.set("custom_colors/font_color", Constants.RED_PROGRESS_COLOR)
	else:
		tt_skill_lvl_require.set("custom_colors/font_color", Constants.NORMAL_COLOR)
	
	update_tooltip_skill_stats()
	update_tooltip_buff_stats()
	set_tooltip_position()


func update_tooltip_skill_stats():
	update_skill_stats_dictionary()
	for _stat_label_name in skill_stat_labels:
		var _multiplier: int
		var _percent_text: String
		var _min_stat: String
		var _max_stat: String
			
		if skill_stat_labels[_stat_label_name][2] == TooltipStatType.PERCENT:
			_multiplier = 100
			_percent_text = "%"
		elif skill_stat_labels[_stat_label_name][2] == TooltipStatType.NUMBER:
			_multiplier = 1
			_percent_text = ""
		elif skill_stat_labels[_stat_label_name][2] == TooltipStatType.SECOND:
			_percent_text = " seconds"
			_min_stat = Utils.to_text_float(skill_stat_labels[_stat_label_name][1], 2) + _percent_text
			skill_stat_labels[_stat_label_name][0].text = _stat_label_name.capitalize() + ": %s" %_min_stat
			continue
		
		_min_stat = Utils.to_text(skill_stat_labels[_stat_label_name][1] * (1 - get_stat_diff(_stat_label_name)) * _multiplier) + _percent_text
		_max_stat = Utils.to_text(skill_stat_labels[_stat_label_name][1] * (1 + get_stat_diff(_stat_label_name)) * _multiplier) + _percent_text
		skill_stat_labels[_stat_label_name][0].text = _stat_label_name.capitalize() + (": %s - %s" %[_min_stat, _max_stat] if _min_stat != _max_stat else ": %s" %_min_stat)


func get_stat_diff(_stat_name: String) -> float:
	var _stat_diff = skill.skill_info.get(_stat_name + "_diff")
	return _stat_diff if _stat_diff != null else 0.0


func create_tooltip_skill_stats():
	empty_skill_stats_label()
	for _stat in skill_stats:
		if skill_stats[_stat][0] != 0:
			skill_stat_labels[_stat] = [create_tooltip_skill_stat(_stat), skill_stats[_stat][0], skill_stats[_stat][1]]
			if _stat == "cold_dmg":
				skill_stat_labels["freeze_strength"] = [create_tooltip_skill_stat("freeze_strength"), skill.freeze_strength, TooltipStatType.PERCENT]
				skill_stat_labels["freeze_length"] = [create_tooltip_skill_stat("freeze_length"), skill.freeze_length, TooltipStatType.SECOND]
			elif _stat == "poison_dmg":
				skill_stat_labels["poison_length"] = [create_tooltip_skill_stat("poison_length"), skill.poison_length, TooltipStatType.SECOND]


func empty_skill_stats_label():
	for _labels in skill_stat_labels:
		skill_stat_labels[_labels][0].queue_free()
	skill_stat_labels.clear()


func create_tooltip_skill_stat(_stat_name: String) -> Label:
	var _dmg_label = GameResourcesLibrary.TOOLTIP_LABEL.instance()
	_dmg_label.name = _stat_name
	tt_skill_stats_box.add_child(_dmg_label)
	return _dmg_label


func empty_skill_buff_labels():
	for _labels in skill_buff_labels:
		skill_buff_labels[_labels].queue_free()
	skill_buff_labels.clear()


func create_tooltip_buff_stats():
	empty_skill_buff_labels()
	for _buff_stat_name in skill.skill_buff:
		skill_buff_labels[_buff_stat_name] = create_tooltip_skill_stat(_buff_stat_name)
		
	if skill_buff_labels.size() > 0:
		tt_buff_length_label = create_tooltip_skill_stat("buff_last")


func update_tooltip_buff_stats():
	for _buff_label_name in skill_buff_labels:
		var _multiplier: int = 100 if _buff_label_name.ends_with("_buff") else 1
		var _percent_text: String = "%" if _buff_label_name.ends_with("_buff") else ""
		var _stat: String = Utils.to_text(skill.skill_buff[_buff_label_name] * _multiplier) + _percent_text
		skill_buff_labels[_buff_label_name].text = _buff_label_name.capitalize() + ": %s" %_stat
	
	if skill_buff_labels.size() > 0 and skill.skill_info.skill_type != Constants.SkillType.PASSIVE:
		tt_buff_length_label.text = "Buff Last: " + Utils.to_text(skill.skill_buff_info.buff_length) + " seconds"


func on_skill_icon_clicked():
	#show side tab -> choose where to put skill
	if skill.skill_info.skill_type != Constants.SkillType.PASSIVE and skill.lvl > 0:                                                      
		character_skill_tab.toggle_select_skill_buttons(true)
		character_skill_tab.select_a_skill(skill)
