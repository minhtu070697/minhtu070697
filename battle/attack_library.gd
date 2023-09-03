extends Node
class_name AttackLibrary

#var
var stats_manager
var host
var on_going_skill_list: Array = []
var equipment_manager : EquipmentManager
var host_equipment : Dictionary

#dictionary of attacks
var attack_list = {
	Constants.AttackList.BASIC_ATTACK : funcref(self, "basic_attack"),
	Constants.AttackList.BASIC_CASTING: funcref(self, "basic_casting"),
	Constants.AttackList.TELEPORT: funcref(self, "teleport"),
	Constants.AttackList.JUMP_ATTACK: funcref(self, "jump_attack"),
	Constants.AttackList.DASH_ATTACK: funcref(self, "dash_attack"),
	Constants.AttackList.BASIC_ACTION: funcref(self, "basic_action"),
	Constants.AttackList.BASIC_BUFF: funcref(self, "basic_buff")
}


func _init(_stats_manager):
	stats_manager = _stats_manager
	equipment_manager = stats_manager.equipment_manager
	host_equipment = equipment_manager.equipment
	host = stats_manager.host
	SignalManager.connect("melee_hit", self, "_on_melee_hit")
	SignalManager.connect("spawn_proj", self, "_on_spawn_proj")
	SignalManager.connect("teleport", self, "_on_teleport")


# region: Basic attack or combo
func attack(_target = null, atk_info: Dictionary = {}) -> Dictionary:
	var atk_result: Dictionary = {
		"hit": false,
		"hit_enemies": [],
		"wp_used": false,
	}
	
	if not host_equipment.has("weapon"):
		return atk_result

	if _target:
		atk_result = melee_attack(_target)
	else:
		var hit_area: Dictionary = FighterUtils.get_atk_hit_area(atk_info, equipment_manager)
		var hit_range: int = hit_area.hit_range
		var hit_arc: int = hit_area.hit_arc
		var hit_enemies: Array = host.check_hit_targets(hit_arc, hit_range)

		if atk_info.has("shake_camera"):
			SignalManager.emit_signal("camera_shake", 0.1, 15.0, 5.0)
		
		for e in hit_enemies:
			dmg_target(e, atk_info)
		
		atk_result = {
			"hit": not hit_enemies.empty(),
			"hit_enemies": hit_enemies,
			"wp_used": not hit_enemies.empty(),
		}
	
	var proj_info: Dictionary = FighterUtils.get_atk_proj_info(atk_info)
	if not proj_info.empty() and proj_info.proj_name != "":
		var proj_target = get_proj_target(proj_info)
		if proj_target:
			_target = proj_target

		spawn_projectiles(_target, proj_info.proj_name, proj_info.proj_num, proj_info.proj_dmg, proj_info.proj_speed, proj_info.proj_fxs)
		atk_result["wp_used"] = true

	return atk_result


func get_proj_target(proj_info: Dictionary) -> FighterActor:
	var targets: Array = host.check_hit_targets(proj_info.proj_arc, proj_info.proj_range)
	return Utils.get_nearest_obj(targets, host.global_position)

# endregion


func farming(_target, _farming_tool: String, _attack_name = Constants.AttackList.BASIC_ACTION):
	if host_equipment.has(_farming_tool): 
		attack_list[_attack_name].call_func(_target, _farming_tool)


#call skill with name in argument
func skill(_skill: Skill, _target = null, _attack_name: int = Constants.AttackList.BASIC_ATTACK, _is_active: bool = true):
	if _skill.skill_buff.size() > 0:
		stats_manager.buff_manager.add_buff(_skill.skill_buff, _skill.skill_buff_info)
	
	if _is_active:
		attack_list[_attack_name].call_func(_skill, _target)


func basic_action(_target, _farming_tool: String):
	if check_basic_action_hit():
		stats_manager.dmg_dealer.send_dmg_packed(_target, stats_manager.dmg_dealer.create_farming_tool_dmg_packed(_farming_tool))


#basic ranged skill, spawn projectiles
func basic_casting(_skill: Skill, _target = null):
	skill_lock(_skill)
	host.play_animation("casting")
		

func teleport(_skill: Skill, _target = null):
	skill_lock(_skill)
	host.play_animation("teleport")


func basic_buff(_skill: Skill, _target = null):
	skill_lock(_skill, 0.2)
	skill_done(_skill)
	

#check farmer stamina before doing anything
func farmer_stamina_check(_current_action):
	var dmg = Constants.FarmerStaminaNeed[_current_action]
	return stats_manager.dmg_receive_manager.farmer_stamina_check(dmg)


#check_skill_requirement
func skill_req_check(_skill: Skill):
	return stats_manager.dmg_receive_manager.skill_req_check(_skill.hp_req, _skill.mana_req)


#check if attack hit	
func check_attack_hit() -> bool:
	if not Utils.node_exists(stats_manager.host.attack_target):
		return false
		
	Utils._print_debug(stats_manager.host.attack_position, " : ", stats_manager.host.attack_target.get_map_position())
	return stats_manager.host.attack_position == stats_manager.host.attack_target.get_map_position()
	
	
func check_basic_action_hit() -> bool:
	if stats_manager.host.current_target == null:
		return false
		
	if !Utils.node_exists(stats_manager.host.current_target.resource):
		return false
	
	return true


#spawn projectile define in skill info
func spawn_projectile(_proj_name: String = "", _proj_number: int = 0, dmg_info: Dictionary = {}, _target = null, _max_speed: int = Constants.PROJECTILE_DEFAULT, _direction: Vector2 = Vector2.ZERO, proj_fxs: Dictionary = {}):
	var temp_dmg_packed = stats_manager.dmg_dealer.create_dmg_packed()
	if not dmg_info.empty():
		temp_dmg_packed = Utils.create_custom_dmg_packed(dmg_info, temp_dmg_packed)

	var _projectile_scene = Utils.load_resource(Constants.PROJECTILES_SCENE %_proj_name, "projectile_scene", _proj_name)
	if _projectile_scene == null:
		return
	
	var _projectile = _projectile_scene.instance()
	_projectile.global_position = stats_manager.host.global_position
	stats_manager.host.map_manager.ysort.add_child(_projectile)
	_projectile.init(_proj_name, temp_dmg_packed, _target, Vector2.INF, _max_speed, Constants.PROJECTILE_DEFAULT, _direction, proj_fxs) #-1 in _init_force = the default init force of projectile


func melee_attack(_target) -> Dictionary:
	if check_attack_hit():
		dmg_target(_target)
		return {
			"hit": true,
			"hit_enemies": [_target],
			"wp_used": true,
		}
	return {
		"hit": false,
		"hit_enemies": [],
		"wp_used": false,
	}


func dmg_target(tg, atk_info: Dictionary = {}) -> void:
	Utils.play_sound(host.audio_player, AudioLibrary.MELEE_ATTACK_HIT_SOUND, -1.0)
	stats_manager.dmg_dealer.send_dmg_packed(tg, Utils.create_custom_dmg_packed(atk_info, stats_manager.dmg_dealer.create_dmg_packed()))

	tg.take_combat_effects(atk_info, host.global_position)


func spawn_projectiles(_target, _proj_name: String = "", _proj_num: int = 1, dmg_info: Dictionary = {}, max_speed: int = Constants.PROJECTILE_DEFAULT, proj_fxs: Dictionary = {}):
	if  _proj_num != 0 and _proj_name != "":
		for i in _proj_num:
			var _direction: Vector2
			if Utils.node_exists(_target):
				_direction = host.direction_to_target(_target.global_position).rotated(((i + 1) / 2) * ((i % 2) * 2 - 1) * Utils.projectiles_spawn_angle(_proj_num))
			else:
				_direction = host.get_facing_direction().rotated(((i + 1) / 2) * ((i % 2) * 2 - 1) * Utils.projectiles_spawn_angle(_proj_num))

			spawn_projectile(_proj_name, _proj_num, dmg_info, _target, max_speed, _direction, proj_fxs)


#call at anim frame spawn projectile
func _on_spawn_proj(_host_name, _skill: Skill, _target):
	if !Utils.node_exists(host):
		return
		
	if host.name != _host_name:
		return

	spawn_projectiles(_target, _skill.skill_info.projectile_name, _skill.skill_info.number_of_projectiles, _skill.get_skill_dmg_stats())
	skill_done(_skill)
	

#call at anim frame, melee attack
func _on_melee_hit(_host_name, _skill: Skill, _target):
	if !Utils.node_exists(host):
		return
	if host.name != _host_name:
		return

	if check_attack_hit():
		var temp_dmg_packed = stats_manager.dmg_dealer.create_dmg_packed()
		temp_dmg_packed = Utils.create_custom_dmg_packed(_skill.get_skill_dmg_stats(), temp_dmg_packed)
		Utils.play_sound(host.audio_player, AudioLibrary.MELEE_ATTACK_HIT_SOUND, 3.0)
		stats_manager.dmg_dealer.send_dmg_packed(_target, temp_dmg_packed)
	
	
# call at anim frame, teleport
func _on_teleport(_host_name, _skill: Skill):
	if !Utils.node_exists(host):
		return
	if host.name != _host_name:
		return
	
	Utils.play_sound(host.audio_player, AudioLibrary.TELEPORT_SOUND, 1.0)
	
	var _teleport_position = host.check_and_fix_position(host.get_global_mouse_position())
	var _host_tween: Tween = host.tween

	if _host_tween.is_inside_tree():
		Utils.start_tween(_host_tween, host, "global_position", host.global_position, _teleport_position, 0.01, Tween.TRANS_LINEAR)
	else:
		host.global_position = _teleport_position

	skill_done(_skill)
	

func jump_attack(_skill: Skill, _target = null):
	skill_lock(_skill, 0.5)

	var animation: Animation = host.animation_player.get_animation("jump_attack")
	host.update_attack_position()
	host.play_animation("jump_attack")

	var _host_tween: Tween = host.tween

	if _host_tween.is_inside_tree():
		var _direction_to_target: Vector2 = host.direction_to_target_on_map(host.attack_position)
		var _jump_position = host.check_and_fix_position(host.map_manager.map_navigator.point_to_world(host.attack_position + _direction_to_target))
		Utils.start_tween(_host_tween, host, "global_position", host.global_position, _jump_position , animation.get_length(), Tween.TRANS_EXPO)

	skill_done(_skill)	


func dash_attack(_skill: Skill, _target = null):
	skill_lock(_skill, 0.3)
	var animation: Animation = host.animation_player.get_animation("run")
	host.update_attack_position()
	host.play_animation("run")

	var _host_tween: Tween = host.tween

	if _host_tween.is_inside_tree():
		var _direction_to_target: Vector2 = host.direction_to_target_on_map(host.attack_position)
		var _dash_position = host.check_and_fix_position(host.map_manager.map_navigator.point_to_world(host.attack_position - _direction_to_target))
		Utils.start_tween(_host_tween, host, "global_position", host.global_position, _dash_position , 0.3, Tween.TRANS_EXPO)
		yield(_host_tween,"tween_completed")
	
	if !Utils.node_exists(_target):
		skill_done(_skill)
		return
	
	var direction_to_target = host.map_manager.map_navigator.get_direction_from_world(host.global_position, _target.global_position)

	if not Utils.node_exists(host):
		return

	host.update_direction(direction_to_target)
	host.check_flip_character(_target.global_position)
	host.play_animation("basic_melee_attack", 2)
	
	skill_done(_skill)
	

func skill_lock(_skill: Skill, _time: float = 0.4):
	SignalManager.emit_signal("skill_lock", host.name, _skill, _time)


func skill_done(_skill: Skill):
	SignalManager.emit_signal("skill_done", host.name, _skill)
