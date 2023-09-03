extends StaticObjects
class_name Decorations

onready var group_btn_remove = $GroupButtonRemove
onready var btn_remove = $GroupButtonRemove/ButtonRemove


#region: button remove
func visible_button_remove(_visible: bool):
	btn_remove.visible = _visible

func rotate_button_remove(is_build):
	if is_build:
		group_btn_remove.scale.x = -group_btn_remove.scale.x
	else:
		if scale.x == 1:
			group_btn_remove.scale.x = 1
		else:
			group_btn_remove.scale.x = -1

func on_click_button_remove_local(): 
	Utils.get_current_character().ui_manager.on_click_button_remove_general(self)

#endregion

#region: general
func built():
	pass

func remove():
	pass

#endregion
