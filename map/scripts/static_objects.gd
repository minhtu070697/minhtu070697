extends Node2D
class_name StaticObjects

onready var shadow_sprite: Sprite = get_node_or_null("Shadow")
var shadow_sprite_name: String
onready var sprite: Sprite = $Sprite
onready var tween := get_node_or_null("Tween")

var sprite_names: Dictionary = {}

var texture_file
var sprite_name: String
var origin: Vector2 = Vector2.ZERO setget set_origin
var gl_origin: Vector2 = Vector2.ZERO setget set_gl_origin
var most_l_point: Vector2
var most_r_point: Vector2
var height_point: int = 0

var size: Vector2 = Vector2.ONE
var is_reload: bool

onready var collision_area: Area2D = get_node_or_null("Sprite/Area2D")
onready var collision = get_node_or_null("Sprite/Area2D/CollisionPolygon2D")
var _sorting: bool = false

var created: bool = false


#wind react vars
onready var wind_react_timer: Timer = get_node_or_null("WindReactTimer")
var react_with_environment: bool = false setget set_react_with_environment

# random event vars
var event_timer: Timer = null
var active_random_event: bool = false setget set_active_random_event


#region: random event
# obj can random active events define by overriding activate_random_event() function
# 1: set active_random_event -> true with set_active_random_event() function
func enable_random_event() -> void:
	create_event_timer()
	connect_event_timer()
	active_event_timer()


func disable_random_event() -> void:
	free_event_timer()
	disconnect_event_timer()


func create_event_timer() -> void:
	if not event_timer:
		event_timer = Timer.new()
		add_child(event_timer)
		event_timer.set_one_shot(true)


func free_event_timer() -> void:
	if Utils.node_exists(event_timer):
		event_timer.queue_free()
		event_timer = null


func connect_event_timer() -> void:
	if not event_timer.is_connected("timeout", self, "_on_event_timer_timeout"):
		event_timer.connect("timeout", self, "_on_event_timer_timeout")


func disconnect_event_timer() -> void:
	if event_timer.is_connected("timeout", self, "_on_event_timer_timeout"):
		event_timer.disconnect("timeout", self, "_on_event_timer_timeout")


func set_active_random_event(_new_value: bool) -> void:
	if active_random_event == _new_value:
		return
	
	active_random_event = _new_value
	if active_random_event:
		enable_random_event()
	else:
		disable_random_event()


func _on_event_timer_timeout() -> void:
	var next_event_time: float = abs(activate_random_event())
	active_event_timer(next_event_time)


func active_event_timer(_time: float = rand_range(5.0, 15.0)) -> void:
	Utils.activate_timer(event_timer, _time)


func wait_to_next_daytime_period() -> float:
	#for test only
	return rand_range(5.0, 10.0)
	# return GameManager.daytime_manager.get_time_duration_to_next_daytime() if GameManager.daytime_manager else 50.0


# random event function
# abstract
# active random event then return time cooldown
func activate_random_event() -> float:
	return 0.0

#endregion


#region: wind react region
# to make this obj react with environment. Just do 1 step
# 1: set react_with_environment to true by func set_react_with_environment
# Done! You can customize how this obj react with environment events by override
# these #react functions
func start_react_with_environment() -> void:
	create_wind_react_timer()
	connect_wind_react_timer()
	connect_wind_signal()
	

func stop_react_with_environment() -> void:
	free_wind_react_timer()
	disconnect_wind_react_timer()
	disconnect_wind_signal()


func create_wind_react_timer() -> void:
	if not wind_react_timer:
		wind_react_timer = Timer.new()
		add_child(wind_react_timer)
		wind_react_timer.set_one_shot(true)


func free_wind_react_timer() -> void:
	if Utils.node_exists(wind_react_timer):
		wind_react_timer.queue_free()
		wind_react_timer = null


func connect_wind_react_timer() -> void:
	if not wind_react_timer.is_connected("timeout", self, "_on_wind_react_timer_timeout"):
		wind_react_timer.connect("timeout", self, "_on_wind_react_timer_timeout")


func disconnect_wind_react_timer() -> void:
	if wind_react_timer.is_connected("timeout", self, "_on_wind_react_timer_timeout"):
		wind_react_timer.disconnect("timeout", self, "_on_wind_react_timer_timeout")


func connect_wind_signal() -> void:
	if not SignalManager.is_connected("wind_blow", self, "_on_wind_blow"):
		SignalManager.connect("wind_blow", self, "_on_wind_blow")


func disconnect_wind_signal() -> void:
	if SignalManager.is_connected("wind_blow", self, "_on_wind_blow"):
		SignalManager.disconnect("wind_blow", self, "_on_wind_blow")


func set_react_with_environment(_new_value: bool) -> void:
	if react_with_environment == _new_value:
		return
	
	react_with_environment = _new_value
	if react_with_environment:
		start_react_with_environment()
	else:
		stop_react_with_environment()


func _on_wind_blow(_wind: Dictionary) -> void:
	var _map_position: Vector2 = GameManager.map_manager_utils.global_to_map_position(global_position)
	if GameManager.environment_manager.environment_event_manager.affect_by_wind(_map_position, _wind):
		var _wind_affect_time: float = get_wind_hit_time(_map_position, _wind)
		active_wind_react_timer(_wind_affect_time)


func get_wind_hit_time(_map_position: Vector2, _wind: Dictionary) -> float:
	return GameManager.environment_manager.environment_event_manager.calculate_wind_affect_time(_map_position, _wind)


func active_wind_react_timer(_time: float = rand_range(1, 3)) -> void:
	Utils.activate_timer(wind_react_timer, _time)


func _on_wind_react_timer_timeout() -> void:
	wind_react()


# react function
func wind_react() -> void:
	pass

#endregion


func set_origin(_new_value: Vector2) -> void:
	origin = _new_value
	gl_origin = GameManager.map_manager_utils.map_to_global_position(origin)
	most_l_point = get_obj_most_left_point()
	most_r_point = get_obj_most_right_point()


#return global position
func get_obj_most_left_point() -> Vector2:
	return GameManager.map_manager_utils.map_to_global_position(origin + Vector2(size.x - 1, 0))
	
	
#return global position
func get_obj_most_right_point() -> Vector2:
	return GameManager.map_manager_utils.map_to_global_position(origin + Vector2(0, size.y - 1))


func set_gl_origin(_new_value: Vector2) -> void:
	gl_origin = GameManager.map_manager_utils.map_to_global_position(origin)


func set_obj_main_collision(_collision) -> void:
	if not (_collision is CollisionPolygon2D or _collision is CollisionShape2D):
		return
	
	collision = _collision
	collision_area = _collision.get_parent()

	if not collision_area is Area2D:
		collision = null
		collision_area = null

#endregion

#region: Nogias YSort
func update_sort_position(_begin: bool = true) -> void:
	if _sorting or GameManager.map_manager == null:
		return
	_sorting = true
	if _begin:
		yield(GameManager.map_manager.ysort.static_unbalance_col_sort(collision_area, self, _begin), "completed")
	else:
		GameManager.map_manager.ysort.static_unbalance_col_sort(collision_area, self, _begin)
	_sorting = false

#endregion


#call when this obj's generated, built, or loaded
func created(_build: bool = true) -> void:
	created = true
	if _build:
		built()
	else:
		loaded()


#abstract
func built() -> void:
	pass


#abstract
func loaded() -> void:
	pass
