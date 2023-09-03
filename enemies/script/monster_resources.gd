extends Resource
class_name MonsterResources


export(String) var monster_name = "goblin"
export(String) var sprite_name = "goblin"

export(Vector2) var size = Vector2(1, 1)
export(Constants.EnemyType) var type : int = Constants.ProjectileType.NORMAL
export(int, 20) var max_number_in_map = 5

export(bool) var is_aggressive = true
export(int) var moving_distance: int = 10

export(Array, String) var class_list = []

#export(int, 20) var num_in_group -> do later
export(int, 20) var num_in_group: int = 1
#spawn-tiles
#boss-minion

export(int, 30) var idle: int = 1
export(int, 30) var run: int = 1
export(int, 30) var basic_melee_attack: int = 1
export(int, 30) var casting: int = 1
export(int, 30) var jump_attack: int = 1
export(int, 30) var die: int = 5

export(String) var cry_sound: String = ""
export(int) var cry_sound_amplify: int = 0.0

var experience: int = 150
var faction: int = Constants.Factions.NONE

var monster_equipment: Dictionary = {
	"weapon" : "iron_sword",
	"coat" : "leather_coat",
	"hat" : "leather_hat",
	"pants" : "leather_pants"
}

func _init(_monster_data: Dictionary) -> void:
	for _var in _monster_data:
		set(_var, Utils.convert_json_data_to_godot_var(_monster_data[_var]))
