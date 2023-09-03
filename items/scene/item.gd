extends Node2D
class_name Item

# Signals
signal broken
signal item_updated

var item_name: String = ""

var stats
export var lvl: int = 1
export var item_rarity: int = Constants.Rarity.ALL
export var item_class = Constants.ItemClass.WEAPON
export var item_sub_class = Constants.WeaponSubClass.ALL 
export var owner_class = "knight"
export var item_id = 0 #0 for random item in class, subclass,...
var lvl_require: int = 1
var item_info: ItemResources

var reforge_time: int = 0

#Dictionary
var item_class_dict = {
	Constants.ItemClass.WEAPON: WeaponStats,
	Constants.ItemClass.ARMOR: ArmorStats,
	Constants.ItemClass.CONSUMABLE: ConsumableStats,
	Constants.ItemClass.SEED: SeedStats,
	Constants.ItemClass.OTHER: OtherItemStats
}


func _init(_item_name: String, _load_data: Dictionary = {}, _item_lvl: int = 1) -> void:
	if not _load_data.empty() and _load_data.info.has("lvl"):
		_item_lvl = _load_data.info.lvl

	load_item_info(_item_name, _item_lvl)

	if item_info.item_class in [Constants.ItemClass.WEAPON, Constants.ItemClass.ARMOR]:
		stats = item_class_dict[item_info.item_class].new(self, _load_data)
	else:
		stats = item_class_dict[item_info.item_class].new(self)
	
	item_rarity = stats.rarity


func load_item_info(_item_name: String, _item_lvl: int = 1):
	item_name = _item_name
	lvl = _item_lvl
	lvl_require = lvl
	var _generated_info = ItemInfo.new()
	item_info = _generated_info.generate_info_by_name(_item_name)
	item_class = item_info.item_class
	item_sub_class = _generated_info.choose_item_sub_class(item_info, item_info.item_class)


func item_use(_affect_character):
	stats.item_use(_affect_character)


func get_item_stats() -> Dictionary:
	var _stats: Dictionary = {}
	_stats["stats"] = stats.stat_list
	_stats["info"] = {}
	_stats["info"]["lvl"] = lvl
	_stats["info"]["item_rarity"] = item_rarity
	stats.get_item_save_infos(_stats["info"])
	return _stats
