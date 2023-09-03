extends EnemyState

var skill: Skill

func _ready():
	SignalManager.connect("casting_finished", self, "_on_casting_finished")
	SignalManager.connect("skill_finished", self, "_on_skill_finished")
	SignalManager.connect("teleport_finished", self, "_on_teleport_finished")
	SignalManager.connect("jump_attack_finished", self, "_on_skill_finished")


func enter(_msg := {}) -> void:
	#pass values of skill in here
	skill = _msg.skill

	if skill.skill_info.is_target and !Utils.node_exists(character.attack_target):
		idle()
		return
		
	character.skill_activating = skill
	#we have 2 types of skill, target and non-target
	character.set_state_label("casting")
	#check skill req, if pass -> casting
	if check_skill_in_range(skill):
		if !check_skill_req(skill):
			idle()
			return
		
		if skill.skill_info.is_target:
			character_stop()
			var direction_to_target = Utils.angle_to_direction(character.distance_to_target(character.attack_target.global_position).angle())
			character.update_direction(direction_to_target)
			character.check_flip_character(character.attack_target.global_position)
			
		#play animation written in skill card, if character doesn't have this anim -> plays normal casting
		character.stats_manager.attack_library.skill(skill, character.attack_target, skill.skill_info.attack_name)
	else: #doesn't meet the req
		state_machine.transition_to("attack_target_seek", {"range": skill.range_of_skill})


func check_skill_in_range(_skill: Skill):
	if !_skill.skill_info.is_target:
		return true
		
	var in_range_of_skill: bool
	in_range_of_skill = character.get_attack_target_distance() <= _skill.range_of_skill
	return in_range_of_skill and Utils.has_stats_manager(character.attack_target)
	
func check_skill_req(_skill: Skill):
	return character.stats_manager.attack_library.skill_req_check(_skill)


func exit() -> void:
	pass
	
#animation call these func 
func melee_hit():
	SignalManager.emit_signal("melee_hit", character.name, skill, character.attack_target)
	
func spawn_proj():
	SignalManager.emit_signal("spawn_proj", character.name, skill, character.attack_target)

func teleport():
	SignalManager.emit_signal("teleport", character.name, skill)

func skill_break_point():
	SignalManager.emit_signal("skill_break_point", character.name, skill)

func _on_casting_finished(_character_name: String = ""):
	_on_skill_finished(_character_name)
	
func _on_teleport_finished(_character_name: String = ""):
	_on_skill_finished(_character_name)

func idle():
	state_machine.transition_to("idle")

func _on_skill_finished(_character_name: String = ""):
	if character.name != _character_name:
		return
	idle()
