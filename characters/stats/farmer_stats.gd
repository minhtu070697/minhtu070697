extends ActorStats
class_name FarmerStats


#Information


#Primary Stats


#Secondary Stats
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











