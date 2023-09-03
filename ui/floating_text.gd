extends Label

onready var tween = $Tween

func show_text(_text, _direction, _duration, _spread):
	set_up_normal_floating_text(_text, _direction, _duration, _spread)
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()

	
func show_critical_text(_text, _direction, _duration, _spread):
	set_up_normal_floating_text(_text, _direction, _duration, _spread)
	Utils.start_tween(tween, self, "rect_scale", rect_scale, rect_scale * 1.5, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	yield(tween,"tween_all_completed")
	queue_free()


func set_up_normal_floating_text(_text, _direction, _duration, _spread):
	text = _text
	var movement = _direction.rotated(rand_range(-_spread / 2, _spread / 2))
	rect_pivot_offset = rect_size / 2

	Utils.start_tween(tween, self, "rect_position", rect_position, rect_position + movement, _duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Utils.start_tween(tween, self, "modulate:a", 1.0, 0.0, _duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
