extends Area2D


onready var host = get_parent()
onready var timer = get_node("Timer")

func _on_Area_body_entered(body: Node) -> void:
	#when stuck, start a timer, after ... seconds, stop stuck avoid. Loop avoid if get stuck again
	if body != host and host.stuck_body == null:
		SignalManager.emit_signal("stuck_detect", host.name, body)
		timer.start()


func _on_Timer_timeout() -> void:
	host.stuck_detect = false
	host.stuck_body = null
	timer.stop()
