extends BaseDecorations
class_name BelowDecorations


var above_objs: Dictionary = {}


func add_above_obj(_obj: StaticObjects) -> void:
	above_objs[_obj.name] = _obj
	# print(name, " ", above_objs)


func remove_above_obj(_obj: StaticObjects) -> void:
	above_objs.erase(_obj.name)
	# print(name, " ", above_objs)
