extends Node2D


onready var audio_player:= $AudioStreamPlayer2D
var water_ambience_sound: AudioStream
const WATER_AMBIENCE_SOUND_PATH: String = "res://environment_sounds/sounds/env_water_ambience_sound.mp3"

var size: Vector2 = Vector2(1, 1)


func _ready() -> void:
	water_ambience_sound = Utils.load_resource(WATER_AMBIENCE_SOUND_PATH, "ambience", "water_ambience")
	Utils.play_sound(audio_player, water_ambience_sound, 8)
