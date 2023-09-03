extends Node

class_name DayTimeManager

var game_manager
var map_manager
var scene_manager

var main_bg = null
var dark_bg = null
var sun = null
var moon = null
var tween = null

var current_color = null
var day_color = Color(1, 1, 1, 1)
var night_color = Color(0.35, 0.4, 0.45, 1)
var dawn_color = Color(0.5, 0.6, 0.6, 1)
var sunset_color = Color(0.71, 0.7, 0.63, 1)

var is_daytime_changable = true
var vfx_duration = 2.5

var timer_label: Label
var time: float
var minutes: float
var hours: float
var timer_speed: int = 1
var current_time = 0.0

var timer_on: bool = false
var is_first_open: bool = false

var dawn_hour = Constants.DayTimeHour[Constants.DayTime.DAWN]
var day_hour = Constants.DayTimeHour[Constants.DayTime.DAY]
var sunset_hour = Constants.DayTimeHour[Constants.DayTime.SUNSET]
var night_hour = Constants.DayTimeHour[Constants.DayTime.NIGHT]

var dawn_delta_time = dawn_hour * 60.0
var day_delta_time = day_hour * 60.0
var sunset_delta_time = sunset_hour * 60.0
var night_delta_time = night_hour * 60.0

var current_daytime = Constants.DayTime.DAY


func _init(_game_manager):
	game_manager = _game_manager


func init_nodes_from_map_manager(_map_manager):
	if game_manager.is_outside_map_features():
		map_manager = _map_manager
		main_bg = map_manager.group_bg.get_node_or_null("0")
		dark_bg = map_manager.group_bg.get_node_or_null("DarkBackground")
		sun = map_manager.group_bg.get_node_or_null("Sun")
		moon = map_manager.group_bg.get_node_or_null("Moon")
		tween = map_manager.group_bg.get_node_or_null("Tween")


func daytime_input(event):
	scene_manager = game_manager.scene_manager
	if not map_manager.is_battlefield and is_daytime_changable:
		if (
			event.is_action_pressed("day_changing")
			and current_daytime != Constants.DayTime.DAY
		):
			daytime_changing_input(day_hour, day_delta_time)
		elif (
			event.is_action_pressed("night_changing")
			and current_daytime != Constants.DayTime.NIGHT
		):
			daytime_changing_input(night_hour, night_delta_time)
		elif (
			event.is_action_pressed("dawn_changing")
			and current_daytime != Constants.DayTime.DAWN
		):
			daytime_changing_input(dawn_hour, dawn_delta_time)
		elif (
			event.is_action_pressed("sunset_changing")
			and current_daytime != Constants.DayTime.SUNSET
		):
			daytime_changing_input(sunset_hour, sunset_delta_time)


#region: logic
func daytime_changing():
	if not map_manager.is_battlefield and is_daytime_changable:
		if is_day_hours():
			if not is_first_open:
				is_first_open = true
				day_changing()
			elif current_daytime != Constants.DayTime.DAY:
				day_changing()
		elif is_night_hours():
			if not is_first_open:
				is_first_open = true
				night_changing()
			elif current_daytime != Constants.DayTime.NIGHT:
				night_changing()
		elif is_dawn_hours():
			if not is_first_open:
				is_first_open = true
				dawn_changing()
			elif current_daytime != Constants.DayTime.DAWN:
				dawn_changing()
		elif is_sunset_hours():
			if not is_first_open:
				is_first_open = true
				sunset_changing()
			elif current_daytime != Constants.DayTime.SUNSET:
				sunset_changing()


func day_changing():
	is_daytime_changable = false
	day_changing_vfx()
	current_daytime = Constants.DayTime.DAY
	GameManager.scene_manager.change_status_custom(GameManager.scene_manager.day_title, 0, 1)
	SignalManager.emit_signal("day")


func night_changing():
	is_daytime_changable = false
	night_changing_vfx()
	current_daytime = Constants.DayTime.NIGHT
	GameManager.scene_manager.change_status_custom(GameManager.scene_manager.night_title, 0, 1)
	SignalManager.emit_signal("night")


func dawn_changing():
	is_daytime_changable = false
	dawn_changing_vfx()
	current_daytime = Constants.DayTime.DAWN
	GameManager.scene_manager.change_status_custom(GameManager.scene_manager.dawn_title, 0, 1)
	SignalManager.emit_signal("dawn")


func sunset_changing():
	is_daytime_changable = false
	sunset_changing_vfx()
	current_daytime = Constants.DayTime.SUNSET
	GameManager.scene_manager.change_status_custom(GameManager.scene_manager.sunset_title, 0, 1)
	SignalManager.emit_signal("sunset")

#endregion


#region: vfx
func day_changing_vfx():
	sun.visible = true
	if is_night_time():
		daylight_general_vfx()
	Utils.start_tween(
		tween,
		dark_bg,
		"color",
		current_color,
		day_color,
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	yield(tween, "tween_completed")
	moon.visible = false
	is_daytime_changable = true
	run_timer()
	current_color = day_color


func dawn_changing_vfx():
	if is_night_time():
		daylight_general_vfx()
	Utils.start_tween(
		tween,
		dark_bg,
		"color",
		current_color,
		dawn_color,
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	yield(tween, "tween_completed")
	moon.visible = false
	is_daytime_changable = true
	run_timer()
	current_color = dawn_color


func sunset_changing_vfx():
	if is_night_time():
		daylight_general_vfx()
	Utils.start_tween(
		tween,
		dark_bg,
		"color",
		current_color,
		sunset_color,
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	yield(tween, "tween_completed")
	moon.visible = false
	is_daytime_changable = true
	run_timer()
	current_color = sunset_color


func night_changing_vfx():
	moon.visible = true
	daynight_general_vfx()
	Utils.start_tween(
		tween,
		dark_bg,
		"color",
		current_color,
		night_color,
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	yield(tween, "tween_completed")
	sun.visible = false
	is_daytime_changable = true
	run_timer()
	current_color = night_color


func is_night_time():
	return (
		current_daytime != Constants.DayTime.DAY
		and current_daytime != Constants.DayTime.DAWN
		and current_daytime != Constants.DayTime.SUNSET
	)


func daylight_general_vfx():
	sun.visible = true
	Utils.start_tween(
		tween,
		main_bg,
		"modulate",
		Color(0.2, 0.25, 0.3, 1),
		Color(0.75, 1, 1, 1),
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	Utils.start_tween(
		tween,
		sun,
		"position",
		Vector2(-1500, 1500),
		Vector2(-215, -254),
		vfx_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	Utils.start_tween(
		tween,
		moon,
		"position",
		Vector2(784, -265),
		Vector2(1500, 1500),
		vfx_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)


func daynight_general_vfx():
	moon.visible = true
	Utils.start_tween(
		tween,
		main_bg,
		"modulate",
		Color(1, 1, 1, 1),
		Color(0.15, 0.2, 0.25, 1),
		vfx_duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	Utils.start_tween(
		tween,
		sun,
		"position",
		Vector2(-215, -254),
		Vector2(-1500, 1500),
		vfx_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	Utils.start_tween(
		tween,
		moon,
		"position",
		Vector2(1500, 1500),
		Vector2(784, -265),
		vfx_duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)


#endregion


#region: current timing
func run_timer():
	timer_on = true


func stop_timer():
	timer_on = false


func set_current_timing(_delta):
	if timer_on:
		time += _delta * timer_speed
		convert_timer()
		set_timer()
		set_timer_text()

		if game_manager.is_outside_map_features():
			daytime_changing()


func convert_timer():
	minutes = fmod(time, 60)
	hours = fmod(fmod(time, 60 * 60) / 60, 24)


func set_timer():
	current_time = "%02d:%02d" % [hours, minutes]


func set_timer_text():
	var character: Character = Utils.get_current_character()
	if not character:
		return
	
	timer_label = character.ui_manager.get_node_or_null("GroupHUD").get_node_or_null(
		"CharacterInfo"
	).timer_label
	timer_label.text = current_time


func daytime_changing_input(_hours: float, _time: float):
	stop_timer()
	hours = _hours
	minutes = 0.0
	time = _time
	set_timer()
	set_timer_text()
	daytime_changing()


func is_day_hours():
	return hours >= day_hour and hours < sunset_hour


func is_night_hours():
	return (hours >= 0.0 and hours < dawn_hour) or hours >= night_hour


func is_dawn_hours():
	return hours >= dawn_hour and hours < day_hour


func is_sunset_hours():
	return hours >= sunset_hour and hours < night_hour


func get_next_daytime() -> int: #oke 
	if current_daytime == Constants.DayTime.DAY:
		return Constants.DayTime.SUNSET
	elif current_daytime == Constants.DayTime.SUNSET:
		return Constants.DayTime.NIGHT
	elif current_daytime == Constants.DayTime.NIGHT:
		return Constants.DayTime.DAWN
	elif current_daytime == Constants.DayTime.DAWN:
		return Constants.DayTime.DAY
	else:
		return Constants.DayTime.DAY


func get_next_daytime_time() -> float:
	return Constants.DayTimeHour[get_next_daytime()]


func get_time_duration_to_next_daytime() -> float:
	var next_dt_time: float = get_next_daytime_time()
	if next_dt_time < hours:
		next_dt_time += 24.0
	
	return (next_dt_time - hours) * 60
#endregion
