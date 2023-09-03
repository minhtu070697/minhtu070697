extends CharacterState

var target_position = null
var paths: PoolVector2Array
var stuck_avoid_paths: PoolVector2Array = []


func _ready():
	SignalManager.connect("stuck_detect", self, "_on_stuck_detect")
	SignalManager.connect("target_clicked", self, "_on_target_clicked")


func unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		SignalManager.emit_signal("mouse_left_clicked")
		if Utils.is_in_buildable_map(character.map_manager.map_type): character.map_manager.check_disable_remove_item_choosing()
		if Utils.moving_click_is_valid():
			target_position = character.get_global_mouse_position()
			character.attacking = false
			character.skill_activating = null
			character.free_attack_target()
			set_up_paths()
	
	check_key_input(event)


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	#stuck avoid
	character.weapon_label.text = Constants.DirectionName[character.current_direction]
	if character.stuck_detect:
		if !Utils.node_exists(character.stuck_body):
			character.stuck_detect = false
			return

		character.stuck_avoid(character.stuck_body.global_position)
		set_up_paths()
		return

	# move
	if len(paths) == 0:
		idle()
	else:
		if len(paths) == 1:
			character.arrive_to(paths[0])
		else:
			character.seek(paths[0])
			if character.global_position.distance_to(paths[0]) <= Steering.DEFAULT_STOP_THRESHOLD:
				paths.remove(0)
				set_up_paths()

		if character.velocity == Vector2.ZERO:
			idle()

	# ex: check if player near by stairs => show go up/down floor ui
	if (
		character.map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or character.map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		character.map_manager.show_go_up_down_ui()


func enter(_msg := {}) -> void:
	character.ui_manager.visible_hud(false)
	if character.dead:
		state_machine.transition_to("die")
		return

	character.set_state_label(name)
	character.play_animation("run")
	target_position = msg.target_position
	set_up_paths()


func exit() -> void:
	target_position = null


func idle():
	state_machine.transition_to("idle")
	target_position = null
	paths = []


func set_up_paths():
	for test in 1:
		paths = character.get_path_to_target(target_position)


func _on_stuck_detect(_host_name, _stuck_body):
	if _host_name != character.name or _stuck_body == null:
		return
	character.stuck_detect = true
	character.stuck_body = _stuck_body


#idle if click on enemies
func _on_target_clicked(_enemy, _enemy_position):
	character.water_target = false
	idle()


func _on_AttackButton_button_up() -> void:
	if state_machine.state == self:
		character.basic_attack()
