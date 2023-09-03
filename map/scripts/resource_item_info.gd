extends Node

class_name ResourceItemInfo

var item_name
var rarity = [0, 1, 2]
var max_amount

func _init(_item_name, _max_amount):
	self.item_name = _item_name
	self.max_amount = _max_amount
	
func generate_rarity():
	return Utils.random_int(rarity.min(), rarity.max())

func generate_amount():
	return Utils.random_int(1, 3)
