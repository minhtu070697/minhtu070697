extends CharacterState

# Constants
const ATK_SHORT: Dictionary = {
	"light": "l",
	"heavy": "h",
} 

# Private Vars
var _max_combo: int = 1
var _current_combo: String = ""
var _combo_activated: bool = false
var _stack_combo: bool = true
var _current_atk_info: Dictionary = {}
var _combo_ready: bool = true
var _input_locked: bool = false

var equipment_manager: EquipmentManager


func _ready():
	SignalManager.connect("attack_finished", self, "_on_attack_animation_finished")
	SignalManager.connect("health_changed", self, "_on_attack_succeed")


func unhandled_input(event):
	if _input_locked:
		return
	
	if (event is InputEventKey and GameManager.is_outside_map() 
		and not GameManager.build_manager.holding_object 
		and not character.ui_manager.is_group_build_farming_visible()
		and not GameManager.save_load_manager.remove_object_mode):
		if Input.is_action_just_released("basic_attack"):
			check_and_active_combo()
		elif Input.is_action_just_released("heavy_attack"):
			check_and_active_combo("heavy")
	

func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()

	if _input_locked:
		return
	if character.get_input_direction() != Vector2.ZERO:
		character.attacking = false
		character.skill_activating = null
		character.free_attack_target()
		state_machine.transition_to("walk")


func enter(_msg := {}) -> void:
	character.set_state_label("basic_attack")
	character_stop()

	if not set_up_equipment_manager():
		state_machine.transition_to('idle')
		return
	
	update_max_combo()
	if _msg.has("atk"):
		if _msg.atk == "heavy":
			check_and_active_combo("heavy")
	else:
		check_and_active_combo()


func set_up_equipment_manager() -> bool:
	if equipment_manager == null:
		equipment_manager = character.get_equipment_manager()
		
	return equipment_manager != null


func basic_attack(atk_info: Dictionary) -> void:
	if not character.tool_equipped("basic_attack"):
		state_machine.transition_to('idle')
		return
	
	_combo_ready = false
	_input_locked = true

	var max_atk_range: int = max(FighterUtils.get_atk_hit_area(atk_info, equipment_manager).hit_range, FighterUtils.get_atk_proj_info(atk_info).proj_range)
	character.set_detect_range_radius(max_atk_range)

	show_wp_sprite()
	play_attack_animation(atk_info)


func show_wp_sprite() -> void:
	character.load_tool_sprite(character.get_tool("basic_attack"), "basic_attack")
	character.show_tool()


func change_direction_to(direction: Vector2) -> void:
	var direction_to_target = character.map_manager.map_navigator.get_direction_from_world(character.global_position, direction)
	character.update_direction(direction_to_target)
	character.check_flip_character(direction)


func find_nearest_target(atk_info: Dictionary = {}) -> FighterActor:
	return character.get_nearest_enemy(get_atk_range(atk_info))


func get_atk_range(atk_info: Dictionary = {}) -> int:
	if atk_info.has("hit_range"):
		return atk_info.hit_range
	else:
		return equipment_manager.get_weapon_hit_area().hit_range


func play_attack_animation(atk_info: Dictionary = {}):
	var _atk_speed = character.stats_manager.stats.atk_speed * get_atk_speed(atk_info)
	var anim_name: String = get_atk_anim_name(atk_info)
	if not character.animation_player.get_animation(anim_name):
		return

	var _animation_length = character.animation_player.get_animation(anim_name).get_length()
	var _animation_speed = _atk_speed
	character.play_animation(anim_name, _animation_speed)


func get_atk_anim_name(atk_info: Dictionary = {}) -> String:
	if atk_info.has("atk_animation"):
		return atk_info.atk_animation
	else:
		return equipment_manager.get_wp_default_anim()


func get_atk_speed(atk_info: Dictionary = {}) -> float:
	if atk_info.has("atk_speed"):
		return atk_info.atk_speed
	else:
		return 1.0


func exit() -> void:
	_current_combo = ""
	_combo_activated = false
	_combo_ready = true
	character.hide_tool()


func _on_attack_animation_finished(_character_name = ""):
	if character.name != _character_name:
		return
	state_machine.transition_to("idle")


func _attack_hit():
	var atk_result: Dictionary = {}
	
	atk_result = character.stats_manager.attack_library.attack(null, _current_atk_info)
	if atk_result["wp_used"]:
		character.use_equipment("weapon")

	if not _combo_activated or _stack_combo:
		ready_for_next_combo()


func _on_attack_succeed(_target_name = "", _attack_owner_name = ""):
	if _attack_owner_name == "":
		return
		
	if character.name != _attack_owner_name or !Utils.node_exists(character.attack_target):
		return
		
	if character.attack_target.name == _target_name:
		if character.attack_target.stats_manager.stats.hp <= 0:
			_on_target_die()


# region: Combo
func update_max_combo() -> void:
	var equipment_manager: EquipmentManager = character.get_equipment_manager()
	_max_combo = equipment_manager.get_weapon_max_combo() if equipment_manager != null else 0


func ready_for_next_combo() -> void:
	_combo_ready = not reach_max_combo()


func reach_max_combo() -> bool:
	return _current_combo.length() >= _max_combo


func check_and_active_combo(atk_type: String = "light") -> void:
	if not _combo_ready:
		return
	
	_current_combo += ATK_SHORT[atk_type]
	_current_atk_info = equipment_manager.get_combo_info(_current_combo)
	if _current_atk_info.empty():
		_current_atk_info = equipment_manager.get_basic_atk_info(atk_type)
	else:
		_combo_activated = true
	
	if not _current_atk_info.empty():
		basic_attack(_current_atk_info)
	
# endregion


func unlock_input() -> void:
	_input_locked = false


func _on_target_die():
	#vfx
	character.attack_target = null

