extends Node

signal antidoting()
signal unfreezing()

onready var health_states = get_children()

func _ready() -> void:
	for health_state in health_states:
		health_state.connect("effect_over", self, "_on_effect_over")
		health_state.health_states_manager = self


func _on_effect_over(_state):
	for health_state in health_states:
		health_state._check_and_update_effect(_state)
