extends Node
class_name ResourceItemCalculator

var resource_item_manager
var animation_loop_count = 0

func _init(resource_item_manager):
	self.resource_item_manager = resource_item_manager

# fishing calculating
func is_fishing_loop() -> bool:
	var random = get_fishing_loop_chance()
	if random == 0:
		animation_loop_count += 1
		return true
	else:
		animation_loop_count = 0
		return false

func is_fishing_max_loop(_max: int) -> bool:
	if animation_loop_count >= _max:
		animation_loop_count = 0
		return true
	else:
		return false

func is_catch_success() -> bool:
	# var random = get_catch_chance()
	var random = 0
	if random == 0:
		return true
	else:
		return false

func get_fishing_loop_chance() -> int:
	var value = 0
	match (resource_item_manager.current_resource_item.rarity):
		0: value = Utils.random_int(0, 9)
		1: value = Utils.random_int(0, 1)
		2: value = 0 
	return value

func get_catch_chance() -> int:
	var value = 0
	match (resource_item_manager.current_resource_item.rarity):
		0: value = 0
		1: value = Utils.random_int(0, 1)
		2: value = Utils.random_int(0, 9)
	return value
