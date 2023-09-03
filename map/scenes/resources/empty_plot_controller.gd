extends Node
class_name EmptyPlotController

const YOUNG_PLANT_SCENE_PATH = "res://young_plants/scene/young_plant.tscn"

var has_young_plant: bool = false
var young_plant: YoungPlant = null

var fertilizer_in_plot: int = 150

var character: Character
var seed_inventory

var target_top_arrow_pointer: PointerTopArrow = null

onready var empty_plot = get_parent()

func _ready() -> void:
	create_and_move_pointer_arrow_to_this_empty_plot()


func young_plant_seed(_young_plant_name: String):
	if has_young_plant:
		return
	has_young_plant = true
	young_plant = Utils.load_resource(YOUNG_PLANT_SCENE_PATH, "young_plant", "scene").instance()
	var _young_plant_map_position = GameManager.map_manager_utils.global_to_map_position(empty_plot.global_position)
	young_plant.global_position = empty_plot.global_position
	empty_plot.get_parent().add_child(young_plant)
	GameManager.map_manager.map_info.append_resource(young_plant, Constants.ResourceType.YOUNG_PLANT, _young_plant_map_position)
	young_plant.init(_young_plant_name)
	young_plant.set_young_plant_farm_plot(self)
	young_plant.created()

	GameManager.map_manager.ysort.nogias_insert(young_plant)
	young_plant.update_sort_position()
	destroy_top_pointer_arrow()


func fertilizer_consumed(_consume_amount: int) -> int:
	var _fertilizer_consume_amount = Utils.clamp_int(_consume_amount, 0, fertilizer_in_plot)
	fertilizer_in_plot -= _fertilizer_consume_amount
	return _fertilizer_consume_amount


func plant_removed() -> void:
	has_young_plant = false
	create_and_move_pointer_arrow_to_this_empty_plot()


func on_mouse_right_click() -> void:
	if has_young_plant:
		return
		
	if !character:
		character = Utils.get_current_character()

	if !seed_inventory:
		seed_inventory = character.get_node_or_null("ui/SeedInventory")
	
	if not Utils.node_exists(seed_inventory):
		return
	
	select_young_plant()


func select_young_plant() -> void:
	seed_inventory.selecting_plot = self
	seed_inventory.show_seed_inventory()


func remove_empty_plot() -> void:
	hide_seed_inventory()
	destroy_top_pointer_arrow()


func hide_seed_inventory() -> void:
	if not Utils.node_exists(seed_inventory):
		seed_inventory = null
		return
	
	seed_inventory.selecting_plot = null
	seed_inventory.hide_seed_inventory()


func create_top_pointer_arrow() -> void:
	target_top_arrow_pointer = Utils.load_resource("res://ui/scenes/PointerTopArrow.tscn", "obj_top_arrow_pointer", "scene").instance()
	GameManager.map_manager.add_child(target_top_arrow_pointer)


func destroy_top_pointer_arrow() -> void:
	target_top_arrow_pointer.fly_away()
	target_top_arrow_pointer = null


func create_and_move_pointer_arrow_to_this_empty_plot() -> void:
	create_top_pointer_arrow()
	move_top_arrow_pointer(empty_plot)
	target_top_arrow_pointer.set_pointer_scale(0.4)
	target_top_arrow_pointer.set_pointer_transparent(0.4)


func move_top_arrow_pointer(_target: Node, _hover_height: Vector2 = Vector2(0, -10)) -> void:
	target_top_arrow_pointer.move_to_target(_target, _hover_height)


func remove_farm_plot() -> void:
	empty_plot.queue_free()
	empty_plot = null
