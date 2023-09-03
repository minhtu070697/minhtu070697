extends StaticObjects
class_name StaticResources

var resource_type: int = Constants.ResourceType.TREE
var sprite_size: Vector2 = Vector2(0, 0)
var resource_name: String = ""

var resource_name_by_sprite: Dictionary = {}

func _ready() -> void:
	resource_name = get_resource_name_by_sprite()


func check_and_spawn_item(_item_name: String, _appear_position: Vector2 = global_position) -> void:
	GameManager.yield_item_manager.check_and_spawn_item(_item_name, _appear_position)


func yield_item(_resource_name: String = resource_name, _appear_position: Vector2 = global_position) -> void:
	GameManager.yield_item_manager.yield_item(_resource_name, _appear_position)


func get_resource_name_by_sprite() -> String:
	if not resource_name_by_sprite.has(sprite_name):
		return ""
	
	return resource_name_by_sprite[sprite_name]


