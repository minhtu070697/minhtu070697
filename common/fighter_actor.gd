# Abstract class
extends Actor
class_name FighterActor

# Signals
signal enemy_targeted(enemy, enemy_position)
signal atk_target_freed


# Constants
const AtkAnimFinishedSignal: Dictionary = {
	"basic_melee_attack": "attack_finished",
	"heavy_attack": "attack_finished",
	"basic_attack": "attack_finished",
	"360_attack": "attack_finished",
	"heavy_smash": "attack_finished",
}


# Vars
export(int, 60) var lvl: int = 1

var attack_target = null
var attack_position: Vector2 = Vector2.ZERO

onready var weapon_label: Label = $WeaponLabel
onready var stats_manager = get_node("StatsManager")
onready var target_detect_area: Area2D = $AttackRange
onready var target_detect_collision: CollisionShape2D = $AttackRange/CollisionShape2D

var skill_activating: Skill = null


func _ready():
	add_to_group("fighter")
	SignalManager.connect("health_changed", self, "_on_health_changed")


func _on_animation_finished(anim_name: String):
	SignalManager.emit_signal(_get_anim_finished_signal(anim_name), get_name())
	Utils.on_resource_animation_finished(self, anim_name)


func _get_anim_finished_signal(anim_name: String) -> String:
	if AtkAnimFinishedSignal.has(anim_name):
		return AtkAnimFinishedSignal[anim_name]
	return anim_name + "_finished"


func update_direction(direction: int):
	if stats_manager and stats_manager.stats and stats_manager.stats.total_speed == 0:
		return
	.update_direction(direction)


func seek(target_position: Vector2):
	velocity += Steering.seek(velocity, global_position, target_position, stats_manager.stats.walk_speed)


func arrive_to(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.arrive_to(velocity, global_position, target_position, stats_manager.stats.walk_speed)


func stuck_avoid(target_position: Vector2):
	if global_position.distance_to(target_position) < 100 and !Utils.is_at_edge_of_map(map_manager.list_map_positions, map_manager.size, get_map_position()):
		velocity += Steering.stuck_avoid(velocity, global_position, target_position, stats_manager.stats.walk_speed)


func flee(target_position: Vector2):
	if global_position.distance_to(target_position) < 50:
		velocity += Steering.flee(velocity, global_position, target_position, stats_manager.stats.walk_speed)


func pursue(target_position: Vector2, target_velocity: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.pursue(velocity, global_position, target_position, target_velocity, stats_manager.stats.walk_speed)


func set_weapon_label(text):
	weapon_label.text = str(text)


func get_attack_target_distance() -> float:
	if Utils.node_exists(attack_target):
		var distance = get_map_position() - attack_target.get_map_position()
		return max(abs(distance.x), abs(distance.y))
	return 1000.0


func update_attack_position():
	if attack_target != null:
		if attack_position != attack_target.get_map_position():
			attack_position = attack_target.get_map_position()


func _on_health_changed(_name: String, _atk_owner_name: String):
	if _name != name  or _atk_owner_name == "" or not effect_tween.is_inside_tree() or effect_tween.is_active():
		return
	
	Utils.start_tween(effect_tween, $BodyParts, "modulate", stats_manager.status_color , Constants.HIT_EFFECT_COLOR, Constants.HIT_EFFECT_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Utils.start_tween(effect_tween, $BodyParts, "modulate", Constants.HIT_EFFECT_COLOR, stats_manager.status_color, Constants.HIT_EFFECT_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


# region: Attack target
func target_enemy(enemy, enemy_position: Vector2) -> void:
	attack_target = enemy
	attack_position = enemy_position
	emit_signal("enemy_targeted", enemy, enemy_position)


func free_attack_target() -> void:
	attack_target = null
	attack_position = Vector2.ZERO
	emit_signal("atk_target_freed")


func set_detect_range_radius(r: float) -> void:
	target_detect_collision.shape.radius = r


func get_attack_targets(r: float = 0) -> Array:
	if r > 0:
		set_detect_range_radius(r)

	return target_detect_area.get_overlapping_bodies()


func get_nearest_enemy(r: float = 40) -> FighterActor:
	var sur_targets: Array = get_attack_targets(r)
	if sur_targets.size() == 0:
		return null
	var nearest_distance: float = Constants.A_VERY_LARGE_NUMBER
	var selected_target = null
	
	for tg in sur_targets:
		if not Utils.target_is_enemy(self, tg):
			continue
		
		var dt: float = global_position.distance_to(tg.global_position)
		if dt < nearest_distance:
			selected_target = tg
			nearest_distance = dt
	
	return selected_target


func target_nearest_enemy(r: float = 40) -> bool:
	var selected_target: FighterActor = get_nearest_enemy(r)
	
	if selected_target:
		target_enemy(selected_target, selected_target.get_map_position())
		return true
	else:
		return false


func check_hit_targets(arc: int, r: float) -> Array:
	var sur_targets: Array = get_attack_targets(r)
	var hit_targets: Array = []
	for tg in sur_targets:
		if not Utils.target_is_enemy(self, tg):
			continue
		if Utils.target_in_area(Constants.DirectionDegree[current_direction], facing_left(), global_position, tg.global_position, arc, r):
			hit_targets.append(tg)
	
	return hit_targets


func get_equipment_manager():
	if not stats_manager or not stats_manager.equipment_manager:
		return null
	return stats_manager.equipment_manager

# endregion


# region: Take combat effects
# fx_pos: Global position, fx_vel: Velocity affects the effect result
func take_combat_effects(fx_info: Dictionary, fx_pos: Vector2, fx_vel: Vector2 = Vector2.ZERO) -> void:
	if fx_info.has("knockback"):
		take_ext_force(fx_info.knockback, fx_pos.direction_to(global_position), fx_vel)
	if fx_info.has_all(["strength", "cyclone_r", "cyclone_left"]):
		hit_by_cyclone(fx_pos, fx_info.strength, fx_info.cyclone_r, fx_info.cyclone_left)


func hit_by_cyclone(source_pos: Vector2, strength: int, r: int, left: bool = true) -> void:
	var distance: float = source_pos.distance_to(global_position)
	if source_pos.distance_to(global_position) > r:
		return
	
	var cyclone_str: float = (1 - pow((distance/r), 1.2))
	var force_direction: Vector2 = -source_pos.direction_to(global_position) * cyclone_str
	force_direction += force_direction.rotated(deg2rad(90)) * 1.1 * (1 if left else -1)
	take_ext_force(strength, Utils.convert_to_iso_vector(force_direction))

# endregion
