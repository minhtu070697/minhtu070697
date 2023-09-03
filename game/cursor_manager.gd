extends Node

class_name CursorManager

var default_cursor = preload("res://ui/textures/cursors/cursor.png")
var inactive_cursor = preload("res://ui/textures/cursors/inactive_cursor.png")
var active_cursor = preload("res://ui/textures/cursors/active_cursor.png")
var axe_cursor = preload("res://ui/textures/cursors/axe.png")
var pick_cursor = preload("res://ui/textures/cursors/pick.png")
var hoe_cursor = preload("res://ui/textures/cursors/hoe.png")
var rod_cursor = preload("res://ui/textures/cursors/rod.png")
var build_cursor = preload("res://ui/textures/cursors/build_cursor.png")

var current_cursor = null
var default_hotspot = Vector2(5, 5)
var build_hotspot = Vector2(5, 5)


func load_cursor():
	if is_active_custom_cursor():
		detect_by_collision()
		Input.set_custom_mouse_cursor(current_cursor, Input.CURSOR_ARROW, default_hotspot)
	else:
		if is_holding_object():
			Input.set_custom_mouse_cursor(build_cursor, Input.CURSOR_ARROW, build_hotspot)
		else:
			Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, default_hotspot)


func detect_by_collision():
	var map_manager = GameManager.map_manager
	var node_origin = Utils.get_node_origin_from_current_cursor_if_inside_area2d(map_manager)
	if node_origin != null:
		var top_item = Utils.get_current_map_info(map_manager).top_item(node_origin)
		if (
			top_item != null
			and (
				top_item.is_clickable_resource()
				or top_item.is_decoration()
				or top_item.is_above_decoration()
				or top_item.is_below_decoration()
				or top_item.is_tall_decoration()
				or top_item.is_wall_decoration()
				or top_item.is_walkable_decoration()
				or top_item.is_buildable_decoraion()
			)
		):
			current_cursor = active_cursor
	else:
		detect_by_data(map_manager)


func detect_by_data(map_manager):
	var local_mouse_position = map_manager.map_navigator.world_to_point(
		map_manager.get_global_mouse_position()
	)
	if Utils.is_outside_of_map(
		map_manager.list_map_positions, map_manager.size, local_mouse_position
	):
		current_cursor = inactive_cursor
		return

	var top_item = Utils.get_current_map_info(map_manager).top_item(local_mouse_position)
	if top_item != null:
		if top_item.is_tile() and top_item.name == "WaterTileMap":
			current_cursor = rod_cursor
		elif top_item.is_resource():
			if top_item.resource_type == Constants.ResourceType.TREE:
				current_cursor = axe_cursor
			elif (
				top_item.resource_type == Constants.ResourceType.STONE
				or top_item.resource_type == Constants.ResourceType.GOLD
				or top_item.resource_type == Constants.ResourceType.AMBER
				or top_item.resource_type == Constants.ResourceType.AMETHYST
				or top_item.resource_type == Constants.ResourceType.DIAMOND
				or top_item.resource_type == Constants.ResourceType.EMERALD
				or top_item.resource_type == Constants.ResourceType.QUARTZ
				or top_item.resource_type == Constants.ResourceType.RUBY
				or top_item.resource_type == Constants.ResourceType.SAPPSHIRE
			):
				current_cursor = pick_cursor
			elif top_item.resource_type == Constants.ResourceType.OTHER:
				current_cursor = hoe_cursor
			else:
				current_cursor = default_cursor
		else:
			current_cursor = default_cursor
	else:
		current_cursor = default_cursor


func is_holding_object():
	return GameManager.build_manager.holding_object


func is_active_custom_cursor():
	return Utils.is_able_to_checking_cursor()
