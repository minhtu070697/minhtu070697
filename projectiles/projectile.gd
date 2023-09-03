extends KinematicBody2D
class_name Projectile

# Constants
enum Phase {INIT, FLYING, HIT, DEATH}


onready var sprite : Sprite = $Sprite
onready var life_timer : Timer = $LifeTimer
onready var base_animation_player : AnimationPlayer = $BaseAnimationPlayer
onready var map_manager = GameManager.map_manager
onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var spell_particles: Array = $Spells.get_children()
onready var explosion_particles: Array = $Explosions.get_children()

export var use_sprite_sheet: bool = false

var proj_name: String = ""
var proj_info: ProjectileResources

var map_info: MapInfo

export var max_speed: int
var death_position: Vector2

var velocity: Vector2 = Vector2.ZERO
var init_force: int = 0
var current_target
var accelerate: int = Constants.DEFAULT_CHARACTER_ACCELERATE

var current_direction
var animation_player: AnimationPlayer

var original_dmg_packed : DamagePacked = null
var dmg_packed : DamagePacked = null

var area_of_dmg_x: int
var area_of_dmg_y: int

var enemy_hit_list: Dictionary = {}

var animation_frames: Dictionary = {"flying": 7, "die": 5}

var is_death: bool = false

var init_sound: Resource
var flying_sound: Resource
var death_sound: Resource

var fx: Dictionary = {}


# Proj effects
export var has_cyclone_fx_on: Dictionary = {
	Phase.FLYING: false,
}
export var cyclone_fx_data: Dictionary = {
	"strength": 6000,
	"cyclone_r": 180,
	"cyclone_left": true,
}

export var shake_cam_on: Dictionary = {
	Phase.INIT: false,
	Phase.FLYING: false,
	Phase.HIT: false,
	Phase.DEATH: false,
}
export var shake_cam_data: Dictionary = {
	"duration": 0.2,
	"freq": 15.0,
	"amp": 16.0,
}


func _ready() -> void:
	add_to_group("projectiles")
	map_info = map_manager.map_info
	life_timer.connect("timeout", self, "_on_LifeTimer_timeout")
	set_up_animation_player()


func set_up_animation_player() -> void:
	if use_sprite_sheet:
		animation_player = base_animation_player.duplicate()
		add_child(animation_player)
	else:
		base_animation_player.queue_free()


func init(
	_name: String = "arrow", _dmg_packed: DamagePacked = null,
	_target = null, _death_position = Vector2.INF,
	_max_speed: int = 300, _init_force: int = 300, _init_direction: Vector2 = Vector2.ZERO,
	_fx_data: Dictionary = {}
): # _max_speed = -1 -> use default speed of proj
	# set projectile info + stats
	proj_name = _name
	original_dmg_packed = _dmg_packed
	current_target = _target
	death_position = _death_position

	# set up proj effects
	set_up_fx(_fx_data)
	
	if Utils.node_exists(current_target):
		death_position = current_target.global_position
	
	var generated_info: FlyingProjectileInfo = FlyingProjectileInfo.new(self)
	proj_info = generated_info.proj_info

	init_sound = Utils.load_resource(Constants.PROJECTILE_INIT_SOUNDS_PATH % proj_info.init_sound, "proj_sound", proj_info.init_sound + "_init") if proj_info.init_sound != "" else null
	flying_sound = Utils.load_resource(Constants.PROJECTILE_FLYING_SOUNDS_PATH % proj_info.flying_sound, "proj_sound", proj_info.flying_sound + "_flying") if proj_info.flying_sound != "" else null
	death_sound = Utils.load_resource(Constants.PROJECTILE_DEATH_SOUNDS_PATH % proj_info.death_sound, "proj_sound", proj_info.death_sound + "_death") if proj_info.death_sound != "" else null

	if _max_speed == Constants.PROJECTILE_DEFAULT:
		max_speed = proj_info.default_max_speed
	else:
		max_speed = int(abs(_max_speed))
	
	if _init_force == Constants.PROJECTILE_DEFAULT:
		init_force = proj_info.default_init_force
	else:
		init_force = _init_force
	
	dmg_packed = Utils.create_dmg_packed(proj_info.dmg_modify, original_dmg_packed)
	area_of_dmg_x = int(proj_info.size.x / 2)
	area_of_dmg_y = int(proj_info.size.y / 2)

	accelerate = proj_info.default_accelerate
	
	# start projectile life_time
	life_timer.wait_time = proj_info.life_time
	life_timer.start()
	play_init_sound()

	if use_sprite_sheet:
		animation_player.play("Flying")

	for _spell_particle in spell_particles:
		_spell_particle.emitting = true
	
	active_init_fxs()


func _physics_process(_delta: float) -> void:
	play_flying_sound()
	
	_on_death_position()
	_chasing()
	if proj_info.is_missile:
		_moving_missile()
	else:
		_moving()

	if use_sprite_sheet:
		current_direction = Utils.angle_to_direction(velocity.angle())
		update_direction(current_direction)
	
	if proj_info.type != Constants.ProjectileType.NOT_HIT:
		_on_hit()
	
	activate_flying_fxs()


# region: Effects
func set_up_fx(fx_data: Dictionary) -> void:
	fx = fx_data.duplicate()
	for phase_fxs in fx:
		set_up_cyclone_fx_data(fx[phase_fxs])
		set_up_cam_shake_fx_data(fx[phase_fxs])


func can_active_fx(phase: int, fx_active_data: Dictionary = {}) -> bool:
	return fx_active_data.has(phase) and fx_active_data[phase]


func active_init_fxs(affect_tgs: Array = []) -> void:
	if fx.has("appear"):
		active_proj_fxs(Phase.INIT, fx.appear, affect_tgs)


func activate_flying_fxs(affect_tgs: Array = []) -> void:
	if fx.has("flying"):
		active_proj_fxs(Phase.FLYING, fx.flying, affect_tgs)


func activate_death_fxs(affect_tgs: Array = []) -> void:
	if fx.has("death"):
		active_proj_fxs(Phase.DEATH, fx.death, affect_tgs)


func activate_hit_fxs(affect_tgs: Array = []) -> void:
	if fx.has("hit"):
		active_proj_fxs(Phase.HIT, fx.hit, affect_tgs)


func active_proj_fxs(phase: int, fx_data: Dictionary, affect_tgs: Array = []) -> void:
	if fx_data.has("cyclone") or can_active_fx(phase, has_cyclone_fx_on):
		cyclone_fx(fx_data.cyclone, affect_tgs)
	
	if fx_data.has("shake_camera") or can_active_fx(phase, shake_cam_on):
		shake_camera(fx_data.shake_camera, global_position)
	
	if fx_data.has("knockback") and phase == Phase.HIT:
		knockback_fx(fx_data, affect_tgs)


# region: Knockback
func knockback_fx(fx_data: Dictionary, affect_tgs: Array) -> void:
	for enemy in affect_tgs:
		if String(enemy.faction) != String(dmg_packed.faction):
			enemy.take_combat_effects(fx_data, global_position, velocity)

# endregion


# region: Cyclone effect
func cyclone_fx(cyclone_data: Dictionary = {}, affect_tgs: Array = []) -> void:
	var tgs: Array = []
	if affect_tgs.empty():
		tgs = get_tree().get_nodes_in_group("fighter")
	else:
		tgs = affect_tgs
	
	for enemy in tgs:
		if String(enemy.faction) != String(dmg_packed.faction):
			enemy.take_combat_effects(cyclone_data, global_position)


func set_up_cyclone_fx_data(fx_data: Dictionary) -> void:
	if not fx_data.has("cyclone"):
		return
	
	for key in cyclone_fx_data:
		if not fx_data.cyclone.has(key):
			fx_data.cyclone[key] = cyclone_fx_data[key]

# endregion


# region: Camera shake 
func set_up_cam_shake_fx_data(fx_data: Dictionary) -> void:
	if not fx_data.has("shake_camera"):
		return
	
	for key in shake_cam_data:
		if not fx_data.shake_camera.has(key):
			fx_data.shake_camera[key] = shake_cam_data[key]


func shake_camera(fx_data: Dictionary, obj_pos: Vector2 = Vector2.INF) -> void:
	SignalManager.emit_signal("camera_shake", fx_data.duration, fx_data.freq, fx_data.amp, obj_pos)

# endregion
# endregion


# move at constant speed, always toward target position
func _moving():
	if death_position != Vector2.INF:
		velocity += Steering.seek(velocity, global_position, death_position, max_speed)
		move()


# move similar to heat-seeking missile
func _moving_missile():
	if death_position != Vector2.INF:
		velocity += Steering.seek(velocity, global_position, death_position, max_speed).normalized() * Constants.DEFAULT_CHARACTER_ACCELERATE
		velocity = velocity.normalized() * min(velocity.length(), max_speed)
		move()


func _chasing():
	if proj_info.is_chase and Utils.node_exists(current_target):
		death_position = current_target.global_position


# when this proj reaches it's death position
func _on_death_position():
	if get_map_position() == get_map_position(death_position):
		_on_death()


func _on_death():
	if is_death:
		return
	
	is_death = true
	play_death_sound()	
	set_physics_process(false)

	# active on death effects
	activate_death_fxs()

	play_death_animation_and_particles()
	# if has death_proj -> spawn them and death
	spawn_projs_on_death()
	# death: play animation "death"
	
	# release projectile node (after done, refactor, create queue of projectiles, use when need, disable after death)
	yield(wait_and_free(), "completed")
	queue_free()


func spawn_projs_on_death() -> void:
	spawn_projectiles(proj_info.projectile_on_death, proj_info.num_of_proj_on_death)


func play_death_animation_and_particles():
	for _spell_particle in spell_particles:
		_spell_particle.emitting = false
	
	for _explosion_particle in explosion_particles:
		_explosion_particle.emitting = true


#wait animation, sound all finish
func wait_and_free():
	var lifetime: float = explosion_particles[0].lifetime if explosion_particles.size() > 0 else 0.5
	var speed_scale: float = explosion_particles[0].speed_scale if explosion_particles.size() > 0 else 1
	var time: float = (lifetime * 2) / speed_scale
	
	yield(Utils.start_coroutine(time), "completed")
	if audio_player.stream != flying_sound and audio_player.playing:
		yield(audio_player, "finished")


func _on_hit():
	var hit_targets: Array = get_hit_targets()
	
	if hit_targets != []:
		activate_hit_fxs(hit_targets)

		for hit_target in hit_targets:
			# if enemy's already got hit by this proj, pass until timer reach 0
			if enemy_hit_list.has(hit_target.name) and enemy_hit_list[hit_target.name].time_left > 0.0:
				continue
			
			hit_enemy(hit_target)
			post_hit_enemy(hit_target)
			
			
		if proj_info.type == Constants.ProjectileType.NORMAL:
			_on_death()


func hit_enemy(tg) -> void:
	tg.stats_manager.dmg_receive_manager.receive_dmg_packed(dmg_packed)


func post_hit_enemy(tg) -> void:
	# set timer on enemy, so this proj can't hit the enemy for x.x seconds
	set_enemy_timer(tg.name)


# create a timer for hit enemy, it won't be hit again until timer timeout
func set_enemy_timer(_enemy_name: String):
	# if enemy's never get hit by this proj before
	if !enemy_hit_list.has(_enemy_name):
		enemy_hit_list[_enemy_name] = Timer.new()
		enemy_hit_list[_enemy_name].one_shot = true
		add_child(enemy_hit_list[_enemy_name])
	
	enemy_hit_list[_enemy_name].set_wait_time(proj_info.dmg_frequency)
	enemy_hit_list[_enemy_name].start()


#find all enemies hit by this proj
func get_hit_targets() -> Array:
	var hit_enemies: Array = []
	for enemy in get_tree().get_nodes_in_group("fighter"):
		# if is_hit(enemy) and enemy != dmg_packed.atk_owner and Utils.has_stats_manager(enemy):
		if String(enemy.faction) != String(dmg_packed.faction):
			if enemy_in_range(enemy, Vector2(area_of_dmg_x, area_of_dmg_y)):
				hit_enemies.append(enemy)
	return hit_enemies


func enemy_in_range(_enemy, _range: Vector2) -> bool:
	# get distance from this proj to enemy
	var distance: Vector2 = get_map_position() - _enemy.get_map_position()
	# return if enemy stands in the area of dmg
	return _range.x >= abs(distance.x) and _range.y >= abs(distance.y)


func get_map_position(_position = position) -> Vector2: #no arg for self position
	return map_manager.map_navigator.world_to_point(_position)


func _on_LifeTimer_timeout():
	_on_death()


func move():
	if velocity != Vector2.ZERO:
		flip_h_sprite()
	velocity = move_and_slide(velocity)


func flip_h_sprite():
	sprite.flip_h = velocity.x < 0


func spawn_projectiles(_proj_name: String = "flying_axe", _proj_number: int = 0, _target = null):
	if _proj_number != 0 and _proj_name != "":
		for i in _proj_number:
			spawn_projectile(_proj_name, _proj_number, _target)
	

func spawn_projectile(_proj_name: String = "flying_axe", _proj_number: int = 0, _target = null):
	var _projectile_scene = Utils.load_resource(Constants.PROJECTILES_SCENE % _proj_name, "projectile_scene", _proj_name)
	var _projectile = _projectile_scene.instance()
	_projectile.global_position = global_position
	map_manager.ysort.add_child(_projectile)
	_projectile.init(_proj_name, Utils.create_dmg_packed(proj_info.proj_on_death_dmg_modify, original_dmg_packed), _target, Vector2.INF, Constants.PROJECTILE_DEFAULT, Constants.PROJECTILE_DEFAULT, Vector2.ZERO, fx)


func update_direction(direction: int):
	if direction == current_direction:
		return

	current_direction = direction
	for animation_name in animation_player.get_animation_list():
		if animation_name == "RESET":
			continue
		var frame_count = animation_frames[animation_name]
		var animation: Animation = animation_player.get_animation(animation_name)
		
		var track_index = animation.find_track("Sprite:frame")
		if track_index > -1:
			for i in range(frame_count):
				animation.track_set_key_value(
					track_index, i, frame_count * direction + i
					)


func play_init_sound():
	Utils.play_sound(audio_player, init_sound, proj_info.init_sound_amplify)


func play_flying_sound():
	if audio_player.playing:
		return
	
	Utils.play_sound(audio_player, flying_sound, proj_info.flying_sound_amplify)


func play_death_sound():
	Utils.play_sound(audio_player, death_sound, proj_info.death_sound_amplify)

