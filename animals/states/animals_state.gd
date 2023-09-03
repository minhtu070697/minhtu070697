extends ActorState
class_name AnimalsState


func _ready():
	yield(owner.owner, "ready")
	character = owner.owner
	assert(character != null)
