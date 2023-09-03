class_name FighterUtils


static func get_atk_proj_info(atk_info: Dictionary) -> Dictionary:
	var return_info: Dictionary = {
		"proj_name": "",
		"proj_num": 1,
		"proj_range": 0,
		"proj_arc": 0,
		"proj_speed": Constants.PROJECTILE_DEFAULT,
		"proj_dmg": {},
		"proj_fxs": {},
	}
	
	if atk_info.has("proj_info") and atk_info.proj_info.has("proj_name"):
		var proj_info: Dictionary = atk_info.proj_info
		
		for key in proj_info:
			if return_info.has(key):
				return_info[key] = proj_info[key]

	return return_info


static func get_atk_hit_area(atk_info: Dictionary, equipment_manager: EquipmentManager) -> Dictionary:
	var hit_range: int = 0
	var hit_arc: int = 0
	var wp_hit_area: Dictionary = equipment_manager.get_weapon_hit_area()
	if atk_info.has("hit_range"):
		hit_range = atk_info.hit_range
	else:
		hit_range = wp_hit_area.hit_range
	
	if atk_info.has("hit_arc"):
		hit_arc = atk_info.hit_arc
	else:
		hit_arc = wp_hit_area.hit_arc
	
	return {
		"hit_range": hit_range,
		"hit_arc": hit_arc,
	}
