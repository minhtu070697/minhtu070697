extends AnimalsState
class_name AnimalsLieDown


func _ready() -> void:
	pass


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()


func enter(_msg := {}) -> void:
	var _animation_name: String = "lie_down"
	if _msg.has("animation"):
		_animation_name = _msg.animation
	
	if character.dead:
		state_machine.transition_to("die")
		return
	if !character.state_timer.is_connected("timeout", self, "_on_state_timer_timeout"):
		character.state_timer.connect("timeout", self, "_on_state_timer_timeout")
	if character.current_navigator_use in character.animal_info.where_to_lie_down:
		lie_down(_animation_name)
		character.change_status_text("lie_down")
	else:
		idle()


func exit() -> void:
	pass


func idle():
	state_machine.transition_to("idle")


func lie_down(_animation_name: String):
	character.set_state_label(_animation_name)
	character.play_animation(_animation_name)
	Utils.activate_timer(character.state_timer, rand_range(2, 7))


func _on_state_timer_timeout():
	if state_machine.state == self:
		idle()
