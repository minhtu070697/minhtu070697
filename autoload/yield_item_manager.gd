extends Node
class_name YieldItemManager


# convert item id -> item name
func get_item_name_by_id(_id: String) -> String:
	if not GameResourcesLibrary.item_id_list.has(_id):
		return ""
	return GameResourcesLibrary.item_id_list[_id]


# harvest item yield
func check_and_spawn_item(_item_name: String, _appear_position: Vector2) -> void:
	GameManager.resource_item_manager.get_current_resource_item(_item_name)
	if GameManager.resource_item_manager.is_resource_item_available():
		spawn_item(_item_name, _appear_position)
		add_item_to_character_inventory()


func spawn_item(_item_name: String, _appear_position: Vector2) -> void:
	GameManager.resource_item_manager.item.spawn(_item_name, _appear_position)
	GameManager.resource_item_manager.remove_resource_item(_item_name)


func add_item_to_character_inventory() -> void:
	# logic
	var _name = GameManager.resource_item_manager.current_resource_item.item_name
	var _amount = GameManager.resource_item_manager.current_resource_item.amount
	PlayerInventory.add_item(_name, _amount)

	#ui
	show_item_added_number(_amount)


func show_item_added_number(_amount: int) -> void:
	var character = Utils.get_current_character()
	character.show_item_label()
	character.set_item_label("+", _amount)


func get_yield_item_list(_object_name: String) -> Dictionary:
	if not GameResourcesLibrary.static_resource_data.has(_object_name):
		return {}
	return GameResourcesLibrary.static_resource_data[_object_name].item_yield


# static resource yield, will rename later
func yield_item(_object_name: String, _appear_position: Vector2) -> void:
	var _yield_item_list: Dictionary = get_yield_item_list(_object_name)
	for _item_name in _yield_item_list:
		if randf() <= _yield_item_list[_item_name].chance:
			check_and_spawn_item(_item_name, _appear_position)


# enemy yield
func enemy_yield_item(_object_name: String, _appear_position: Vector2) -> void:
	var _yield_item_list: Dictionary = get_enemy_yield_item_list(_object_name)
	for _item_name in _yield_item_list:
		if randf() <= _yield_item_list[_item_name].chance:
			check_and_spawn_item(_item_name, _appear_position)


func get_enemy_yield_item_list(_object_name: String) -> Dictionary:
	if not GameResourcesLibrary.monster_resources_list_json.has(_object_name):
		return {}
	return GameResourcesLibrary.monster_resources_list_json[_object_name].item_yield

