extends Control

onready var water_meter = $PanelContainer/TooltipContainer/WaterMeter/WaterMeterBar
onready var health_meter = $PanelContainer/TooltipContainer/HealthMeter/HealthMeterBar
onready var fertilizer_meter = $PanelContainer/TooltipContainer/FertilizerMeter/FertilizerMeterBar
onready var grow_meter = $PanelContainer/TooltipContainer/GrowMeter/GrowMeterBar
onready var grow_meter_time_left = $PanelContainer/TooltipContainer/GrowMeter/GrowMeterBar/GrowMeterTimeLeft
onready var fertilizer_in_plot_left = $PanelContainer/TooltipContainer/FertilizerInPlot/FertilizerInPlotLeft

onready var young_plant_name := $PanelContainer/TooltipContainer/YoungPlantName

var young_plant: YoungPlant


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if young_plant == null:
		return
	
	update_grow_meter()


func set_young_plant_info(_young_plant: YoungPlant):
	young_plant = _young_plant
	set_young_plant_name()


func set_young_plant_name():
	young_plant_name.text = young_plant.young_plant_name.capitalize()


func tooltip_enable():
	if young_plant == null:
		return
	set_physics_process(true)
	connect_to_plant()
	update_tooltip()
	visible = true

func tooltip_disable():
	if young_plant == null:
		return
	visible = false
	set_physics_process(false)
	disconnect_to_plant()


func update_tooltip():
	update_water_meter()
	update_fertilizer_meter()
	update_health_meter()
	update_grow_meter()


func update_water_meter():
	water_meter.max_value = young_plant.young_plant_info.water_meter_max
	water_meter.value = young_plant.water_meter


func update_fertilizer_meter():
	if not Utils.node_exists(young_plant.farm_plot):
		return
	fertilizer_meter.max_value = young_plant.young_plant_info.fertilizer_meter_max
	fertilizer_meter.value = young_plant.fertilizer_meter
	fertilizer_in_plot_left.text = Utils.to_text(young_plant.farm_plot.fertilizer_in_plot) + "g"


func update_health_meter():
	health_meter.max_value = young_plant.young_plant_info.health_meter_max
	health_meter.value = young_plant.health_meter

func update_grow_meter():
	grow_meter.max_value = young_plant.young_plant_info.phase_time[String(young_plant.current_phase)] * 3600
	grow_meter.value = grow_meter.max_value - young_plant.growing_timer.time_left
	grow_meter_time_left.text = Utils.float_to_time_format(young_plant.growing_timer.time_left, true)


func _on_water_meter_change():
	update_water_meter()

func _on_fertilizer_meter_change():
	update_fertilizer_meter()

func _on_health_meter_change():
	update_health_meter()

func _on_decease_status_change():
	pass


func connect_to_plant():
	if !young_plant.is_connected("water_meter_change", self, "_on_water_meter_change"):
		young_plant.connect("water_meter_change", self, "_on_water_meter_change")
	if !young_plant.is_connected("fertilizer_meter_change", self, "_on_fertilizer_meter_change"):
		young_plant.connect("fertilizer_meter_change", self, "_on_fertilizer_meter_change")
	if !young_plant.is_connected("health_meter_change", self, "_on_health_meter_change"):
		young_plant.connect("health_meter_change", self, "_on_health_meter_change")
#	if !young_plant.is_connected("decease_status_change", self, "_on_decease_status_change"):
#		young_plant.connect("decease_status_change", self, "_on_decease_status_change")


func disconnect_to_plant():
	if young_plant.is_connected("water_meter_change", self, "_on_water_meter_change"):
		young_plant.disconnect("water_meter_change", self, "_on_water_meter_change")
	if young_plant.is_connected("fertilizer_meter_change", self, "_on_fertilizer_meter_change"):
		young_plant.disconnect("fertilizer_meter_change", self, "_on_fertilizer_meter_change")
	if young_plant.is_connected("health_meter_change", self, "_on_health_meter_change"):
		young_plant.disconnect("health_meter_change", self, "_on_health_meter_change")
#	if young_plant.is_connected("decease_status_change", self, "_on_decease_status_change"):
#		young_plant.disconnect("decease_status_change", self, "_on_decease_status_change")
