extends FighterActor
class_name Character

# Vars
onready var ui_manager: UIManager = $ui
onready var body_sprite := $BodyParts/Body
onready var eyes_sprite := $BodyParts/Eyes
onready var hair_sprite := $BodyParts/Hair
onready var pants_sprite := $BodyParts/Pants
onready var coat_sprite := $BodyParts/Coat
onready var head_sprite := $BodyParts/Head
onready var tool_sprite := $BodyParts/Tool
onready var tail_sprite := $BodyParts/Tail
onready var ears_sprite := $BodyParts/Ears
onready var status_sprite := $BodyParts/Status

onready var camera: Camera2D = $Camera2D
onready var light: Sprite = $BodyParts/Light
onready var item_label: Label = $ItemLabel

var current_resource_item_type
var player_inventory = PlayerInventory

var attacking: bool = false
var target_top_arrow_pointer: PointerTopArrow = null

# Private vars
var _current_target_id: int = 0


func _ready():
	animation_frames = {
		"idle": 8,
		"run": 8,
		"basic_action": 7,
		"jump": 2,
		"fishing_throw": 10,
		"fishing_waiting": 5,
		"fishing_biting": 6,
		"fishing_pull": 7,
		"fishing_catch": 4,
		"fishing_jump": 3,
		"basic_melee_attack": 9,
		"heavy_attack": 9,
		"360_attack": 9,
		"die": 5,
		"casting": 9,
		"teleport": 9,
		"jump_attack": 7,
		"water": 8,
		"heavy_smash": 7,
	}

	body_parts = [
		body_sprite,
		head_sprite,
		eyes_sprite,
		hair_sprite,
		pants_sprite,
		coat_sprite,
		tool_sprite,
		tail_sprite,
		ears_sprite,
		status_sprite
	]

	#logic
	add_to_group("characters")
	SignalManager.connect("target_clicked", self, "_on_target_clicked")
	SignalManager.connect("wind_blow", self, "_on_wind_blow")
	show_equipments()
	update_direction(Constants.Direction.DOWN_SIDE)

	# efx
	spawn_character_efx()
	add_to_group(str(faction))
	enable_character_light()
	show_equipments()


func update_sprite_direction(_direction: int):
	.update_sprite_direction(_direction)
	if (
		_direction == Constants.Direction.UP
		or _direction == Constants.Direction.UP_SIDE
	):
		if tail_sprite.visible:
			$BodyParts.move_child(tail_sprite, $BodyParts.get_child_count() - 1)
		
		$BodyParts.move_child(tool_sprite, 0)
	else:
		if tail_sprite.visible:
			$BodyParts.move_child(tail_sprite, 0)
		
		$BodyParts.move_child(tool_sprite, $BodyParts.get_child_count() - 1)


# region: tools + equipment
func hide_tool():
	tool_sprite.visible = false


func show_tool():
	tool_sprite.visible = true


func get_tool(_action: String = "basic_action"):
	if _action == "casting":
		return "weapon"

	# get weapon => battlefield
	if _action == "basic_attack":
		if ui_manager.inventory.equip_slots[3].get_child_count() > 1:
			return "weapon"
	# get tool => farming
	else:
		if water_target:
			if ui_manager.inventory.equip_slots[4].get_child_count() > 1:
				return "fishing_rod"
		else:
			if current_target == null:
				return "nothing"

			match current_target.resource_type:
				Constants.ResourceType.TREE, Constants.ResourceType.PLANT:
					if ui_manager.inventory.equip_slots[5].get_child_count() > 1:
						return "axe"
				Constants.ResourceType.GOLD, Constants.ResourceType.DIAMOND, Constants.ResourceType.EMERALD, Constants.ResourceType.RUBY, Constants.ResourceType.AMBER, Constants.ResourceType.AMETHYST, Constants.ResourceType.QUARTZ, Constants.ResourceType.SAPPSHIRE:
					if ui_manager.inventory.equip_slots[6].get_child_count() > 1:
						return "pick"
				Constants.ResourceType.STONE:
					if ui_manager.inventory.equip_slots[6].get_child_count() > 1:
						return "pick"
				Constants.ResourceType.OTHER, Constants.ResourceType.YOUNG_PLANT:
					if ui_manager.inventory.equip_slots[7].get_child_count() > 1:
						return "hoe"
				Constants.ResourceType.BATTLE_VASE:
					if ui_manager.inventory.equip_slots[7].get_child_count() > 1:
						return "hoe"

	return "nothing"


func load_tool_sprite(_tool_name: String, _action_name: String) -> void:
	if _tool_name == "nothing":
		return

	if ResourceLoader.exists(
		"res://characters/textures/%s/%s-01-%s.png" % [_action_name, _tool_name, _action_name]
	):
		tool_sprite.texture = Utils.load_resource(
			"res://characters/textures/%s/%s-01-%s.png" % [_action_name, _tool_name, _action_name],
			_tool_name,
			"anim_texture"
		)


func tool_equipped(_action: String) -> bool:
	return false if get_tool(_action) == "nothing" else true


func show_equipments():
	var hair_index = 3
	var coat_index = 5
	var pants_index = 4

	for i in range(ui_manager.inventory.equip_slots.size() - 1):
		if ui_manager.inventory.equip_slots[i].get_child_count() > 1:
			match i:
				0:
					body_parts[hair_index].visible = true
				1:
					body_parts[coat_index].visible = true
				2:
					body_parts[pants_index].visible = true
		else:
			match i:
				0:
					body_parts[hair_index].visible = false
				1:
					body_parts[coat_index].visible = false
				2:
					body_parts[pants_index].visible = false


func show_item_label():
	item_label.visible = true
	item_label.get_child(0).play("show")
	yield(item_label.get_child(0), "animation_finished")
	item_label.visible = false


func set_item_label(text, amount):
	item_label.text = text + String(amount)

# endregion


func hide_status():
	status_sprite.visible = false


func show_status():
	status_sprite.visible = true


func play_status_animation():
	status_sprite.get_child(0).play("status_attention")


# region: checking
func is_left() -> bool:
	if body_sprite.flip_h:
		return true
	else:
		return false


func _on_target_clicked(_target, _target_position):
	if _target == self:
		return
	target_enemy(_target, _target_position)
	basic_attack()


func target_enemy(enemy, enemy_position: Vector2) -> void:
	attack_target = enemy
	attack_position = enemy_position
	emit_signal("enemy_targeted", enemy, enemy_position)


func set_z_index(index):
	self.z_index = index


func is_standing_on_buildable_object(item):
	var character_point = self.get_map_position()
	var size = item.size
	var origin = item.origin
	for x in range(size.x):
		for y in range(size.y):
			var item_point = origin + Vector2(x, y)
			if character_point == item_point:
				return true

# endregion


# region: efx
func spawn_character_efx():
	yield(map_manager, "ready")
	var body_parts_node = get_node("BodyParts")
	body_parts_node.modulate.a = 0

	# remove loading scene
	GameManager.scene_manager.remove_loading_scene()

	# delay
	var delay_time = .5
	yield(Utils.start_coroutine(delay_time), "completed")

	# play portal
	var portal = load("res://map/scenes/vfxs/Portal.tscn").instance()
	map_manager.ysort.add_child(portal)
	portal.global_position = Vector2(self.position.x, self.position.y - 25)
	portal.modulate.a = 0

	portal.visible = true
	portal.get_child(2).play("portal_scale")

	# sfx
	play_chacter_spawn_sound()

	# tween body parts
	yield(portal.get_child(2), "animation_finished")
	Utils.start_tween(
		tween,
		body_parts_node,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.8,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	# play backwards portal
	yield(tween, "tween_completed")
	portal.get_child(2).play_backwards("portal_scale")

	# remove portal
	yield(portal.get_child(2), "animation_finished")
	portal.queue_free()

	SignalManager.emit_signal("player_ready")


func character_fade(is_in, duration):
	var body_parts_node = get_node("BodyParts")
	if is_in:
		Utils.start_tween(
			tween,
			body_parts_node,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			duration,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
	else:
		Utils.start_tween(
			tween,
			body_parts_node,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			duration,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)


# ex: turn on light2D when player enter Mining Map
func enable_character_light():
	if (
		map_manager.map_type == Constants.MapSceneType.MINING_MAP
		or (
			map_manager.map_type == Constants.MapSceneType.FARM_MAP
			and GameManager.daytime_manager.current_daytime == Constants.DayTime.NIGHT
		)
	):
		visible_light(true)
		scale_character_light()
	else:
		light.visible = false


func scale_character_light():
	if map_manager.map_type == Constants.MapSceneType.MINING_MAP:
		tween.interpolate_property(
			light,
			"scale",
			Vector2.ZERO,
			Vector2(.3, .3),
			1,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
	else:
		tween.interpolate_property(
			light, "scale", Vector2.ZERO, Vector2(.3, .3), 1, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR
		)


func visible_light(_visible):
	light.visible = _visible

# endregion


# region: sfx
func play_chacter_spawn_sound():
	GameManager.audio_manager.play_sub_sound(GameManager.audio_manager.character_spawn)


func _on_wind_blow(_wind: Dictionary) -> void:
	var _map_position: Vector2 = get_map_position()
	if GameManager.environment_manager.environment_event_manager.affect_by_wind(
		_map_position, _wind
	):
		GameManager.env_sound_manager.environment_bg_sound_manager.play_environment_sound(
			self,
			Utils.load_resource(AudioLibrary.WIND_BLOW_SOUND_PATH, "event_sound", "wind_blow"),
			5,
			true
		)
# endregion


#only-character-func when click on interactable-obj, create an arrow pointer on top of target obj
func set_current_target(_map_info_item: MapInfoItem) -> void:
	if _map_info_item == current_target:
		return
	.set_current_target(_map_info_item)

	if !Utils.node_exists(target_top_arrow_pointer):
		create_top_pointer_arrow()

	target_top_arrow_pointer.move_to_target(current_target.resource)


func create_top_pointer_arrow() -> void:
	if !current_target or !Utils.node_exists(current_target.resource):
		return

	target_top_arrow_pointer = Utils.load_resource("res://ui/scenes/PointerTopArrow.tscn", "obj_top_arrow_pointer", "scene").instance()
	map_manager.add_child(target_top_arrow_pointer)


func destroy_top_pointer_arrow() -> void:
	target_top_arrow_pointer.fly_away()
	target_top_arrow_pointer = null


func _on_health_changed(_name: String, _atk_owner_name: String):
	._on_health_changed(_name, _atk_owner_name)

	if _name != name  or _atk_owner_name == "":
		return
	SignalManager.emit_signal("camera_shake", 0.2, 30, 4)
	

func free_current_target() -> void:
	.free_current_target()

	if Utils.node_exists(target_top_arrow_pointer):
		destroy_top_pointer_arrow()


func use_equipment(_eq_name: String) -> void:
	var equipment: Dictionary = stats_manager.equipment_manager.equipment
	if equipment.has(_eq_name):
		var eq: Item = equipment[_eq_name]
		eq.item_use(self)


# region: Attack target checking
func get_another_atk_target(next: bool = true) -> bool:
	var sur_targets: Array = get_attack_targets(300)
	if sur_targets.size() == 0:
		return false
	
	var _tg: Actor = null
	if next:
		_tg = get_next_atk_target(sur_targets)
	else:
		_tg = get_prev_atk_target(sur_targets)
	
	if not Utils.node_exists(_tg):
		return false
	
	target_enemy(_tg, _tg.get_map_position())
	return true


func get_next_atk_target(sur_targets: Array) -> Actor:
	_current_target_id += 1
	if _current_target_id >= sur_targets.size():
		_current_target_id = 0
	var next_id: int = _current_target_id
	
	while not Utils.target_is_enemy(self, sur_targets[next_id]):
		next_id += 1
		if next_id >= sur_targets.size():
			next_id = 0
		
		if next_id == _current_target_id:
			return null
	
	_current_target_id = next_id
	return sur_targets[_current_target_id]


func get_prev_atk_target(sur_targets: Array) -> Actor:
	_current_target_id -= 1
	if _current_target_id < 0 or _current_target_id >= sur_targets.size():
		_current_target_id = sur_targets.size() - 1
	var next_id: int = _current_target_id
	
	while not Utils.target_is_enemy(self, sur_targets[next_id]):
		next_id -= 1
		if next_id < 0 or next_id >= sur_targets.size():
			next_id = sur_targets.size() - 1
		
		if next_id == _current_target_id:
			return null
	
	_current_target_id = next_id
	return sur_targets[_current_target_id]


func basic_attack() -> void:
	if not Utils.node_exists(attack_target):
		var find_success: bool = target_nearest_enemy()
		if find_success:
			attacking = true
	else:
		attacking = true

# endregion


# region: Day-Night reaction
# abstract
func _on_day_transition() -> void:
	enable_character_light()


# abstract
func _on_sunset_transition() -> void:
	enable_character_light()


# abstract
func _on_night_transition() -> void:
	enable_character_light()


# abstract
func _on_dawn_transition() -> void:
	enable_character_light()

# endregion


func die() -> void:
	dead = true
	play_animation("die")
	GameManager.save_load_manager.save_spawn_data()
	SignalManager.emit_signal("character_dead")


func get_input_direction() -> Vector2:
	return Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()
