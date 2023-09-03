extends EnemyState


func _ready() -> void:
	SignalManager.connect("enemy_moving", self, "_on_moving_timer_timeout")

	
func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()
	
	if out_of_moving_distance():
		return_to_spawn_position()
	#=====Check and trans to atk state====
	if character.map_manager.player_ready:
		check_and_transition_to_attack_state()


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
		
	character.set_state_label("idle")
	character.play_animation("idle")
	SignalManager.emit_signal("character_arrived", character.name)
	character.moving_timer.start()
	character.set_weapon_label(character.monster_info.monster_name)


func exit() -> void:
	pass


func out_of_moving_distance() -> bool:
	var _distance = character.get_map_position() - character.get_map_position(character.spawn_origin)
	return max(abs(_distance.x), abs(_distance.y)) > character.monster_info.moving_distance


func return_to_spawn_position() -> void:
	character.free_attack_target()
	
	var _temp_x = Utils.random_int(-2,2)
	var _temp_y = Utils.random_int(-2,2)
	state_machine.transition_to(
				"seek", 
				{"target_position": character.spawn_origin + character.map_manager.map_navigator.point_to_world(Vector2(_temp_x, _temp_y))}
			)

#after x seconds, host move randomly in range (4,4)
func _on_moving_timer_timeout(_host_name) -> void:
	if _host_name == character.name:
		if character.cry_sound != null:
			if Utils.random_int(1,10) < 2:
				Utils.play_sound(character.audio_player, character.cry_sound, character.monster_info.cry_sound_amplify)
			
		var _temp_x = Utils.random_int(-4,4)
		var _temp_y = Utils.random_int(-4,4)
		state_machine.transition_to(
				"seek", 
				{"target_position": character.map_manager.map_navigator.point_to_world(character.get_map_position() + Vector2(_temp_x, _temp_y))}
			)


func check_and_transition_to_attack_state() -> void:
	if !is_instance_valid(character.attack_target):
		character.attack_target = null
		
	if character.attack_target != null and character.is_aggressive:
		choose_what_to_do()


func to_basic_attack_state() -> void:
	if character.get_attack_target_distance() <= character.stats_manager.equipment_manager.weapon_range:
		character.update_attack_position()
		state_machine.transition_to("basic_melee_attack")
	else:
		state_machine.transition_to("attack_target_seek", {"range": character.stats_manager.equipment_manager.weapon_range})


func choose_what_to_do() -> void:
	if character.skill_activating != null:
		state_machine.transition_to("casting", {"skill": character.skill_activating})
	
	var _character_skill_manager = character.stats_manager.skill_manager
	var _num_of_skill = _character_skill_manager.skill_list.size()
	if _num_of_skill > 0:
		var _random = Utils.random_int(0, 1)
		if _random == 1:
			state_machine.transition_to("casting", {"skill": _character_skill_manager.skill_list.values()[Utils.random_int(0, _character_skill_manager.skill_list.size() - 1)]})
			return
			
	to_basic_attack_state()
