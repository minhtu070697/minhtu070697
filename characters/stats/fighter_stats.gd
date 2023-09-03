extends ActorStats
class_name FighterStats


#Information
var fighter_class: String = "Knight"

#Primary Stats

#Secondary Stats

#Derived var base_accuracy

#Derived Stats


#Elemental Resistance
var fire_resist: float
var cold_resist: float
var lightning_resist: float
var poison_resist: float

var fire_resist_max: float
var cold_resist_max: float
var lightning_resist_max: float
var poison_resist_max: float

var base_craft_chance

#Derived Stats
var craft_rating

var farming_dmg: Dictionary = {
	"axe": {
		"p_atk": 0,
		"m_atk": 0,
		"atk_speed": 1
	},
	"pick": {
		"p_atk": 0,
		"m_atk": 0,
		"atk_speed": 1
	},
	"hoe": {
		"p_atk": 0,
		"m_atk": 0,
		"atk_speed": 1
	}
}


func _init(_host, _host_class = []).(_host, _host_class):
	set_basic_stats()
	update_stats()
	set_hp_mana_max()
	
	
func set_secondary_stats():
	.set_secondary_stats()

	fire_resist_max = host_class.fire_resist_max
	cold_resist_max = host_class.cold_resist_max
	lightning_resist_max = host_class.lightning_resist_max
	poison_resist_max = host_class.poison_resist_max

	fire_resist = min(fire_resist_max, check_equipment_stat("fire_resist"))
	cold_resist = min(cold_resist_max, check_equipment_stat("cold_resist"))
	lightning_resist = min(lightning_resist_max, check_equipment_stat("lightning_resist"))
	poison_resist = min(poison_resist_max, check_equipment_stat("poison_resist"))


func set_derived_stats():
	.set_derived_stats()
	craft_rating = cal_craft_rating()
	cal_farming_tool_atk()


func cal_farming_tool_atk() -> void:
	if equipment_manager == null:
		return
		
	for _farming_tool_name in equipment_manager.farming_tools:
		if !equipment_manager.equipment.has(_farming_tool_name):
			farming_dmg[_farming_tool_name].p_atk = 0
			farming_dmg[_farming_tool_name].m_atk = 0
			farming_dmg[_farming_tool_name].atk_speed = 0
			continue

		farming_dmg[_farming_tool_name].p_atk = cal_farming_tool_p_atk(_farming_tool_name)
		farming_dmg[_farming_tool_name].m_atk = cal_farming_tool_m_atk(_farming_tool_name)
		farming_dmg[_farming_tool_name].atk_speed = cal_farming_tool_atk_speed(_farming_tool_name)
		

func cal_farming_tool_p_atk(_tool_name: String) -> float:
	return (1 + strength * 0.03) * (strength * 0.075 + agility * 0.025 + farming_tool_p_dmg(_tool_name) + check_equipment_stat("p_dmg_add") + check_buff_stat("p_dmg_add"))


func cal_farming_tool_m_atk(_tool_name: String) -> float:
	return (1 + intelligence * 0.03) * (intelligence * 0.075 + agility * 0.025 + farming_tool_m_dmg(_tool_name) + check_equipment_stat("m_dmg_add") + check_buff_stat("m_dmg_add"))


func farming_tool_p_dmg(_tool_name: String) -> float: 
	return equipment_manager.farming_tools[_tool_name].p_dmg

func farming_tool_m_dmg(_tool_name: String) -> float:
	return equipment_manager.farming_tools[_tool_name].m_dmg

#use atk_speed_add for speed buff now, can expand -> tree chop speed add, mining speed add,... later
func cal_farming_tool_atk_speed(_tool_name: String) -> float:
	return (host_class.base_atk_speed * check_farming_tool_atk_speed(_tool_name) * (1 + check_equipment_stat("atk_speed_add") + check_buff_stat("atk_speed_add"))) * total_speed


func check_farming_tool_atk_speed(_tool_name: String):
	if equipment_manager == null or not equipment_manager.equipment.has(_tool_name):
		return 1.0
	return equipment_manager.equipment[_tool_name].item_info.atk_speed
