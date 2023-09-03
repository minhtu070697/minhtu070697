extends FlyingProjectile
class_name FlyingStraightProjectile


func init(
	_name: String = "arrow", _dmg_packed: DamagePacked = null,
	_target = null, _death_position = Vector2.INF,
	_max_speed: int = 300, _init_force: int = 300, _init_direction: Vector2 = Vector2.ZERO,
	_fx_data: Dictionary = {}, _chain_child_number: int = 0, _hit_targets_list: Array = []
): #_max_speed = -1 -> use default speed of proj
	.init(_name, _dmg_packed, _target, _death_position, _max_speed, _init_force, _init_direction, _fx_data, _chain_child_number, _hit_targets_list)
	death_position = global_position + velocity * 9999


func _on_death_position():
	if get_map_position() == get_map_position(death_position) or Utils.is_outside_of_map(map_manager.list_map_positions, map_manager.size, get_map_position()):
		_on_death()
