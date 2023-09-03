extends Node
class_name EnvironmentEventManager

enum EnvironmentState { NORMAL, RAIN }

const EVENT_RAND_EXP = 0.2
const WIND_LAST = 1
const WIND_MIN_SPEED: int = 10
const WIND_MAX_SPEED: int = 20
const WIND_MIN_SIZE: int = 5
const WIND_MAX_SIZE: int = 30
const SMALL_WIND_MIN_SIZE: int = 3
const SMALL_WIND_MAX_SIZE: int = 5
const WIND_DIRECTION_FRAGMENT: int = 10

const EventPeriod: Dictionary = {EnvironmentState.NORMAL: 2.5, EnvironmentState.RAIN: 4}

var current_event_state: int = EnvironmentState.NORMAL
var environment_state_event_total_weight: Dictionary = {}

var environment_manager
var map_manager

onready var event_timer := $EventTimer

var environment_state_event_list_with_chance: Dictionary = {
	EnvironmentState.NORMAL:
	{"wind_blow": 100, "small_wind_blow": 280, "insects_ambience": 50, "rain": 10},
	EnvironmentState.RAIN: {"wind_blow": 100, "small_wind_blow": 70}
}


func _ready() -> void:
	environment_manager = owner
	event_timer.connect("timeout", self, "_on_event_timer_timeout")
	get_current_event_period()
	activate_event_timer()
	calculate_event_total_weight()


func calculate_event_total_weight() -> void:
	for _state in environment_state_event_list_with_chance:
		environment_state_event_total_weight[_state] = Utils.calculate_total_weight_from_dictionary(
			environment_state_event_list_with_chance[_state]
		)

	# print(environment_state_event_total_weight)


func get_current_event_period() -> float:
	return EventPeriod[current_event_state]


func get_current_event_list_with_chance() -> Dictionary:
	return environment_state_event_list_with_chance[current_event_state]


func set_map_manager(_map_manager) -> void:
	map_manager = _map_manager


func activate_event_timer() -> void:
	Utils.activate_timer(
		event_timer,
		rand_range(
			get_current_event_period() * (1 - EVENT_RAND_EXP),
			get_current_event_period() * (1 + EVENT_RAND_EXP)
		)
	)


func _on_event_timer_timeout() -> void:
	if not Utils.node_exists(map_manager):
		queue_free()
		return
	active_event()
	activate_event_timer()


func active_event() -> void:
	if !environment_manager.current_environment_is_farm():
		return
	var _event: String = Utils.random_with_chance_from_dictionary(
		environment_state_event_list_with_chance[current_event_state],
		environment_state_event_total_weight[current_event_state]
	)
	# print(_event)
	match _event:
		"wind_blow":
			active_wind_blow()
		"small_wind_blow":
			active_small_wind_blow()
		"insects_ambience":
			active_insects_ambience()


func active_insects_ambience() -> void:
	if Utils.get_current_daytime() != Constants.DayTime.NIGHT:
		active_event()
		return

	var audio_player: AudioStreamPlayer2D = GameManager.env_sound_manager.environment_bg_sound_manager.play_environment_sound(
		self,
		Utils.load_resource(
			AudioLibrary.GRASS_INSECT_AMBIENCE, "ambience_sound", "grass_insects_1"
		),
		16,
		true
	)

	if audio_player == null:
		active_event()


#region: wind blow
func active_wind_blow() -> void:
	if not Utils.node_exists(map_manager):
		return
	SignalManager.emit_signal(
		"wind_blow", create_wind(Vector2(map_manager.map_width, map_manager.map_height))
	)


func active_small_wind_blow() -> void:
	if not Utils.node_exists(map_manager):
		return
	SignalManager.emit_signal(
		"wind_blow", create_small_wind(Vector2(map_manager.map_width, map_manager.map_height))
	)


func create_wind(_area_size: Vector2, _appear_at_edge_of_area: bool = true) -> Dictionary:
	var _init_position: Vector2 = set_wind_init_position(_area_size, _appear_at_edge_of_area)
	var _direction: Vector2 = set_wind_direction()
	var _speed: int = set_wind_speed()
	var _size: int = set_wind_size()
	return {
		"init_position": _init_position, "direction": _direction, "speed": _speed, "size": _size
	}


func create_small_wind(_area_size: Vector2, _appear_at_edge_of_area: bool = true) -> Dictionary:
	var _init_position: Vector2 = set_wind_init_position(_area_size, _appear_at_edge_of_area)
	var _direction: Vector2 = set_wind_direction()
	var _speed: int = set_wind_speed()
	var _size: int = set_small_wind_size()
	return {
		"init_position": _init_position, "direction": _direction, "speed": _speed, "size": _size
	}


func set_wind_init_position(_area_size: Vector2, _appear_at_edge_of_area: bool = true) -> Vector2:
	var _rand_x: int = Utils.random_int(0, 2 * _area_size.x - 1)
	var _rand_y: int = Utils.random_int(0, 2 * _area_size.y - 1)
	var _init_position_x: int = (
		(_rand_x / (int(_area_size.x) - 1)) * (int(_area_size.x) - 1)
		if _appear_at_edge_of_area
		else (_rand_x % (int(_area_size.x) - 1))
	)
	var _init_position_y: int = (
		(_rand_y / (int(_area_size.y) - 1)) * (int(_area_size.y) - 1)
		if _appear_at_edge_of_area
		else (_rand_y % (int(_area_size.y) - 1))
	)
	return Vector2(_init_position_x, _init_position_y)


func set_wind_direction() -> Vector2:
	var _wind_direction: Vector2 = Vector2(
		Utils.random_int(-WIND_DIRECTION_FRAGMENT, WIND_DIRECTION_FRAGMENT),
		Utils.random_int(-WIND_DIRECTION_FRAGMENT, WIND_DIRECTION_FRAGMENT)
	)
	return _wind_direction if _wind_direction != Vector2(0, 0) else set_wind_direction()


func set_wind_speed() -> int:
	return Utils.random_int(WIND_MIN_SPEED, WIND_MAX_SPEED)


func set_small_wind_size() -> int:
	return Utils.random_int(SMALL_WIND_MIN_SIZE, SMALL_WIND_MAX_SIZE)


func set_wind_size() -> int:
	return Utils.random_int(WIND_MIN_SIZE, WIND_MAX_SIZE)


func affect_by_wind(_map_position: Vector2, _wind: Dictionary) -> bool:
	var _a: float = (
		1 if abs(_wind.direction.x) < abs(_wind.direction.y)
		else float(_wind.direction.y) / float(_wind.direction.x)
	)
	var _b: float = (
		1 if abs(_wind.direction.y) < abs(_wind.direction.x)
		else float(_wind.direction.x) / float(_wind.direction.y)
	)
	var _c: float = _b * _wind.init_position.y - _a * _wind.init_position.x
	return abs(_a * _map_position.x - _b * _map_position.y + _c) < _wind.size + 1


func calculate_wind_affect_time(_map_position: Vector2, _wind: Dictionary) -> float:
	if _wind.direction.x >= _wind.direction.y:
		return abs(_map_position.x - _wind.init_position.x) / float(_wind.speed) + 1.0
	else:
		return abs(_map_position.y - _wind.init_position.y) / float(_wind.speed) + 1.0


func change_environment() -> void:
	if environment_manager.current_environment_is_farm():
		activate_event_timer()
	else:
		Utils.deactivate_timer(event_timer)
#endregion
