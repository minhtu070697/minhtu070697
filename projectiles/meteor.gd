extends Projectile
class_name Meteor


func init(
	_name: String = "arrow", _dmg_packed: DamagePacked = null,
	_target = null, _death_position = Vector2.INF,
	_max_speed: int = 300, _init_force: int = 300, _init_direction: Vector2 = Vector2.ZERO,
	_fx_data: Dictionary = {}
): #_max_speed = -1 -> use default speed of proj
	.init(_name, _dmg_packed, _target, _death_position, _max_speed, _init_force, _init_direction, _fx_data)
	global_position = death_position + Vector2(0,-500)
	velocity = (death_position - global_position).normalized() * init_force
