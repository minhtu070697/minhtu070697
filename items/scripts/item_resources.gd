extends Resource
class_name ItemResources

# Info
var item_id : int = 1
var item_name : String = "Bare Hands"
var item_desc: String = "This is an item"
var item_class : int = 0
var weapon_class : int = 0
var armor_class : int = 0
var consumable_class : int = 0
var item_rarity : int = 0 # 0 for all rarity item, 1->5 for only specific rarity

# Weapon info
var dmg_percent : float = 1.0 # Normal item should have dmg_percent * atk_speed ~ 1.0
var physical_percent : float = 0.5 # 0 for a full random p - m item, 0.01 -> 0.5 for a magical item, 0.51 -> 1.0 for a physical item
var max_dmg_diff : float = 1.0 # 0 -> item with min_dmg = max_dmg, 1.0 -> item with dmg 0 -> 2x
var atk_range : int = 1
var atk_speed : float = 1.0
var hit_range: int = 0
var hit_arc: int = 0
var max_combo: int = 1
var attacks: Dictionary = {}
var combos: Dictionary = {}
var durability: int = 0
var atk_animation: String = "basic_melee_attack"

var item_sprite: String = ""

# Buff, consume effects
var buffs: String = ""
var consume_effects: String = ""

# Planting
var young_tree_name: String = ""


func _init(_item_data: Dictionary) -> void:
	for _var in _item_data:
		set(_var, Utils.convert_json_data_to_godot_var(_item_data[_var]))
