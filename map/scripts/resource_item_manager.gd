extends Node

class_name ResourceItemManager

#TODO: refactor this script

var game_manager
var map_manager
var resource_item_calculator: ResourceItemCalculator

var test_amount = 1000
var item_info_fish = ResourceItemInfo.new(Constants.FISH_ITEM, test_amount)
var item_info_wood = ResourceItemInfo.new(Constants.WOOD_ITEM, test_amount)
var item_info_stone = ResourceItemInfo.new(Constants.STONE_ITEM, test_amount)
var item_info_gold = ResourceItemInfo.new(Constants.GOLD_ITEM, test_amount)
var item_info_diamond = ResourceItemInfo.new(Constants.DIAMOND_ITEM, test_amount)
var item_info_emerald = ResourceItemInfo.new(Constants.EMERALD_ITEM, test_amount)
var item_info_ruby = ResourceItemInfo.new(Constants.RUBY_ITEM, test_amount)
var item_info_amber = ResourceItemInfo.new(Constants.AMBER_ITEM, test_amount)
var item_info_amethyst = ResourceItemInfo.new(Constants.AMETHYST_ITEM, test_amount)
var item_info_quartz = ResourceItemInfo.new(Constants.QUARTZ_ITEM, test_amount)
var item_info_sapphire = ResourceItemInfo.new(Constants.SAPPHIRE_ITEM, test_amount)
var item_info_potion = ResourceItemInfo.new(Constants.POTION_ITEM, test_amount)
var item_info_rope = ResourceItemInfo.new(Constants.ROPE_ITEM, test_amount)
var item_info_carrot = ResourceItemInfo.new(Constants.CARROT_ITEM, test_amount)
var item_info_chilly = ResourceItemInfo.new(Constants.CHILLY_ITEM, test_amount)
var item_info_peach = ResourceItemInfo.new(Constants.PEACH_ITEM, test_amount)
var item_info_carrot_seed = ResourceItemInfo.new(Constants.CARROT_SEED_ITEM, test_amount)
var item_info_chilly_seed = ResourceItemInfo.new(Constants.CHILLY_SEED_ITEM, test_amount)
var item_info_peach_seed = ResourceItemInfo.new(Constants.PEACH_SEED_ITEM, test_amount)
var item_info_beef = ResourceItemInfo.new(Constants.BEEF_ITEM, test_amount)


var list_items_info = [
	item_info_fish,
	item_info_wood,
	item_info_stone,
	item_info_gold,
	item_info_diamond,
	item_info_emerald,
	item_info_ruby,
	item_info_amber,
	item_info_amethyst,
	item_info_quartz,
	item_info_sapphire,
	item_info_potion,
	item_info_rope,
	item_info_carrot,
	item_info_chilly,
	item_info_peach,
	item_info_carrot_seed,
	item_info_chilly_seed,
	item_info_peach_seed,
	item_info_beef
]

var resource_items = {
	Constants.FISH_ITEM: [],
	Constants.WOOD_ITEM: [],
	Constants.STONE_ITEM: [],
	Constants.GOLD_ITEM: [],
	Constants.DIAMOND_ITEM: [],
	Constants.EMERALD_ITEM: [],
	Constants.RUBY_ITEM: [],
	Constants.AMBER_ITEM: [],
	Constants.AMETHYST_ITEM: [],
	Constants.QUARTZ_ITEM: [],
	Constants.SAPPHIRE_ITEM: [],
	Constants.POTION_ITEM: [],
	Constants.ROPE_ITEM: [],
	Constants.CARROT_ITEM: [],
	Constants.CHILLY_ITEM: [],
	Constants.PEACH_ITEM: [],
	Constants.CARROT_SEED_ITEM: [],
	Constants.CHILLY_SEED_ITEM: [],
	Constants.PEACH_SEED_ITEM: [],
	Constants.BEEF_ITEM: [],
}

var item: ResourceItem
var current_resource_item


func _init(_game_manager, _map_manager):
	map_manager = _map_manager
	game_manager = _game_manager
	self.resource_item_calculator = ResourceItemCalculator.new(self)
	add_resource_item()


func get_current_resource_item(current_resource_item_type):
	current_resource_item = get_resource_item(current_resource_item_type)


func get_resource_item(current_resource_item_type):
	var resource_items_value = get_resource_item_value(current_resource_item_type)
	if resource_items_value.size() == 0:
		return null
	return Utils.random_from_array(resource_items_value)


func get_resource_item_value(current_resource_item_type):
	match current_resource_item_type:
		Constants.FISH_ITEM: return resource_items[item_info_fish.item_name]
		Constants.WOOD_ITEM: return resource_items[item_info_wood.item_name]
		Constants.STONE_ITEM: return resource_items[item_info_stone.item_name]
		Constants.GOLD_ITEM: return resource_items[item_info_gold.item_name]
		Constants.DIAMOND_ITEM: return resource_items[item_info_diamond.item_name]
		Constants.EMERALD_ITEM: return resource_items[item_info_emerald.item_name]
		Constants.RUBY_ITEM: return resource_items[item_info_ruby.item_name]
		Constants.AMBER_ITEM: return resource_items[item_info_amber.item_name]
		Constants.AMETHYST_ITEM: return resource_items[item_info_amethyst.item_name]
		Constants.QUARTZ_ITEM: return resource_items[item_info_quartz.item_name]
		Constants.SAPPHIRE_ITEM: return resource_items[item_info_sapphire.item_name]
		Constants.POTION_ITEM: return resource_items[item_info_potion.item_name]
		Constants.ROPE_ITEM: return resource_items[item_info_rope.item_name]
		Constants.CARROT_ITEM: return resource_items[item_info_carrot.item_name]
		Constants.CHILLY_ITEM: return resource_items[item_info_chilly.item_name]
		Constants.PEACH_ITEM: return resource_items[item_info_peach.item_name]
		Constants.CARROT_SEED_ITEM: return resource_items[item_info_carrot_seed.item_name]
		Constants.CHILLY_SEED_ITEM: return resource_items[item_info_chilly_seed.item_name]
		Constants.PEACH_SEED_ITEM: return resource_items[item_info_peach_seed.item_name]
		Constants.BEEF_ITEM: return resource_items[item_info_beef.item_name]


func add_resource_item():
	for _i in range(list_items_info.size()):
		for _j in range(list_items_info[_i].max_amount):
			if(resource_items[list_items_info[_i].item_name].size() >= list_items_info[_i].max_amount):
				return
			item = ResourceItem.new(list_items_info[_i], self)
			resource_items[list_items_info[_i].item_name].append(item)


func remove_resource_item(current_resource_item_type):
	var resource_items_value = get_resource_item_value(current_resource_item_type)
	var item_index = resource_items_value.find(current_resource_item)
	resource_items_value.remove(item_index)


func is_resource_item_available() -> bool:
	if current_resource_item != null: 
		return true
	else: 
		return false


# testing only: log any data for testing
func debug_log():
	# log: fish info
	print("=============================")
	for i in resource_items[Constants.CARROT_ITEM]:
		print("-", i.item_name, "(", i.rarity, ")", ": ", i.amount)
		
