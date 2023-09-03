extends Node
class_name ReforgeItemController

func _init() -> void:
	pass


func reforge_item(_item_slot, _ingredient_slots) -> Dictionary:
	var _reforged_ingredient: Array = []
	var _not_reforged_ingredient: Array = []
	var _reforge_item = _item_slot.item
	for ingredient_slot in _ingredient_slots:
		if ingredient_slot.item == null:
			continue

		var _item_reforge_bonus_stats = GameResourcesLibrary.reforge_item_resource[ingredient_slot.item.item_info.item_name] if GameResourcesLibrary.reforge_item_resource.has(ingredient_slot.item.item_info.item_name) else null
		if _item_reforge_bonus_stats:
			for i in ingredient_slot.item.item_amount:
				for _bonus_stat_name in _item_reforge_bonus_stats:
					var _bonus_stat = _item_reforge_bonus_stats[_bonus_stat_name]
					if randf() <= _bonus_stat.chance:
						add_bonus_stat_to_item(_reforge_item, _bonus_stat)
				_reforge_item.reforge_item()
				
			_reforged_ingredient.append(ingredient_slot)
		else:
			_not_reforged_ingredient.append(ingredient_slot)
	
	return {
		"reforged_ingredient": _reforged_ingredient,
		"not_reforged_ingredient": _not_reforged_ingredient
	}


func add_bonus_stat_to_item(_reforge_item, _bonus_stat: Dictionary):
	var _item_reforged_time: float = _reforge_item.item_info.reforge_time + 1
	var _reforge_item_stat_list = _reforge_item.item_info.stats.stat_list
	if _reforge_item_stat_list.has(_bonus_stat["name"]):
		_reforge_item_stat_list[_bonus_stat["name"]] = max(_reforge_item_stat_list[_bonus_stat["name"]] + calculate_bonus_stat(_reforge_item, _bonus_stat)/_item_reforged_time, calculate_bonus_stat(_reforge_item, _bonus_stat) + _reforge_item_stat_list[_bonus_stat["name"]] * ((4 * _item_reforged_time - 2) / (5 * _item_reforged_time)))
	else:
		_reforge_item_stat_list[_bonus_stat["name"]] = calculate_bonus_stat(_reforge_item, _bonus_stat)


func calculate_bonus_stat(_reforge_item, _bonus_stat: Dictionary) -> float:
	if _bonus_stat.is_use_min_max_value:
		return rand_range(_bonus_stat.min_value, _bonus_stat.max_value)
	
	return _reforge_item.item_info.lvl * _bonus_stat.level_multiplier * Utils.random_percent(70,130)
