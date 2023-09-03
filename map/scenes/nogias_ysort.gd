extends YSort
class_name NogiasYSort


export(bool) var enable_nogias_ysort: bool = true
export(bool) var focus_long_obj: bool = true
const MAX_COMPARE_DISTANCE_X: int = 50
const MAX_COMPARE_DISTANCE_Y: int = 200

#for normal_decoration only
var _need_check_above_objs: Array = []


func nogias_ysort() -> void:
	if not enable_nogias_ysort:
		return
	# children_heapsort(self)


# only use when all obj are ysorted
func nogias_insert(_obj: Node2D, _check_height_p: bool = false, _in_array: Array = [], _check_moving: bool = false) -> void:
	if not enable_nogias_ysort:
		return

	var obj_infos: Dictionary = get_obj_infos(_obj)
	
	if _check_height_p:
		move_obj_bottom_tree(_obj, self)
		move_abv_to_blw(_obj)
		#sort above decorations
		sort_with_list_objs(_obj, _obj.below_obj.above_objs.values(), false, true, true)
	else:
		search_move_obj_to_right_idx(_obj, obj_infos)
		check_position_with_long_obj(_obj, obj_infos, false)
		if focus_long_obj:
			check_position_with_long_obj(_obj, obj_infos, true)
		
		if _check_moving:
			check_moving_objs(_obj, obj_infos)
		
		check_with_abv_objs_in_list(_obj, obj_infos, self, _need_check_above_objs, false, true)
	
	_need_check_above_objs.clear()


func move_abv_to_blw(_abv_obj: AboveDecorations) -> void:
	move_obj_to_right_idx(_abv_obj, _abv_obj.below_obj.get_index() + 1)


#test new function
#sort only in list objs, return if obj is change pos
func sort_with_list_objs(_obj: Node2D, _in_array: Array, _only_near_obj: bool = false, _only_static: bool = false, _check_abv: bool = false) -> bool:
	if not enable_nogias_ysort:
		return false
	var obj_infos: Dictionary = get_obj_infos(_obj)
	var sorted: bool = check_with_objs_in_list(_obj, obj_infos, self, _in_array, _only_near_obj, _only_static, _check_abv)
	return sorted


#region: test
func check_moving_objs(_obj: Node2D, _obj_infos: Dictionary) -> void:
	var _search: int = begin_check(_obj, _obj_infos, self, false, true, false, [], false, true)
	# print(_obj.name, " result moving moving pos: ", _search)
	move_obj_to_right_idx(_obj, _search)


#endregion
func check_height_p(_obj: Node2D, _obj_infos: Dictionary, _in_array: Array = []) -> void:

	var _search: int = begin_check(_obj, _obj_infos, self, false, true, true, _in_array)
	# print(_obj.name, " height result moving pos: ", _search)
	move_obj_to_right_idx(_obj, _search)


func check_near_above_obj(_obj: Node2D, _obj_infos: Dictionary, _in_array: Array = [], _begin_obj: Node2D = null) -> void:
	var _search: int = begin_check(_obj, _obj_infos, self, false, true, false, _in_array, true)
	move_obj_to_right_idx(_obj, _search)


func check_position_with_long_obj(_obj: Node2D, _obj_infos: Dictionary, _focus_long_obj: bool = false, _in_array: Array = []) -> void:
	var _search: int = begin_check(_obj, _obj_infos, self, _focus_long_obj, true)
	# print(_obj.name, " long result moving pos: ", _search)
	move_obj_to_right_idx(_obj, _search)


func check_with_objs_in_list(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _list: Array, _only_near_obj: bool = false, _only_static: bool = false, _check_abv: bool = false) -> bool:
	var current_obj_idx: int = _obj.get_index()
	var idx: int = get_objs_idx_in_list(_obj, _obj_infos, _list, _only_near_obj, _only_static, _check_abv)
	if idx > current_obj_idx:
		idx -=1
	idx = min(idx, _parent.get_child_count() - 1)
	var sorted: bool = current_obj_idx != idx
	move_obj_to_right_idx(_obj, idx)
	# if sorted:
	# 	print(_obj, "change from: ", current_obj_idx, " to: ", idx)
	return sorted


func check_with_abv_objs_in_list(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _list: Array, _only_near_obj: bool = false, _only_static: bool = false) -> void:
	var idx: int = get_objs_idx_in_abv_list(_obj, _obj_infos, _list, _only_near_obj, _only_static)
	idx = min(idx, _parent.get_child_count() - 1)
	move_obj_to_right_idx(_obj, idx)


func begin_check(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false, _find_moving: bool = false, _begin_obj: Node2D = null) -> int:
	var _size: int = _parent.get_child_count()
	var _current_obj_idx: int = _obj.get_index() if _begin_obj == null else _begin_obj.get_index()
	var _result: int = lf_check_surround_objs(_obj, _obj_infos, _parent, _current_obj_idx, _size - 1, 0, _size, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, _find_moving)
	if _result > _current_obj_idx:
		_result -=1
	_result = min(_result, _size - 1) if _result >= 0 else _current_obj_idx
	return _result


func check_n_add_abv_objs_to_check_list(_current_idx: int, _parent: Node2D) -> void:
	var current_obj: Node2D = _parent.get_child(_current_idx)
	if current_obj is BelowDecorations:
		add_above_objs_to_check(current_obj)


func lf_check_surround_objs(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _max: int, _min: int, _size: int, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false, _find_moving: bool = false) -> int:
	var _left_static_idx: int = find_left_obj(_obj, _obj_infos, _parent, _current, _min, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
	if _left_static_idx == -1:
		var _right_static_idx: int = find_right_obj(_obj, _obj_infos, _parent, _current, _max, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
		if _right_static_idx == -1:
			# print("lr-1")
			return -1
		else:
			_current = _right_static_idx
			if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos, _check_height):
				# print("l-1,<r")
				return -1
			else:
				if not _in_same_below_obj and not _check_height:
					check_n_add_abv_objs_to_check_list(_current, _parent)
				while true:
					# print("XASD")
					var _right_static_idx_next: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
					if _right_static_idx_next != -1:
						if nogias_sort_az(_obj, _parent.get_child(_right_static_idx_next), _obj_infos, _check_height):
							# print("l-1, r <r")
							return _current + 1
						else:
							_current = _right_static_idx_next
							if not _in_same_below_obj and not _check_height:
								check_n_add_abv_objs_to_check_list(_current, _parent)
							
					else:
						return _current + 1
				
				return -1
	else:
		_current = _left_static_idx
		
		if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos, _check_height):
			while true:
				# print("LLASD")
				var _left_static_idx_next: int = find_left_obj(_obj, _obj_infos, _parent, _current - 1, _min, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
				if _left_static_idx_next != -1:
					if nogias_sort_az(_obj, _parent.get_child(_left_static_idx_next), _obj_infos, _check_height):
						_current = _left_static_idx_next
						
					else:
						if not _in_same_below_obj and not _check_height:
							check_n_add_abv_objs_to_check_list(_current, _parent)
						return _current + 1
						
				else:
					# print("l l-1")
					return _current
			
			return -1
			
		else:
			if not _in_same_below_obj and not _check_height:
				check_n_add_abv_objs_to_check_list(_current, _parent)
			var _right_static_idx: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
			if _right_static_idx == -1:
				# print("l r-1")
				return -1
			else:
				_current = _right_static_idx
				if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos, _check_height):
					# print("l <r")
					return -1
				else:
					if not _in_same_below_obj and not _check_height:
						check_n_add_abv_objs_to_check_list(_current, _parent)
					while true:
						# print("RRASD")
						var _right_static_idx_next: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj, !_find_moving)
						if _right_static_idx_next != -1:
							if nogias_sort_az(_obj, _parent.get_child(_right_static_idx_next), _obj_infos, _check_height):
								return _current + 1
							else:
								_current = _right_static_idx_next
								if not _in_same_below_obj and not _check_height:
									check_n_add_abv_objs_to_check_list(_current, _parent)
						else:
							return _current + 1
					
					return -1


func search_move_obj_to_right_idx(_obj: Node2D, _obj_infos: Dictionary, _focus_long_obj: bool = false) -> void:
	move_obj_bottom_tree(_obj, self)
	var _search: int = nogias_bsearch(_obj, _obj_infos, self, _focus_long_obj)
	# print(_obj.name, " result pos: ", _search)
	move_obj_to_right_idx(_obj, _search)


func move_obj_bottom_tree(_obj: Node2D, _parent: Node2D) -> void:
	var _size: int = _parent.get_child_count()
	move_child(_obj, _size - 1)


func move_obj_to_right_idx(_obj: Node2D, _idx: int) -> void:
	if _idx == -1:
		return
	
	var sorted_abv_objs: Dictionary = {}
	if _obj is BelowDecorations:
		sorted_abv_objs = get_relative_moving_idx_abv_objs(_obj, _idx)
	move_child(_obj, _idx)
	# print("move ", _obj.name, " to pos: ", _idx)
	for i in sorted_abv_objs:
		var _obj_idx: int = _obj.get_index()
		move_obj_bottom_tree(sorted_abv_objs[i], self)
		# print("move ", sorted_abv_objs[i].name, " to pos: ", _obj_idx+i)
		move_child(sorted_abv_objs[i], _obj_idx+i)


func get_relative_moving_idx_abv_objs(_below_obj: BelowDecorations, _idx: int) -> Dictionary:
	var sorted_abv_objs: Dictionary = {}
	var cr_idx: int = _below_obj.get_index()
	for i in _below_obj.above_objs.size():
		sorted_abv_objs[i + 1] = get_child(cr_idx + i + 1)

	return sorted_abv_objs


func nogias_bsearch(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _focus_long_obj: bool = false) -> int:
	var _size: int = _parent.get_child_count()
	var _result: int = nogias_bsearch_frag(_obj, _obj_infos, _parent, _size/2, _size - 1, 0, _size, _focus_long_obj)
	_result = min(_result, _size - 1)
	return _result


func nogias_bsearch_frag(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _max: int, _min: int, _size: int, _focus_long_obj: bool = false) -> int:
	if _parent.get_child(_current).name == _obj.name:
		# print("compare with self")
		if _current == _min:
			_current = min(_current + 1, _size - 1)
		elif _current == _max:
			_current = max(0, _current - 1)
		else:
			_current += 1
	
	if _current == _min:
		# print("cr=min")
		if _min == 0:
			if nogias_sort_az(_obj, _parent.get_child(_min), _obj_infos, false, "cr=min"):
				return _current #0
			else:
				return _current + 1 #1
		else:
			return _current + 1
	
	if _current == _max:
		# print("cr=max")
		if _max == _size - 1:
			if nogias_sort_az(_obj, _parent.get_child(_max), _obj_infos, false, "cr=max"):
				return _current - 1
			else:
				return _current
		else:
			return _current
	
	var _left_static_idx: int = find_left_obj(_obj, _obj_infos, _parent, _current, _min, _focus_long_obj)
	if _left_static_idx == -1:
		# print("l=-1")
		var _right_static_idx: int = find_right_obj(_obj, _obj_infos, _parent, _current, _max, _focus_long_obj)
		if _right_static_idx == -1:
			return -1
		else:
			_current = _right_static_idx
			if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos, false, "l-1,r"):
				return _current
			else:
				var _right_static_idx_next: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj)
				if _right_static_idx_next != -1:
					if nogias_sort_az(_obj, _parent.get_child(_right_static_idx_next), _obj_infos, false, "l-1,rr"):
						return _current + 1
					else:
						_current = _right_static_idx_next
						return nogias_bsearch_frag(_obj, _obj_infos, _parent, (_current + _max) / 2, _max, _current, _size, _focus_long_obj)
				else:
					return _current + 1
	else:
		# print("l")
		_current = _left_static_idx
		
		if _current == _min:
			if _min == 0:
				if nogias_sort_az(_obj, _parent.get_child(_min), _obj_infos, false, "l,cr=min"):
					return _current #0v
				else:
					return _current + 1 #1
			else:
				# print("l=min, cr+1")
				return _current + 1
				
		if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos):
			var _left_static_idx_next: int = find_left_obj(_obj, _obj_infos, _parent, _current - 1, _min, _focus_long_obj)
			if _left_static_idx_next != -1:
				if nogias_sort_az(_obj, _parent.get_child(_left_static_idx_next), _obj_infos, false, "ll"):
					_current = _left_static_idx_next
					return nogias_bsearch_frag(_obj, _obj_infos, _parent, (_current + _min) / 2, _current, _min, _size, _focus_long_obj)
				else:
					return _current
			else:
				return _current
			
		else:
			var _right_static_idx: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj)
			if _right_static_idx == -1:
				return -1
			else:
				_current = _right_static_idx
				if nogias_sort_az(_obj, _parent.get_child(_current), _obj_infos, false, "lr"):
					return _current
				else:
					var _right_static_idx_next: int = find_right_obj(_obj, _obj_infos, _parent, _current + 1, _max, _focus_long_obj)
					if _right_static_idx_next != -1:
						if nogias_sort_az(_obj, _parent.get_child(_right_static_idx_next), _obj_infos, false, "lrr"):
							return _current + 1
						else:
							_current = _right_static_idx_next
							return nogias_bsearch_frag(_obj, _obj_infos, _parent, (_current + _max) / 2, _max, _current, _size, _focus_long_obj)
					else:
						return _current + 1


func find_left_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _min: int, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false, _find_static: bool = true) -> int:
	if _find_static:
		return find_left_static_obj(_obj, _obj_infos, _parent, _current, _min, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj)
	else:
		return find_left_moving_obj(_obj, _obj_infos, _parent, _current, _min, _focus_long_obj, _only_near_obj)


func find_left_static_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _min: int, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false) -> int:
	if _current < _min:
		return -1
	for i in range(_current, _min - 1, -1):
		var _i_obj: Node2D = _parent.get_child(i)
		if (_i_obj != _obj and _i_obj.visible and _i_obj is StaticObjects and (_in_same_below_obj or not (_i_obj is AboveDecorations)) and (not _focus_long_obj or get_obj_size(_i_obj) != Vector2.ONE)
			and (not _only_near_obj or obj_is_nearby(_obj, _i_obj, _obj_infos)) and (not _check_height or in_another_obj(_obj, _i_obj, _obj_infos))
			and (_in_array == [] or (_i_obj in _in_array))):
			return i
	return -1


func find_left_moving_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _min: int, _focus_long_obj: bool = false, _only_near_obj: bool = false) -> int:
	if _current < _min:
		return -1
	for i in range(_current, _min - 1, -1):
		var _i_obj: Node2D = _parent.get_child(i)
		if (_i_obj != _obj and _i_obj.visible and not ( _i_obj is StaticObjects) and (not _focus_long_obj or get_obj_size(_i_obj) != Vector2.ONE)
			and (not _only_near_obj or obj_is_nearby(_obj, _i_obj, _obj_infos))):
			return i
	return -1


func find_right_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _max: int, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false, _find_static: bool = true) -> int:
	if _find_static:
		return find_right_static_obj(_obj, _obj_infos, _parent, _current, _max, _focus_long_obj, _only_near_obj, _check_height, _in_array, _in_same_below_obj)
	else:
		return find_right_moving_obj(_obj, _obj_infos, _parent, _current, _max, _focus_long_obj, _only_near_obj)


func find_right_static_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _max: int, _focus_long_obj: bool = false, _only_near_obj: bool = false, _check_height: bool = false, _in_array: Array = [], _in_same_below_obj: bool = false) -> int:
	if _current > _max:
		return -1
	for i in range(_current, _max + 1):
		var _i_obj: Node2D = _parent.get_child(i)
		if (_i_obj != _obj and _i_obj.visible and _i_obj is StaticObjects and (_in_same_below_obj or not (_i_obj is AboveDecorations)) and (not _focus_long_obj or get_obj_size(_i_obj) != Vector2.ONE)
			and (not _only_near_obj or obj_is_nearby(_obj, _i_obj, _obj_infos)) and (not _check_height or in_another_obj(_obj, _i_obj, _obj_infos))
			and (_in_array == [] or (_i_obj in _in_array))):
			return i
	
	return -1


func find_right_moving_obj(_obj: Node2D, _obj_infos: Dictionary, _parent: Node2D, _current: int, _max: int, _focus_long_obj: bool = false, _only_near_obj: bool = false) -> int:
	if _current > _max:
		return -1
	for i in range(_current, _max + 1):
		var _i_obj: Node2D = _parent.get_child(i)
		if (_i_obj != _obj and _i_obj.visible and not (_i_obj is StaticObjects) and (not _focus_long_obj or get_obj_size(_i_obj) != Vector2.ONE)
			and (not _only_near_obj or obj_is_nearby(_obj, _i_obj, _obj_infos))):
			return i
	
	return -1


# func in_same_below_obj(_obj: StaticObjects, _obj2: StaticObjects, _obj_infos: Dictionary) -> bool:
# 	if _below_obj_list.size() <= 0 or _obj2 == _below_obj_list[-1] or _obj2.height_point != _obj.height_point:
# 		return false
	
# 	return in_another_obj(_obj2, _below_obj_list[-1], _obj_infos)


func in_another_obj(_obj: Node2D, _obj2: Node2D, _obj_infos: Dictionary) -> bool:
	var _obj_map_pos: Vector2 = GameManager.map_manager_utils.global_to_map_position(get_compare_points(_obj, _obj2, _obj_infos))
	var _pos_in_obj2: Vector2 = _obj_map_pos - get_obj_origin(_obj2)
	var _obj2_size: Vector2 = get_obj_size(_obj2)
	return _pos_in_obj2.x < _obj2_size.x and _pos_in_obj2.x >= 0 and _pos_in_obj2.y < _obj2_size.y and _pos_in_obj2.y >= 0


func obj_is_nearby(_obj: Node2D, _obj2: Node2D, _obj_infos: Dictionary) -> bool:
	var obj2_infos: Dictionary = get_obj_infos(_obj2)
	var _obj_pos: Vector2 = get_compare_points(_obj, _obj2, _obj_infos)
	var _obj2_pos: Vector2 = get_compare_points(_obj2, _obj, obj2_infos)
	var _distance_x: float = abs(_obj_pos.x - _obj2_pos.x)
	var _distance_y: float = abs(_obj_pos.y - _obj2_pos.y)
	return _distance_x <= MAX_COMPARE_DISTANCE_X and _distance_y <= MAX_COMPARE_DISTANCE_Y


func nogias_height_sort_az(a: StaticObjects, b: StaticObjects) -> bool:
	# print("======check-height=============")
	# print(a.name, " height: ", a.height_point)
	# print(b.name, " height: ", b.height_point)
	if not a or not b:
		return false
	return a.height_point < b.height_point


func nogias_sort_az(a: Node2D, b: Node2D, _a_infos: Dictionary, _check_height: bool = false, _debug_msg: String = "") -> bool:
	if _check_height:
		return nogias_height_sort_az(a, b)

	var _a_origin: Vector2 = _a_infos.map_origin
	var a_gl_origin: Vector2 = _a_infos.global_origin
	var a_most_lp: Vector2 = _a_infos.most_lp
	var a_most_rp: Vector2 = _a_infos.most_rp
	var _b_origin: Vector2 = get_obj_origin(b)
	var b_gl_origin: Vector2 = get_obj_global_origin(b)
	# if _debug_msg:
	# 	print("sort debug msg: ", _debug_msg)
	if a_gl_origin.x > b_gl_origin.x:
		# print("=====left-line======= ", get_obj_global_origin(a).x , " ", get_obj_global_origin(b).x)
		# print(a.name, " rpy: ", get_obj_most_right_point(a, _a_origin).y)
		# print(b.name, " lpy: ", get_obj_most_left_point(b, _b_origin).y)
		return a_most_rp.y <= get_obj_most_left_point(b, _b_origin).y
	elif a_gl_origin.x == b_gl_origin.x:
		var _b_size: Vector2 = get_obj_size(b)
		if _b_size.x >= _b_size.y:
			# print("=====middle-line=======", get_obj_global_origin(a).x , " ", get_obj_global_origin(b).x)
			# print(a.name, " lpy: ", get_obj_most_left_point(a, _a_origin).y)
			# print(b.name, " rpy: ", get_obj_most_right_point(b, _b_origin).y)
			var b_rp: Vector2 = get_obj_most_right_point(b, _b_origin)
			if a_most_lp.y == b_rp.y and a is StaticObjects and b is StaticObjects:
				return nogias_height_sort_az(a, b)
			else:
				return a_most_lp.y <= get_obj_most_right_point(b, _b_origin).y
		else:
			# print("=====middle-line=======", get_obj_global_origin(a).x , " ", get_obj_global_origin(b).x)
			# print(a.name, " rpy: ", get_obj_most_right_point(a, _a_origin).y)
			# print(b.name, " lpy: ", get_obj_most_left_point(b, _b_origin).y)
			var b_lp: Vector2 = get_obj_most_left_point(b, _b_origin)
			if a_most_rp.y == b_lp.y and a is StaticObjects and b is StaticObjects:
				return nogias_height_sort_az(a, b)
			else:
				return a_most_rp.y <= get_obj_most_left_point(b, _b_origin).y
	else:
		# print("=====right-line=======", get_obj_global_origin(a).x , " ", get_obj_global_origin(b).x)
		# print(a.name, " lpy: ", get_obj_most_left_point(a, _a_origin).y)
		# print(b.name, " rpy: ", get_obj_most_right_point(b, _b_origin).y)
		return a_most_lp.y <= get_obj_most_right_point(b, _b_origin).y


#return global position
func get_compare_points(a: Node2D, b: Node2D, _a_infos: Dictionary, _b_infos: Dictionary = {}) -> Vector2:
	var _a_origin: Vector2 = _a_infos.map_origin
	var a_gl_origin: Vector2 = _a_infos.global_origin
	var a_most_lp: Vector2 = _a_infos.most_lp
	var a_most_rp: Vector2 = _a_infos.most_rp
	var b_gl_origin: Vector2 = get_obj_global_origin(b) if _b_infos.empty() else _b_infos.global_origin
	if a_gl_origin.x > b_gl_origin.x:
		return a_most_rp
	elif a_gl_origin.x == b_gl_origin.x:
		var _b_size: Vector2 = get_obj_size(b) if _b_infos.empty() else _b_infos.size
		if _b_size.x >= _b_size.y:
			return a_most_lp
		else:
			return a_most_rp
	else:
		return a_most_lp


#return dict of all obj needed compare infos
func get_obj_infos(_obj: Node2D) -> Dictionary:
	var map_ori: Vector2 = get_obj_origin(_obj)
	var glb_ori: Vector2 = get_obj_global_origin(_obj)
	var lp: Vector2 = get_obj_most_left_point(_obj, map_ori)
	var rp: Vector2 = get_obj_most_right_point(_obj, map_ori)
	var size: Vector2 = get_obj_size(_obj)
	return {
		"map_origin": map_ori,
		"global_origin": glb_ori,
		"most_lp": lp,
		"most_rp": rp,
		"size": size
	}


#return map position
func get_obj_origin(_obj: Node2D) -> Vector2:
	if _obj is StaticObjects:
		return _obj.origin
	else:
		return GameManager.map_manager_utils.global_to_map_position(_obj.global_position)


func get_obj_global_origin(_obj: Node2D) -> Vector2:
	if _obj is StaticObjects:
		return _obj.gl_origin
	else:
		return GameManager.map_manager_utils.map_to_global_position(GameManager.map_manager_utils.global_to_map_position(_obj.global_position))


#return global position
func get_obj_most_left_point(_obj: Node2D, _origin: Vector2) -> Vector2:
	# print(_obj.name, " lp: ", _origin + Vector2(get_obj_size(_obj).x - 1, 0))
	if _obj is StaticObjects:
		return _obj.most_l_point
	return GameManager.map_manager_utils.map_to_global_position(_origin + Vector2(get_obj_size(_obj).x - 1, 0))


#return global position
func get_obj_most_right_point(_obj: Node2D, _origin: Vector2) -> Vector2:
	# print(_obj.name, " rp: ", _origin + Vector2(0, get_obj_size(_obj).y - 1))
	if _obj is StaticObjects:
		return _obj.most_r_point
	return GameManager.map_manager_utils.map_to_global_position(_origin + Vector2(0, get_obj_size(_obj).y - 1))


func get_obj_size(_obj: Node2D) -> Vector2:
	if _obj.get("size"):
		return _obj.size
	else:
		return Vector2.ONE


#region: heapsort
# func children_heapsort(_parent: Node2D) -> void:
# 	var _len: int = _parent.get_child_count()

# 	for i in range((_len/2 - 1), -1, -1):
# 		heapify(_parent, _len, i)

# 	for i in range((_len - 1), 0, -1):
# 		swap_obj_tree_pos(_parent.get_child(0), _parent.get_child(i), _parent)
# 		heapify(_parent, i, 0)


# func heapify(_parent: Node2D, _size: int, _idx: int) -> void:
# 	var _largest: int = _idx
# 	var _left: int = 2*_idx + 1
# 	var _right: int = 2*_idx + 2
	
# 	if (_left < _size and nogias_sort_az(_parent.get_child(_largest), _parent.get_child(_left))):
# 		_largest = _left
	
# 	if (_right < _size and nogias_sort_az(_parent.get_child(_largest), _parent.get_child(_right))):
# 		_largest = _right
	
# 	if _largest != _idx:
# 		swap_obj_tree_pos(_parent.get_child(_idx), _parent.get_child(_largest), _parent)
# 		heapify(_parent, _size, _largest)


# func swap_obj_tree_pos(_a: Node2D, _b: Node2D, _parent: Node2D) -> void:
# 	var _old_a_idx: int = _a.get_index()
# 	_parent.move_child(_a, _b.get_index())
# 	_parent.move_child(_b, _old_a_idx)


func add_above_objs_to_check(_below_obj: BelowDecorations) -> void:
	# print("from ", _below_obj.name, " appends: ", _below_obj.above_objs)
	_need_check_above_objs.append_array(_below_obj.above_objs.values())
	
	
func get_objs_idx_in_list(_obj: Node2D, _obj_infos: Dictionary, _list_obj: Array, _only_near_obj: bool = false, _only_static: bool = false, _abv_objs: bool = false) -> int:
	var cr_obj_idx: int = _obj.get_index()
	# print(_obj.name, " c_check from idx: ", cr_obj_idx)
	var obj_idx_larger: bool = false
	# print(_list_obj)
	for checking_obj in _list_obj:
		if checking_obj == _obj or not checking_obj or not checking_obj.visible or (not _abv_objs and checking_obj is AboveDecorations) or not ((not _only_near_obj or obj_is_nearby(_obj, checking_obj, _obj_infos)) and (not _only_static or (checking_obj is StaticObjects and checking_obj.created))):
			continue
		# print("checking obj: ", checking_obj.name)
		var checking_obj_idx: int = checking_obj.get_index()
		obj_idx_larger = cr_obj_idx > checking_obj_idx
		if obj_idx_larger:
			if nogias_sort_az(_obj, checking_obj, _obj_infos):
				cr_obj_idx = checking_obj_idx
		else:
			if not nogias_sort_az(_obj, checking_obj, _obj_infos):
				cr_obj_idx = checking_obj_idx + 1
				# print(_obj.name, " is larger than ", checking_obj.name, " and move to: ", cr_obj_idx)

				if checking_obj is BelowDecorations:
					# print(checking_obj.name, " is blwobj, with ", checking_obj.above_objs.size(), " abvobjs")
					cr_obj_idx += checking_obj.above_objs.size()
					# print("move obj to: ", cr_obj_idx)
	
	# print(_obj.name, " collision_check idx: ", cr_obj_idx)
	return cr_obj_idx


func get_objs_idx_in_abv_list(_obj: Node2D, _obj_infos: Dictionary, _list_obj: Array, _only_near_obj: bool = false, _only_static: bool = false) -> int:
	var cr_obj_idx: int = _obj.get_index()
	var obj_idx_larger: bool = false
	# print(_list_obj)
	for checking_obj in _list_obj:
		if checking_obj == _obj or not checking_obj or not ((not _only_near_obj or obj_is_nearby(_obj, checking_obj, _obj_infos)) and (not _only_static or checking_obj is StaticObjects)):
			continue
		# print("checking obj: ", checking_obj.name)
		var checking_obj_idx: int = checking_obj.get_index()
		obj_idx_larger = cr_obj_idx > checking_obj_idx
		if not obj_idx_larger:
			cr_obj_idx = checking_obj_idx + 1
	
	# print(_obj.name, " abv_check idx: ", cr_obj_idx)
	return cr_obj_idx


#region: collision area
func get_overlapping_objs(_area: Area2D) -> Array:
	var list: Array = []
	if _area == null:
		return []
	
	# print("overlap with: ", _area.get_overlapping_areas())
	for area in _area.get_overlapping_areas():
		# print(name, " overlap with: ", area.owner.name)
		if area.owner is Node2D:
			list.append(area.owner)
	
	# print("return : ", list)
	return list


#region: Nogias YSort
func static_unbalance_col_sort(_area: Area2D, _obj: StaticObjects, _begin: bool = true) -> void:
	# print(_obj.name, " is sorting!")
	if _begin:
		yield(Utils.start_coroutine(0.04), "completed")
	var overlap_objs: Array = get_overlapping_objs(_area)
	# print(_obj.name, "overlap with ", overlap_objs)
	var sorted: bool = sort_with_list_objs(_obj, overlap_objs, false, true)
	if sorted and _obj.size.x != _obj.size.y:
		for overlap_obj in overlap_objs:
			if overlap_obj.visible and not overlap_obj is AboveDecorations and overlap_obj is StaticObjects and overlap_obj != _obj and overlap_obj.created and overlap_obj.size.x == overlap_obj.size.y:
				# print(overlap_obj.name, " updating sort pos")
				overlap_obj.update_sort_position(false)


func moving_col_sort(_area: Area2D, _obj: Node2D, _wait_a_bit: bool = true) -> bool:
	# print(_obj.name, " is sorting!")
	if _wait_a_bit:
		yield(Utils.start_coroutine(0.1), "completed")
	var overlap_objs: Array = get_overlapping_objs(_area)
	# print(_obj.name, "overlap with ", overlap_objs)
	var sorted: bool = sort_with_list_objs(_obj, overlap_objs)
	return sorted

#endregion
