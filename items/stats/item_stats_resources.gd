extends Resource
class_name ItemOldResources

export var name : String
export var rarity : int 
export var chance : float 
export var is_primary_stat : bool 
export var min_value : float 
export var max_value : float 
export var is_use_min_max_value : bool
export var level_multiplier : float
export(int, "all", "weapon", "armor") var stat_class : int
export var user_class : String
export var physical_magical_linked : bool = false
export var value : float


func _init(_item_stat_data: Dictionary) -> void:
	for _var in _item_stat_data:
		set(_var, Utils.convert_json_data_to_godot_var(_item_stat_data[_var]))
