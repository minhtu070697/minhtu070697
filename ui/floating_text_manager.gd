extends Node2D


var text_label_scene = Utils.load_resource("res://ui/floating_text.tscn", "floating_text_scene", "scene")

export var direction = Vector2(0,-50)
export var duration = 1
export var spread = PI/2

func show_text(_text, _is_crit: bool = false):
	var text_label = text_label_scene.instance()
	add_child(text_label)
	if !_is_crit:
		text_label.show_text(str(_text), direction, duration, spread)
	else:
		text_label.show_critical_text(str(_text), direction, duration, spread)
