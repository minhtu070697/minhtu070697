extends CharacterState


var current_farming_tool: String


func _ready():
	SignalManager.connect("basic_action_finished", self, "_on_basic_animation_finished")
	SignalManager.connect("health_changed", self, "_on_attack_succeed")


func unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if (!character.map_manager.is_click_outside_map_bounds()):
			state_machine.transition_to(
				"seek", {"target_position": character.get_global_mouse_position()}
			)


func enter(_msg := {}) -> void:
	character.ui_manager.visible_hud(false)
	character.set_state_label("basic_action")
	character.free_attack_target()
	if character.current_target != null and Utils.node_exists(character.current_target.resource) and Utils.has_stats_manager(character.current_target.resource) and character.stats_manager.attack_library.farmer_stamina_check(Constants.FarmerAction.GATHERING) and character.tool_equipped("basic_action"):
		var direction_to_target = character.map_manager.map_navigator.get_direction_from_world(character.global_position, character.current_target.resource.global_position)
		current_farming_tool = character.get_tool("basic_action")
		if direction_to_target != null: character.update_direction(direction_to_target)
		character.load_tool_sprite(current_farming_tool, "basic_action")
		character.show_tool()
		character.check_flip_character(character.current_target.resource.global_position)
		play_basic_action_animation()
	else:
		character.free_current_target()
		state_machine.transition_to("idle")


func play_basic_action_animation():
	var _atk_speed = character.stats_manager.stats.farming_dmg[current_farming_tool].atk_speed
	var _animation_length = character.animation_player.get_animation("basic_action").get_length()
	var _animation_speed = _animation_length * _atk_speed
	character.play_animation("basic_action", _animation_speed)


func exit() -> void:
	character.hide_tool()


func _on_basic_animation_finished(_character_name = ""):
	if character.name != _character_name:
		return


func basic_action_hit():
	if Utils.node_exists(character.current_target.resource):
		_on_resource_hit()


# general using: tree, mine, other_resource
func _on_attack_succeed(_target_name = "", _attack_owner_name = ""):
	if _attack_owner_name == "":
		return
		
	if character.name != _attack_owner_name or character.current_target == null or state_machine.state != self:
		return
	
	if character.current_target.resource.name == _target_name:
		#vfx
		character.current_target.resource.create_hit_particle()
		character.use_equipment(current_farming_tool)
		#logic
		if character.current_target.resource.stats_manager.stats.hp <= 0:
			_on_resource_die()
		else:
			character.current_target.resource.on_hit()
			state_machine.transition_to("basic_action")


func _on_resource_hit():
	character.stats_manager.attack_library.farming(character.current_target.resource, current_farming_tool, Constants.AttackList.BASIC_ACTION)

	# sfx
	play_resource_hit_sound()


func _on_resource_die():
	# data
	character.map_manager.map_info.remove_resource(character.current_target, character.current_target.size, character.current_target.origin)
	character.free_current_target()
	# animate
	state_machine.transition_to("idle")
	
	# sfx
	play_resource_die_sound()


func play_resource_hit_sound():
	match (character.current_target.resource_type):
		Constants.ResourceType.TREE: GameManager.audio_manager.play_main_sound(GameManager.audio_manager.cutting_tree)
		Constants.ResourceType.GOLD, Constants.ResourceType.DIAMOND, Constants.ResourceType.EMERALD, Constants.ResourceType.RUBY, Constants.ResourceType.AMBER, Constants.ResourceType.AMETHYST, Constants.ResourceType.QUARTZ, Constants.ResourceType.SAPPSHIRE:
			GameManager.audio_manager.play_main_sound(GameManager.audio_manager.mining)
		Constants.ResourceType.STONE: GameManager.audio_manager.play_main_sound(GameManager.audio_manager.mining)
		Constants.ResourceType.OTHER: GameManager.audio_manager.play_main_sound(GameManager.audio_manager.cutting_tree)
		Constants.ResourceType.BATTLE_VASE: GameManager.audio_manager.play_main_sound(GameManager.audio_manager.mining)
		Constants.ResourceType.PLANT, Constants.ResourceType.YOUNG_PLANT:
			GameManager.audio_manager.play_main_sound(GameManager.audio_manager.cutting_tree)


func play_resource_die_sound():
	var random = Utils.random_int(0, 1)
	if random == 0:
		GameManager.audio_manager.play_sub_sound(GameManager.audio_manager.collect)
	else:
		GameManager.audio_manager.play_sub_sound(GameManager.audio_manager.collect_1)
