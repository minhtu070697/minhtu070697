extends Node
class_name HealthState

signal effect_over(_self)
onready var timer := $Timer


var health_states_manager

var stats_manager: StatsManager
var host
var tween: Tween
var dmg_receive_manager: DamageReceiveManager
var dmg_receive_calculator: DamageCalculator


func _ready():
	yield(owner, "ready")
	yield(owner.owner, "ready")
	stats_manager = owner as StatsManager
	tween = stats_manager.get_node("Tween")
	host = owner.owner
	assert(host != null)
	dmg_receive_manager = stats_manager.dmg_receive_manager
	dmg_receive_calculator = dmg_receive_manager.dmg_calculator


func start_timer(_length: float):
	timer.start(_length)


func _check_and_update_effect(_state):
	if _state == self or timer.is_stopped():
		return
		
	update_effect()
	

func update_effect():
	pass

