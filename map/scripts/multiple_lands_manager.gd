extends Node2D

class_name MultipleLandsManager


var game_manager

var unlock_map_position: String = "unlock_map_"

var list_map_positions_default = Constants.list_map_positions_default

var list_unlock_map_positions = [
	unlock_map_position + str(list_map_positions_default[0]),
	unlock_map_position + str(list_map_positions_default[1]),
	unlock_map_position + str(list_map_positions_default[2]),
	unlock_map_position + str(list_map_positions_default[3]),
	unlock_map_position + str(list_map_positions_default[4]),
	unlock_map_position + str(list_map_positions_default[5]),
	unlock_map_position + str(list_map_positions_default[6]),
	unlock_map_position + str(list_map_positions_default[7])
]


func _init(_game_manager):
	game_manager = _game_manager


func multiple_lands_input(event):
	if not game_manager.map_manager.is_fog_tweening:
		if event.is_action_pressed(list_unlock_map_positions[0]):
			unlock_map(list_map_positions_default[0])
		elif event.is_action_pressed(list_unlock_map_positions[1]):
			unlock_map(list_map_positions_default[1])
		elif event.is_action_pressed(list_unlock_map_positions[2]):
			unlock_map(list_map_positions_default[2])
		elif event.is_action_pressed(list_unlock_map_positions[3]):
			unlock_map(list_map_positions_default[3])
		elif event.is_action_pressed(list_unlock_map_positions[4]):
			unlock_map(list_map_positions_default[4])
		elif event.is_action_pressed(list_unlock_map_positions[5]):
			unlock_map(list_map_positions_default[5])
		elif event.is_action_pressed(list_unlock_map_positions[6]):
			unlock_map(list_map_positions_default[6])
		elif event.is_action_pressed(list_unlock_map_positions[7]):
			unlock_map(list_map_positions_default[7])
		

func unlock_map(new_map_position):
	if is_able_to_unlock(new_map_position):
		# logic
		game_manager.map_manager.add_new_map_position(new_map_position)
		GameManager.save_load_manager.save_multiple_lands(new_map_position)

		var unlock_map_position_points: Array = get_points_from_unlock_map_position(new_map_position)
		var land_walkable_points = game_manager.map_manager.map_navigator._add_walkable_points_land(unlock_map_position_points)
		var water_walkable_points = game_manager.map_manager.map_navigator._add_walkable_points_water(unlock_map_position_points)
		var combined_walkable_points = game_manager.map_manager.map_navigator._add_walkable_points_combined(unlock_map_position_points)

		game_manager.map_manager.map_navigator._connect_walkable_points_custom(land_walkable_points, water_walkable_points, combined_walkable_points)

		game_manager.map_manager.map_generator.fill_objects_custom(unlock_map_position_points)
		game_manager.map_manager.map_navigator._add_disabled_points_custom(unlock_map_position_points)
		GameManager.enemy_manager.enemy_generator.fill_enemies_in_land_pos(new_map_position)

		# vfx
		game_manager.map_manager.remove_fog(new_map_position)
		game_manager.map_manager.remove_line(new_map_position)
		game_manager.map_manager.remove_land_label(new_map_position)
		game_manager.map_manager.set_land_labels(false, 0, 0)
		private_vfx()

		# empty memories
		game_manager.map_manager.queue_free_all_multiple_lands_vfx_nodes()


func is_already_unlocked(new_map_position):
	return game_manager.map_manager.list_map_positions.has(new_map_position)


func get_points_from_unlock_map_position(new_map_position) -> Array:
	var points = []
	var xrange_temp = Utils.cal_xrange(new_map_position, game_manager.map_manager.size)
	var yrange_temp = Utils.cal_yrange(new_map_position, game_manager.map_manager.size)
	for x in range(xrange_temp.x, xrange_temp.y):
		for y in range(yrange_temp.x, yrange_temp.y):
			points.append(Vector2(x, y))
	return points


func is_engle_map_position(new_map_position):
	return (new_map_position == Vector2(0, 0) or new_map_position == Vector2(2, 2)
		or new_map_position == Vector2(0, 2) or new_map_position == Vector2(2, 0))


func is_nearby_engle_1_map_position(new_map_position):
	var engle_1: Vector2
	if new_map_position == Vector2(0, 0):
		engle_1 = Vector2(new_map_position.x + 1, new_map_position.y)
	elif new_map_position == Vector2(2, 2):
		engle_1 = Vector2(new_map_position.x - 1, new_map_position.y)
	elif new_map_position == Vector2(0, 2):
		engle_1 = Vector2(new_map_position.x + 1, new_map_position.y)
	elif new_map_position == Vector2(2, 0):
		engle_1 = Vector2(new_map_position.x - 1, new_map_position.y)
	return engle_1


func is_nearby_engle_2_map_position(new_map_position):
	var engle_2: Vector2
	if new_map_position == Vector2(0, 0):
		engle_2 = Vector2(new_map_position.x, new_map_position.y + 1)
	elif new_map_position == Vector2(2, 2):
		engle_2 = Vector2(new_map_position.x, new_map_position.y - 1)
	elif new_map_position == Vector2(0, 2):
		engle_2 = Vector2(new_map_position.x, new_map_position.y - 1)
	elif new_map_position == Vector2(2, 0):
		engle_2 = Vector2(new_map_position.x, new_map_position.y + 1)
	return engle_2


func is_able_to_unlock_engle_map_position(new_map_position):
	return game_manager.map_manager.list_map_positions.has(is_nearby_engle_1_map_position(new_map_position)) or game_manager.map_manager.list_map_positions.has(is_nearby_engle_2_map_position(new_map_position))


func is_able_to_unlock(new_map_position):
	if not is_already_unlocked(new_map_position):
		if not is_engle_map_position(new_map_position):
			return true
		elif is_able_to_unlock_engle_map_position(new_map_position):
			return true
		else:
			return false
	else:
		return false


func private_vfx():
	var unlock_land_vfx = Utils.load_resource("res://ui/scenes/UnlockLandVFX.tscn", "ullandvfx", "scene").instance()
	var tween = unlock_land_vfx.get_node_or_null("Tween")
	var background = unlock_land_vfx.get_node_or_null("Background")
	var title_panel = unlock_land_vfx.get_node_or_null("Panel")
	var character = Utils.get_current_character()  

	character.ui_manager.add_child(unlock_land_vfx)
	unlock_land_vfx.rect_global_position = Vector2(260, 116)
	
	background.visible = true
	Utils.start_tween(tween, background, "color", Color(0, 0, 0, 0), Color(0, 0, 0, .75), 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(tween, title_panel, "rect_position", Vector2(-111, -500), Vector2(-111, -86), 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)

	yield(tween, "tween_completed")

	Utils.start_tween(tween, background, "color", Color(0, 0, 0, .75), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 3)
	Utils.start_tween(tween, title_panel, "rect_position", Vector2(-111, -86), Vector2(-111, -500), 0.5, Tween.TRANS_BACK, Tween.EASE_IN, 3)

	yield(Utils.start_coroutine(4.0), "completed")
	unlock_land_vfx.queue_free()
