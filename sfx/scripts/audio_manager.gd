extends Node

var map_manager

onready var bg_music: AudioStreamPlayer = $Music
onready var main_sound = $MainSound
onready var sub_sound = $SubSound
onready var ui_sound = $UISound
onready var basic_attack_sound = $Basic_Attack_Sound
onready var skill_1_sound = $Skill_1_Sound
onready var skill_2_sound = $Skill_2_Sound
onready var skill_3_sound = $Skill_3_Sound
onready var skill_4_sound = $Skill_4_Sound

var music_path = "res://sfx/musics/%s.mp3"
var sound_path = "res://sfx/sounds/%s.mp3"

var render = load(sound_path % "render")
var character_spawn = load(sound_path % "character_spawn")
var seek = load(sound_path % "seek")
var mining = load(sound_path % "mining")
var cutting_tree = load(sound_path % "cutting_tree")
var collect = load(sound_path % "collect")
var collect_1 = load(sound_path % "collect_1")
var magnet = load(sound_path % "magnet")
var fishing_throw = load(sound_path % "fishing_throw")
var fishing_waiting = load(sound_path % "fishing_waiting")
var fishing_biting = load(sound_path % "fishing_biting")
var fishing_pull = load(sound_path % "fishing_pull")
var crafting = load(sound_path % "crafting")
var click = load(sound_path % "click")

var basic_attack = load(sound_path % "attack_hit_sound_2")
var charge_skill = load(sound_path % "charge_skill")
var fire_skill = load(sound_path % "fire_skill")
var flash_skill = load(sound_path % "flash_skill")
var ice_skill = load(sound_path % "ice_skill")
var meteor_skill = load(sound_path % "meteor_skill")
var sand_skill = load(sound_path % "sand_skill")


func _ready() -> void:
	connect_bg_music_player()


func play_music(_map_manager):
	map_manager = _map_manager
	
	if not GameManager.mute_music:
		play_bg_music()
	else:
		disconnect_bg_music_player()


func connect_bg_music_player() -> void:
	if not bg_music.is_connected("finished", self, "_on_bg_music_finished"):
		bg_music.connect("finished", self, "_on_bg_music_finished")


func disconnect_bg_music_player() -> void:
	if bg_music.is_connected("finished", self, "_on_bg_music_finished"):
		bg_music.disconnect("finished", self, "_on_bg_music_finished")


func play_main_sound(sound):
	main_sound.stream = sound
	main_sound.play()


func play_sub_sound(sound):
	Utils.play_sound(sub_sound, sound, -12.0)


func play_ui_sound(sound):
	ui_sound.stream = sound
	ui_sound.play()


func play_basic_attack_sound():
	basic_attack_sound.stream = basic_attack
	basic_attack_sound.play()


func play_skill_sound(index, sound):
	match index:
		0:
			skill_1_sound.stream = sound
			skill_1_sound.play()
		1:
			skill_2_sound.stream = sound
			skill_2_sound.play()
		2:
			skill_3_sound.stream = sound
			skill_3_sound.play()
		3:
			skill_4_sound.stream = sound
			skill_4_sound.play()


#region: bg music
func _on_bg_music_finished() -> void:
	activate_bg_music_event()


func activate_bg_music_event() -> void:
	var _event: String = Utils.random_with_chance_from_dictionary(Constants.random_event_with_chance.BGMusicWChance, Constants.random_event_with_chance.bg_music_tt_weight)
	# print(_event)
	match _event:
		"play":
			play_bg_music()
		"not_play":
			wait_for_bg_music()


func play_bg_music() -> void:
	Utils.play_sound(bg_music, get_bg_music(), -15.0)


func get_bg_music() -> Resource:
	if map_manager.is_battlefield:
		return get_battle_bg_music()
	else:
		match map_manager.map_type:
			Constants.MapSceneType.FARM_MAP:
				return get_farm_bg_music()
			Constants.MapSceneType.BASE_MAP, Constants.MapSceneType.BASE_UPGRADE_MAP:
				return get_base_bg_music()
			Constants.MapSceneType.MINING_MAP:
				return get_mining_bg_music()
			_:
				return get_farm_bg_music()


func get_farm_bg_music() -> Resource:
	if Utils.get_current_daytime() == Constants.DayTime.DAY:
		return Utils.pick_random_sound_from_collection(AudioLibrary.BG_FARM_DAY, "bg_farm_day", AudioLibrary.NUM_OF_BG_FARM_DAY)
	elif Utils.get_current_daytime() == Constants.DayTime.SUNSET:
		return Utils.pick_random_sound_from_collection(AudioLibrary.BG_FARM_SUNSET, "bg_farm_sunset", AudioLibrary.NUM_OF_BG_FARM_SUNSET)
	elif Utils.get_current_daytime() == Constants.DayTime.NIGHT:
		return Utils.pick_random_sound_from_collection(AudioLibrary.BG_FARM_DAY, "bg_farm_night", AudioLibrary.NUM_OF_BG_FARM_NIGHT)
	else:
		return Utils.pick_random_sound_from_collection(AudioLibrary.BG_FARM_DAY, "bg_farm_day", AudioLibrary.NUM_OF_BG_FARM_DAY)


func get_base_bg_music() -> Resource:
	return Utils.pick_random_sound_from_collection(AudioLibrary.BG_BASE, "bg_base", AudioLibrary.NUM_OF_BG_BASE)


func get_mining_bg_music() -> Resource:
	return Utils.pick_random_sound_from_collection(AudioLibrary.BG_MINING, "bg_mining", AudioLibrary.NUM_OF_BG_MINING)


func get_battle_bg_music() -> Resource:
	return Utils.pick_random_sound_from_collection(AudioLibrary.BG_BATTLE, "bg_battle", AudioLibrary.NUM_OF_BG_BATTLE)


func get_boss_battle_bg_music() -> Resource:
	return Utils.pick_random_sound_from_collection(AudioLibrary.BG_BOSS_BATTLE, "bg_boss_battle", AudioLibrary.NUM_OF_BG_BOSS_BATTLE)


func wait_for_bg_music() -> void:
	yield(Utils.start_coroutine(5.0), "completed")
	activate_bg_music_event()

#endregion
