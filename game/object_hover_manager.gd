extends Node
class_name ObjectHoverManager

signal right_click_on_obj(obj_name, compare_point)
signal point_recalculate(obj_name)

var hovering_objects: Dictionary = {}
var msg_debugs: Dictionary = {}


func add_hover_obj_to_list(_obj_name: String, _priority: int, _msg_debug: String = "") -> void:
	hovering_objects[_obj_name] = _priority
	if _msg_debug != "":
		msg_debugs[_obj_name] = _msg_debug


func remove_hover_obj_from_list(_obj_name: String) -> void:
	hovering_objects.erase(_obj_name)


func not_hover_any_object() -> bool:
	return hovering_objects.size() == 0


func get_most_priority_obj() -> String:
	var _most_priority_obj_name: String = ""
	var _most_obj_value: int = -9999999999999
	for _obj_name in hovering_objects:
		if hovering_objects[_obj_name] > _most_obj_value:
			_most_priority_obj_name = _obj_name
			_most_obj_value = hovering_objects[_obj_name]
	
#	print(hovering_objects)
#	print(_most_priority_obj_name)
#	print(msg_debugs)
	msg_debugs.clear()
	return _most_priority_obj_name


func _unhandled_input(event: InputEvent) -> void:
	if hovering_objects.empty():
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and not event.pressed:
		var compare_point: Vector2 = GameManager.map_manager_utils.global_to_map_position(GameManager.get_global_mouse_position())

		for _obj_name in hovering_objects:
			emit_signal("point_recalculate", _obj_name, compare_point)
		
		emit_signal("right_click_on_obj", get_most_priority_obj())
