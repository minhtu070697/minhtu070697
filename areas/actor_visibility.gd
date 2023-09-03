extends Node2D
class_name ActorVisibility

const LOOP_FRAGMENTS: int = 40

var seeing_angle: int = 120
var seeing_distance: int = 400 setget set_seeing_distance
export(int) var seeing_direction: int = 0
var enable: bool = true setget set_enable

onready var ray_cast: RayCast2D = $RayCast2D
onready var ray_cast_line: Line2D = $Line2D

var current_frag: int = 0
onready var host: Node2D = get_parent()

var start: bool = false


func _ready() -> void:
	if not host_meet_reqs():
		disable_this()
		return
	else:
		start = true
	
	set_cast_ray_visible()
	update_seeing_distance()
	set_enable(false)


func disable_this() -> void:
	set_enable(false)
	ray_cast.queue_free()
	ray_cast_line.queue_free()
	ray_cast = null
	ray_cast_line = null


func host_meet_reqs() -> bool:
	return Utils.node_exists(host) and host.has_method("visibility_function")


func _physics_process(_delta: float) -> void:
	if not start:
		return
	
	set_rotation_degrees(seeing_direction + ray_swing())
	inscrease_current_frag()
	host.visibility_function()


func ray_swing() -> float:
	return -(seeing_angle / 2) + (float(seeing_angle) / LOOP_FRAGMENTS) * (current_frag % LOOP_FRAGMENTS)


func set_seeing_distance(_new_value: int) -> void:
	seeing_distance = max(0, _new_value)
	update_seeing_distance()


func update_seeing_distance() -> void:
	set_ray_cast_distance(seeing_distance)
	set_line_length(seeing_distance)


func set_ray_cast_distance(_distance: int) -> void:
	if not ray_cast or not ray_cast.enabled:
		return
	ray_cast.cast_to = Vector2(seeing_distance, 0)


func set_line_length(_l: int) -> void:
	if not ray_cast_line or not ray_cast_line.visible:
		return
	ray_cast_line.points[1].x = _l


func inscrease_current_frag() -> void:
	current_frag = Utils.random_int(0, LOOP_FRAGMENTS)


func set_cast_ray_visible(_visible: bool = true) -> void:
	if not ray_cast_line:
		return
	
	ray_cast_line.visible = _visible and GameManager.show_cast_ray


func set_ray_cast_enable(_enable: bool = true) -> void:
	if not ray_cast:
		return
	
	ray_cast.enabled = _enable


func set_enable(_new_value: bool) -> void:
	enable = _new_value
	enable_visibility(enable)


func enable_visibility(_enable: bool = true) -> void:
	set_ray_cast_enable(_enable)
	set_cast_ray_visible(_enable)
	set_physics_process(_enable)
