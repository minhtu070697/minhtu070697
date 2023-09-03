extends State
class_name GameState

var game_manager

var fallback_states = []
var non_fallbackable_states = []

func _ready():
	yield(owner, "ready")
	game_manager = owner
	assert(game_manager != null)

