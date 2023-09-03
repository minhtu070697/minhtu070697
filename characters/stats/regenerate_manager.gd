extends Node
class_name RegenerateManager


var mana_regenerate_timer : Timer
var stamina_regenerate_timer : Timer

var stats_manager
var character_stats


func _init(_stats_manager) -> void:
	stats_manager = _stats_manager
	character_stats = stats_manager.stats
	if stats_manager.owner_type != "resources":
		mana_regenerate_timer = Timer.new()
		stats_manager.add_child(mana_regenerate_timer)
		character_stats.connect("mana_changed", self, "_on_character_mana_changed")
		mana_regenerate_timer.connect("timeout", self, "_regenerate_mana")


func _on_character_health_changed():
	if character_stats.hp >= character_stats.max_hp:
		Utils.deactivate_timer(stamina_regenerate_timer)
	elif character_stats.hp <= 0:
		stats_manager.disconnect("health_changed", self, "_on_character_health_changed")
		
		if stats_manager.is_connected("mana_changed", self, "_on_character_mana_changed"):
			stats_manager.disconnect("mana_changed", self, "_on_character_mana_changed")
			mana_regenerate_timer.disconnect("timeout", self, "_regenerate_mana")
		
		stamina_regenerate_timer.disconnect("timeout", self, "_regenerate_stamina")
		Utils.deactivate_timer(stamina_regenerate_timer)
		Utils.deactivate_timer(mana_regenerate_timer)
	else:
		Utils.activate_timer(stamina_regenerate_timer, Constants.FARMER_STAMINA_RESTORE_TIME)


func _on_character_mana_changed():
	if character_stats.mana >= character_stats.max_mana or character_stats.mana <= 0:
		Utils.deactivate_timer(mana_regenerate_timer)
	else:
		Utils.activate_timer(mana_regenerate_timer, Constants.MANA_RESTORE_TIME)


func _regenerate_stamina():
	character_stats.set_hp(character_stats.hp + character_stats.max_hp * Constants.FARMER_DEFAULT_STAMINA_RESTORE_AMOUNT / 100.0)


func _regenerate_mana():
	character_stats.set_mana(character_stats.mana + character_stats.max_mana * Constants.DEFAULT_MANA_RESTORE_AMOUNT / 100.0)

