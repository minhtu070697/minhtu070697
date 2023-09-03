tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("res://addons/empty_save_file/EmptySaveFilesButton.tscn").instance()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
