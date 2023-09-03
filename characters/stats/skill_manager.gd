extends Node
class_name ActorSkillManager

#{"skill_name": Skill}
var skill_list: Dictionary = {}
var stats_manager
var host

var available_skill_point: int = 0 setget set_available_skill_point


func _init(_stats_manager, _host) -> void:
	stats_manager = _stats_manager
	host = _host
	reload_skill_list()


func reload_skill_list():
	set_host_skill_list()
	active_all_passive_skills()


func set_host_skill_list() -> void:
	skill_list.clear()
	for _skill_name in stats_manager.host_class.skill_list:
		var _skill: Skill = Skill.new(_skill_name)
		skill_list[_skill.skill_name] = _skill


func active_all_passive_skills():
	for _skill_name in skill_list:
		var _skill: Skill = skill_list[_skill_name]
		if is_passive_skill(_skill) and skill_list[_skill_name].lvl > 0:
			active_passive_skill(_skill)


func active_passive_skill(_skill: Skill):
	stats_manager.attack_library.skill(_skill, null, Constants.AttackList.BASIC_BUFF, false)

func deactive_passive_skill(_skill: Skill):
	stats_manager.buff_manager.force_delete_buff(_skill.skill_buff_info.buff_name)


func lvl_up_skill(_skill_name: String, _lvl_up_num: int = 1):
	var _skill_past_lvl: int = skill_list[_skill_name].lvl
	skill_list[_skill_name].lvl_up(_lvl_up_num)
	var _skill_current_lvl: int = skill_list[_skill_name].lvl
	if is_passive_skill(skill_list[_skill_name]):
		if skill_list[_skill_name].lvl > 0:
			active_passive_skill(skill_list[_skill_name])
		else:
			deactive_passive_skill(skill_list[_skill_name])
	
	if skill_list[_skill_name].skill_info.skill_type != Constants.SkillType.PASSIVE:
		if _skill_past_lvl == 0 and _skill_current_lvl > 0:
			SignalManager.emit_signal("skill_create", skill_list[_skill_name], host)
		elif _skill_past_lvl > 0 and _skill_current_lvl == 0:
			SignalManager.emit_signal("skill_remove", skill_list[_skill_name], host)


func is_passive_skill(_skill: Skill) -> bool:
	return _skill.skill_info.skill_type == Constants.SkillType.PASSIVE


func set_available_skill_point(_new_value: int):
	available_skill_point = _new_value
	SignalManager.emit_signal("update_character_skill_tab", host, true)


func use_skill_point(_skill_name: String):
	if available_skill_point <= 0:
		return
	
	lvl_up_skill(_skill_name)
	set_available_skill_point(available_skill_point - 1)
	GameManager.save_load_manager.character_save.character_save(host)


func refund_skill_point(_skill_name: String, _refund_num: int):
	lvl_up_skill(_skill_name, -_refund_num)
	set_available_skill_point(available_skill_point + _refund_num)
	SignalManager.emit_signal("update_character_skill_tab", host, true)
	GameManager.save_load_manager.character_save.character_save(host)


func load_skill_points_from_save(_save_data: Dictionary):
	set_available_skill_point(_save_data.stats.unspend_skill_points)
	for _skill_name in _save_data.skills:
		if skill_list.has(_skill_name) and _save_data.skills[_skill_name] > 0:
			lvl_up_skill(_skill_name, _save_data.skills[_skill_name])
		else:
			set_available_skill_point(available_skill_point + _save_data.skills[_skill_name])
