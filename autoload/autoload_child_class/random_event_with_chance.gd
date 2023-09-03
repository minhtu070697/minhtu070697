extends Node
class_name RandomEventWithChance

# animal behaviour
const AnimalBehaviourWithChance: Dictionary = {
	"walk": 65,
	"run": 35,
	"lie_down": 20,
	"sleep": 20
}
var animal_behaviour_total_weight: int


# livestock behaviour, livestock behaviour is extended from animal behaviour
const LivestockBehaviourWithChance: Dictionary = {
	"eat": 35,
	"return_to_barn": 5
}
var livestock_behaviour_total_weight: int


# farm dog behaviour, farm dog behaviour is extended from animal behaviour
const FarmDogBehaviourWithChance: Dictionary = {
#	"eat": 35,
	"chase_livestock": 30,
	"move_to_owner": 40,
}
var farm_dog_behaviour_total_weight: int

# farm dog play behaviour
const FarmDogPlayBehaviourWithChance: Dictionary = {
	"lie_down": 20,
	"run_around": 20,
	"run_around_owner": 20,
	"move_to_owner": 20,
	"belly_up": 20
}
var farm_dog_play_behaviour_total_weight: int

# tree event
const TreeEventListWithChance: Dictionary = {
	"bird_sing": 50,
	"bird_fly_away": 15
}
var tree_event_total_weight: int = 0

const TreeNightEventListWithChance: Dictionary = {
	"spawn_fireflies": 10,
}
var tree_night_event_total_weight: int = 0


# night grass insects
const InsectsSoundsWChance: Dictionary = {
	"insects_sound": 50,
	"insects_sleep": 15
}
var insects_sounds_tt_weight: int = 0

# bg music events
const BGMusicWChance: Dictionary = {
	"play": 50,
	"not_play": 300
}
var bg_music_tt_weight: int = 0


func _init() -> void:
	cal_animal_behaviour_total_weight()
	cal_livestock_behaviour_total_weight()
	cal_farm_dog_behaviour_total_weight()
	cal_farm_dog_play_behaviour_total_weight()
	cal_tree_event_total_weight()
	cal_tree_night_event_total_weight()
	cal_insects_sounds_tt_weight()
	cal_bg_music_tt_weight()


#calculate total weight
func cal_animal_behaviour_total_weight() -> void:
	animal_behaviour_total_weight = calculate_total_weight_from_dictionary(AnimalBehaviourWithChance)

func cal_livestock_behaviour_total_weight() -> void:
	livestock_behaviour_total_weight = calculate_total_weight_from_dictionary(LivestockBehaviourWithChance)

func cal_farm_dog_behaviour_total_weight() -> void:
	farm_dog_behaviour_total_weight = calculate_total_weight_from_dictionary(FarmDogBehaviourWithChance)

func cal_farm_dog_play_behaviour_total_weight() -> void:
	farm_dog_play_behaviour_total_weight = calculate_total_weight_from_dictionary(FarmDogPlayBehaviourWithChance)

func cal_tree_event_total_weight() -> void:
	tree_event_total_weight = calculate_total_weight_from_dictionary(TreeEventListWithChance)

func cal_tree_night_event_total_weight() -> void:
	tree_night_event_total_weight = calculate_total_weight_from_dictionary(TreeNightEventListWithChance)

func cal_insects_sounds_tt_weight() -> void:
	insects_sounds_tt_weight = calculate_total_weight_from_dictionary(InsectsSoundsWChance)

func cal_bg_music_tt_weight() -> void:
	bg_music_tt_weight = calculate_total_weight_from_dictionary(BGMusicWChance)


#functions
func random_with_chance_from_dictionary_list(_dict_list: Array, _total_weight: int = 0, _debug_msg: String = "") -> String:
	if _total_weight <= 0:
		_total_weight = calculate_total_weight_from_dictionary_list(_dict_list)
	var _rand_number = Utils.random_int(0, _total_weight)
#	print(_debug_msg, " ", _rand_number, ": ", _total_weight)
	for _dictionary in _dict_list:
		for _action in _dictionary:
			if _rand_number <= _dictionary[_action]:
				return _action
			_rand_number -= _dictionary[_action]
	return ""


func random_with_chance_from_dictionary(_dict: Dictionary, _total_weight: int = 0) -> String:
	return random_with_chance_from_dictionary_list([_dict], _total_weight)


func calculate_total_weight_from_dictionary_list(_dict_list: Array) -> int:
	var _total_weight: int = 0
	for _dictionary in _dict_list:
		for _chance in _dictionary.values():
			_total_weight += _chance
	return _total_weight


func calculate_total_weight_from_dictionary(_dict: Dictionary) -> int:
	return calculate_total_weight_from_dictionary_list([_dict])
