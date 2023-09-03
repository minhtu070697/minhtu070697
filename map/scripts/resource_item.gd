extends Node2D

class_name ResourceItem

var character
var resource_item_manager
var resource_item_info
var item_name
var rarity
var amount

var resource_item
var water_splash

var sprite_name


func _init(resource_item_info, resource_item_manager):
	self.resource_item_manager = resource_item_manager
	self.resource_item_info = resource_item_info
	self.item_name = resource_item_info.item_name
	self.rarity = resource_item_info.generate_rarity()
	self.amount = resource_item_info.generate_amount()

func spawn(current_resoure_item_type: String, _appear_position: Vector2 = Vector2.ZERO):
	if current_resoure_item_type != null:
		# ex: spawn logic
		character = Utils.get_current_character()
		
		if not Utils.node_exists(character):
			return
		
		var total = 0
		var resource_items = []

		if current_resoure_item_type == Constants.FISH_ITEM: total = 1
		else: total = Utils.random_int(4, 5)

		for i in total:
			resource_item = Utils.load_resource("res://map/scenes/vfxs/ResourceItem.tscn", "resource_item", "scene").instance()
			var sprite = resource_item.get_node_or_null("Sprite")
			sprite_name = current_resoure_item_type
			sprite.texture = Utils.load_resource("res://map/textures/objects/items/" + sprite_name + ".png", "res_item_texture", sprite_name)
			GameManager.map_manager.ysort.add_child(resource_item)

			if current_resoure_item_type != Constants.FISH_ITEM:
				if _appear_position == Vector2.ZERO:
					_appear_position = character.current_target.resource.global_position
				resource_item.scale = Vector2(0.85, 0.85)
				resource_items.append(resource_item)
				resource_item.position = _appear_position
				if character.current_direction == Constants.Direction.UP or character.current_direction == Constants.Direction.UP_SIDE or character.current_direction == Constants.Direction.SIDE:
					character.set_z_index(1)

		# ex: spawn animation
		if current_resoure_item_type != Constants.FISH_ITEM:
			for i in resource_items.size():
				spawn_animate(i, resource_items)
			collect_animate_step_1(character.global_position, resource_items)

func spawn_animate(i, resource_items):
	if resource_items[i] != null:
		var start_pos= resource_items[i].global_position
		var mid_pos = Vector2(resource_items[i].global_position.x, resource_items[i].global_position.y - 20)
		var final_pos = Vector2(resource_items[i].global_position.x + Utils.random_int(-20, 20), resource_items[i].global_position.y + Utils.random_int(0, 10))
		var duration = 0.15
		var tween = resource_item.get_node_or_null("Tween")
		Utils.start_tween(tween, resource_items[i], "position", start_pos, mid_pos, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		yield(tween, "tween_completed")
		var tween_1 = resource_item.get_node_or_null("Tween")
		Utils.start_tween(tween_1, resource_items[i], "position", mid_pos, final_pos, duration * 2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func destroy_object():
	resource_item.queue_free()

func destroy_multiple_object(resource_items):
	var delay_time = 0.75
	yield(Utils.start_coroutine(delay_time), "completed")
	for i in resource_items.size():
		resource_items[i].queue_free()
	resource_items.clear()	

func fish_spawn_pos(var position: Vector2, var direction: int, var is_left: bool) -> Vector2:
	if direction == Constants.Direction.UP:
		return Vector2(position.x, position.y - 60)
	elif direction == Constants.Direction.UP_SIDE:
		if is_left:
			return Vector2(position.x - 50, position.y - 40)
		else:
			return Vector2(position.x + 50, position.y - 40)
	elif direction == Constants.Direction.SIDE:
		if is_left:
			return Vector2(position.x - 55, position.y - 20)
		else:
			return Vector2(position.x + 55, position.y + 20)
	elif direction == Constants.Direction.DOWN_SIDE:
		if is_left:
			return Vector2(position.x - 50, position.y + 40)
		else:
			return Vector2(position.x + 50, position.y + 40)
	elif direction == Constants.Direction.DOWN:
		return Vector2(position.x, position.y + 60)
	else:
		return Vector2.ZERO

func fish_animate(var position: Vector2, var current_direction: int, var is_left: bool):
	if resource_item != null:
		var animation_player: AnimationPlayer = resource_item.get_node_or_null("AnimationPlayer")
		var animation: Animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		animation.track_set_path(track_index, ".:position")

		var time = 0
		for i in 8:
			animation.track_insert_key(track_index, time, fish_animate_path(position, current_direction, i, is_left))
			time += 0.1

		animation_player.add_animation("move", animation)
		animation_player.play("move")

func fish_animate_path(var position: Vector2, var current_direction: int, var index: int, var is_left: bool) -> Vector2:
	var x
	var y
	var x_left
	var x_right

	if current_direction == Constants.Direction.UP:
		x_left = [15, 20, 20, 15, 0, 0, 0, 0]
		x_right = [-15, -20, -20, -15, 0, 0, 0, 0]
		y = [50, 35, 50, 50, 60, 60, 55, 55] 
	elif current_direction == Constants.Direction.UP_SIDE:
		x_left = [-50, -40, -30, -30, 0, 0, 0, 0]
		x_right = [50, 40, 30, 30, 0, 0, 0, 0]
		y = [30, 35, 35, 40, 60, 60, 55, 55]
	elif current_direction == Constants.Direction.SIDE:
		x_left = [-45, -30, -20, -20, 0, 0, 0, 0]
		x_right = [45, 30, 20, 20, 0, 0, 0, 0]
		y = [20, 30, 35, 35, 60, 60, 55, 55]
	elif current_direction == Constants.Direction.DOWN_SIDE:
		x_left = [-50, -40, -25, -20, 0, 0, 0, 0]
		x_right = [50, 40, 25, 20, 0, 0, 0, 0]
		y = [0, 25, 35, 45, 60, 60, 55, 55]
	elif current_direction == Constants.Direction.DOWN:
		x_left = [-15, -20, -20, -15, 0, 0, 0, 0]
		x_right = [15, 20, 20, 15, 0, 0, 0, 0]
		y = [50, 35, 50, 50, 60, 60, 55, 55]
	if is_left: x = x_left 
	else: x = x_right

	return Vector2(position.x + x[index], position.y - y[index])

func collect_animate_step_1(var target: Vector2, resource_items):
	var delay_time = 0.4
	yield(Utils.start_coroutine(delay_time), "completed")
	# sfx
	play_collect_sound()
	# logic
	for i in resource_items.size():
		var tween = resource_items[i].get_node_or_null("Tween")
		Utils.start_tween(tween, resource_items[i], "position", resource_items[i].global_position, resource_items[i].global_position, 0.035, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		yield (tween, "tween_completed")
		collect_animate_step_2(i, target, resource_items)
	destroy_multiple_object(resource_items)
	if Utils.node_exists(character):
		character.set_z_index(0)


func collect_animate_step_2(i, target, resource_items):
	var duration = 0.15
	if resource_items[i] != null:
		var start_position = resource_items[i].global_position
		var final_position = Vector2(target.x, target.y - 25)

		var tween_1 = resource_items[i].get_node_or_null("Tween")
		Utils.start_tween(tween_1, resource_items[i], "position", start_position, final_position, duration, Tween.TRANS_BACK, Tween.EASE_IN)

		var tween_2 = tween_1
		Utils.start_tween(tween_2, resource_items[i], "scale", Vector2(0.85, 0.85), Vector2.ZERO, duration, Tween.TRANS_BACK, Tween.EASE_IN)


func play_collect_sound():
	GameManager.audio_manager.play_main_sound(GameManager.audio_manager.magnet)

func spawn_water_splash(var position: Vector2, var current_direction: int, var is_left: bool):
	# spawn prefab
	water_splash = load("res://map/scenes/vfxs/WaterSplash.tscn").instance()
	GameManager.map_manager.ysort.add_child(water_splash)
	water_splash.position = fish_spawn_pos(position, current_direction, is_left)

	# add animation
	animate_water_splash()
	
func destroy_water_splash():
	if water_splash != null: water_splash.queue_free()

func animate_water_splash():
	if water_splash != null: water_splash.get_child(0).play("water_splash")
