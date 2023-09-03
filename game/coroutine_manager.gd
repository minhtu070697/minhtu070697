extends Node
class_name CoroutineManager


var coroutines: Dictionary = {}


func _init() -> void:
	pass


func append_coroutine(_coroutine) -> void:
	coroutines[_coroutine] = _coroutine


func pop_coroutine(_coroutine) -> void:
	if not coroutines.empty():
		coroutines.erase(_coroutine)
		_coroutine.queue_free()


func stop_all_coroutines() -> void:
	for _coroutine in coroutines.values():
		_coroutine.stop()
		_coroutine.queue_free()
	
	coroutines.clear()
