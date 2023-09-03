extends AnimalsState
class_name AnimalsSleep


func _ready() -> void:
	pass


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()


func enter(_msg := {}) -> void:
	if character.dead:
		state_machine.transition_to("die")
		return
	if !character.state_timer.is_connected("timeout", self, "_on_state_timer_timeout"):
		character.state_timer.connect("timeout", self, "_on_state_timer_timeout")
	if character.current_navigator_use in character.animal_info.where_to_sleep:
		sleep()
		character.change_status_text("sleep")
	else:
		state_machine.transition_to("lie_down")


func exit() -> void:
	pass


func idle():
	state_machine.transition_to("idle")


func sleep():
	character.set_state_label("sleep")
	character.play_animation("sleep")
	Utils.activate_timer(character.state_timer, rand_range(3, 8))


func _on_state_timer_timeout():
	if state_machine.state == self:
		idle()
