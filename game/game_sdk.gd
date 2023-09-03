extends Node


func is_exported_platform():
	if OS.has_feature("standalone"):
		return true
	else:
		return false
