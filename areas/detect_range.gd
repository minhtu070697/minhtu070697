extends Area2D

onready var host = get_parent()
onready var detect_timer: Timer = $DetectTimer
const DETECT_PERIOD: int = 2


func _ready() -> void:
	detect_timer.connect("timeout", self, "_on_detect_timer_timeout")
	Utils.activate_timer(detect_timer, DETECT_PERIOD)


func _on_DetectRange_body_entered(body: Node) -> void:
	if not Utils.node_exists(body):
		return

	if body is FarmPet:
		body.action_when_near_a_livestock(host)
	elif body is Animals and String(body.faction) == String(host.faction):
		if body.fleeing and body.barn_returning:
			#comment in demo-only
#			host.fleeing_to_barn()
			pass


func _on_LiveStockDetectRange_body_exited(body: Node) -> void:
	if !Utils.node_exists(body) or body != host.farm_pet_nearby:
		return
	
	host.farm_pet_nearby = null


func _on_detect_timer_timeout() -> void:
	for _body in get_overlapping_bodies():
		_on_DetectRange_body_entered(_body)

