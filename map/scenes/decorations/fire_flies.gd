extends KinematicBody2D
class_name FireFlies

# Constants
const MAX_MAX_SPEED: int = 55
const MIN_MAX_SPEED: int = 3
const MAX_MOVING_WAIT_TIME: float = 0.6
const MIN_MOVING_WAIT_TIME: float = 0.2

const MAX_MAX_LIGHT_STR: float = 0.55
const MIN_MAX_LIGHT_STR: float = 0.35
const MIN_LIGHT_STR: float = 0.1
const MAX_LIGHT_SIGNAL: int = 5
const MIN_LIGHT_SIGNAL: int = 0
const MAX_SIGNAL_WAIT_TIME: int = 10
const MIN_SIGNAL_WAIT_TIME: int = 1

const MAX_LIFE_TIME: float = 9.5
const MIN_LIFE_TIME: float = 3.0

const MAX_MOVE_DISTANCE: int = 120
const MIN_MOVE_DISTANCE: int = 10

const MAX_ACCELERATE: int = 1
const MIN_ACCELERATE: int = 5

const MAX_APPEAR_TIME: float = 2.0
const MIN_APPEAR_TIME: float = 0.1

# Vars
onready var sprite: Sprite = $Sprite
onready var light: Sprite = $GreenLight
onready var tween: Tween = $Tween
onready var light_timer: Timer = $LightTimer
onready var moving_timer: Timer = $MovingTimer

# Private vars
var _max_speed: float = 50
var _max_light_str: float = 0.5
var _accelerate: float = 1.0
var _velocity: Vector2 = Vector2.ZERO
var _current_light: float = 0.2
var _life_time: float = 3
var _current_moving_pos: Vector2 = Vector2.INF


func _ready() -> void:
	light_timer.connect("timeout", self, "_on_light_timer_timeout")
	moving_timer.connect("timeout", self, "_on_moving_timer_timeout")
	visible = false
	set_up_max_light_str()
	get_tree().create_timer(rand_range(MIN_APPEAR_TIME, MAX_APPEAR_TIME)).connect("timeout", self, "live_start")


func set_up_max_light_str() -> void:
	_max_light_str = rand_range(MIN_MAX_LIGHT_STR, MAX_MAX_LIGHT_STR)
	light.modulate.a = _max_light_str


func _physics_process(_delta: float) -> void:
	_moving()


func live_start() -> void:
	_life_time = rand_range(MIN_LIFE_TIME, MAX_LIFE_TIME)
	get_tree().create_timer(_life_time).connect("timeout", self, "_on_life_timer_timeout")
	visible = true
	_on_moving_timer_timeout()
	start_light_timer()


# region: Moving
func _moving() -> void:
	if _current_moving_pos != Vector2.INF:
		_velocity += Steering.seek(_velocity, global_position, _current_moving_pos, _max_speed).normalized() * _accelerate
		_velocity = _velocity.normalized() * min(_velocity.length(), _max_speed)
		move()


func move() -> void:
	_velocity = move_and_slide(_velocity)


func get_next_moving_pos() -> Vector2:
	var moving_pos: Vector2 = Vector2(Utils.random_neg_pos() * Utils.random_int(MIN_MOVE_DISTANCE, MAX_MOVE_DISTANCE), Utils.random_neg_pos() * Utils.random_int(MIN_MOVE_DISTANCE, MAX_MOVE_DISTANCE))
	return global_position + moving_pos


func _on_moving_timer_timeout() -> void:
	_max_speed = Utils.random_int(MIN_MAX_SPEED, MAX_MAX_SPEED)
	_accelerate = rand_range(MIN_ACCELERATE, MAX_ACCELERATE)
	_current_moving_pos = get_next_moving_pos()
	get_tree().create_timer(rand_range(MIN_MOVING_WAIT_TIME, MAX_MOVING_WAIT_TIME)).connect("timeout", self, "_on_moving_timer_timeout")

# endregion


# region: Light
func _on_light_timer_timeout() -> void:
	for i in Utils.random_int(MIN_LIGHT_SIGNAL, MAX_LIGHT_SIGNAL):
		yield(flash_light_signal(), "completed")
	start_light_timer()


func start_light_timer() -> void:
	get_tree().create_timer(rand_range(MIN_SIGNAL_WAIT_TIME, MAX_SIGNAL_WAIT_TIME)).connect("timeout", self, "_on_light_timer_timeout")


func flash_light_signal() -> void:
	change_light_str(MIN_LIGHT_STR, 0.04)
	change_core_light_str(MIN_LIGHT_STR + 0.2, 0.04)
	yield(tween, "tween_all_completed")
	change_light_str(_max_light_str, 0.04)
	change_core_light_str(_max_light_str + 0.2, 0.04)
	yield(tween, "tween_all_completed")


func change_light_str(light_str: float, duration: float = 0.15) -> void:
	Utils.start_tween(tween, light, "modulate:a", light.get_modulate().a, light_str, duration)


func change_core_light_str(light_str: float, duration: float = 0.15) -> void:
	Utils.start_tween(tween, sprite, "modulate:a", sprite.get_modulate().a, light_str, duration)
	# endregion


# region: Dying
func _on_life_timer_timeout() -> void:
	dying()
	yield(tween, "tween_all_completed")
	queue_free()


func dying() -> void:
	tween.remove_all()
	remove_timers()
	change_light_str(0)
	change_core_light_str(0)
	

func remove_timers() -> void:
	light_timer.queue_free()
	light_timer = null
	
	moving_timer.queue_free()
	moving_timer = null
# endregion
