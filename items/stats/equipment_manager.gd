extends Node
class_name EquipmentManager

#Var
var equipment_bonus_stat: Dictionary = {}
var equipment: Dictionary = {}
var weapon_range: float
var weapon_p_dmg: float = 0
var weapon_m_dmg: float = 0

var stats_manager

var farming_tools: Dictionary = Constants.EquipmentManagerFarmingToolsNewDict.duplicate()


func _init(_stats_manager):
	stats_manager = _stats_manager
	create_monster_equipment()
	cal_total_bonus_stat()
	update_weapon()
	set_farming_tools()


func cal_total_bonus_stat():
	equipment_bonus_stat.clear()
	for item in equipment:
		var item_stat_list = equipment[item].stats.stat_list
		for stat in item_stat_list:
			if not equipment_bonus_stat.has(stat):
				equipment_bonus_stat[stat] = 0
				
			equipment_bonus_stat[stat] += item_stat_list[stat]


# region: Weapon
func set_weapon_range():
	weapon_range = equipment["weapon"].stats.atk_range if equipment.has("weapon") else 1


func set_weapon_dmg():
	weapon_p_dmg = equipment["weapon"].stats.p_dmg if equipment.has("weapon") else 0
	weapon_m_dmg = equipment["weapon"].stats.m_dmg if equipment.has("weapon") else 0


func get_weapon_hit_area() -> Dictionary:
	var hit_range: int = equipment["weapon"].stats.hit_range if equipment.has("weapon") else 0
	var hit_arc: int = equipment["weapon"].stats.hit_arc if equipment.has("weapon") else 0
	return {
		"hit_range": hit_range,
		"hit_arc": hit_arc,
	}


func get_wp_default_anim() -> String:
	return equipment["weapon"].item_info.atk_animation if equipment.has("weapon") else ""


func get_weapon_max_combo() -> int:
	  return equipment["weapon"].stats.max_combo if equipment.has("weapon") else 1


func get_wp_combo_info() -> Dictionary:
	return equipment["weapon"].item_info.combos if equipment.has("weapon") else {}


func get_basic_atk_info(atk_name: String = "light") -> Dictionary:
	if not equipment.has("weapon"):
		return {}
	
	var wp_attacks: Dictionary = equipment["weapon"].item_info.attacks
	var info: Dictionary = {}
	
	if wp_attacks.has(atk_name):
		info = wp_attacks[atk_name]
	
	return info


func get_combo_info(combo_name: String) -> Dictionary:
	if not equipment.has("weapon"):
		return {}
	
	var wp_combos: Dictionary = equipment["weapon"].item_info.combos
	var info: Dictionary = {}
	
	if wp_combos.has(combo_name):
		info = wp_combos[combo_name]
	
	return info


func update_weapon() -> void:
	set_weapon_range()
	set_weapon_dmg()
# endregion


# region: Tools
func set_farming_tools():
	for _farming_tool_name in farming_tools:
		set_farming_tool(_farming_tool_name)


func set_farming_tool(_farming_tool_name: String):
	if !equipment.has(_farming_tool_name):
		farming_tools[_farming_tool_name].range = 0
		farming_tools[_farming_tool_name].p_dmg = 0
		farming_tools[_farming_tool_name].m_dmg = 1
		return
	
	farming_tools[_farming_tool_name].range = equipment[_farming_tool_name].stats.atk_range
	farming_tools[_farming_tool_name].p_dmg = equipment[_farming_tool_name].stats.p_dmg
	farming_tools[_farming_tool_name].m_dmg = equipment[_farming_tool_name].stats.m_dmg
# endregion


func on_update_equipment(_equipment_type: String):
	cal_total_bonus_stat()

	if _equipment_type == "weapon":
		# print("weapon updated")
		update_weapon()
	
	if _equipment_type in ["axe", "pick", "hoe"]:
		set_farming_tool(_equipment_type)


func add_update_equipment(_equipment_type: String, _equipment_item: Item):
	equipment[_equipment_type] = _equipment_item
	on_update_equipment(_equipment_type)
	stats_manager.stats.update_stats()


func remove_equipment(_equipment_type: String):
	equipment.erase(_equipment_type)
	on_update_equipment(_equipment_type)
	stats_manager.stats.update_stats()


func create_monster_equipment():
	if stats_manager.host is Enemy:
		var _item_lvl: int = max(0, stats_manager.host.lvl - Constants.MONSTER_ITEM_LVL_GAP)
		if _item_lvl == 0:
			return

		for _equipment in stats_manager.host.monster_info.monster_equipment:
			equipment[_equipment] = Item.new(stats_manager.host.monster_info.monster_equipment[_equipment], {}, _item_lvl)
