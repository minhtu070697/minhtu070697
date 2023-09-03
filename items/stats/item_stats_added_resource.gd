extends Resource
class_name ItemStatsResources

export var name : String
export var value : float


func _init(_name: String, _value: float = 0) -> void:
	name = _name
	value = _value

