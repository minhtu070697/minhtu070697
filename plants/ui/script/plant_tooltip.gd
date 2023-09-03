extends Control


onready var harvest_meter := $PanelContainer/TooltipContainer/HarvestMeter/HarvestMeterBar
onready var harvest_meter_time_left := $PanelContainer/TooltipContainer/HarvestMeter/HarvestMeterBar/HarvestMeterTimeLeft
onready var harvest_time_left := $PanelContainer/TooltipContainer/HarvestTimeLeft
onready var harvest_meter_holder := $PanelContainer/TooltipContainer/HarvestMeter

onready var plant_name := $PanelContainer/TooltipContainer/PlantName

var plant: GrownPlant

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if plant == null:
		return
	
	update_harvest_meter()


func set_plant_info(_plant: GrownPlant):
	plant = _plant
	set_plant_name()


func set_plant_name():
	plant_name.text = plant.plant_name.capitalize()


func tooltip_enable():
	if plant == null:
		return
	set_physics_process(true)
	check_harvest_meter_visible()
	connect_to_plant()
	update_tooltip()
	visible = true

func tooltip_disable():
	if plant == null:
		return
	visible = false
	set_physics_process(false)
	disconnect_to_plant()


func update_tooltip():
	update_harvest_time_left()


func check_harvest_meter_visible():
	if plant.harvest_timer.is_stopped():
		hide_harvest_meter()
	else:
		show_harvest_meter()


func update_harvest_meter():
	harvest_meter.max_value = plant.plant_info.harvest_wait_time
	harvest_meter.value = harvest_meter.max_value - plant.harvest_timer.time_left
	harvest_meter_time_left.text = Utils.float_to_time_format(plant.harvest_timer.time_left, true)

func hide_harvest_meter():
	if harvest_meter_holder.visible:
		harvest_meter_holder.visible = false
		set_physics_process(false)

func show_harvest_meter():
	if !harvest_meter_holder.visible:
		harvest_meter_holder.visible = true
		set_physics_process(true)


func update_harvest_time_left():
	harvest_time_left.text = "Harvest left: " + Utils.to_text(plant.harvest_time_remain)


func connect_to_plant():
	if !plant.is_connected("harvest_time_change", self, "_on_harvest_time_change"):
		plant.connect("harvest_time_change", self, "_on_harvest_time_change")
	if !plant.is_connected("ready_to_harvest", self, "_on_ready_to_harvest"):
		plant.connect("ready_to_harvest", self, "_on_ready_to_harvest")


func _on_harvest_time_change():
	show_harvest_meter()
	update_harvest_time_left()


func _on_ready_to_harvest():
	hide_harvest_meter()


func disconnect_to_plant():
	if plant.is_connected("harvest_time_change", self, "_on_harvest_time_change"):
		plant.disconnect("harvest_time_change", self, "_on_harvest_time_change")
	if plant.is_connected("ready_to_harvest", self, "_on_ready_to_harvest"):
		plant.disconnect("ready_to_harvest", self, "_on_ready_to_harvest")



