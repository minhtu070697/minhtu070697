extends CollectResources
class_name GrownPlant

signal harvest_time_change()

enum Status {FULL, DEAD}
enum Quality {LESS, NORMAL, PERFECT}

const PLANT_SPRITE_PATH = "res://plants/textures/%s/%s-growth.png" #%[sprite_name, sprite_name, phase]

onready var animation_player : AnimationPlayer = $AnimationPlayer

onready var plant_tooltip := $PlantTooltipHolder/PlantTooltip
onready var plant_tooltip_area := $PlantTooltipHolder/TooltipCheckArea

var plant_info: Dictionary
var plant_name: String = "carrot"

var plant_status: int = Status.FULL
var plant_quality: int = Quality.PERFECT

var farm_plot = null

func _ready() -> void:
	plant_tooltip_area.connect("mouse_entered", self, "_on_tooltip_area_mouse_entered")
	plant_tooltip_area.connect("mouse_exited", self, "_on_tooltip_area_mouse_exited")


func init(_name: String = "", _plant_quality: int = Quality.PERFECT) -> void:
	plant_name = _name if _name != "" else "carrot"
	load_grown_plant_info()
	if plant_info.plant_name == "":
		queue_free()
		return
	
	set_plant_sprite_position()
	load_plant_sprite_at_current_status()
	harvest_time_remain = plant_info.harvest_time
	plant_quality = _plant_quality
	start_harvest_wait_time()
	plant_tooltip.set_plant_info(self)


func set_plant_sprite_position():
	sprite.position = Vector2(plant_info.sprite_position.x, plant_info.sprite_position.y)


func set_plant_farm_plot(_farm_plot) -> void:
	farm_plot = _farm_plot


func load_grown_plant_info():
	plant_info = Constants.PlantDefaultInfo.duplicate()
	for _info_name in GameResourcesLibrary.plant_resource[plant_name]:
		plant_info[_info_name] = GameResourcesLibrary.plant_resource[plant_name][_info_name]


func load_plant_sprite(_sprite_name: String, _status_name: String, _dead: bool = false):
	var _sprite_name_final = "%s-%s" %[_sprite_name, _status_name] if !_dead else "%s-dead" %[_sprite_name]
	var _sprite_name_path = PLANT_SPRITE_PATH %[_sprite_name, _sprite_name_final]
	sprite.texture = Utils.load_resource(_sprite_name_path, "plant", _sprite_name_final)


func load_plant_sprite_at_current_status():
	load_plant_sprite(plant_info.sprite_name, HarvestStatus.keys()[harvest_status].to_lower())


func load_plant_dead_sprite():
	load_plant_sprite(plant_info.sprite_name, HarvestStatus.keys()[harvest_status].to_lower(), true)


func _on_tooltip_area_mouse_entered():
	plant_tooltip.tooltip_enable()

func _on_tooltip_area_mouse_exited():
	plant_tooltip.tooltip_disable()


func plant_remove():
	remove_plant_from_map_info()
	if farm_plot:
		farm_plot.plant_removed()
	GameManager.map_manager.map_navigator._add_build_disabled_points(size, GameManager.map_manager_utils.global_to_map_position(global_position))
	queue_free()


func is_dead() -> bool:
	return plant_status == Status.DEAD


func remove_plant_from_map_info():
	var _map_position = GameManager.map_manager_utils.global_to_map_position(global_position)
	var _map_info = GameManager.map_manager.map_info
	_map_info.remove_resource(_map_info.top_item(_map_position), size, _map_position)


func start_harvest_wait_time(_time: float = plant_info.harvest_wait_time):
	.start_harvest_wait_time(_time)
	load_plant_sprite_at_current_status()
	emit_signal("harvest_time_change")


func ready_to_harvest():
	harvest_status = HarvestStatus.FULL
	load_plant_sprite_at_current_status()
	emit_signal("ready_to_harvest")


#override
func run_out_of_harvest_time() -> void:
	plant_die()


func plant_die():
	plant_status = Status.DEAD
	load_plant_dead_sprite()
	plant_tooltip_area.disconnect("mouse_entered", self, "_on_tooltip_area_mouse_entered")
	plant_tooltip_area.disconnect("mouse_exited", self, "_on_tooltip_area_mouse_exited")
	plant_tooltip.queue_free()
	plant_tooltip_area.queue_free()


func harvest_yield():
	for _quality_name in Quality:
		if plant_quality >= Quality[_quality_name]:
			if !plant_info.harvest_yield.has(_quality_name.to_lower()):
				continue
			var _quality = plant_info.harvest_yield[_quality_name.to_lower()]
#			print(_quality_name, ": ", _quality)
			for _item_name in _quality:
				if randf() <= _quality[_item_name].chance:
					check_and_spawn_item(_item_name)

