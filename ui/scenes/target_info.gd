extends Node
class_name TargetInfo

onready var hp_progress: TextureProgress = $HPBar
onready var hp_label: Label = $HPLabel
onready var name_label: Label = $HBoxContainer/NameLabel
onready var level_label: Label = $HBoxContainer/LevelLabel
onready var ui_manager = find_parent("ui")
onready var tween: Tween = $Tween

var target_highlight

var character
var max_hp: int
var cur_hp: int

var host_target = null


func _ready() -> void:
	set_physics_process(false)
	SignalManager.connect("health_changed", self, "_on_target_health_changed")
	character = ui_manager.get_parent()
	if character:
		connect_character_signals()
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	if Utils.node_exists(target_highlight) and target_highlight.visible and Utils.node_exists(host_target):
		target_highlight.global_position = host_target.global_position


# Connect character signals
func connect_character_signals() -> void:
	if not character.is_connected("enemy_targeted", self, "_on_enemy_targeted"):
		character.connect("enemy_targeted", self, "_on_enemy_targeted")
		character.connect("atk_target_freed", self, "_on_atk_target_freed")


func disconnect_character_signals() -> void:
	if character.is_connected("enemy_targeted", self, "_on_enemy_targeted"):
		character.disconnect("enemy_targeted", self, "_on_enemy_targeted")
		character.disconnect("atk_target_freed", self, "_on_atk_target_freed")


# Set HP text + HP Bar progression
func set_hp() -> void:
	if !check_host_target():
		return
		
	max_hp = host_target.stats_manager.stats.max_hp
	cur_hp = host_target.stats_manager.stats.hp
	
	hp_progress.max_value = round(max_hp)
	hp_progress.value = round(cur_hp)

	set_hp_label()
	if cur_hp <= 0:
		_set_visible(false)
		free_target()


func set_hp_label() -> void:
	hp_label.text = String(round(cur_hp)) + "/" + String(round(max_hp))


func check_host_target() -> bool:
	if Utils.node_exists(host_target):
		return true
			
	_set_visible(false)
	free_target()
	return false


func set_target_name() -> void:
	if host_target is Enemy:
		name_label.text = host_target.monster_info.monster_name.capitalize()


func set_target_lvl() -> void:
	level_label.text = "Lvl. " + str(host_target.stats_manager.stats.lvl)


func _on_enemy_targeted(target, target_pos: Vector2) -> void:
	if not Utils.node_exists(target_highlight) and character.map_manager.get("target_highlight"):
		target_highlight = character.map_manager.target_highlight
	if target == host_target or target == ui_manager.character:
		return
	_set_visible()
	update_target_info(target)


func _on_atk_target_freed() -> void:
	_set_visible(false)
	free_target()


func update_target_info(target) -> void:
	host_target = target
	set_target_lvl()
	set_target_name()
	set_hp()


func _on_target_health_changed(_name, _atk_owner_name):
	if _name == character.name or !check_host_target() or _name != host_target.name:
		return
	
	set_hp()


func _set_visible(_visible: bool = true) -> void:
	set_deferred("visible", _visible)
	if Utils.node_exists(target_highlight): target_highlight.set_deferred("visible", _visible)


func free_target() -> void:
	host_target = null
