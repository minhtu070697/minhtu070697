# Abstract class
extends KinematicBody2D
class_name Actor

const VISIBILTY_NODE_PATH: String = "res://areas/ActorVisibilty.tscn"

export var show_state_label = false
export var max_speed = Constants.DEFAULT_WALK_SPEED
export var show_navigation_path = false

onready var base_animation_player: AnimationPlayer = $BaseAnimationPlayer
onready var state_label: Label = get_node_or_null("StateLabel")
onready var map_manager = get_node_or_null("/root/MapManager")
onready var floating_text = $FloatingTextManager
onready var tween := $Tween
onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var body_parts_node := $BodyParts

var current_direction

# Physic vars
var velocity: Vector2 = Vector2.ZERO #total vel
var exteral_vel: Vector2 = Vector2.ZERO
var ext_vel_destroy_exp: float = 4000.0
export var mass: int = 100.0

var water_target: bool = false
var water_target_position: Vector2
var ground_target: bool = false
var ground_target_position: Vector2
var current_target: MapInfoItem

var previous_local_position: Vector2 = Vector2.INF

var stuck_detect: bool = false
var stuck_body

var animation_player: AnimationPlayer
var effect_tween: Tween
var dead = false

var inside_map_position: Vector2

var size = Vector2(1, 1)

export(Constants.Factions) var faction = Constants.Factions.NONE

var body_parts: Array
var animation_frames

var current_navigator_use: int = Constants.NavigatorType.LAND
var visibility: ActorVisibility = null
var is_visible: bool = false

onready var collision_area: Area2D = get_node_or_null("Area2D")
var react_to_daytime: bool = false setget set_daytime_reaction


func _ready():
	add_to_group("living")
	SignalManager.connect("character_arrived", self, "_on_character_arrived")
	set_up_state_label()
	animation_player = base_animation_player.duplicate()
	effect_tween = tween.duplicate()
	add_child(animation_player)
	add_child(effect_tween)
	animation_player.connect("animation_finished", self, "_on_animation_finished")
	update_inside_map_position()
	create_visibility()
	start_react_with_daytime()


func _physics_process(delta: float) -> void:
	physics_process(delta)


func physics_process(delta: float) -> void:
	check_and_move(delta)
	ext_vel_destroy(delta)


#region: state label
func set_up_state_label() -> void:
	if not show_state_label and state_label != null:
		state_label.queue_free()
		state_label = null


func set_state_label(text):
	if state_label == null:
		return

	state_label.text = text

#endregion


func play_animation(_name: String, _speed: float = 1.0, _blend: float = -1.0):
	if not _name in animation_player.get_animation_list():
		print("animation not exist!")
		return

	animation_player.stop()
	animation_player.play(_name, _blend, _speed)


func update_animation_speed(_speed: float = 1):
	animation_player.playback_speed = _speed
	tween.playback_speed = _speed


func facing_left() -> bool:
	return body_parts[0].flip_h


func force_flip_h_sprite(is_left: bool):
	for part in body_parts:
		part.flip_h = is_left

		if is_visible:
			flip_eyes_direction()


func flip_h_sprite():
	if current_direction == Constants.Direction.UP or current_direction == Constants.Direction.DOWN:
		return

	for part in body_parts:
		part.flip_h = velocity.x < 0

		if is_visible:
			flip_eyes_direction()


func check_flip_character(target_global_position):
	if current_direction == Constants.Direction.UP or current_direction == Constants.Direction.DOWN:
		return

	force_flip_h_sprite((global_position - target_global_position).x > 0)


func get_facing_direction() -> Vector2:
	var side: int = -1 if facing_left() else 1
	return Vector2(1,0).rotated(deg2rad(Constants.DirectionDegree[current_direction])) * Vector2(side, 1)


func update_direction(direction: int):
	if direction == current_direction:
		return

	current_direction = direction
	update_sprite_direction(direction)
	if is_visible:
		update_eyes_direction(direction)


func update_sprite_direction(_direction: int) -> void:
	for animation_name in animation_player.get_animation_list():
		if animation_name == "RESET":
			continue
		var frame_count = animation_frames[animation_name]
		var animation: Animation = animation_player.get_animation(animation_name)
		for part in body_parts:
			var track_index = animation.find_track("BodyParts/" + part.name + ":frame")
			if track_index > -1:
				for i in range(frame_count):
					animation.track_set_key_value(track_index, i, frame_count * _direction + i)


func update_eyes_direction(_direction: int) -> void:
	var _angle: int = Constants.DirectionDegree[_direction]

	visibility.seeing_direction = _angle * visibility.scale.x


func flip_eyes_direction() -> void:
	visibility.scale.x = int(velocity.x > 0) * 2 - 1
	update_eyes_direction(current_direction)


# region: Moving + Velocity
func stop_moving():
	velocity = Vector2.ZERO


# must call in _physic_process
func moving(delta: float, direction: Vector2) -> void:
	velocity = direction * max_speed


func get_combined_velocity() -> Vector2:
	return velocity + exteral_vel


func take_ext_force(strength: int, direction: Vector2, vel: Vector2 = Vector2.ZERO) -> void:
	var new_ext_vel: Vector2 = (direction + vel.normalized()) * strength / mass
	exteral_vel += new_ext_vel


func ext_vel_destroy(delta: float) -> void:
	if exteral_vel.x == 0:
		pass
	elif exteral_vel.x > 0:
		exteral_vel.x = max(0, exteral_vel.x - delta*ext_vel_destroy_exp*cos(deg2rad(30)))
	else:
		exteral_vel.x = min(0, exteral_vel.x + delta*ext_vel_destroy_exp*cos(deg2rad(30)))

	if exteral_vel.y == 0:
		pass
	elif exteral_vel.y > 0:
		exteral_vel.y = max(0, exteral_vel.y - delta*ext_vel_destroy_exp*sin(deg2rad(30)))
	else:
		exteral_vel.y = min(0, exteral_vel.y + delta*ext_vel_destroy_exp*sin(deg2rad(30)))


func move(v: Vector2 = get_combined_velocity()):
	if velocity != Vector2.ZERO:
		flip_h_sprite()
	move_and_slide(v)


func check_and_move(delta) -> void:
	if get_combined_velocity() == Vector2.ZERO:
		return

	if movable(delta, get_combined_velocity()):
		move()
	else:
		slide_at_disable_tile_edge(delta)


func movable(delta, v: Vector2) -> bool:
	var new_pos: Vector2 = global_position + v*delta
	var new_map_pos: Vector2 = get_map_position(new_pos)
	if GameManager.map_manager:
		var mnavigator = GameManager.map_manager.map_navigator
		return new_map_pos == get_map_position() or not mnavigator.is_point_disabled(mnavigator.point_to_index(new_map_pos))
	else:
		return false


func slide_at_disable_tile_edge(delta) -> void:
	var slide_vectors: Dictionary = Utils.get_slide_velocity_vectors(get_combined_velocity())
	for v in slide_vectors.values():
		if movable(delta, v):
			move(v)
			return


func seek(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.seek(
			velocity, global_position, target_position, Constants.DEFAULT_WALK_SPEED
		)


func arrive_to(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.arrive_to(
			velocity, global_position, target_position, Constants.DEFAULT_WALK_SPEED
		)


func stuck_avoid(target_position: Vector2):
	if (
		global_position.distance_to(target_position) < 100
		and !Utils.is_at_edge_of_map(
			map_manager.list_map_positions, map_manager.size, get_map_position()
		)
	):
		velocity += Steering.stuck_avoid(
			velocity, global_position, target_position, Constants.DEFAULT_WALK_SPEED
		)


func flee(target_position: Vector2):
	if global_position.distance_to(target_position) < 50:
		velocity += Steering.flee(
			velocity, global_position, target_position, Constants.DEFAULT_WALK_SPEED
		)


func pursue(target_position: Vector2, target_velocity: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.pursue(
			velocity,
			global_position,
			target_position,
			target_velocity,
			Constants.DEFAULT_WALK_SPEED
		)
# endregion

func get_path_to_target(target_position: Vector2):
	return get_path_from_position_to_target(global_position, target_position)


func get_path_from_position_to_target(
	_from_position: Vector2, _target_position: Vector2
) -> PoolVector2Array:
	var map_info = Utils.get_current_map_info(map_manager)
	var top_item = map_info.top_item(map_manager.map_navigator.world_to_point(_target_position))

	#return empty if target_position is out of map size
	if top_item == null:
		return PoolVector2Array()

	#get target resource
	if top_item.is_resource():
		set_current_target(top_item)
	else:
		free_current_target()

	#cal shortest paths
	return calculate_shortest_path(_from_position, _target_position, top_item)


func set_current_target(_map_info_item: MapInfoItem) -> void:
	current_target = _map_info_item


func free_current_target() -> void:
	current_target = null


#cal shortest paths from position to position (global - global)
func calculate_shortest_path(
	_from_position: Vector2, _target_position: Vector2, _target_position_top_item: MapInfoItem
) -> PoolVector2Array:
	var paths: PoolVector2Array = []

	if current_navigator_use == Constants.NavigatorType.LAND:
		water_target = (
			_target_position_top_item.name in map_manager.map_info.water_walkable_tiles_name
			and !map_manager.is_battlefield
		)
		if water_target:
			water_target_position = map_manager.map_navigator.point_to_world(
				_target_position_top_item.point
			)
			paths = map_manager.map_navigator.get_path_by_between_navigators_world_position(
				_from_position,
				_target_position,
				current_navigator_use,
				Constants.NavigatorType.WATER
			)

	elif current_navigator_use == Constants.NavigatorType.WATER:
		ground_target = (
			_target_position_top_item.name in map_manager.map_info.land_walkable_tiles_name
			and !map_manager.is_battlefield
		)
		if ground_target:
			ground_target_position = map_manager.map_navigator.point_to_world(
				_target_position_top_item.point
			)
			paths = map_manager.map_navigator.get_path_by_between_navigators_world_position(
				_from_position,
				_target_position,
				current_navigator_use,
				Constants.NavigatorType.LAND
			)

	if paths.size() == 0:
		paths = map_manager.map_navigator.get_path_by_world_positions(
			_from_position, _target_position, current_navigator_use
		)

	if len(paths) > 0:
		paths.remove(0)

	if show_navigation_path:
		_draw_navigation_path(paths)

	return paths


func _on_character_arrived(_name):
	if _name == name:
		_delete_navigation_path()


func _on_animation_finished(anim_name: String):
	SignalManager.emit_signal(anim_name + "_finished", get_name())
	Utils.on_resource_animation_finished(self, anim_name)


func _delete_navigation_path():
	var existing = get_node_or_null("/root/character-navigation")
	if existing != null:
		existing.free()


func _draw_navigation_path(paths):
	_delete_navigation_path()
	var line2d = Line2D.new()
	line2d.name = "character-navigation"
	line2d.width = 2
	for path in paths:
		line2d.add_point(path)
	get_tree().root.add_child(line2d)


func get_map_position(_position = position) -> Vector2:
	return (
		map_manager.map_navigator.world_to_point(_position)
		if map_manager and map_manager.map_navigator
		else Vector2(1, 1)
	)


func map_to_global_position(_map_position: Vector2) -> Vector2:
	return map_manager.map_navigator.point_to_world(_map_position)


func distance_to_target_on_map(_target_position: Vector2) -> Vector2:
	return _target_position - get_map_position()


func direction_to_target_on_map(_target_position: Vector2) -> Vector2:
	return distance_to_target_on_map(_target_position).normalized()


func distance_to_target(_target_position: Vector2) -> Vector2:
	return _target_position - global_position


func direction_to_target(_target_position: Vector2) -> Vector2:
	return distance_to_target(_target_position).normalized()


func position_out_side_of_map(_global_position: Vector2) -> bool:
	var _map_position = get_map_position(_global_position)
	return Utils.is_outside_of_map(map_manager.list_map_positions, map_manager.size, _map_position)


#pull this actor return to map area if
func convert_out_side_to_map(_global_position: Vector2) -> Vector2:
	if position_out_side_of_map(_global_position):
		var _map_position: Vector2 = get_map_position(_global_position)
		if map_manager.map_type == Constants.MapSceneType.FARM_MAP:
			var xrange: Vector2 = Utils.cal_xrange(inside_map_position, map_manager.size)
			var yrange: Vector2 = Utils.cal_yrange(inside_map_position, map_manager.size)
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		else:
			var xrange: Vector2 = map_manager.xrange
			var yrange: Vector2 = map_manager.yrange
			_map_position.x = Utils.clamp_int(_map_position.x, xrange.x, xrange.y - 1)
			_map_position.y = Utils.clamp_int(_map_position.y, yrange.x, yrange.y - 1)
		return map_to_global_position(_map_position)
	else:
		return _global_position


func check_and_fix_position(_global_position: Vector2) -> Vector2:
	var _teleport_position = convert_out_side_to_map(_global_position)
	var _paths = get_path_to_target(_teleport_position)
	if _paths.size() > 0:
		_teleport_position = _paths[-1]
	return _teleport_position


func play_footstep_sound() -> void:
	Utils.play_sound(
		audio_player,
		Utils.pick_random_sound_from_collection(
			AudioLibrary.FOOTSTEP_ON_GRASS_SOUNDS,
			"footstep_sound",
			AudioLibrary.NUMBER_OF_FOOTSTEP_SOUND
		)
	)


func update_inside_map_position() -> void:
	inside_map_position = Utils.get_current_map_position(
		map_manager.list_map_positions, map_manager.size, get_map_position()
	)


#region: visibility
func create_visibility(_create: bool = true) -> void:
	visibility = Utils.load_resource(VISIBILTY_NODE_PATH, "actor_visibility", "scene").instance()
	add_child(visibility)

	if visibility:
		enable_visibility()


func enable_visibility() -> void: #abstract
	pass


func visibility_function() -> void: #abstract
	pass

#endregion


#region: collision area
func get_overlapping_objs() -> Array:
	var list: Array = []
	if collision_area == null:
		return []
	
	# print(name, " overlap with: ", collision_area.get_overlapping_areas())
	for area in collision_area.get_overlapping_areas():
		# print(name, " overlap with: ", area.owner.name)
		if area.owner is Node2D:
			list.append(area.owner)
	
	# print(name, " return : ", list)
	return list

#endregion


#region: Nogias YSort
func update_sort_position(_wait_a_bit: bool = true) -> void:
	if map_manager == null:
		return
	
	map_manager.ysort.moving_col_sort(collision_area, self, _wait_a_bit)

#endregion


# region: death
# abstract
func die() -> void:
	pass
# endregion


# region: yield item
func yield_item(_name: String, _appear_position: Vector2 = global_position) -> void:
	GameManager.yield_item_manager.enemy_yield_item(_name, _appear_position)
# endregion


# region: Day-Night reaction
func connect_datetime_signals() -> void:
	if not SignalManager.is_connected("day", self, "_on_day_transition"):
		SignalManager.connect("day", self, "_on_day_transition")
		SignalManager.connect("sunset", self, "_on_sunset_transition")
		SignalManager.connect("night", self, "_on_night_transition")
		SignalManager.connect("dawn", self, "_on_dawn_transition")


func disconnect_datetime_signals() -> void:
	if SignalManager.is_connected("day", self, "_on_day_transition"):
		SignalManager.disconnect("day", self, "_on_day_transition")
		SignalManager.disconnect("sunset", self, "_on_sunset_transition")
		SignalManager.disconnect("night", self, "_on_night_transition")
		SignalManager.disconnect("dawn", self, "_on_dawn_transition")


func set_daytime_reaction(_react: bool) -> void:
	if react_to_daytime == _react:
		return
	
	react_to_daytime = _react
	if react_to_daytime:
		start_react_with_daytime()
	else:
		stop_react_with_daytime()


func start_react_with_daytime() -> void:
	connect_datetime_signals()


func stop_react_with_daytime() -> void:
	disconnect_datetime_signals()


# abstract
func _on_day_transition() -> void:
	pass


# abstract
func _on_sunset_transition() -> void:
	pass


# abstract
func _on_night_transition() -> void:
	pass


# abstract
func _on_dawn_transition() -> void:
	pass

# endregion

