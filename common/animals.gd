extends Actor
class_name Animals

#signals
signal moving()
signal eating()
signal lying_down(lie_animation_name)
signal sleeping()

#consts
const ANIMAL_TIMERS_PATH: String = "res://animals/scenes/AnimalTimers.tscn"
const MAX_WET_METER: int = 100
const MIN_WET_METER: int = 0
const DISABLE_WL_NEED_TIME: int = 10
const SWIMMING_SINK_DEPTH: int = 7

enum MEMORIES {WATER_EDGE}
enum LiveStatus {ALIVE, DEAD}

#vars
var animal_sound_path: String = "res://animals/sounds/%s_cry_sound.mp3"
var animal_sprite_path: String

var animal_swimming_sound_path: String = "res://animals/sounds/%s_swim_sound.mp3"

var animal_behaviour_total_weight: int = 0
var animal_behaviour_list: Array = [Constants.random_event_with_chance.AnimalBehaviourWithChance]

onready var state_machine := get_node_or_null("States")
onready var shadow_sprite = $BodyParts/Shadow
onready var body_sprite := $BodyParts/Body
onready var food_sprite := $BodyParts/Body/Food

onready var idle_timer: Timer
onready var wet_timer: Timer
onready var state_timer: Timer

onready var status_label := get_node_or_null("StatusPanel/StatusLabel")

export(String) var animal_name: String = "cow"
var animal_type: int
var animal_info: Dictionary

var cry_sound: Resource
var swimming_sound: Resource
var walk_speed: int = 0
var run_speed: int = 0
var current_speed: int = 0

var running: bool = false
var jump_into_water_max_distance: int = 2
var wet_meter: int = 0 setget set_wet_meter

var land_returning: bool = false
var water_returning: bool = false

var live_status: int = LiveStatus.ALIVE

var action_speed: float = 1.0
var land_water_need_disabled: bool = false setget set_disable_land_water_need

onready var default_body_sprite_position: Vector2 = body_sprite.position

var animal_status_text: Dictionary = {}
var memory: Dictionary = {}


func _ready():
	init_animal_timers()
	animation_frames = {"idle": 6, "run": 6, "lie_down": 6, "livestock_guide": 6, 
						"sleep": 9, "walk": 6, "die": 5, "belly_up": 6, "eat": 10,
						"fast_swim": 5, "flee": 5, "idle_swim": 6,
						"jump": 5, "swim": 4}
	body_parts = [body_sprite]
	
	state_machine.get_node("idle").connect("animal_arrived", self, "_on_arrived")
	state_machine.get_node("seek").connect("cant_find_path", self, "_on_fail_to_find_path")
	load_animal_info()
	set_animation_frames()
	load_sounds()
	add_to_group(faction)
	Utils.activate_timer(wet_timer, animal_info.wet_meter_fill_up_time)
	update_direction(Constants.Direction.DOWN_SIDE)


func physics_process(delta: float) -> void:
	pass


func init_animal_timers() -> void:
	var animal_timers = Utils.load_resource(ANIMAL_TIMERS_PATH, "animal_timers", "scene").instance()
	add_child(animal_timers)
	idle_timer = $AnimalTimers/IdleTimer
	wet_timer = $AnimalTimers/WetTimer
	state_timer = $AnimalTimers/StateTimer
	connect_animal_timers()


func connect_animal_timers() -> void:
	idle_timer.connect("timeout", self, "_on_idle_timer_timeout")
	wet_timer.connect("timeout", self, "_on_wet_timer_timeout")


func free_animal_timers() -> void:
	var animal_timers := get_node_or_null("AnimalTimers")
	if animal_timers != null:
		animal_timers.queue_free()
		idle_timer = null
		wet_timer = null
		state_timer = null


func calculate_behaviour_total_weight():
	animal_behaviour_total_weight = 0
	animal_behaviour_total_weight += Constants.random_event_with_chance.animal_behaviour_total_weight


func select_action_to_do() -> String:
	return Constants.random_event_with_chance.random_with_chance_from_dictionary_list(animal_behaviour_list, animal_behaviour_total_weight)


func load_sounds() -> void:
	cry_sound = Utils.load_resource(animal_sound_path %animal_info.cry_sound, animal_name, "cry_sound") if animal_info.cry_sound != "" else null
	swimming_sound = Utils.load_resource(animal_swimming_sound_path %animal_info.swimming_sound, animal_name, "swimming_sound") if animal_info.swimming_sound != "" else null


#change animation frame information from animation_frames dictionary,
#use when update animation from update_direction function
func set_animation_frames():
	for _animation in animal_info.animation_frames:
		animation_frames[_animation] = animal_info.animation_frames[_animation]


#abstract function, have to describe in child class
func load_animal_info():
	pass


#load animal info from dictionary data
func load_info(_animal_info_resource: Dictionary, _animal_default_info: Dictionary):
	if animal_name == "":
		queue_free()
		return

	animal_info = _animal_default_info.duplicate()
	for _info_name in _animal_info_resource[animal_name]:
		animal_info[_info_name] = _animal_info_resource[animal_name][_info_name]
	faction = animal_info.faction
	walk_speed = animal_info.walk_speed
	run_speed = animal_info.run_speed
	current_speed = walk_speed
	wet_meter = animal_info.min_wet_meter
	animal_status_text = animal_info.status_text


func do_somethings() -> void:
	if state_machine.state.name != "idle":
		return
	if land_returning or water_returning:
		emit_signal("moving")
		return
	var _action: String = select_action_to_do()
	do_things(_action)


func _on_idle_timer_timeout():
	do_somethings()


func _on_wet_timer_timeout():
	if current_navigator_use == Constants.NavigatorType.WATER:
		if water_returning:
			set_wet_meter((animal_info.max_wet_meter + animal_info.min_wet_meter)/2)
		else:
			set_wet_meter(wet_meter + 1)
		if wet_meter < MAX_WET_METER:
			wet_timer.start()
	else:
		if land_returning:
			set_wet_meter((animal_info.max_wet_meter + animal_info.min_wet_meter)/2)
		else:
			set_wet_meter(wet_meter - 1)
		
		if wet_meter > MIN_WET_METER:
			wet_timer.start()


func do_things(_action: String):
#	print(name, ": ", _action)
	match _action:
		"run":
			start_running()
			emit_signal("moving")
		"walk":
			start_walking()
			emit_signal("moving")
		"lie_down":
			emit_signal("lying_down", "lie_down")
		"sleep":
			emit_signal("sleeping")


func start_idle_timer(_time_amount: float = animal_info.idle_time):
	idle_timer.start(_time_amount)


func _on_fail_to_find_path() -> void:
	do_other_things()


func do_other_things() -> void:
	reset_action()
	do_somethings()


func reset_action() -> void:
	set_disable_land_water_need(true)


#region: steering
#override
func seek(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.seek(velocity, global_position, target_position, current_speed * action_speed)
	move()

#override
func arrive_to(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.arrive_to(velocity, global_position, target_position, current_speed * action_speed)
	move()

#override
func stuck_avoid(target_position: Vector2):
	if global_position.distance_to(target_position) < 100 and !Utils.is_at_edge_of_map(map_manager.list_map_positions, map_manager.size, get_map_position()):
		velocity += Steering.stuck_avoid(velocity, global_position, target_position, current_speed * action_speed)
	move()

#override
func flee(target_position: Vector2):
	if global_position.distance_to(target_position) < 50:
		velocity += Steering.flee(velocity, global_position, target_position, current_speed * action_speed)
	move()

#override
func pursue(target_position: Vector2, target_velocity: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.pursue(velocity, global_position, target_position, target_velocity, current_speed * action_speed)
	move()
#endregion


func start_running() -> void:
	if running:
		return
	running = true
	current_speed = run_speed
	if velocity != Vector2.ZERO:
		play_animation("run")


func start_walking() -> void:
	if !running:
		return
	running = false
	current_speed = walk_speed
	if velocity != Vector2.ZERO:
		play_animation("walk")

#abstract
func _on_arrived():
	pass


#show food sprite
func show_food(_show: bool = true) -> void:
	if food_sprite.texture:
		food_sprite.visible = _show


#region: jump in-out water
func can_jump_into_water() -> bool:
	return animal_info.move_on_ground and animal_info.move_on_water and on_ground()


func can_jump_out_of_water() -> bool:
	return animal_info.move_on_ground and animal_info.move_on_water and on_water()


func on_ground() -> bool:
	return current_navigator_use == Constants.NavigatorType.LAND

func on_water() -> bool:
	return current_navigator_use == Constants.NavigatorType.WATER


func set_water_mask_shader(_enable: bool) -> void:
	if body_sprite.material:
		body_sprite.material.set_shader_param("enable_water_mask", _enable)


func swimming() -> void:
	current_navigator_use = Constants.NavigatorType.WATER
	shadow_sprite.visible = false
	water_sinking(SWIMMING_SINK_DEPTH)
	set_water_mask_shader(true)
	wet_timer.start()


func jumped_out_of_water() -> void:
	current_navigator_use = Constants.NavigatorType.LAND
	set_water_mask_shader(false)
	shadow_sprite.visible = true
	water_rising(SWIMMING_SINK_DEPTH)
	wet_timer.start()


#animation this animal sinking into water to _depth pixel
func water_sinking(_depth: int = 1) -> void:
	body_parts_node.position += Vector2(0, _depth)
	body_sprite.position -= Vector2(0, _depth)

	if tween.is_inside_tree():
		if body_sprite.material:
			body_sprite.material.set_shader_param("water_color_shift", Vector2(0.0, -0.02))
			Utils.start_tween(tween, body_sprite.material, "shader_param/water_color_shift", Vector2(0.0, -0.02), Vector2(0.0, 0.0), 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)

		Utils.start_tween(tween, body_sprite, "position", body_sprite.position, body_sprite.position + Vector2(0, _depth), 0.6, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	else:
		body_sprite.position = body_sprite.position + Vector2(0, _depth)


#animation this animal rising from water from _from_depth pixel
func water_rising(_from_depth: int = 1) -> void:
	body_parts_node.position -= Vector2(0, _from_depth)
	body_sprite.position += Vector2(0, _from_depth)

	if tween.is_inside_tree():
		Utils.start_tween(tween, body_sprite, "position", body_sprite.position, default_body_sprite_position, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		body_sprite.position = default_body_sprite_position

#endregion


func set_wet_meter(_new_value: int):
	wet_meter = Utils.clamp_int(_new_value, MIN_WET_METER, MAX_WET_METER)
	# print(name, ", ", current_navigator_use, ", wet meter: ", wet_meter)
	choose_action_at_current_wet()


func choose_action_at_current_wet():
	land_returning = wet_meter > animal_info.max_wet_meter
	water_returning = wet_meter < animal_info.min_wet_meter


#region: dead
#override
func die() -> void:
	if live_status == LiveStatus.DEAD:
		return
	change_status_to_dead()


func change_status_to_dead():
#	print("die")
	live_status = LiveStatus.DEAD
	size = Vector2(animal_info.dead_size.x, animal_info.dead_size.y) if body_parts_node.scale.x == 1 else Vector2(animal_info.dead_size.y, animal_info.dead_size.x)
	dead = true #when dead == true -> all state will trans to die state


#delete unuse nodes when this animal die
func delete_not_use_children_nodes():
	if Utils.node_exists(self):
		$States.queue_free()
		free_animal_timers()
		tween.queue_free()


#reset animal sprite to default (idle first frames), stop then change to dead sprite
func change_sprite_to_dead():
	play_animation("idle")
	animation_player.stop(true)
	body_sprite.texture = Utils.load_resource(animal_sprite_path %[animal_name, animal_name], animal_name, "dead_sprite")


#add this animal dead body to map info and can be interacted
func add_dead_body_to_map_info():
	map_manager.map_info.append_resource(self, Constants.ResourceType.ANIMAL_DEAD_BODY, get_map_position())
	GameManager.map_manager.map_navigator._add_build_disabled_points(size, get_map_position())


func remove_dead_body_from_map_info():
	map_manager.map_info.remove_resource(map_manager.map_info.top_item(get_map_position()), size, get_map_position())
#endregion


#region: harvest dead body
func dead_body_harvest():
	harvest_yield()
	remove_dead_body_from_map_info()
	queue_free()


func harvest_yield():
	for _item_name in animal_info.harvest_yield:
		if randf() <= animal_info.harvest_yield[_item_name].chance:
			spawn_item(_item_name)
			add_item_to_character_inventory()


#spawn yield item when this animal dead body is harvested
func spawn_item(_item_name: String):
	GameManager.resource_item_manager.get_current_resource_item(_item_name)
	GameManager.resource_item_manager.item.spawn(_item_name)


func add_item_to_character_inventory():
	var _name = GameManager.resource_item_manager.current_resource_item.item_name
	var _amount = GameManager.resource_item_manager.current_resource_item.amount
	PlayerInventory.add_item(_name, _amount)
#endregion


#override
func _on_animation_finished(_name: String):
	SignalManager.emit_signal(_name + "_finished", get_name())


func play_sound(_sound: Resource, _amplify: int = 0):
	Utils.play_sound(audio_player, _sound, _amplify)


func stop_sound():
	audio_player.stop()


func play_swimming_sound() -> void:
	play_sound(swimming_sound, animal_info.swimming_sound_amplify)


func stop_swimming_sound() -> void:
	stop_sound()
	

func update_sprite_direction(_direction: int) -> void:
	for animation_name in animation_player.get_animation_list():
		if animation_name == "RESET":
			continue
		var frame_count = animation_frames[animation_name]
		var animation: Animation = animation_player.get_animation(animation_name)
		var animation_hframe: int = 0
		for part in body_parts:
			var animation_hframe_index: int = animation.find_track("BodyParts/" + part.name + ":hframes")
			if animation_hframe_index > -1:
				animation_hframe = animation.track_get_key_value(animation_hframe_index, 0)
			var track_index = animation.find_track("BodyParts/" + part.name + ":frame")
			var frame_key_value
			if track_index > -1 and animation_hframe_index > -1:
				for i in range(frame_count):
					frame_key_value = animation.track_get_key_value(track_index, i)
					animation.track_set_key_value(
						track_index, i, animation_hframe * _direction + frame_key_value % animation_hframe
					)			


#override
func calculate_shortest_path(_from_position: Vector2, _target_position: Vector2, _target_position_top_item: MapInfoItem) -> PoolVector2Array:
	var target_tile_name: String = Utils.get_current_map_info(map_manager).get_target_tile(get_map_position(_target_position))
	var paths: PoolVector2Array = []

	if current_navigator_use == Constants.NavigatorType.LAND:
		water_target = target_tile_name in map_manager.map_info.water_walkable_tiles_name and !_target_position_top_item.is_buildable_decoraion() and !map_manager.is_battlefield
		if water_target:
			water_target_position = map_manager.map_navigator.point_to_world(_target_position_top_item.point)
			paths = map_manager.map_navigator.get_path_by_between_navigators_world_position(_from_position, _target_position, current_navigator_use, Constants.NavigatorType.WATER)

	elif current_navigator_use == Constants.NavigatorType.WATER:
		ground_target = (target_tile_name in map_manager.map_info.land_walkable_tiles_name or _target_position_top_item.is_buildable_decoraion()) and !map_manager.is_battlefield
		if ground_target:
			ground_target_position = map_manager.map_navigator.point_to_world(_target_position_top_item.point)
			paths = map_manager.map_navigator.get_path_by_between_navigators_world_position(_from_position, _target_position, current_navigator_use, Constants.NavigatorType.LAND)
	
	if paths.size() == 0:
		paths = map_manager.map_navigator.get_path_by_world_positions(_from_position, _target_position, current_navigator_use)

	if len(paths) > 0:
		paths.remove(0)

	if show_navigation_path:
		_draw_navigation_path(paths)

	return paths


#change status box's text 
func change_status_text(_status_name: String) -> void:
	if animal_status_text.empty() or !status_label or !animal_status_text.has(_status_name):
		return
	
	status_label.text = Utils.random_from_array(animal_status_text[_status_name])


func set_disable_land_water_need(_new_value: bool) -> void:
	land_water_need_disabled = _new_value

	get_tree().create_timer(DISABLE_WL_NEED_TIME).connect("timeout", self, "_on_need_timer_timeout")


func _on_need_timer_timeout() -> void:
	land_water_need_disabled = false


#region: visibility
func enable_visibility() -> void: #override
	is_visible = true
	visibility.enable = true


func visibility_function() -> void:
	if not need_to_find_smthing():
		visibility.enable = false
		return

	if not visibility.ray_cast:
		return
	var collider = visibility.ray_cast.get_collider()
	if collider:
		if collider is TileMap:
			see_tile_map(collider)


func see_tile_map(_tile_map: TileMap) -> void:
	var tileset: TileSet = _tile_map.tile_set
	var cl_local_pos: Vector2 = _tile_map.world_to_map(visibility.ray_cast.get_collision_point())
	var cl_cell_idx: int = _tile_map.get_cell(cl_local_pos.x, cl_local_pos.y)
	
	if cl_cell_idx < 0:
		return
		
	var tile_name: String = tileset.tile_get_name(cl_cell_idx)
	
	if tile_name.begins_with("earth_wa"):
		found_water_edge(cl_local_pos)


func need_to_find_tilemap() -> bool:
	return not memory.has(MEMORIES.WATER_EDGE)


func need_to_find_smthing() -> bool:
	return need_to_find_tilemap() or false #add when they need to find smthing else


func found_water_edge(_local_pos: Vector2) -> void:
	memory[MEMORIES.WATER_EDGE] = _local_pos


func refind_water_edge() -> void:
	memory.erase(MEMORIES.WATER_EDGE)
	enable_visibility()

#endregion


#region: reaction with surround objs
# abstract
func reaction_to_obj(_obj: Node2D) -> void:
	pass

#endregion
