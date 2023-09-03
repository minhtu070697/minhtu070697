extends Animals
class_name Livestocks

#const
const LIVESTOCK_TIMERS_PATH: String = "res://animals/livestocks/scenes/LivestockTimers.tscn"
enum GrowStatus { BABY, MATURE }

#vars
var livestocks_scare_sound_path: String = "res://animals/livestocks/sounds/%s_scare_sound.mp3"

var scare_timer: Timer
var inside_barn_timer: Timer
var life_timer: Timer

var inside_barn: bool = false
var fleeing: bool = false
var barn: LivestockBarnController
var barn_returning: bool = false

var life_time: int = 0
var growth_time: int = 0

var is_fed: bool = false

var scare_sound
var grow_status: int = GrowStatus.BABY

var farm_pet_nearby = null


func _ready():
	animal_type = Constants.AnimalType.LIVESTOCK
	init_livestock_timers()
	animal_behaviour_list.append(Constants.random_event_with_chance.LivestockBehaviourWithChance)
	add_to_group("livestocks")
	calculate_behaviour_total_weight()
	Utils.activate_timer(life_timer, 3600)


#region: set-up
func load_animal_info():
	load_info(GameResourcesLibrary.livestock_resource, Constants.LivestockDefaultInfo)


func calculate_behaviour_total_weight():
	.calculate_behaviour_total_weight()
	animal_behaviour_total_weight += Constants.random_event_with_chance.livestock_behaviour_total_weight


func load_sounds():
	animal_sound_path = "res://animals/livestocks/sounds/%s_cry_sound.mp3"
	.load_sounds()
	scare_sound = (
		Utils.load_resource(
			livestocks_scare_sound_path % animal_info.scare_sound, animal_name, "scare_sound"
		)
		if animal_info.scare_sound != ""
		else cry_sound
	)


func init_livestock_timers() -> void:
	var livestock_timers = Utils.load_resource(LIVESTOCK_TIMERS_PATH, "livestock_timers", "scene").instance()
	add_child(livestock_timers)
	scare_timer = $LivestockTimers/ScareTimer
	inside_barn_timer = $LivestockTimers/InsideBarnTimer
	life_timer = $LivestockTimers/LifeTimer
	connect_livestock_timers()


func connect_livestock_timers() -> void:
	scare_timer.connect("timeout", self, "_on_scare_timer_timeout")
	inside_barn_timer.connect("timeout", self, "_on_inside_barn_timer_timeout")
	life_timer.connect("timeout", self, "_on_life_timer_timeout")


func free_livestock_timers() -> void:
	var livestock_timers := get_node_or_null("LivestockTimers")
	if livestock_timers != null:
		livestock_timers.queue_free()
		scare_timer = null
		inside_barn_timer = null
		life_timer = null
#endregion


func _on_scare_timer_timeout():
	fleeing = false
	if velocity == Vector2.ZERO:
		return
	if !farm_pet_nearby:
		start_walking()
	else:
		scare()


func set_barn(_barn: LivestockBarnController):
	barn = _barn


func return_to_barn():
	barn_returning = true

	if barn.barn_navigator_type != current_navigator_use and (water_target or ground_target):
		return

	state_machine.transition_to(
		"seek", {"target_position": map_to_global_position(barn.barn_door_position)}
	)


func fleeing_to_barn():
	scare()
	return_to_barn()


func scare():
	fleeing = true
	play_scare_sound()
	start_running()
	Utils.activate_timer(scare_timer, animal_info.scare_time)


func play_scare_sound():
	if cry_sound != null:
		if Utils.random_int(1, 100) < 36:
			Utils.play_sound(audio_player, scare_sound, animal_info.cry_sound_amplify)


func start_running():
	if !running:
		running = true
		current_speed = run_speed
	if velocity == Vector2.ZERO:
		return

	if fleeing:
		play_animation("flee")
	else:
		play_animation("run")


#override
func _on_arrived():
	#this animal enter its barn when arrive
	if barn_returning and current_navigator_use == barn.barn_navigator_type:
		if close_to_barn_door(get_map_position()):
			enter_barn()


func close_to_barn_door(_map_position: Vector2) -> bool:
	var _distance: Vector2 = _map_position - barn.barn_door_position

	return (
		abs(_distance.x) < barn.barn_door_width.x
		if barn.barn_door_width.x > 0
		else (
			barn.BARN_DOOR_ZONE and abs(_distance.y) < barn.barn_door_width.y
			if barn.barn_door_width.y > 0
			else barn.BARN_DOOR_ZONE
		)
	)

#region: go in, out barn
#before enter, livestock will register with its barn
func enter_barn():
	barn_returning = false
	fleeing = false
	var _enter_barn_success = barn.enter_barn_register(self)
	if _enter_barn_success:
		go_inside_barn()


#when go inside barn, move this livestock to a faraway position, then hide it
func go_inside_barn():
	inside_barn = true
	var _map_navigator = GameManager.map_manager.map_navigator
	state_machine.set_physics_process(false)
	visible = false
	_map_navigator.set_point_disabled(
		_map_navigator.point_to_index(get_map_position()), false, current_navigator_use
	)
	global_position = Vector2(Constants.A_VERY_LARGE_NUMBER, Constants.A_VERY_LARGE_NUMBER)
	Utils.activate_timer(
		inside_barn_timer, animal_info.in_barn_time * Utils.random_percent(70, 130)
	)

	#for demo only, queue_free livestock when go inside barn
	die()
	return


func go_outside_barn(_appear_position: Vector2):
	inside_barn = false
	state_machine.set_physics_process(true)
	visible = true
	global_position = map_to_global_position(_appear_position)
	do_somethings()


#after sometimes since it go inside barn, it'll register to go outside again.
func _on_inside_barn_timer_timeout():
	var _go_out_result = barn.go_outside_barn_register(self)
	if not _go_out_result.success:
		Utils.activate_timer(
			inside_barn_timer, animal_info.in_barn_time * Utils.random_percent(70, 130)
		)
	else:
		go_outside_barn(_go_out_result.appear_position)
#endregion


#override
func do_somethings():
	if inside_barn or state_machine.state.name != "idle":
		return
	if barn_returning:
		return_to_barn()
		return
	if fleeing:
		emit_signal("moving")
		return

	.do_somethings()


#override
func do_things(_action: String):
	.do_things(_action)
	# print(name, ": ", _action)
	match _action:
		"eat":
			if current_navigator_use in animal_info.where_to_eat:
				emit_signal("eating")
			else:
				do_somethings()
		"return_to_barn":
			return_to_barn()


#override
func force_flip_h_sprite(is_left: bool):
	body_parts_node.scale.x = int(!is_left) * 2 - 1

	if is_visible:
		flip_eyes_direction()


#override
func flip_h_sprite():
	if current_direction == Constants.Direction.UP or current_direction == Constants.Direction.DOWN:
		return

	body_parts_node.scale.x = int(!(velocity.x < 0)) * 2 - 1

	if is_visible:
		flip_eyes_direction()


func _on_life_timer_timeout():
	a_day_pass()


#region: grow up
func a_day_pass():
	old()
	grow()


func grow():
	if grow_status == GrowStatus.MATURE:
		return

	growth_time += 1
	if is_fed:
		growth_time += 0.25
		is_fed = false
	if growth_time > animal_info.growth_time:
		grow_status = GrowStatus.MATURE


func old():
	life_time += 1
	if life_time > animal_info.lifespan:
		die()


func die() -> void:
	if barn:
		barn.remove_livestock(self)
	if inside_barn:
		queue_free()
	else:
		.die()
#endregion


#override
func delete_not_use_children_nodes():
	.delete_not_use_children_nodes()
	free_livestock_timers()
	$DetectRange.queue_free()


func change_sprite_to_dead():
	animal_sprite_path = "res://animals/livestocks/textures/%s/%s_growth_dead.png"
	.change_sprite_to_dead()


#override
func reset_action() -> void:
	.reset_action()
	if barn_returning:
		barn_returning = false


#region: reaction with surround objs
func reaction_to_obj(_obj: Node2D) -> void:
	if _obj is Animals:
		if _obj.animal_type == Constants.AnimalType.FARM_PET:
			reaction_to_farm_pet(_obj)


func reaction_to_farm_pet(_farm_pet: Animals) -> void:
	if _farm_pet.is_guiding:
		fleeing_to_barn()
	if _farm_pet.animal_name == "farm_dog":
		if _farm_pet.is_chasing_livestock:
			action_when_chased_by_farm_pet()


func set_farm_pet_nearby(_farm_pet_nearby):
	farm_pet_nearby = _farm_pet_nearby


func action_when_chased_by_farm_pet():
	scare()
	emit_signal("moving")
#endregion


#lam tiep o day, thiet ke reaction to objs
