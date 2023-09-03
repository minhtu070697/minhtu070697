extends Node
class_name EnvironmentManager


var game_manager
var map_manager

onready var environment_event_manager: EnvironmentEventManager = $EnvironmentEventManager

var current_environment: int = Constants.EnvironmentType.FARM

func _ready() -> void:
	game_manager = owner


func set_map_manager(_map_manager) -> void:
	map_manager = _map_manager
	environment_event_manager.set_map_manager(map_manager)


func change_environment(_new_environment: int) -> void:
	current_environment = _new_environment
	environment_event_manager.change_environment()

func current_environment_is_farm() -> bool:
	return current_environment == Constants.EnvironmentType.FARM

func current_environment_is_cave() -> bool:
	return current_environment == Constants.EnvironmentType.CAVE

func current_environment_is_in_house() -> bool:
	return current_environment == Constants.EnvironmentType.IN_HOUSE
