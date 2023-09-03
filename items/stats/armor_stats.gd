extends ItemStats
class_name ArmorStats


#Information

#Stats


#Primary Stats
var p_armor_rating
var m_armor_rating

#Secondary Stats

#Attribute
var evansion_rate_add


#Vars
var stat_generator

#Dictionary

	
func _init(_item, _load_data: Dictionary = {}).(_item):
	if _load_data.empty():
		create_stats()
	else:
		load_stat_list(_load_data)
	

func create_stats():
	stat_generator = ItemRandomStatsGenerator.new(self)
	var temp_stat_list = stat_generator.item_stat_list
	for _stat in temp_stat_list:
		stat_list[_stat.name] = _stat.value


func load_stat_list(stats_data: Dictionary) -> void:
	if stats_data.info.has("item_rarity"):
		rarity = stats_data.info.item_rarity
	stat_list = stats_data.stats