extends Node

onready var hp_progress = $HPBar
onready var mp_progress = $MPBar
onready var exp_progress = $EXPBar
onready var hp_label = $HPLabel
onready var mp_label = $MPLabel
onready var exp_label = $EXPLabel
onready var lvl_label = $LevelLabel
onready var timer_label = $TimerLabel
onready var ui_manager = find_parent("ui")

var stats_manager
var max_hp: int
var max_mp: int
var cur_hp: int
var cur_mp: int
var cur_exp: int
var max_exp: int


func _ready() -> void:
	yield(ui_manager.get_parent(), "ready")
	stats_manager = ui_manager.character.stats_manager
	set_hp()
	set_mp()
	set_exp()
	stats_manager.stats.connect("exp_changed", self, "_on_exp_changed")
	stats_manager.stats.connect("mana_changed", self, "_on_mana_changed")
	stats_manager.stats.connect("health_changed", self, "_on_health_changed")



# HP
func set_hp():
	max_hp = ui_manager.character.stats_manager.stats.max_hp
	cur_hp = ui_manager.character.stats_manager.stats.hp
	
	hp_progress.max_value = round(max_hp)
	hp_progress.value = round(cur_hp)
	
	set_hp_label()


func set_hp_label():
	hp_label.text = String(round(cur_hp)) + "/" + String(round(max_hp))
	lvl_label.text = "Lvl: " + Utils.to_text(ui_manager.character.stats_manager.stats.lvl)


# MP
func set_mp():
	# checking:
	max_mp = ui_manager.character.stats_manager.stats.max_mana
	cur_mp = ui_manager.character.stats_manager.stats.mana
	
	mp_progress.max_value = round(max_mp)
	mp_progress.value = round(cur_mp)
	
	set_mp_label()


func set_mp_label():
	mp_label.text = String(round(cur_mp)) + "/" + String(round(max_mp))


#Exp
func set_exp():
	max_exp = Constants.CharacterExpPerLvl[ui_manager.character.stats_manager.stats.lvl]
	cur_exp = ui_manager.character.stats_manager.stats.experience
	
	exp_progress.max_value = round(max_exp)
	exp_progress.value = round(cur_exp)
	set_exp_label()


func set_exp_label():
	exp_label.text = String(round(cur_exp)) + "/" + String(round(max_exp))


func _on_exp_changed():
	set_exp()


func _on_mana_changed():
	set_mp()


func _on_health_changed():
	set_hp()
