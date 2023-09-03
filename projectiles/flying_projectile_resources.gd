extends Resource
class_name ProjectileResources


export(String) var proj_name: String = "flying_axe"

export(String, FILE) var sprite = "res://characters/textures/basic_action/axe-01-basic_action.png"
export(float) var life_time: float = 180.0

export(Vector2) var size = Vector2(1, 1)
export(bool) var is_chase: bool = false
export(Constants.ProjectileType) var type : int = Constants.ProjectileType.NORMAL

export(float) var dmg_frequency: float = 1.0

export(String) var projectile_on_death: String = ""
export var num_of_proj_on_death = 0

export(float, -5.0, 50.0, 0.05) var dmg_modify: float = 1.0
export(float, -5.0, 50.0, 0.05) var proj_on_death_dmg_modify: float = 1.0

export(int) var default_max_speed: int = 300
export(int) var default_init_force: int = 300
export(int) var default_accelerate: int = Constants.DEFAULT_CHARACTER_ACCELERATE
export(bool) var is_missile: bool = true #if true, projectile will act like a chasing missile.

export(bool) var is_chain: bool = false #if true, projectile will hit multiple target.
export(int) var chain_num: int = 0
export(int) var chain_range: int = 0
export(int) var spread_num: int = 1

export(String) var init_sound: String = ""
export(float) var init_sound_amplify: float = 0.0
export(String) var flying_sound: String = ""
export(float) var flying_sound_amplify: float = 0.0
export(String) var death_sound: String = ""
export(float) var death_sound_amplify: float = 0.0


func _init(_projectile_data: Dictionary) -> void:
	for _var in _projectile_data:
		set(_var, Utils.convert_json_data_to_godot_var(_projectile_data[_var]))
