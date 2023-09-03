extends BaseDecorations
class_name AboveDecorations


var below_obj: BelowDecorations = null


#override
func created(_build: bool = true) -> void:
	.created()
	add_below_objs()
	add_self_to_below_objs()


#override
func remove() -> void:
	.remove()
	remove_self_from_below_objs()


func add_below_objs() -> void:
	for x in range(size.x):
		for y in range(size.y):
			var point = origin + Vector2(x, y)
			var p_items: Array = Utils.get_current_map_info(GameManager.map_manager).get_item(point)
			for i in p_items.size():
				if p_items[-i-1].type == Constants.MapInfoType.BELOW_DECORATION:
					below_obj = p_items[-i-1].decoration
					return
				elif p_items[-i-1].type == Constants.MapInfoType.TILE_MAP:
					break


func add_self_to_below_objs() -> void:
	below_obj.add_above_obj(self)


func remove_self_from_below_objs() -> void:
	below_obj.remove_above_obj(self)
