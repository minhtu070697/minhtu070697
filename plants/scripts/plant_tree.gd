extends GrownPlant
class_name GrownPlantTree

onready var animation_stopper := $AnimationStopper
onready var particle_2d := $Sprite/Particles2D
onready var vfx_hit: Sprite = $VFX_Hit

onready var stats_manager = $StatsManager

export(int, 60) var lvl: int = 1

func _ready() -> void:
	animation_stopper.connect("timeout", self, "_on_animation_stopper_timeout")
	SignalManager.connect("death", self, "_on_death")
	animation_player.connect("animation_finished", self, "_on_animation_finished")
	particle_2d.emitting = false


func _on_animation_stopper_timeout():
	particle_2d.emitting = false


func _on_animation_finished(animation_name):
	Utils.on_resource_animation_finished(get_node("."), animation_name, vfx_hit)


func _on_death(_host_name):
	if _host_name == name:
		animation_player.play("die")


func set_plant_farm_plot(_farm_plot) -> void:
	pass


func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 30, 5, 0)
	on_efx()


func on_efx():
	if stats_manager.stats.hp > 0:
		particle_2d.emitting = true
		animation_stopper.start(0.3)


func plant_die():
	plant_tooltip_area.disconnect("mouse_entered", self, "_on_tooltip_area_mouse_entered")
	plant_tooltip_area.disconnect("mouse_exited", self, "_on_tooltip_area_mouse_exited")
	plant_tooltip.queue_free()
	plant_tooltip_area.queue_free()
	harvest_status = HarvestStatus.EMPTY
	load_plant_sprite_at_current_status()


func create_hit_particle() -> void:
	vfx_hit.visible = true
