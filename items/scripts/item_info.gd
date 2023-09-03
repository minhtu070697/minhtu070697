extends Node2D
class_name ItemInfo

#Var
export var item_list: Dictionary

var item_info: ItemResources
var item_sub_class


func _init(_item = null) -> void:
	item_list = GameResourcesLibrary.item_resources_list_json
	if _item != null:
		generate_info(_item)


func generate_info_by_name(_item_name: String) -> ItemResources:
	return ItemResources.new(item_list[_item_name])


func generate_info(_item):
	#Create a list of matched item_info (E.G is weapon? is used by farmer or fighter or both?)
	var item_info_list = []
	#add item_info that matched with the criteria of item
	for item_res_name in item_list:
		var item_res = item_list[item_res_name]
		if item_info_match(_item, item_res):
			item_info_list.append(item_res)

	if item_info_list.size() == 0:
		#Set Host_class -> Null Class
		item_info = ItemResources.new(item_list["null_item"])
	else:
		var item_info_number = Utils.random_int(0, item_info_list.size() - 1)
		item_info = ItemResources.new(item_info_list[item_info_number])

	item_sub_class = choose_item_sub_class(item_info, item_info.item_class)


func item_info_match(item, item_res: Dictionary) -> bool:
	return (
		check_item_id(item, item_res)
		or (
			check_item_class(item, item_res)
			and check_item_rarity(item, item_res)
		)
	)


func check_item_id(item, item_res: Dictionary) -> bool:
	return item.item_id == item_res.item_id


func check_item_class(item, item_res: Dictionary) -> bool:
	if (
		item_res.item_class == Constants.ItemClass.ALL
		or (
			item.item_class == Constants.ItemClass.ALL
			and item_res.item_class != Constants.ItemClass.EMPTY
		)
	):
		return true

	if item_res.item_class == item.item_class:
		return check_item_sub_class(item, item_res, item.item_class)

	return false


func check_item_sub_class(item, item_res: Dictionary, item_class) -> bool:
	if item.item_sub_class == 0 and choose_item_sub_class(item_res, item_class) != -1:
		return true

	var item_res_sub_class = choose_item_sub_class(item_res, item_class)
	return item_res_sub_class == 0 or item_res_sub_class == item.item_sub_class


func check_item_rarity(item, item_res: Dictionary) -> bool:
	return (
		item.item_rarity == Constants.Rarity.ALL
		or item_res.item_rarity == Constants.Rarity.ALL
		or item.item_rarity == item_res.item_rarity
	)


func choose_item_sub_class(item_res, item_class):
	match item_class:
		1:
			return (
				item_res.weapon_class
				if item_res.weapon_class != Constants.WeaponSubClass.BARE_HANDS
				else -1
			)
		2:
			return item_res.armor_class
		3:
			return item_res.consumable_class
		_:
			return -1
