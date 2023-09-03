extends Node

var monster_resources_list_json: Dictionary
var monster_name_list: Array
var actor_class_resources_list_json: Dictionary
var item_resources_list_json: Dictionary
var item_stat_resources_list_json: Dictionary
var skill_resources_list_json: Dictionary
var projectile_resources_list_json: Dictionary
var stat_buff_list_json: Dictionary
var consumable_stats_resource: Dictionary
var reforge_item_resource: Dictionary
var young_plant_resource: Dictionary
var plant_resource: Dictionary
var livestock_resource: Dictionary
var livestock_barn_resource: Dictionary
var character_save_test: Dictionary
var farm_pet_resource: Dictionary
var new_character_inventory: Dictionary
var cooking_recipe: Dictionary
var item_id_list: Dictionary
var static_resource_data: Dictionary


const STAT_BUFF_NODE = preload("res://characters/stats/stat_buff.tscn")

#UI_SCENES
const TOOLTIP_LABEL = preload("res://ui/scenes/tooltip_label.tscn")

#SKILL_SCENES
const SKILL_ITEM_SCENE = preload("res://ui/scenes/skill_item.tscn")


#Dictionary with the following pattern: {
#	object_type | EX: "young_plant" : {
#		sprite_name | EX: "carrot_1" : load("..../carrot_1.png")
#	}
#} so all resources will be loaded only 1 time at the first time load, after that, we can use it freely
var ResouceLibrary: Dictionary = {}


func _ready() -> void:
	monster_resources_list_json = load_json("monster_resource")
	monster_name_list = monster_resources_list_json.keys()
	actor_class_resources_list_json = load_json("actor_class_resource")
	item_resources_list_json = load_json("item_resource")
	item_stat_resources_list_json = load_json("item_stat_resource")
	skill_resources_list_json = load_json("skill_resource")
	projectile_resources_list_json = load_json("projectile_resource")
	stat_buff_list_json = load_json("stat_buffs")
	consumable_stats_resource = load_json("consumable_stats_resource")
	reforge_item_resource = load_json("reforge_item_resource")
	young_plant_resource = load_json("young_plant_resource")
	plant_resource = load_json("plant_resource")
	livestock_resource = load_json("livestock_resource")
	livestock_barn_resource = load_json("livestock_barn_resource")
	character_save_test = JsonData.load_data(JsonData.character_info_data_path)
	farm_pet_resource = load_json("farm_pet_resource")
	new_character_inventory = load_json("new_character_inventory")
	cooking_recipe = load_json("cook_recipe")
	item_id_list = load_json("item_id_list")
	static_resource_data = load_json("static_resource_data")


func load_json(_file_name: String):
	return JsonData.load_data(JsonData.json_path % _file_name)
