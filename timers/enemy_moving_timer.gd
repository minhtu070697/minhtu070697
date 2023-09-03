extends Timer

onready var host = get_parent()


func _on_MovingTimer_timeout() -> void:
	SignalManager.emit_signal("enemy_moving", host.name)
	stop()
