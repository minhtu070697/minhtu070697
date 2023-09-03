extends HealthState
class_name LightningShocking

onready var freezing_state = get_parent().get_node("freezing")
onready var freezing_strength: float

func _ready() -> void:
	yield(owner, "ready")
	yield(owner.owner, "ready")
	dmg_receive_calculator.connect("lightning_shocking", self, "_on_lightning_shocking")
 

func _on_lightning_shocking(_lightning_dmg: float, faction: String) -> void:
	freezing_strength = freezing_state.freezing_strength
	if !(freezing_strength <= 0.1 or freezing_strength >= 0.7):
		_lightning_dmg *= Constants.LIGHTNING_ADD_WATER_DMG_MULTIPLIER
	dmg_receive_manager.receive_dmg_packed(Utils.create_direct_dmg_packed(_lightning_dmg, faction))


func update_effect():
	pass
