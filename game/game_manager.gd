extends Node2D

var current_scene
var current_session

var save_load_manager
var scene_manager
var audio_manager
var map_vfx_manager
var cursor_manager
var build_manager
var multiple_lands_manager
var daytime_manager
var resource_item_manager
var map_manager
var map_manager_utils: MapManagerUtils  #has position relate functions
var exp_reward_manager: ExperienceRewardManager
var env_sound_manager: EnvironmentSoundManager
var coroutine_manager: CoroutineManager
var tween_manager: TweenManager
var enemy_manager: EnemyManager
var yield_item_manager: YieldItemManager

var environment_manager: EnvironmentManager
var object_hover_manager: ObjectHoverManager
export(bool) var mute_music: bool = false
export(bool) var free_equipment: bool = false
export(bool) var show_cast_ray: bool = true
export(bool) var show_grid_build: bool = false
export(bool) var json_beautify: bool = true

const ENV_SOUND_MANAGER_PATH: String = "res://autoload/autoload_scenes/environment_sound_manager.tscn"
const ENV_MANAGER_PATH: String = "res://game/scenes/environment_manager.tscn"
const OBJ_HOVER_MANAGER: String = "res://game/scenes/ObjectHoverManager.tscn"
const EXP_REWARD_MANAGER: String = "res://game/scenes/ExpRewardManager.tscn"

var character_exist: bool = false


func _ready() -> void:
	SignalManager.connect("scene_changed", self, "_on_scene_changed")
	randomize()
	init_coroutine_manager()
	init_tween_manager()
	init_main_scene()


func _input(event):
	if is_outside_map_features() and multiple_lands_manager != null:
		multiple_lands_manager.multiple_lands_input(event)


func _physics_process(_delta):
	if cursor_manager != null:
		cursor_manager.load_cursor()


func set_map_manager(_map_manager):
	map_manager = _map_manager
	map_manager_utils = MapManagerUtils.new(map_manager)

	init_obj_hover_manager()
	init_env_manager()
	init_scene_manager()
	init_audio_manager()
	init_cursor_manager()
	init_save_load_manager(map_manager)
	init_map_vfx_manager(map_manager)
	init_resource_item_manager(map_manager)
	init_build_manager(map_manager)
	init_daytime_manager(map_manager)
	init_multiple_lands_manager()
	init_exp_reward_manager()
	init_env_sound_manager()
	init_enemy_manager()
	init_yield_item_manager()


func init_env_manager() -> void:
	if Utils.node_exists(map_manager):
		if not Utils.node_exists(environment_manager):
			environment_manager = Utils.load_resource(ENV_MANAGER_PATH, "env_manager", "scene").instance()
			add_child(environment_manager)

		environment_manager.set_map_manager(map_manager)
		environment_manager.change_environment(map_manager.environment_type)

	elif Utils.node_exists(environment_manager):
		environment_manager.queue_free()
		environment_manager = null


func is_outside_map_features():
	return (
		map_manager != null
		and map_manager.map_type == Constants.MapSceneType.FARM_MAP
		and not map_manager.is_battlefield
	)


func is_outside_map():
	return map_manager != null and map_manager.map_type == Constants.MapSceneType.FARM_MAP


func is_inside_house() -> bool:
	return (
		map_manager != null
		and (
			map_manager.map_type == Constants.MapSceneType.BASE_MAP
			or map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
		)
	)


func is_inside_mining_cave() -> bool:
	return map_manager != null and map_manager.map_type == Constants.MapSceneType.MINING_MAP


func is_battlefield() -> bool:
	return map_manager != null and map_manager.is_battlefield


func change_scene(scene_path):
	current_scene = scene_path
	get_tree().change_scene(scene_path)


func _on_scene_changed(_new_scene_path: String):
	if _new_scene_path == scene_manager.farm_path:
		environment_manager.change_environment(Constants.EnvironmentType.FARM)
	elif _new_scene_path == scene_manager.mining_cave_path:
		environment_manager.change_environment(Constants.EnvironmentType.CAVE)
	elif _new_scene_path == scene_manager.base_path:
		environment_manager.change_environment(Constants.EnvironmentType.IN_HOUSE)
	elif _new_scene_path == scene_manager.base_upgrade_path:
		environment_manager.change_environment(Constants.EnvironmentType.IN_HOUSE)


func init_scene_manager():
	if not Utils.node_exists(scene_manager):
		scene_manager = load("res://ui/scenes/SceneManager.tscn").instance()
		self.add_child(scene_manager)


func init_audio_manager():
	if not Utils.node_exists(audio_manager):
		audio_manager = load("res://sfx/scenes/AudioManager.tscn").instance()
		self.add_child(audio_manager)


func init_cursor_manager():
	cursor_manager = CursorManager.new()


func init_save_load_manager(_map_manager):
	save_load_manager = SaveLoadManager.new(self, _map_manager)


func init_map_vfx_manager(_map_manager):
	map_vfx_manager = MapVFXManager.new(self, _map_manager)


func init_resource_item_manager(_map_manager):
	resource_item_manager = ResourceItemManager.new(self, _map_manager)


func init_build_manager(_map_manager):
	build_manager = BuildManager.new(self, _map_manager, _map_manager.map_type)
	build_manager.show_grid_build = show_grid_build


func init_daytime_manager(_map_manager):
	daytime_manager = DayTimeManager.new(self)
	daytime_manager.init_nodes_from_map_manager(_map_manager)


func init_multiple_lands_manager():
	if is_outside_map_features():
		multiple_lands_manager = MultipleLandsManager.new(self)


func init_exp_reward_manager() -> void:
	if not Utils.node_exists(exp_reward_manager):
		exp_reward_manager = Utils.load_resource(EXP_REWARD_MANAGER, "exp_rw_manager", "scene").instance()
		add_child(exp_reward_manager)


func init_env_sound_manager() -> void:
	if not Utils.node_exists(env_sound_manager):
		env_sound_manager = Utils.load_resource(ENV_SOUND_MANAGER_PATH, "env_sound_manager", "scene").instance()
		add_child(env_sound_manager)


func init_obj_hover_manager() -> void:
	if not Utils.node_exists(object_hover_manager) and Utils.node_exists(map_manager):
		object_hover_manager = Utils.load_resource(OBJ_HOVER_MANAGER, "obj_hover_manager", "scene").instance()
		add_child(object_hover_manager)


func init_coroutine_manager() -> void:
	coroutine_manager = CoroutineManager.new()


func init_tween_manager() -> void:
	tween_manager = TweenManager.new()


func init_enemy_manager() -> void:
	# if is_battlefield():
	if map_manager and is_outside_map_features():
		enemy_manager = EnemyManager.new()
	elif enemy_manager != null:
		enemy_manager.queue_free()
		enemy_manager = null


func init_yield_item_manager() -> void:
	yield_item_manager = YieldItemManager.new()


#region: functions, we will move this region to better in the future.

#endregion


func init_main_scene():
	if get_tree().current_scene.name == "LoadingScene":
		var delay = 0.15
		yield(Utils.start_coroutine(delay), "completed")
		var farm_map = "res://map/scenes/MapManager.tscn"
		change_scene(farm_map)


func get_current_char_lvl() -> int:
	var current_char: FighterActor = Utils.get_current_character()
	if current_char != null:
		return current_char.stats_manager.stats.lvl

	return 1
