extends Node
class_name TweenManager


var tweens: Dictionary = {}


func _init() -> void:
	pass


func append_tween(_tween: Tween) -> void:
	tweens[_tween] = _tween


func pop_tween(_tween: Tween) -> void:
	tweens.erase(_tween)


func stop_all_tweens() -> void:
	for _tween in tweens.values():
		if Utils.node_exists(_tween):
			_tween.stop_all()
	
	tweens.clear()
