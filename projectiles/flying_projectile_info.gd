extends Node2D
class_name FlyingProjectileInfo

var proj_info : ProjectileResources

func _init(_proj) -> void:
	if _proj != null:
		proj_info = ProjectileResources.new(GameResourcesLibrary.projectile_resources_list_json[_proj.proj_name])

