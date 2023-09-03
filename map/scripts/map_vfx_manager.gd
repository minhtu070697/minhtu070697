extends Node

class_name MapVFXManager

var game_manager
var map_manager

var clouds = []
var cloud_alpha

var fade_shader: float = 0
var overlay_shader: float = 0

var top = Vector2.ZERO
var left = Vector2.ZERO
var right = Vector2.ZERO
var bot = Vector2.ZERO

var intensity = .03
var max_a = .5
var min_a = intensity

var wind_grass_shader = load("res://efx/shader/wind_grass.tres")
var earth_water_shake_shader = load("res://efx/shader/earth_water_shake_shader.tres")
var water_wave_shader = load("res://efx/shader/water_wave.tres")
var water_wave_shader_1 = load("res://efx/shader/water_wave_1.tres")
var water_wave_shader_2 = load("res://efx/shader/water_wave_2.tres")
var water_wave_shader_3 = load("res://efx/shader/water_wave_3.tres")
var water_wave_shader_4 = load("res://efx/shader/water_wave_4.tres")
var water_wave_shader_5 = load("res://efx/shader/water_wave_5.tres")


func _init(_game_manager, _map_manager):
	game_manager = _game_manager
	map_manager = _map_manager


func spawn_cloud():
	var x_range_0_2 = Utils.cal_xrange(Vector2(0, 2), map_manager.size)
	var y_range_0_2 = Utils.cal_yrange(Vector2(0, 2), map_manager.size)
	var x_range_2_0 = Utils.cal_xrange(Vector2(2, 0), map_manager.size)
	var y_range_2_0 = Utils.cal_yrange(Vector2(2, 0), map_manager.size)

	top = map_manager.map_navigator.point_to_world(Vector2.ZERO).y
	left = map_manager.map_navigator.point_to_world(Vector2(x_range_0_2.x, y_range_0_2.y)).x
	right = map_manager.map_navigator.point_to_world(Vector2(x_range_2_0.y, y_range_2_0.x)).x
	bot = map_manager.map_navigator.point_to_world(
		Vector2(map_manager.max_size, map_manager.max_size)
	).y

	var total_cloud = map_manager.size / 1.5
	for i in total_cloud:
		var cloud = Utils.load_resource("res://map/scenes/vfxs/Cloud.tscn", "cloud", "scene").instance()
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rng_int = Utils.random_int(0, 1)
		if rng_int == 1: cloud.scale = Vector2(-1, 1)
		cloud.position = Vector2(rng.randf_range(left, right), rng.randf_range(top, bot))
		cloud.z_index = 10
		map_manager.ysort.add_child(cloud)
		clouds.append(cloud)
		set_cloud_default_color(cloud)


func destroy_cloud():
	if clouds.size() > 0:
		for i in clouds.size():
			clouds[i].queue_free()
		clouds.clear()


func set_cloud_default_color(cloud: Node):
	var cloud_sprite = cloud.get_node_or_null("Sprite")
	if map_manager.is_battlefield:
		cloud_alpha = 0.5
	else:
		cloud_sprite.modulate = Color.white
		cloud_alpha = .05
	cloud_sprite.modulate.a = cloud_alpha


func set_cloud_alpha(is_increase: bool, is_limit: bool):
	for i in clouds.size():
		var cloud_sprite = clouds[i].get_node_or_null("Sprite")
		if is_limit:
			cloud_sprite.modulate.a = cloud_sprite.modulate.a
		else:
			if is_increase:
				cloud_sprite.modulate.a += intensity
			else:
				cloud_sprite.modulate.a -= intensity


func set_min_max_cloud_alpha(is_max: bool):
	for i in clouds.size():
		var cloud_sprite = clouds[i].get_node_or_null("Sprite")
		if is_max:
			cloud_sprite.modulate.a = max_a
		else:
			cloud_sprite.modulate.a = min_a


func visible_map_shaders(visible: bool):
	# wind_grass_shader.set_shader_param("pause", visible)
	# earth_water_shake_shader.set_shader_param("pause", visible)
	# water_wave_shader.set_shader(null)
	# water_wave_shader_1.set_shader(null)
	# water_wave_shader_2.set_shader(null)
	# water_wave_shader_3.set_shader(null)
	# water_wave_shader_4.set_shader(null)
	# water_wave_shader_5.set_shader(null)
	GameManager.map_manager.water_tile_map.visible = visible
