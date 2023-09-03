extends Projectile
class_name FlyingProjectile

export(bool) var is_rotate := false
export(bool) var rotate_particle := false
export(float) var init_angle := 0

onready var spells = $Spells
onready var collision_area: Area2D = get_node_or_null("Area2D")

var chain_child_number: int = 0
var hit_targets_list := []
var current_hit_targets := []
var chain_hit_again: bool = false
var projectile_scene

var previous_map_pos: Vector2 = Vector2.INF

# Proj effects
export var shake_cam_on_moving: bool = false


func init(
	_name: String = "arrow", _dmg_packed: DamagePacked = null,
	_target = null, _death_position = Vector2.INF,
	_max_speed: int = 300, _init_force: int = 300, _init_direction: Vector2 = Vector2.ZERO,
	_fx_data: Dictionary = {}, _chain_child_number: int = 0, _hit_targets_list: Array = []
): #_max_speed = -1 -> use default speed of proj
	.init(_name, _dmg_packed, _target, _death_position, _max_speed, _init_force, _init_direction, _fx_data)
	velocity = _init_direction.normalized() * init_force
	if death_position == Vector2.INF:
		death_position = global_position + velocity * 9999
	if proj_info.is_chain:
		chain_child_number = _chain_child_number
		hit_targets_list = _hit_targets_list


func _physics_process(_delta: float) -> void:
	if is_rotate:
		if rotate_particle:
			for spell_particle in spell_particles:
				spell_particle.process_material.angle = init_angle - rad2deg(velocity.angle())
		else:
			spells.set_rotation(deg2rad(init_angle) + velocity.angle())
	
	if is_moved():
		update_sort_position(false)
		previous_map_pos = get_map_position()


func spawn_projs_on_death() -> void:
	.spawn_projs_on_death()
	
	on_chain_and_spread()


func on_chain_and_spread():
	if proj_info.is_chain and proj_info.chain_num > chain_child_number:
		projectile_scene = Utils.load_resource(Constants.PROJECTILES_SCENE % proj_info.proj_name, "projectile_scene", proj_info.proj_name)
		
		var _next_targets = find_next_targets()
		if _next_targets.size() < proj_info.spread_num:
			chain_hit_again = true
			_next_targets += find_next_targets(chain_hit_again)
		
		for _next_target in _next_targets:
			if _next_target != null:
				spawn_chain_projectile(_next_target)


func spawn_chain_projectile(_target = null):
	var _projectile_scene = projectile_scene
	var _projectile = _projectile_scene.instance()
	_projectile.global_position = global_position
	map_manager.ysort.add_child(_projectile)
	var _direction: Vector2 = _target.global_position - global_position
	_projectile.init(proj_info.proj_name, Utils.create_dmg_packed(proj_info.proj_on_death_dmg_modify, original_dmg_packed), _target, Vector2.INF, Constants.PROJECTILE_DEFAULT, Constants.PROJECTILE_DEFAULT, _direction, fx, chain_child_number + 1, hit_targets_list + current_hit_targets)


func find_next_targets(_is_hit_again: bool = false) -> Array:
	var _next_targets: Array = []
	for enemy in get_tree().get_nodes_in_group("fighter"):
		# if is_hit(enemy) and enemy != dmg_packed.atk_owner and Utils.has_stats_manager(enemy):
		if String(enemy.faction) != String(dmg_packed.faction) and (enemy in hit_targets_list) == _is_hit_again and !(enemy in current_hit_targets):
			if enemy_in_range(enemy, Vector2(proj_info.chain_range, proj_info.chain_range)):
				_next_targets.append(enemy)
				if _next_targets.size() >= proj_info.spread_num:
					return _next_targets
	return _next_targets


func post_hit_enemy(tg) -> void:
	.post_hit_enemy(tg)

	if proj_info.is_chain:
		current_hit_targets.append(tg)


func get_hit_targets() -> Array:
	var hit_enemies: Array = []
	for enemy in get_tree().get_nodes_in_group("fighter"):
		# if is_hit(enemy) and enemy != dmg_packed.atk_owner and Utils.has_stats_manager(enemy):
		if String(enemy.faction) != String(dmg_packed.faction) and (enemy in hit_targets_list) == chain_hit_again:
			if enemy_in_range(enemy, Vector2(area_of_dmg_x, area_of_dmg_y)):
				hit_enemies.append(enemy)
	return hit_enemies


# region: ysort
func is_moved():
	return get_map_position() != previous_map_pos


func update_sort_position(_wait_a_bit: bool = true) -> void:
	if map_manager == null:
		return
	
	map_manager.ysort.moving_col_sort(collision_area, self, _wait_a_bit)

# endregion
