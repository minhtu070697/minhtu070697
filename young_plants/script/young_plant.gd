extends StaticObjects
class_name YoungPlant

signal water_meter_change
signal fertilizer_meter_change
signal health_meter_change
signal decease_status_change

enum DmgType {WATER, BUG}
enum Status {HAPPY, GOOD, BAD, DEAD}

const YOUNG_PLANT_SPRITE_PATH = "res://young_plants/texture/%s/%s-%s.png" #%[sprite_name, sprite_name, phase]
const YOUNG_PLANT_DIE_PATH = "res://young_plants/texture/%s/%s-die-%s.png" #%[sprite_name, sprite_name, phase]
const PLANT_SCENE_PATH = "res://plants/scenes/plant.tscn"
const PLANT_TREE_SCENE_PATH = "res://plants/scenes/plant_tree.tscn"
const PLANT_ROOT_SCENE_PATH = "res://plants/scenes/plant_root.tscn"
const INFORMATION_ICON_PATH = "res://ui/textures/icons/information_icon.png"
const DANGER_INFORMATION_ICON_PATH = "res://ui/textures/icons/information_icon_danger.png"

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var growing_timer: Timer = $YoungPlantTimers/GrowingTimer
onready var water_timer: Timer = $YoungPlantTimers/WaterTimer
onready var fertilizer_timer: Timer = $YoungPlantTimers/FertilizerTimer
onready var health_timer: Timer = $YoungPlantTimers/HealthTimer
onready var decease_timer: Timer = $YoungPlantTimers/DeceaseTimer

onready var young_plant_tooltip := $YoungPlantTooltipHolder/YoungPlantTooltip
onready var young_plant_tooltip_area := $YoungPlantTooltipHolder/TooltipCheckArea

var young_plant_info: Dictionary
var young_plant_name: String = "carrot"

var water_meter: int = 0 setget set_water_meter
var fertilizer_meter: int = 0 setget set_fertilizer_meter
var health_meter: int = 0 setget set_health_meter
var decease_status: Array = []
var dmg_per_tick: Dictionary = {}

var current_phase: int = 1
var young_plant_status: int = Status.HAPPY
var farm_plot = null


func _ready() -> void:
	growing_timer.connect("timeout", self, "_phase_time_out")
	water_timer.connect("timeout", self, "_on_water_timer_timeout")
	health_timer.connect("timeout", self, "_on_health_timer_timeout")
	fertilizer_timer.connect("timeout", self, "_on_fertilizer_timer_timeout")
	young_plant_tooltip_area.connect("mouse_entered", self, "_on_tooltip_area_mouse_entered")
	young_plant_tooltip_area.connect("mouse_exited", self, "_on_tooltip_area_mouse_exited")


func init(_name: String = "") -> void:
	young_plant_name = _name if _name != "" else "carrot"
	load_young_plant_info()
	if young_plant_info.young_plant_name == "":
		queue_free()
		return
	
	set_young_plant_sprite_position()
	load_young_plant_sprite_at_current_phase()
	start_growing()
	young_plant_tooltip.set_young_plant_info(self)


func set_young_plant_farm_plot(_farm_plot):
	farm_plot = _farm_plot


func set_young_plant_sprite_position():
	sprite.position = Vector2(young_plant_info.sprite_position.x, young_plant_info.sprite_position.y)


func load_young_plant_info():
	young_plant_info = Constants.YoungPlantDefaultInfo.duplicate()
	for _info_name in GameResourcesLibrary.young_plant_resource[young_plant_name]:
		young_plant_info[_info_name] = GameResourcesLibrary.young_plant_resource[young_plant_name][_info_name]


func load_young_plant_sprite(_sprite_name: String, _phase: int, _dead: bool = false):
	var _sprite_name_final = _sprite_name + "-die" if _dead else _sprite_name
	var _sprite_name_path = YOUNG_PLANT_SPRITE_PATH %[_sprite_name, _sprite_name_final, String(_phase)]
	
	sprite.texture = Utils.load_resource(_sprite_name_path, "young_plant", _sprite_name_final + "_" + String(_phase))


func load_young_plant_sprite_at_current_phase():
	load_young_plant_sprite(young_plant_info.sprite_name, current_phase)

func load_young_plant_dead_sprite_at_current_phase():
	load_young_plant_sprite(young_plant_info.sprite_name, current_phase, true)


func init_water_meter():
	set_water_meter(young_plant_info.water_meter_max)


func init_fertilizer_meter():
	set_fertilizer_meter(young_plant_info.fertilizer_meter_max / 2)


func init_health_meter():
	set_health_meter(young_plant_info.health_meter_max)


func start_growing():
	activate_timer(growing_timer, young_plant_info.phase_time["1"] * 3600)
	activate_timer(water_timer, Constants.YOUNG_PLANT_WATER_DROP_TIME)
	activate_timer(fertilizer_timer, Constants.YOUNG_PLANT_FERTILIZER_DROP_TIME)
	# activate_decease_timer()
	
	init_water_meter()
	init_health_meter()
	init_fertilizer_meter()


func stop_growing():
	deactivate_timer(growing_timer)
	deactivate_timer(water_timer)
	deactivate_timer(fertilizer_timer)
	deactivate_timer(health_timer)


func activate_timer(_timer: Timer, _time_amount: int):
	if !_timer.is_stopped():
		return
	_timer.start(_time_amount)


func deactivate_timer(_timer: Timer):
	if _timer.is_stopped():
		return
	
	_timer.stop()


func _phase_time_out():
	grow()


func grow():
	if current_phase < young_plant_info.growth_phase:
		current_phase += 1
		load_young_plant_sprite_at_current_phase()
		activate_timer(growing_timer, young_plant_info.phase_time[String(current_phase)] * 3600)
	else:
		stop_growing()
		fully_grown()


func fully_grown():
	var _grown_plant_scene
	remove_young_plant_from_map_info()

	if GameResourcesLibrary.plant_resource[young_plant_info.growth_plant_name].plant_type == "tree":
		farm_plot_destroy(GameManager.map_manager_utils.global_to_map_position(global_position))
		_grown_plant_scene = Utils.load_resource(PLANT_TREE_SCENE_PATH, "plant_tree", "scene")
	elif GameResourcesLibrary.plant_resource[young_plant_info.growth_plant_name].plant_type == "plant":
		_grown_plant_scene = Utils.load_resource(PLANT_SCENE_PATH, "plant", "scene")
	elif GameResourcesLibrary.plant_resource[young_plant_info.growth_plant_name].plant_type == "root":
		_grown_plant_scene = Utils.load_resource(PLANT_ROOT_SCENE_PATH, "plant_root", "scene")

	var _grown_plant = _grown_plant_scene.instance()
	var _grown_plant_map_position = GameManager.map_manager_utils.global_to_map_position(global_position)
	_grown_plant.global_position = GameManager.map_manager_utils.map_to_global_position(_grown_plant_map_position)
	get_parent().add_child(_grown_plant)
	add_grown_plant_to_map_info(_grown_plant, _grown_plant_map_position)
	_grown_plant.init(young_plant_info.growth_plant_name)
	_grown_plant.created()

	GameManager.map_manager.ysort.nogias_insert(_grown_plant)
	_grown_plant.update_sort_position()
	#lam tiep o day, map_info append resource vao, lay resource_type trong scene luon.
	if farm_plot:
		_grown_plant.set_plant_farm_plot(farm_plot)
	
	queue_free()


func add_grown_plant_to_map_info(_grown_plant, _grown_plant_map_position: Vector2):
	GameManager.map_manager.map_info.append_resource(_grown_plant, Constants.ResourceType.PLANT, _grown_plant_map_position)
	if !GameManager.map_manager.map_navigator.is_point_disabled(GameManager.map_manager.map_navigator.point_to_index(_grown_plant_map_position)):
		GameManager.map_manager.map_navigator._add_build_disabled_points(_grown_plant.size, _grown_plant_map_position)


func remove_young_plant_from_map_info():
	var _map_position = GameManager.map_manager_utils.global_to_map_position(global_position)
	var _map_info = GameManager.map_manager.map_info
	_map_info.remove_resource(_map_info.top_item(_map_position), size, _map_position)


func farm_plot_destroy(_map_position: Vector2):
	GameManager.map_manager.map_info.remove_resource(GameManager.map_manager.map_info.top_item(_map_position), Vector2(1, 1), _map_position)
	farm_plot.remove_farm_plot()
	farm_plot = null


func set_water_meter(_new_value: int):
	var _old_water_meter = water_meter
	water_meter = Utils.clamp_int(_new_value, 0, young_plant_info.water_meter_max)
	if water_meter != _old_water_meter:
		emit_signal("water_meter_change")
		if _old_water_meter > 0 and water_meter <= 0:
			water_meter_depleted()
		elif _old_water_meter == 0 and water_meter > 0:
			water_meter_filled()


func set_fertilizer_meter(_new_value: int):
	var _old_fertilizer_meter = fertilizer_meter
	fertilizer_meter = Utils.clamp_int(_new_value, 0, young_plant_info.fertilizer_meter_max)
	emit_signal("fertilizer_meter_change")
	if fertilizer_meter != _old_fertilizer_meter:
		emit_signal("fertilizer_meter_change")


func set_health_meter(_new_value: int):
	var _old_health_meter = health_meter
	health_meter = Utils.clamp_int(_new_value, 0, young_plant_info.health_meter_max)
	if health_meter != _old_health_meter:
		emit_signal("health_meter_change")
		if _old_health_meter > 0 and health_meter == 0:
			young_plant_die()


func consume_fertilizer():
	set_fertilizer_meter(fertilizer_meter - young_plant_info.fertilizer_meter_max * young_plant_info.fertilizer_drop_speed / 100.0)


func fill_fertilizer():
	if not Utils.node_exists(farm_plot):
		return
	set_fertilizer_meter(fertilizer_meter + farm_plot.fertilizer_consumed(min(young_plant_info.fertilizer_meter_max - fertilizer_meter, young_plant_info.fertilizer_meter_max * young_plant_info.fertilizer_drop_speed * 3 / 100.0)))


func _on_water_timer_timeout():
	set_water_meter(water_meter - young_plant_info.water_meter_max * young_plant_info.water_drop_speed / 100.0)


func _on_fertilizer_timer_timeout():
	fill_fertilizer()
	consume_fertilizer()


func water_meter_depleted():
	dmg_per_tick[DmgType.WATER] = young_plant_info.health_drop_speed * young_plant_info.health_meter_max / 100.0
	young_plant_damaged()


func water_meter_filled():
	dmg_per_tick.erase(DmgType.WATER)


func young_plant_damaged():
	activate_timer(health_timer, Constants.YOUNG_PLANT_HEALTH_DROP_TIME)
	young_plant_tooltip_area.texture = Utils.load_resource(DANGER_INFORMATION_ICON_PATH, "young_plant_info", "danger_icon_texture")


func young_plant_healed():
	if dmg_per_tick.empty():
		young_plant_tooltip_area.texture = Utils.load_resource(INFORMATION_ICON_PATH, "young_plant_info", "icon_texture")
		if health_meter == young_plant_info.health_meter_max:
			deactivate_timer(health_timer)


func young_plant_heal():
	var heal_amount: float = young_plant_info.health_drop_speed * young_plant_info.health_meter_max / 100.0 / 3.0
	set_health_meter(health_meter + heal_amount)
	young_plant_healed()


func _on_health_timer_timeout():
	if dmg_per_tick.empty():
		young_plant_heal()
	else:
		young_plant_take_dmg()


func young_plant_take_dmg():
	var _dmg = 0
	for dmg_name in dmg_per_tick:
		_dmg += dmg_per_tick[dmg_name]
	set_health_meter(health_meter - _dmg)


func young_plant_die():
	young_plant_status = Status.DEAD
	stop_growing()
	load_young_plant_dead_sprite_at_current_phase()
	young_plant_tooltip_area.disconnect("mouse_entered", self, "_on_tooltip_area_mouse_entered")
	young_plant_tooltip_area.disconnect("mouse_exited", self, "_on_tooltip_area_mouse_exited")
	young_plant_tooltip.queue_free()
	young_plant_tooltip_area.queue_free()


func _on_tooltip_area_mouse_entered():
	young_plant_tooltip.tooltip_enable()

func _on_tooltip_area_mouse_exited():
	young_plant_tooltip.tooltip_disable()


func young_plant_remove():
	remove_young_plant_from_map_info()
	if farm_plot:
		farm_plot.plant_removed()
	GameManager.map_manager.map_navigator._add_build_disabled_points(size, GameManager.map_manager_utils.global_to_map_position(global_position))
	queue_free()


func is_dead() -> bool:
	return young_plant_status == Status.DEAD


func player_take_care():
	set_water_meter(young_plant_info.water_meter_max)
	set_fertilizer_meter(young_plant_info.fertilizer_meter_max)



