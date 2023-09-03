extends FighterActor
class_name Enemy

onready var body_sprite := $BodyParts/Body
onready var click_shape := $Hurtbox/CollisionShape2D

var animation_loop_count := 0

onready var moving_timer = get_node("MovingTimer")

var is_aggressive: bool = true

export(String) var monster_name: String
var monster_info: MonsterResources

var cry_sound: Resource
onready var spawn_origin: Vector2 = global_position
onready var attack_range: Area2D = get_node_or_null("AttackRange")


func _ready():
	animation_frames = {"idle": 27, "run": 27, "basic_melee_attack": 27, "die": 5, "jump_attack": 27, "casting": 10}
	body_parts = [body_sprite]
	get_info()
	load_sounds()
	set_monster_sprite()
	is_aggressive = monster_info.is_aggressive
	add_to_group("enemies")
	add_to_group(str(faction))
	update_direction(Constants.Direction.DOWN_SIDE)


func load_sounds():
	cry_sound = Utils.load_resource(Constants.MONSTER_CRY_SOUNDS_PATH %monster_info.cry_sound, "monster_sound", monster_info.cry_sound + "_cry") if monster_info.cry_sound != "" else null


func set_monster_sprite():
	set_animation_frames()


func set_animation_frames():
	for _animation in animation_frames:
		var _animation_frame = monster_info.get(_animation)
		if _animation_frame:
			animation_frames[_animation] = _animation_frame
		else:
			animation_frames[_animation] = 1


func get_info():
	if monster_name == "":
		monster_name = "goblin"
		
	if monster_info == null:
		var monster_generator = MonsterGenerator.new(monster_name)
		monster_info = monster_generator.monster_info
		faction = monster_info.faction


func die() -> void:
	yield_item(monster_name)
	play_animation("die")
	GameManager.enemy_manager.enemy_info.remove_enemy(
		name, size, get_map_position()
	)


# region: Target enemies
# override
func target_enemy(enemy, enemy_position: Vector2) -> void:
	.target_enemy(enemy, enemy_position)
	Utils.play_sound(audio_player, cry_sound, monster_info.cry_sound_amplify)


func free_attack_target() -> void:
	attack_target = null


func cant_find_path() -> void:
	var enemies: Array = get_in_range_enemies()
	if enemies.empty():
		free_attack_target()
	else:
		pick_random_target(enemies)


func get_in_range_enemies() -> Array:
	if attack_range == null:
		return []
	else:
		return attack_range.get_near_enemies()


func pick_random_target(enemies: Array) -> void:
	var picked_enemy: FighterActor = Utils.random_from_array(enemies)
	target_enemy(picked_enemy, picked_enemy.get_map_position())

