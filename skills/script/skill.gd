extends Node
class_name Skill

var skill_info: SkillResources
var skill_buff: Dictionary = {}
var skill_buff_info: Dictionary = {}
var skill_name := ""
var lvl := 0
var cooldown := 0.0

#requirement
var hp_req := 0
var mana_req := 0
var range_of_skill := 1

#stats
var p_dmg := 0
var m_dmg := 0
var weapon_dmg := 0.0

var fire_dmg := 0
var cold_dmg := 0
var lightning_dmg := 0
var poison_dmg := 0

var freeze_length := 0.0
var freeze_strength := 0.0

var poison_length := 0.0

var CALCULATE_STAT_LIST = ["cooldown", "hp_req", "mana_req", "range_of_skill", "p_dmg", "m_dmg", "weapon_dmg", "fire_dmg", "cold_dmg", "lightning_dmg", "poison_dmg", "freeze_length", "freeze_strength", "poison_length"]


func get_skill_dmg_stats() -> Dictionary:
	return {
		"p_dmg": p_dmg,
		"m_dmg": m_dmg,
		"weapon_dmg": weapon_dmg,
		"fire_dmg": fire_dmg,
		"cold_dmg": cold_dmg,
		"lightning_dmg": lightning_dmg,
		"poison_dmg": poison_dmg,
		"freeze_length": freeze_length,
		"freeze_strength": freeze_strength,
		"poison_length": poison_length,
		"p_dmg_diff": skill_info.p_dmg_diff,
		"m_dmg_diff": skill_info.m_dmg_diff,
		"weapon_dmg_diff": skill_info.weapon_dmg_diff,
		"fire_dmg_diff": skill_info.fire_dmg_diff,
		"cold_dmg_diff": skill_info.cold_dmg_diff,
		"lightning_dmg_diff": skill_info.lightning_dmg_diff,
		"poison_dmg_diff": skill_info.poison_dmg_diff,
}


func _init(_name: int = Constants.SkillList.BASIC_ATTACK) -> void:
	skill_name = Constants.SkillNameList[_name]
	
	if _name == Constants.SkillList.BASIC_ATTACK:
		return
		
	load_skill_info()
	calculate_skill_stats()


func load_skill_info():
	skill_info = SkillResources.new(GameResourcesLibrary.skill_resources_list_json[skill_name])
	

func calculate_skill_stats():
	for _stat in CALCULATE_STAT_LIST:
		calculate_stat(_stat)
	
	if skill_info.buffs != "":
		var _skill_buff_data : Dictionary = GameResourcesLibrary.stat_buff_list_json[skill_info.buffs] 
		var _got_name: bool = false
		var _got_buff_length: bool = false
		for _buff in _skill_buff_data:
			if !_got_name:
				if _buff ==	"buff_name":
					skill_buff_info[_buff] = _skill_buff_data[_buff]
					_got_name = true
					continue
			
			if _buff.begins_with("base_"):
				var _stat_buff_name = _buff.replacen("base_", "")

				if !_got_buff_length:
					if _stat_buff_name == "buff_length":
						skill_buff_info[_stat_buff_name] = _skill_buff_data[_buff] + _skill_buff_data[_stat_buff_name + "_lvl_up"] * (lvl - 1)
						_got_buff_length = true
						continue
				
				skill_buff[_stat_buff_name] = _skill_buff_data[_buff] + _skill_buff_data[_stat_buff_name + "_lvl_up"] * (lvl - 1)


func calculate_stat(_stat_name: String):
	var _stat = get(_stat_name)
	var _stat_basic = skill_info.get("base_" + _stat_name)
	var _stat_lvl_up = skill_info.get(_stat_name + "_lvl_up")
	
	_stat = _stat_basic + _stat_lvl_up * (lvl - 1)
	set(_stat_name, _stat)


func lvl_up(_lvl_number: int = 1):
	lvl += _lvl_number
	
	calculate_skill_stats()
