extends EnemyState

signal cant_find_path


var target_position = null
var paths: PoolVector2Array
var force_find_path: bool = false

const MAX_TRY := 10


func _ready():
	SignalManager.connect("stuck_detect", self, "_on_stuck_detect")

func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	# if character.stuck_detect:
	# 	if !Utils.node_exists(character.stuck_body):
	# 		character.stuck_detect = false
	# 		return
			
	# 	character.stuck_avoid(character.stuck_body.global_position)
	# 	set_up_paths()
	# 	return
		
	if len(paths) == 0:
		idle()
	else:
		if len(paths) == 1:
			character.arrive_to(paths[0])
		else:
			character.seek(paths[0])
			if character.global_position.distance_to(paths[0]) <= Steering.DEFAULT_STOP_THRESHOLD:
				paths.remove(0)
				set_up_paths()

		if character.velocity == Vector2.ZERO:
			idle()


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	character.set_state_label(name)
	character.play_animation("run")
	target_position = msg.target_position
	set_up_paths()


func exit() -> void:
	target_position = null


func idle():
	state_machine.transition_to("idle")
	target_position = null
	paths = []


func set_up_paths(_target_pos: Vector2 = Vector2.INF, _core_pos: Vector2 = Vector2.INF, _tried: int = 0, _continous_find: bool = false):
	var tg_pos: Vector2 = _target_pos if _target_pos != Vector2.INF else target_position
	var core_pos: Vector2 = _core_pos if (_core_pos != Vector2.INF and not _continous_find) else tg_pos
	paths = character.get_path_to_target(tg_pos)

	if paths.empty():
		# print(character.name, " cant_find_path to: ", tg_pos)
		if force_find_path and _tried <= MAX_TRY:
			set_up_paths(find_enable_point_around(character.global_position, core_pos), core_pos, _tried + 1, _continous_find)
		else:
			# print("we tried but all fail")
			character.cant_find_path()
	else:
		target_position = tg_pos


func _on_stuck_detect(_host_name, _stuck_body):
	if _host_name != character.name or _stuck_body == null:
		return
	character.stuck_detect = true
	character.stuck_body = _stuck_body


func find_enable_point_around(_fr_pos: Vector2, _to_pos: Vector2) -> Vector2:
	var reverse_dir: Vector2 = (_fr_pos - _to_pos).normalized() * Utils.random_int(40, 120)
	reverse_dir = reverse_dir.rotated(deg2rad(Utils.random_int(-60, 60)))
	var new_pos: Vector2 = _fr_pos + reverse_dir
	return new_pos
