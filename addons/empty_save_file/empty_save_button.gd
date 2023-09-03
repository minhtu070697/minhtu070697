tool
extends Button

# write - map (inside/outside)
var map_build_data_path = "res://jsons/map_build_data.json"
var house_build_data_ground_floor_path = "res://jsons/house_build_data.json"
var house_build_data_1st_floor_path = "res://jsons/house_build_data_1st.json"
var house_build_data_2nd_floor_path = "res://jsons/house_build_data_2nd.json"
var multiple_lands_data_path = "res://jsons/multiple_lands_data.json"

var house_upgrade_build_data_ground_floor_path = "res://jsons/house_upgrade_build_data.json"
var house_upgrade_build_data_1st_floor_path = "res://jsons/house_upgrade_build_data_1st.json"
var house_upgrade_build_data_2nd_floor_path = "res://jsons/house_upgrade_build_data_2nd.json"

# write - map daytime
var map_daytime_data_path = "res://jsons/map_daytime_data.json"
var current_timing_data_path = "res://jsons/current_timing.json"

# write - character
var character_spawn_data_path = "res://jsons/character_spawn_data.json"
var character_info_data_path = "res://jsons/character_save.json"

# write - first time open game
var first_time_open_data_path = "res://jsons/first_time_open.json"


func _enter_tree() -> void:
	if !is_connected("button_up", self, "_on_clicked"):
		connect("button_up", self, "_on_clicked")


func _on_clicked() -> void:
	print("- CLEAR ALL SAVING DATA -")
	empty_save_files()


func empty_save_files() -> void:
	empty_save_file(map_build_data_path)
	empty_save_file(house_build_data_ground_floor_path)
	empty_save_file(house_build_data_1st_floor_path)
	empty_save_file(house_build_data_2nd_floor_path)
	empty_save_file(house_upgrade_build_data_ground_floor_path)
	empty_save_file(house_upgrade_build_data_1st_floor_path)
	empty_save_file(house_upgrade_build_data_2nd_floor_path)
	empty_save_file(map_daytime_data_path)
	empty_save_file(current_timing_data_path)
	empty_save_file(character_spawn_data_path)
	empty_save_file(character_info_data_path)
	empty_save_file(multiple_lands_data_path)
	empty_save_file(first_time_open_data_path)


func empty_save_file(_file_path) -> void:
	save_data(_file_path, {})


func save_data(file_path, data):
	var json_data = data
	var file_data = File.new()

	file_data.open(file_path, File.WRITE)
	file_data.store_string(JSONBeautifier.beautify_json(to_json(json_data)))
	file_data.close()
