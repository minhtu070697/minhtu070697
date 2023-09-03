extends ActorState
class_name EnemyState


func _ready():
	yield(owner, "ready")
	character = owner as Enemy
	assert(character != null)
	

