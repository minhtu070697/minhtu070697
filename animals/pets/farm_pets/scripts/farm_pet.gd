extends Animals
class_name FarmPet

#signals
signal play_around(_target_position, _action_name)

#consts
enum GrowStatus { BABY, MATURE }
const MAX_DISTANCE_WHEN_PLAY_WITH_OWNER: int = 3
const FARM_PET_BREATH_SOUND_PATH: String = "res://animals/pets/farm_pets/sounds/%s_breath_sound.mp3"

#vars
var pet_owner = null

var calling_barn: LivestockBarnController
var calling_barn_out_side_livestocks: Dictionary
var calling_barn_queue: Array = []

var is_guiding: bool = false

var life_time: int = 0
var growth_time: int = 0

var is_fed: bool = false

onready var life_timer := $LifeTimer

var breath_sound: Resource
var grow_status: int = GrowStatus.BABY

var is_playing_with_owner: bool = false

onready var status_animation_player: AnimationPlayer = get_node_or_null(
	"StatusPanel/StatusAnimationPlayer"
)


func _ready() -> void:
	animal_type = Constants.AnimalType.FARM_PET
	add_to_group("farm_pets")
	SignalManager.connect("return_to_barn_call", self, "_on_barn_call_to_return")
	life_timer.connect("timeout", self, "_on_life_timer_timeout")
	calculate_behaviour_total_weight()


func _physics_process(_delta: float) -> void:
	if calling_barn_out_side_livestocks.size() > 0 and velocity == Vector2.ZERO:
		livestocks_guiding()
	elif calling_barn_out_side_livestocks.size() == 0 and calling_barn:
		guiding_livestocks_done()


#region: set up
#override
func load_sounds():
	animal_sound_path = "res://animals/pets/farm_pets/sounds/%s_cry_sound.mp3"
	.load_sounds()
	breath_sound = (
		Utils.load_resource(
			FARM_PET_BREATH_SOUND_PATH % animal_info.breath_sound, animal_name, "breath_sound"
		)
		if animal_info.breath_sound != ""
		else null
	)


#override
func load_animal_info():
	load_info(GameResourcesLibrary.farm_pet_resource, Constants.FarmPetDefaultInfo)
#endregion


#region: guide livestock
#farm pet pick a barn from a queue that still call it,
func choose_calling_barn_from_queue():
	if calling_barn_queue.size() == 0 or calling_barn:
		return
	for i in calling_barn_queue.size():
		if !Utils.node_exists(calling_barn_queue[-(i + 1)]):
			calling_barn_queue.remove(calling_barn_queue.size() - (i + 1))
			choose_calling_barn_from_queue()
			return

		if calling_barn_queue[-(i + 1)].is_calling:
			calling_barn = calling_barn_queue.pop_back()
			calling_barn.is_calling = false
			calling_barn_out_side_livestocks = calling_barn.out_side_livestocks
			return
		else:
			calling_barn_queue.pop_back()


#active when something come near this pet
func on_something_near(_something):
	if _something is Livestocks:
		action_when_near_a_livestock(_something)


func action_when_near_a_livestock(_livestock: Livestocks):
	if is_guiding:
		_livestock.set_farm_pet_nearby(self)
		_livestock.fleeing_to_barn()


#farm pet find the farthest livestock then guide it to its barn
#farm pet do this until all of livestocks return to their barn
func livestocks_guiding():
	Utils.play_sound(audio_player, cry_sound, animal_info.cry_sound_amplify)
	is_guiding = true
	var _target_animal = find_farthest_livestock_from_barn()

	#when at edge of water, farm pet won't chase livestock but jump into - out of water then continue.
	if (
		!_target_animal
		or (
			_target_animal.current_navigator_use != current_navigator_use
			and (water_target or ground_target)
		)
	):
		return
	if _target_animal:
		#move_to_livestock
		start_running()
		move_to_target_animal(_target_animal)
		change_status_text("guide_livestock")


func move_to_target_animal(_target_animal):
	move_to_global_position(_target_animal.global_position)


func move_to_global_position(_global_position: Vector2):
	state_machine.transition_to("seek", {"target_position": _global_position})


func find_farthest_livestock_from_barn():
	if !Utils.node_exists(calling_barn):
		guiding_livestocks_done()
		return

	var _farthest_animal = null
	var _farthest_animal_distance: float = 0.0
	for _animal in calling_barn_out_side_livestocks.values():
		if !Utils.node_exists(_animal):
			continue

		var _animal_distance_to_barn_door: float = _animal.global_position.distance_to(
			GameManager.map_manager_utils.map_to_global_position(calling_barn.barn_door_position)
		)
		if _animal_distance_to_barn_door > _farthest_animal_distance:
			_farthest_animal_distance = _animal_distance_to_barn_door
			_farthest_animal = _animal
	return _farthest_animal


func _on_barn_call_to_return(_barn: LivestockBarnController):
	calling_barn_queue.append(_barn)
	choose_calling_barn_from_queue()


func guiding_livestocks_done():
	is_guiding = false
	start_walking()
	calling_barn = null
	calling_barn_out_side_livestocks = {}
	choose_calling_barn_from_queue()

#endregion


#override
func do_somethings():
	if !is_guiding:
		.do_somethings()


func _on_life_timer_timeout():
	a_day_pass()


#reggion: grow up
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
#endregion


#override
func change_status_text(_status_name: String) -> void:
	.change_status_text(_status_name)

	if status_animation_player:
		Utils.play_animation(status_animation_player, "status_text_slide_lr")


#override
func reset_action() -> void:
	.reset_action()
	if is_guiding:
		guiding_livestocks_done()


# region: pet owner
func check_pet_owner() -> Actor:
	if not Utils.node_exists(pet_owner):
		pet_owner = get_parent().get_node_or_null("Character") #test only, in realgame a pet always has pet owner at begining
		
	return pet_owner


func get_owner_map_pos() -> Vector2:
	if check_pet_owner() == null:
		return Vector2.INF
	
	return pet_owner.get_map_position()

