extends Area2D

export var invincibility_time = 0.5  # seconds
onready var timer = $Timer
onready var collision_shape = $CollisionShape2D
onready var host = get_parent()


func start_invincibility_timer():
	collision_shape.set_deferred("disabled", true)
	timer.start(invincibility_time)


func _on_Timer_timeout():
	collision_shape.set_deferred("disabled", false)


func _on_Hurtbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and Utils.obj_click_is_valid():
		SignalManager.emit_signal("target_clicked", host, host.get_map_position())
