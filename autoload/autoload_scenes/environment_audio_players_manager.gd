extends Node


onready var free_audio_players: Dictionary
var playing_sound_owner: Dictionary
var playing_audio_player: Dictionary


func _ready() -> void:
	for _audio_player in get_children():
		free_audio_players[_audio_player.name] = _audio_player
		_audio_player.connect("finished", self, "_on_audio_player_finished", [_audio_player])
	
	SignalManager.connect("scene_changed", self, "_on_scene_changed")



# This function will automatically find a free audio player, play sound and return that player, if all players are busy, return null
func play_environment_sound(_object, _sound: Resource, _sound_amplify: int = 0, _amplify_random: bool = false) -> AudioStreamPlayer2D:
	if object_is_playing_this_sound(_object, _sound.get_name()):
		return null
	
	if _amplify_random:
		_sound_amplify += Utils.random_int(-7, 8)
	var _free_audio_player: AudioStreamPlayer2D = find_free_audio_player()
	# print(_free_audio_player)
	# print(_object.name, "playing sound: ", _sound.get_name(), ", is_playing: ", object_is_playing_this_sound(_object, _sound.resource_name))
	if !_free_audio_player:
#		print("all env audio players are busy")
		return null
	
	play_sound(_object, _free_audio_player, _sound, _sound_amplify)
	return _free_audio_player


# Check if a node is requesting same playing sound.
func object_is_playing_this_sound(_object, _audio_name: String) -> bool:
	return playing_sound_owner.has(_object.name) and playing_sound_owner[_object.name].has(_audio_name)


func find_free_audio_player() -> AudioStreamPlayer2D:
	for _audio_player in free_audio_players.values():
		return _audio_player
	
	return null


func _on_audio_player_finished(_audio_player: AudioStreamPlayer2D):
	add_audio_player_to_free_list(_audio_player)
	remove_sound_and_audio_player_from_playing_list(_audio_player.name)


func add_audio_player_to_free_list(_audio_player: AudioStreamPlayer2D):
	free_audio_players[_audio_player.name] = _audio_player


func remove_sound_and_audio_player_from_playing_list(_audio_player_name: String) -> void:
	remove_sound_with_object_from_playing_list(playing_audio_player[_audio_player_name][1], playing_audio_player[_audio_player_name][0])
	remove_audio_player_from_playing_list(_audio_player_name)


func remove_sound_with_object_from_playing_list(_sound_name: String, _sound_owner_name: String):
	if playing_sound_owner.has(_sound_owner_name):
		playing_sound_owner[_sound_owner_name].erase(_sound_name)
		if playing_sound_owner[_sound_owner_name].empty():
			playing_sound_owner.erase(_sound_owner_name)


func remove_audio_player_from_playing_list(_audio_player_name: String):
	playing_audio_player.erase(_audio_player_name)


func play_sound(_object, _audio_player: AudioStreamPlayer2D, _sound: Resource, _sound_amplify: int = 1):
	Utils.play_sound(_audio_player, _sound, _sound_amplify)
	free_audio_players.erase(_audio_player.name)
	register_sound_and_audio_player_to_playing_list(_audio_player.name, _object.name, _sound.get_name())


func add_audio_player_to_playing_list(_audio_player_name: String, _object_name: String, _sound_name: String):
	playing_audio_player[_audio_player_name] = [_object_name, _sound_name]


func add_playing_sound_with_object_to_list(_object_name: String, _sound_name: String):
	if !playing_sound_owner.has(_object_name):
		playing_sound_owner[_object_name] = {}
	playing_sound_owner[_object_name][_sound_name] = 1


func register_sound_and_audio_player_to_playing_list(_audio_player_name: String, _object_name: String, _sound_name: String):
	add_audio_player_to_playing_list(_audio_player_name, _object_name, _sound_name)
	add_playing_sound_with_object_to_list(_object_name, _sound_name)


func _on_scene_changed(_scene_path) -> void:
	for _audio_player in get_children():
		if _audio_player.playing:
			_audio_player.stop()
