extends HealthState
class_name Antidoting

onready var poisoning_state = get_parent().get_node("poisoning")
onready var poisoning_timer = poisoning_state.get_node("Timer")

func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	health_states_manager.connect("antidoting", self, "_on_antidoting")
 

func _on_antidoting() -> void:
	if poisoning_timer.is_stopped():
		return
		
	poisoning_state.antidote()


func update_effect():
	pass
