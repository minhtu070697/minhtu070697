extends FarmPet
class_name FarmDogs

var is_chasing_livestock: bool = false
var dog_play_behaviour_total_weight: int = 0


func _ready() -> void:
	current_navigator_use = Constants.NavigatorType.LAND
	animal_behaviour_list.append(Constants.random_event_with_chance.FarmDogBehaviourWithChance)
	calculate_behaviour_total_weight()
	calculate_play_behaviour_total_weight()


#region: set up
#override
func calculate_behaviour_total_weight():
	.calculate_behaviour_total_weight()
	animal_behaviour_total_weight += Constants.random_event_with_chance.farm_dog_behaviour_total_weight


func calculate_play_behaviour_total_weight():
	dog_play_behaviour_total_weight = Constants.random_event_with_chance.farm_dog_play_behaviour_total_weight
#endregion


func play_breath_sound():
	play_sound(breath_sound, animal_info.breath_sound_amplify)


#override
func do_things(_action: String):
	.do_things(_action)
	match _action:
		"chase_livestock":
			chase_livestock()
		"move_to_owner":
			move_to_owner()
		"run_around":
			run_around()
		"run_around_owner":
			run_around_owner()
		"belly_up":
			belly_up()


func belly_up():
	emit_signal("lying_down", "belly_up")


func run_around_owner():
	action_speed = 1.6
	emit_signal("play_around", Vector2.ZERO, "run_around_owner")


func run_around():
	action_speed = 1.3
	emit_signal("play_around", run_around_start_position(), "run_around")


#find start position to begin running around owner
func run_around_start_position() -> Vector2:
	var _target_position: Vector2 = get_map_position() + ((get_owner_map_pos() - get_map_position()).rotated(deg2rad((Utils.random_int(0,1)*2 - 1 * 90)))).normalized()
	return _target_position


#pick a random livestock and chase it
func chase_livestock():
	var _livestock_in_map: Array = get_tree().get_nodes_in_group("livestocks")
	if _livestock_in_map.size() < 1:
		do_somethings()
		return
	action_speed = 1.3
	is_chasing_livestock = true
	var _lucky_livestock = Utils.random_from_array(_livestock_in_map)
	start_running()
	change_status_text("chase_livestock")
	move_to_target_animal(_lucky_livestock)


#come to owner then play with him/her
func move_to_owner():
	if !current_navigator_use in animal_info.where_to_play:
		do_somethings()
		return

	if check_pet_owner() == null:
		return
	
	is_playing_with_owner = true
	start_running()
	action_speed = 1.3
	move_to_global_position(map_to_global_position(pet_owner.get_map_position() + Utils.facing_vector(pet_owner.current_direction, pet_owner.body_parts[0].flip_h) * Utils.random_int(1, MAX_DISTANCE_WHEN_PLAY_WITH_OWNER - 1)))


func too_far_owner_while_playing() -> bool:
	return Utils.out_of_range(get_map_position(), pet_owner.get_map_position(), Vector2(MAX_DISTANCE_WHEN_PLAY_WITH_OWNER, MAX_DISTANCE_WHEN_PLAY_WITH_OWNER))


#override
func action_when_near_a_livestock(_livestock):
	.action_when_near_a_livestock(_livestock)
	if is_chasing_livestock:
		Utils.play_sound(audio_player, cry_sound, animal_info.cry_sound_amplify)
		_livestock.set_farm_pet_nearby(self)
		_livestock.action_when_chased_by_farm_pet()


func select_play_action() -> String:
	return Constants.random_event_with_chance.random_with_chance_from_dictionary(Constants.random_event_with_chance.FarmDogPlayBehaviourWithChance, dog_play_behaviour_total_weight)


#override
#act depend on action come before
func _on_arrived():
	if is_chasing_livestock:
		is_chasing_livestock = false
		if randf() < 0.6:
			chase_livestock()
		return
	
	if is_playing_with_owner:
		is_playing_with_owner = false
		play_with_owner()


func play_with_owner():
	if check_pet_owner() == null:
		return
	
	check_flip_character(pet_owner.global_position)
	if too_far_owner_while_playing():
		change_status_text("sad")
		return

	var _action: String = select_play_action()
	do_things(_action)
	change_status_text("play_with_owner")
	if randf() < 0.8 and !too_far_owner_while_playing():
		is_playing_with_owner = true
