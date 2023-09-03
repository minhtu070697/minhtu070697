extends Stats
class_name ItemStats


#Information
var rarity
var potential

var item_class
var item_sub_class


#Primary Stats
var lvl = 1
var stat_list: Dictionary = {}

#Secondary Stats


#Vars
var item #another alias for host

#Dictionary
var rarity_potential = {
	1 : [0.8, 1],
	2 : [1.05, 1.2],
	3 : [1.25, 1.5],
	4 : [1.6, 1.8],
	5 : [1.9, 2.1]
}

	
func _init(_item).(_item):
	item = _item
	_name = item.item_info.item_name
	item_class = item.item_info.item_class
	item_sub_class = item.item_sub_class
	item_class = Constants.ItemClass.ARMOR
	lvl = item.lvl
	set_rarity_potential()
	


func set_rarity_potential():
	if item.item_rarity == 0:
		rarity = Utils.random_int(1,5)
	else:
		rarity = item.item_rarity
	potential = rand_range(rarity_potential[rarity][0], rarity_potential[rarity][1])



func item_use(_affect_character):
	pass


# abstract
func get_item_save_infos(_data: Dictionary) -> void:
	pass
