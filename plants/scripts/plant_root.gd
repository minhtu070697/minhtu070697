extends GrownPlant
class_name GrownPlantRoot


func plant_die():
	plant_remove()


func init(_name: String = "", _plant_quality: int = Quality.NORMAL) -> void:
	plant_name = _name if _name != "" else "carrot"
	load_grown_plant_info()
	if plant_info.plant_name == "":
		queue_free()
		return
	
	set_plant_sprite_position()
	ready_to_harvest()
	load_plant_sprite_at_current_status()
	plant_quality = _plant_quality
	plant_tooltip.set_plant_info(self)
