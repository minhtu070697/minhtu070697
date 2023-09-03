extends HealthState
class_name Burning

onready var freezing_state = get_parent().get_node("freezing")
onready var freezing_timer = freezing_state.get_node("Timer")

func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	dmg_receive_calculator.connect("burning", self, "_on_burning")
 

func _on_burning() -> void:
	if freezing_timer.is_stopped():
		return
		
	freezing_state.unfreeze_on_burn()


func update_effect():
	pass
