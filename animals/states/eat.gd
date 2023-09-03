extends AnimalsState


func _ready() -> void:
	pass


func physics_process(_delta: float) -> void:
	.physics_process(_delta)
	character.stop_moving()


func enter(_msg := {}) -> void:
	if !character.state_timer.is_connected("timeout", self, "_on_state_timer_timeout"):
		character.state_timer.connect("timeout", self, "_on_state_timer_timeout")
	if character.dead:
		state_machine.transition_to("die")
		return
	play_eat_animation()
	character.show_food()
	character.set_state_label("eat")
	Utils.activate_timer(character.state_timer, rand_range(1, 5))


func play_eat_animation() -> void:
	if character.on_ground():
		character.play_animation("eat")
	elif character.on_water():
		character.play_animation("eat_swim")


func exit() -> void:
	character.show_food(false)


func idle():
	state_machine.transition_to("idle")


func _on_state_timer_timeout():
	if state_machine.state == self:
		idle()
