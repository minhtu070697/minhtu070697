extends Node2D
class_name ItemRandomStatsGenerator


#Var
export var item_stat_list = []
export var all_stat_list = []


func _init(_item) -> void:
	all_stat_list = GameResourcesLibrary.item_stat_resources_list_json
	item_stat_list = generate_stats(_item)


func generate_stats(_item) -> Array:
	var temp_stats_list = []
	for stat_name in all_stat_list:
		var stat = all_stat_list[stat_name]
		var chance = (randf() / (1 + max(0, (_item.rarity - stat.rarity)) * 0.25))
		
		if not ((stat.is_primary_stat or (chance < stat.chance and _item.rarity >= stat.rarity)) and (_item.item_class == stat.stat_class or stat.stat_class == Constants.ItemClass.ALL)):
			continue
			
		temp_stats_list.append_array(cal_item_stat(stat, _item))
		
	return temp_stats_list


#Calculate min -> max value of stat and return an array of 1 stat, if a stat have physical - magical linked, return array of 2 stats (1 physical, 1 magical)
func cal_item_stat(_stat: Dictionary, _item) -> Array:
	var _temp_value : float 
	var _temp_stat_array = []
	
	#Stat use min, max value
	if _stat.is_use_min_max_value:
		_temp_value = stepify(rand_range(_stat.min_value, _stat.max_value), 0.01)
		_temp_stat_array.append(ItemStatsResources.new(_stat.name, _temp_value))
		return _temp_stat_array
	
	#Stat has value based on item lvl
	_temp_value = _item.lvl * _stat.level_multiplier * Utils.random_percent(80, 120)
	
	#Lone stat
	if not _stat.physical_magical_linked:
		_temp_stat_array.append(ItemStatsResources.new(_stat.name, _temp_value))
		return _temp_stat_array
	
	#Physical and Magical pair stats
	#Create physical stat
	var physical_percent = Utils.random_percent(0, 100)
	var m_temp_value = _temp_value * (1 - physical_percent)
	var p_temp_value = _temp_value * physical_percent
	
	_temp_stat_array.append(ItemStatsResources.new("p_" + _stat.name, p_temp_value))
	_temp_stat_array.append(ItemStatsResources.new("m_" + _stat.name, m_temp_value))
	return _temp_stat_array

