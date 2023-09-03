extends Node
class_name CharacterExperienceManager

var character
var character_stats
var stats_manager


func _init(_stats_manager) -> void:
	stats_manager = _stats_manager
	character = _stats_manager.host
	character_stats = stats_manager.stats


func earn_experience(_value: int):
	if character_stats.experience >= Constants.CharacterExpPerLvl[character_stats.lvl] and character_stats.lvl >= Constants.MAX_CHARACTER_LVL:
		return
		
	character_stats.experience += _value
	check_and_lvl_up_character()


func check_and_lvl_up_character():
	if character_stats.experience >= Constants.CharacterExpPerLvl[character_stats.lvl]:
		if character_stats.lvl >= Constants.MAX_CHARACTER_LVL:
			character_stats.experience = min(character_stats.experience, Constants.CharacterExpPerLvl[character_stats.lvl])
			return

		var _exceed_exp: int = int(character_stats.experience - Constants.CharacterExpPerLvl[character_stats.lvl])
		character_stats.lvl_up()
		character_stats.experience = 0
		earn_experience(_exceed_exp)
