extends Area2D

onready var host_obj: Node2D

onready var collision: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	#host obj MUST be 2 step higher than this area, the right path can be Host_obj -> a node -> this area
	host_obj = get_parent().get_parent()
	
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	#when right click on something, Class objhovermanager will cal and return the most visible obj.
	if GameManager.object_hover_manager:
		GameManager.object_hover_manager.connect("right_click_on_obj", self, "_on_right_click_on_obj")
		GameManager.object_hover_manager.connect("point_recalculate", self, "_on_point_recalculate")


func disable_area() -> void:
	disconnect("mouse_entered", self, "_on_mouse_entered")
	disconnect("mouse_exited", self, "_on_mouse_exited")
	if GameManager.object_hover_manager:
		GameManager.object_hover_manager.disconnect("right_click_on_obj", self, "_on_right_click_on_obj")
		GameManager.object_hover_manager.disconnect("point_recalculate", self, "_on_point_recalculate")


func _on_mouse_entered() -> void:
	#register to objhovermanager this obj is being hovered
	register_to_hover_manager()


func _on_mouse_exited() -> void:
	#register to objhovermanager this obj isn't hovered anymore
	if GameManager.object_hover_manager:
		GameManager.object_hover_manager.remove_hover_obj_from_list(host_obj.name)


func register_to_hover_manager(_compare_point: Vector2 = Vector2.INF) -> void:
	if GameManager.object_hover_manager:
		GameManager.object_hover_manager.add_hover_obj_to_list(host_obj.name, get_host_obj_priority(_compare_point), String(get_host_compare_point(_compare_point)))


#calculate priority point of this area's host_obj.
func get_host_obj_priority(_compare_point: Vector2 = Vector2.INF) -> int:
	var _host_obj_map_position: Vector2
	if _compare_point == Vector2.INF:
		_host_obj_map_position = GameManager.map_manager_utils.global_to_map_position(host_obj.global_position)
	else:
		_host_obj_map_position = GameManager.map_manager_utils.global_to_map_position(get_host_compare_point(_compare_point))

	var h_point: int = 0
	if host_obj is StaticObjects:
		h_point = host_obj.height_point * 0.5
	return int(_host_obj_map_position.x + _host_obj_map_position.y) + host_obj.z_index * 10000 + h_point


#if the returned obj from manager is this area's host obj, we will play this func... because host objs are all different from each others, we won't
#do anything in this func but call a func from somewhere else that defined by this area's host obj.
func _on_right_click_on_obj(_obj_name: String) -> void:
	if _obj_name != host_obj.name:
		return
	
	if collision.disabled:
		disable_area()
		return
	
	# print("right clikc on: ", host_obj.name)
	if host_obj.has_method("on_mouse_right_click"):
		host_obj.on_mouse_right_click()

	if Utils.is_able_to_remove_click():
		# print("right clikc on: ", host_obj.name)
		check_remove_click(host_obj.global_position, Utils.get_scene_name_from_node(host_obj.name))


func _on_point_recalculate(_obj_name: String, _compare_point: Vector2) -> void:
	if _obj_name != host_obj.name:
		return
	
	if collision.disabled:
		disable_area()
		return
	
	register_to_hover_manager(_compare_point)


func check_remove_click(object_global_position, object_name):
	var character = Utils.get_current_character()
	if Utils.is_in_buildable_map(character.map_manager.map_type) and not character.map_manager.is_battlefield:
		character.map_manager.check_remove_item(object_global_position, object_name, host_obj)


#region: right-click compare

#return global position
#_compare_pos: local pos (map pos)
func get_host_compare_point(_compare_pos: Vector2) -> Vector2: 
	var host_origin: Vector2 = get_host_origin()
	var host_glb_origin: Vector2 = GameManager.map_manager_utils.map_to_global_position(host_origin)
	var compare_glb_pos: Vector2 = GameManager.map_manager_utils.map_to_global_position(_compare_pos)
	if host_glb_origin.x > compare_glb_pos.x:
		return get_obj_most_right_point(host_obj, host_origin)
	elif host_glb_origin.x == _compare_pos.x:
		return host_origin
	else:
		return get_obj_most_left_point(host_obj, host_origin)


func get_host_origin() -> Vector2:
	if host_obj is StaticObjects:
		return host_obj.origin
	else: 
		return GameManager.map_manager_utils.global_to_map_position(host_obj.global_position)


func get_host_global_origin() -> Vector2:
	return GameManager.map_manager_utils.map_to_global_position(get_host_origin())


#return global position
func get_obj_most_left_point(_obj: Node2D, _origin: Vector2) -> Vector2:
	#	print(_obj.name, " lp: ", _origin + Vector2(get_obj_size(_obj).x - 1, 0))
		if _obj is StaticObjects:
			return _obj.most_l_point
		return _origin + Vector2(get_obj_size(_obj).x - 1, 0)
	
	
#return global position
func get_obj_most_right_point(_obj: Node2D, _origin: Vector2) -> Vector2:
#	print(_obj.name, " rp: ", _origin + Vector2(0, get_obj_size(_obj).y - 1))
	if _obj is StaticObjects:
		return _obj.most_r_point
	return _origin + Vector2(0, get_obj_size(_obj).y - 1)


func get_obj_size(_obj: Node2D) -> Vector2:
	if _obj.get("size"):
		return _obj.size
	else:
		return Vector2.ONE

#endregion
