extends HealthState
class_name Unfreezing

onready var freezing_state = get_parent().get_node("freezing")
onready var freezing_timer = freezing_state.get_node("Timer")

func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	health_states_manager.connect("unfreezing", self, "_on_unfreezing")
 

func _on_unfreezing() -> void:
	if freezing_timer.is_stopped():
		return
		
	freezing_state.unfreezing()


func update_effect():
	pass
