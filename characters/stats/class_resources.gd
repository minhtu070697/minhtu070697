
extends Resource
class_name ClassResources

export(String) var owner_class
export var owner_type = ["enemy"]
#Basic Stats
export(float) var str_basic: float = 0.1
export(float) var agi_basic: float = 0.1
export(float) var int_basic: float = 0.1
export(float) var vit_basic: float = 0.1
export(float) var base_walk_speed: float = 1.2
export(float) var base_atk_speed: float = 1
export(float) var base_crit_dmg: float = 1.25
export(float) var class_hp_multiplier: float = 2
export(float) var class_mana_multiplier: float = 2
export(int) var base_hp = 20
export(int) var base_mana = 20

#Stats increase when lvl up
export(float) var str_lvlup: float = 0.1
export(float) var agi_lvlup: float = 0.1
export(float) var int_lvlup: float = 0.1
export(float) var vit_lvlup: float = 0.1

#Maximun elemental resistance
export(float) var fire_resist_max: float = 0.75
export(float) var cold_resist_max: float = 0.75
export(float) var lightning_resist_max: float = 0.75
export(float) var poison_resist_max: float = 0.75


export(Array, Constants.SkillList) var skill_list = [Constants.SkillList.FIRE_BALL]

func _init(_class_data: Dictionary) -> void:
	for _var in _class_data:
		set(_var, Utils.convert_json_data_to_godot_var(_class_data[_var]))

