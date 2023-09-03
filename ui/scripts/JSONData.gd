extends Node

var item_data: Dictionary
var crafting_data: Dictionary
var build_ingredients_data: Dictionary

var map_build_data: Dictionary
var house_build_data_ground_floor: Dictionary
var house_build_data_1st_floor: Dictionary
var house_build_data_2nd_floor: Dictionary
var house_upgrade_build_data_ground_floor: Dictionary
var house_upgrade_build_data_1st_floor: Dictionary
var house_upgrade_build_data_2nd_floor: Dictionary
var multiple_lands_data: Dictionary

var first_time_open_data: Dictionary
var character_spawn_data: Dictionary
var map_daytime_data: Dictionary
var current_timing_data: Dictionary

# read
var item_data_path = "res://jsons/ItemData.json"
var crafting_data_path = "res://jsons/CraftingData.json"
var json_path = "res://jsons/%s.json"
var build_ingredients_data_path = "res://jsons/build_ingredient_data.json"

# write - map (inside/outside)
var map_build_data_path = get_data_path_from_current_platform() + "map_build_data.json"
var house_build_data_ground_floor_path = (
	get_data_path_from_current_platform()
	+ "house_build_data.json"
)
var house_build_data_1st_floor_path = (
	get_data_path_from_current_platform()
	+ "house_build_data_1st.json"
)
var house_build_data_2nd_floor_path = (
	get_data_path_from_current_platform()
	+ "house_build_data_2nd.json"
)
var house_upgrade_build_data_ground_floor_path = (
	get_data_path_from_current_platform()
	+ "house_upgrade_build_data.json"
)
var house_upgrade_build_data_1st_floor_path = (
	get_data_path_from_current_platform()
	+ "house_upgrade_build_data_1st.json"
)
var house_upgrade_build_data_2nd_floor_path = (
	get_data_path_from_current_platform()
	+ "house_upgrade_build_data_2nd.json"
)
var multiple_lands_data_path = get_data_path_from_current_platform() + "multiple_lands_data.json"

# write - map daytime
var map_daytime_data_path = get_data_path_from_current_platform() + "map_daytime_data.json"
var current_timing_data_path = get_data_path_from_current_platform() + "current_timing.json"

# write - character
var character_spawn_data_path = get_data_path_from_current_platform() + "character_spawn_data.json"
var character_info_data_path = get_data_path_from_current_platform() + "character_save.json"

# write - first time open game
var first_time_open_data_path = get_data_path_from_current_platform() + "first_time_open.json"


func _ready():
	item_data = load_data(item_data_path)
	crafting_data = load_data(crafting_data_path)
	build_ingredients_data = load_data(build_ingredients_data_path)


func load_data(file_path):
	var json_data
	var file_data = File.new()

	if not file_data.file_exists(file_path):
		return {}

	file_data.open(file_path, File.READ)
	json_data = JSON.parse(file_data.get_as_text())
	file_data.close()

	var return_data = json_data.result
	#create array of keys and sort
	var sorted_dict_keys: Array = return_data.keys()
	sorted_dict_keys.sort_custom(DataKeySort, "sort_data_key_by_string")

	#create new dict with sorted keys and values from old dict
	var sorted_data: Dictionary = {}
	for key in sorted_dict_keys:
		sorted_data[key] = return_data[key]

	return sorted_data


func save_data(file_path, data):
	var json_data = data
	var file_data = File.new()

	file_data.open(file_path, File.WRITE)
	file_data.store_string(json_convert(json_data))
	file_data.close()


func json_convert(data) -> String:
	var converted_data: String = to_json(data)
	if GameManager.json_beautify:
		converted_data = JSONBeautifier.beautify_json(converted_data)
	return converted_data


func get_data_path_from_current_platform() -> String:
	if GameSdk.is_exported_platform():
		return "user://"
	else:
		return "res://jsons/"


class DataKeySort:
	static func sort_data_key_by_string(a: String, b: String) -> bool:
		if a.length() < b.length():
			return true
		elif a.length() > b.length():
			return false
		return a < b

