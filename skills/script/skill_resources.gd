extends Resource
class_name SkillResources


export(String) var skill_name := "fire_ball"
export(String, MULTILINE) var desc := ""

export(String, FILE) var icon_image := "res://characters/textures/basic_action/axe-01-basic_action.png"
export(int) var lvl := 1
export(Constants.SkillType) var skill_type := Constants.SkillType.ACTIVE

export(bool) var is_target := true

export(float) var base_cooldown := 0.0
export(float) var cooldown_lvl_up := 0.0


#requirement 
export(int) var base_hp_req := 0
export(int) var hp_req_lvl_up := 0

export(int) var base_mana_req := 0
export(int) var mana_req_lvl_up := 0

export (int) var base_range_of_skill := 5
export(float) var range_of_skill_lvl_up := 0.2

#stats of skill
export(float) var base_p_dmg := 0.0
export(float) var p_dmg_lvl_up := 0.0
export(float, 0.0, 1.0) var p_dmg_diff := 0.0 #percent

export(float) var base_m_dmg := 0.0
export(float) var m_dmg_lvl_up := 0.0
export(float, 0.0, 1.0) var m_dmg_diff := 0.0 #percent

export(float) var base_weapon_dmg := 0.0 #percent
export(float) var weapon_dmg_lvl_up := 0.0 #percent
export(float, 0.0, 1.0) var weapon_dmg_diff := 0.0 #percent

export(float) var base_fire_dmg := 0.0 
export(float) var fire_dmg_lvl_up := 0.0 
export(float, 0.0, 1.0) var fire_dmg_diff := 0.0 #percent

export(float) var base_cold_dmg := 0.0 
export(float) var cold_dmg_lvl_up := 0.0 
export(float, 0.0, 1.0) var cold_dmg_diff := 0.0 #percent

export(float, 0.0, 1.0) var base_freeze_strength := 0.0 #percent
export(float, 0.0, 1.0) var freeze_strength_lvl_up := 0.0 #percent

export(float) var base_freeze_length:= 0.0 #second
export(float) var freeze_length_lvl_up := 0.0 #second

export(float) var base_lightning_dmg := 0.0 
export(float) var lightning_dmg_lvl_up := 0.0 
export(float, 0.0, 1.0) var lightning_dmg_diff := 0.0 #percent

export(float) var base_poison_dmg := 0.0 
export(float) var poison_dmg_lvl_up := 0.0 
export(float, 0.0, 1.0) var poison_dmg_diff := 0.0 #percent

export(float) var base_poison_length:= 0.0 #second
export(float) var poison_length_lvl_up := 0.0 #second

#buff... do later


#projectiles
export(String) var projectile_name := "" #Name of projectile
export(int, -1, 50) var number_of_projectiles := 0

#attack host would do when use this skill
export(Constants.AttackList) var attack_name := Constants.AttackList.BASIC_ATTACK
export(String) var skill_sound: String = "fire_skill"

export(String) var buffs: String = ""

export(Array) var prerequisite_skills: Array = []
export(int) var require_lvl: int = 1

func _init(_skill_data: Dictionary) -> void:
	for _var in _skill_data:
		set(_var, Utils.convert_json_data_to_godot_var(_skill_data[_var]))
