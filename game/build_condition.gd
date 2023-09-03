extends Node

class_name BuildCondition

var build_manager

var build_ingredients_data: Dictionary
var player_inventory: Dictionary

var object_name: String
var ingredients_name_need: Array
var ingredients_amount_need: Array


func _init(_build_manager):
	build_manager = _build_manager


func set_object_name(building_type: int, object_type: int):
	if building_type == Constants.BuildingType.RESOURCE:
		object_name = str(Constants.ResourceType.keys()[object_type]).to_lower()
	else:
		object_name = str(Constants.DecorationType.keys()[object_type]).to_lower()


func is_reachable_build_conditions():
	build_ingredients_data = JsonData.build_ingredients_data
	player_inventory = PlayerInventory.inventory

	var ingredients = build_ingredients_data[object_name]
	var total_ingredients_need = cal_total_ingredients_need(ingredients)
	var matched = false
	var matched_count = 0

	for item in ingredients:
		var item_name = item
		var item_amount = ingredients[item_name]
		matched = compare_items_in_player_inventory(item_name, item_amount)
		if matched:
			matched_count += 1
			ingredients_name_need.append(item_name)
			ingredients_amount_need.append(item_amount)
		else:
			break

	return matched and matched_count == total_ingredients_need


func compare_items_in_player_inventory(item_name, item_amount):
	var total_inventory_item_amount = 0
	for slots in player_inventory:
		var slot = player_inventory[slots]
		var inventory_item_name = slot[0]
		var inventory_item_amount = slot[1]
		if inventory_item_name == item_name:
			total_inventory_item_amount += inventory_item_amount
			if total_inventory_item_amount >= item_amount:
				return true
	return false


func cal_total_ingredients_need(ingredients):
	var total_ingredients = 0
	for i in ingredients:
		total_ingredients += 1
	return total_ingredients


func cal_items_left_in_player_inventory():
	var list_datas_temp = []
	var list_names_temp = []
	
	for i in ingredients_name_need.size():
		var item_name = ingredients_name_need[i]
		var item_amount = ingredients_amount_need[i]

		for slots in player_inventory:
			var slot = player_inventory[slots]
			var inventory_item_name = slot[0]
			var inventory_item_amount = slot[1]

			if inventory_item_name == item_name:
				var amount_left = inventory_item_amount - item_amount
				if amount_left > 0:
					player_inventory[slots][1] = amount_left
					break
				else:
					# logic
					item_amount = -amount_left
					# remove data
					list_datas_temp.append(slots)
					# remove ui -> wip
					list_names_temp.append(item_name)
	for i in list_datas_temp: player_inventory.erase(i)
	for i in list_names_temp: remove_inventory_slots_item_ui(i)

	GameManager.save_load_manager.character_save.character_save(Utils.get_current_character())


func remove_inventory_slots_item_ui(_item_name):
	var inventory_slots_ui = Utils.get_current_character().ui_manager.inventory.inventory_slots
	for inventory_slot_ui in inventory_slots_ui.get_children():
		if inventory_slot_ui.get_child_count() > 0:
			if inventory_slot_ui.get_child(0).item_name == _item_name:
				inventory_slot_ui.removeSlotItem()


func clear_temp_data():
	ingredients_name_need.clear()
	ingredients_amount_need.clear()


func check_list_buildings_condition(list_buildings):
	build_ingredients_data = JsonData.build_ingredients_data
	player_inventory = PlayerInventory.inventory

	apply_data_to_group_build_ui(list_buildings)

	for i in list_buildings.get_child_count():
		for j in build_ingredients_data:
			if list_buildings.get_child(i).object_data_name == j:
				var ingredients = build_ingredients_data[j]
				var total_ingredients_need = cal_total_ingredients_need(ingredients)
				var matched = false
				var matched_count = 0

				for item in ingredients:
					var item_name = item
					var item_amount = ingredients[item_name]
					matched = compare_items_in_player_inventory(item_name, item_amount)
					if matched:
						matched_count += 1
						ingredients_name_need.append(item_name)
						ingredients_amount_need.append(item_amount)
					else:
						break
				
				if matched and matched_count == total_ingredients_need:
					enable_buildable_buildings(list_buildings, i)
				else:
					disable_buildable_buildings(list_buildings, i)


func enable_buildable_buildings(list_buildings, index):
	list_buildings.get_child(index).disabled = false
	list_buildings.get_child(index).get_node_or_null("Lock").visible = false


func disable_buildable_buildings(list_buildings, index):
	list_buildings.get_child(index).disabled = true
	list_buildings.get_child(index).get_node_or_null("Lock").visible = true


func apply_data_to_group_build_ui(list_buildings):
	for i in list_buildings.get_child_count():
		for j in build_ingredients_data:
			if list_buildings.get_child(i).object_data_name == j:
				var ingredients = build_ingredients_data[j]
				var wood_amount_ui = list_buildings.get_child(i).get_node_or_null("Amount")
				var stone_amount_ui = list_buildings.get_child(i).get_node_or_null("Amount_1")
				for item in ingredients:
					var item_name = item
					var item_amount = ingredients[item_name]
					if wood_amount_ui != null and item_name == "wood":
						wood_amount_ui.text = str(item_amount)
					if stone_amount_ui != null and item_name == "stone":
						stone_amount_ui.text = str(item_amount)
				

func return_ingredients_to_player_inventory(object_remove_name):
	build_ingredients_data = JsonData.build_ingredients_data
	player_inventory = PlayerInventory.inventory

	for i in build_ingredients_data:
		if i == object_remove_name:
			var ingredients = build_ingredients_data[i]
			for item in ingredients:
				var item_name = item
				var item_amount = ingredients[item_name]

				for slots in player_inventory:
					var slot = player_inventory[slots]
					var inventory_item_name = slot[0]
					var inventory_item_amount = slot[1]
		
					if inventory_item_name == item_name:
						var amount_left = inventory_item_amount + item_amount
						if amount_left <= 99:
							player_inventory[slots][1] = amount_left
						else:
							PlayerInventory.add_item(item_name, item_amount)
						break
					else:
						PlayerInventory.add_item(item_name, item_amount)
						break
