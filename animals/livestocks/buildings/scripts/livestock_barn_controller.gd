extends Node2D
class_name LivestockBarnController

signal update_barn_inventory()

var in_barn_livestocks: Dictionary = {}
var out_side_livestocks: Dictionary = {}
var current_in_barn_size: int
var barn_info: Dictionary
var barn_door_position: Vector2
var barn_door_width: Vector2

var is_calling: bool = false
var barn_navigator_type: int = Constants.NavigatorType.LAND

var livestock_barn_inventory: LivestockBarnInventory
var character: Character

const LIVESTOCK_SCENE_PATH: String = "res://animals/livestocks/scenes/%s.tscn"

const LIVESTOCK_APPEAR_ZONE_WHEN_DOOR_FULL: Vector2 = Vector2(1, 1)
const BARN_DOOR_ZONE : int = 2

export var barn_name: String = "cow_barn"
onready var livestock_barn = get_parent()

var current_livestock_quantity_of_each_type: Dictionary = {
	"cow": 0,
	"chicken": 0,
	"duck_1": 0,
	"duck_2": 0
}

const MAX_QUANTITY_OF_EACH_LIVESTOCK_TYPE: Dictionary = {
	"cow": 3,
	"chicken": 3,
	"duck_1": 3,
	"duck_2": 3
}


func _ready() -> void:
	load_barn_info()


func create_livestock(_livestock_name: String):
	#for demo:
	if current_livestock_quantity_of_each_type[_livestock_name] >= MAX_QUANTITY_OF_EACH_LIVESTOCK_TYPE[_livestock_name]:
		return
	
	var _livestock = Utils.load_resource(LIVESTOCK_SCENE_PATH %_livestock_name, _livestock_name, "scene").instance()
	barn_door_position = get_barn_door_position()
	barn_door_width = get_barn_door_width()
	var _livestock_map_position = livestock_appear_position()
	
	if _livestock_map_position == Vector2.INF:
		return
	
	_livestock.global_position = GameManager.map_manager_utils.map_to_global_position(_livestock_map_position)
	livestock_barn.get_parent().add_child(_livestock)
	out_side_livestocks[_livestock.name] = _livestock
	_livestock.barn = self
	_livestock.update_sort_position(true)

	#for_demo:
	current_livestock_quantity_of_each_type[_livestock_name] += 1
	emit_signal("update_barn_inventory")


func livestock_appear_position() -> Vector2:
	var _map_navigator = GameManager.map_manager.map_navigator
	var _appear_position: Vector2 = barn_door_position
	for _x in (barn_door_width.x + LIVESTOCK_APPEAR_ZONE_WHEN_DOOR_FULL.x):
		for _y in (barn_door_width.y + LIVESTOCK_APPEAR_ZONE_WHEN_DOOR_FULL.y):
			for _z in [-1, 1]:
				if !_map_navigator.is_point_disabled(_map_navigator.point_to_index(_appear_position + Vector2(_x * _z, _y * _z))):
					return _appear_position + Vector2(_x * _z, _y * _z)
	return Vector2.INF


func load_barn_info():
	barn_info = Constants.LivestockBarnDefaultInfo.duplicate()
	for _info_name in GameResourcesLibrary.livestock_barn_resource[barn_name]:
		barn_info[_info_name] = GameResourcesLibrary.livestock_barn_resource[barn_name][_info_name]
	barn_door_position = get_barn_door_position()
	barn_door_width = get_barn_door_width()
	barn_navigator_type = load_barn_navigator_type_from_data()


func get_barn_door_position() -> Vector2:
	return GameManager.map_manager_utils.global_to_map_position(livestock_barn.global_position) + (Vector2(barn_info.barn_door_position.x, barn_info.barn_door_position.y) if livestock_barn.scale.x == 1 else Vector2(barn_info.barn_door_position.y, barn_info.barn_door_position.x))


func get_barn_door_width() -> Vector2:
	return Vector2(barn_info.barn_door_width.x, barn_info.barn_door_width.y) if livestock_barn.scale.x == 1 else Vector2(barn_info.barn_door_width.y, barn_info.barn_door_width.x)


func return_to_barn_call():
	is_calling = true
	SignalManager.emit_signal("return_to_barn_call", self)


func enter_barn_register(_livestock) -> bool:
	livestock_enter(_livestock)
	return true


func go_outside_barn_register(_livestock) -> Dictionary:
	if is_calling:
		return {"success": false}
	
	var _appear_position: Vector2 = livestock_appear_position()
	if _appear_position == Vector2.INF:
		return {"success": false}
	livestock_go_outside(_livestock)
	return {"success": true,
	"appear_position": _appear_position
	}


func livestock_go_outside(_livestock) -> void:
	out_side_livestocks[_livestock.name] = _livestock
	in_barn_livestocks.erase(_livestock.name)


func livestock_enter(_livestock) -> void:
	in_barn_livestocks[_livestock.name] = _livestock
	out_side_livestocks.erase(_livestock.name)


func load_barn_navigator_type_from_data() -> int:
	if barn_info.barn_navigator_type == "water":
		return Constants.NavigatorType.WATER
	
	return Constants.NavigatorType.LAND


func remove_livestock(_livestock) -> void:
	current_livestock_quantity_of_each_type[_livestock.animal_name] -= 1
	emit_signal("update_barn_inventory")
	out_side_livestocks.erase(_livestock.name)
	in_barn_livestocks.erase(_livestock.name)


func on_mouse_right_click() -> void:
	if !character:
		character = Utils.get_current_character()

	if !livestock_barn_inventory:
		livestock_barn_inventory = character.get_node_or_null("ui/LivestockBarnInventory")
	
	interact_with_barn()


func interact_with_barn():
	livestock_barn_inventory.selecting_barn = self
	livestock_barn_inventory.show_barn_inventory()


func remove_barn() -> void:
	#remove all livestocks of this barn
	for _livestock in out_side_livestocks.values():
		_livestock.queue_free()
	
	for _livestock in in_barn_livestocks.values():
		_livestock.queue_free()

	#hide livestock_barn_inventory
	hide_livestock_barn_inventory()


func hide_livestock_barn_inventory() -> void:
	livestock_barn_inventory.hide_barn_inventory()
	livestock_barn_inventory.selecting_barn = null


#for demo only:
func livestock_amount_left(_livestock_name: String) -> int:
	if !current_livestock_quantity_of_each_type.has(_livestock_name):
		return 0
	return MAX_QUANTITY_OF_EACH_LIVESTOCK_TYPE[_livestock_name] - current_livestock_quantity_of_each_type[_livestock_name]
