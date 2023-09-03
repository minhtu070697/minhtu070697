extends FarmDecorations

onready var animate_sprite: Sprite = $AnimateSprite
onready var animation_player = $AnimateSprite/AnimationPlayer
onready var pointer = $Sprite/Pointer

onready var collision_house = $Sprite/Area2D_House/CollisionPolygon2D
onready var collision_farm_house = $Sprite/Area2D_Farm_House/CollisionPolygon2D
onready var collision_medium_house = $Sprite/Area2D_Medium_House/CollisionPolygon2D
onready var collision_windmill_house = $AnimateSprite/Area2D_WindMill_House/CollisionPolygon2D
onready var collision_green_house = $Sprite/Area2D_Green_House/CollisionPolygon2D
onready var collision_storage_house = $Sprite/Area2D_Storage_House/CollisionPolygon2D
onready var collision_dock_house = $Sprite/Area2D_Dock_House/CollisionPolygon2D

onready var collision_area_house = $Sprite/Area2D_House
onready var collision_area_farm_house = $Sprite/Area2D_Farm_House
onready var collision_area_medium_house = $Sprite/Area2D_Medium_House
onready var collision_area_windmill_house = $AnimateSprite/Area2D_WindMill_House
onready var collision_area_green_house = $Sprite/Area2D_Green_House
onready var collision_area_storage_house = $Sprite/Area2D_Storage_House
onready var collision_area_dock_house = $Sprite/Area2D_Dock_House

var collisions = []
var collision_areas: Array = []
var faded: bool = false


func _init():
	sprite_names = {
		"house": Vector2(4, 4),
		"farm_house": Vector2(5, 6),
		"medium_house": Vector2(10, 10),
		"windmill_house": Vector2(3, 7),
		"green_house": Vector2(5, 5),
		"storage_house": Vector2(3, 6),
		"dock_house": Vector2(3, 5),
	}
	sprite_build_positions = {
		"house": Vector2(0, -60),
		"farm_house": Vector2(0, -70),
		"medium_house": Vector2(0, -135),
		"windmill_house": Vector2(-20, -125),
		"green_house": Vector2(0, -53),
		"storage_house": Vector2(0, -85),
		"dock_house": Vector2(0, -43),
	}
	sprite_spawn_positions = {
		"house": Vector2(0, -60),
		"farm_house": Vector2(0, -70),
		"medium_house": Vector2(0, -135),
		"windmill_house": Vector2(-20, -125),
		"green_house": Vector2(0, -53),
		"storage_house": Vector2(0, -85),
		"dock_house": Vector2(0, -43),
	}

	sprite_name = Utils.random_from_dict(sprite_names)
	size = sprite_names[sprite_name]


func _ready():
	load_texture()
	load_sprite_position()
	enable_pointer()
	append_collisions()
	enable_collisions()

	btn_remove.connect("pressed", self, "on_click_button_remove_local")


func load_texture():
	texture_file = "res://map/textures/objects/house/%s.png"
	get_sprite().texture = load(texture_file % sprite_name)
	play_animation()


func load_sprite_position():
	if is_reload:
		get_sprite().position = sprite_build_positions[sprite_name]
	else:
		get_sprite().position = sprite_spawn_positions[sprite_name]


func re_load(sprite_name, _is_build):
	if is_reload:
		self.sprite_name = sprite_name
		size = sprite_names[self.sprite_name]
		load_texture()
		load_sprite_position()
		enable_pointer()
		disable_collisions()
		enable_collisions()


func get_sprite():
	if sprite_name == "windmill_house":
		animate_sprite.visible = true
		sprite.visible = false
		return animate_sprite
	else:
		animate_sprite.visible = false
		sprite.visible = true
		return sprite


func append_collisions():
	collisions.append_array(
		[
			collision_house,
			collision_farm_house,
			collision_medium_house,
			collision_windmill_house,
			collision_green_house,
			collision_storage_house,
			collision_dock_house
		]
	)
	collision_areas.append_array(
		[
			collision_area_house,
			collision_area_farm_house,
			collision_area_medium_house,
			collision_area_windmill_house,
			collision_area_green_house,
			collision_area_storage_house,
			collision_area_dock_house
		]
	)


func enable_collisions():
	var _sprite_name_list: Array = sprite_names.keys()
	for i in _sprite_name_list.size():
		collisions[i].disabled = not sprite_name == _sprite_name_list[i]
		collision_areas[i].visible = sprite_name == _sprite_name_list[i]
		
		if not sprite_name == _sprite_name_list[i]:
			set_obj_main_collision(collisions[i])


func disable_collisions():
	for i in range(collisions.size()):
		collisions[i].disabled = true


func fade(is_out: bool):
	if is_out:
		Utils.transparent_object_between_camera_and_player(get_sprite(), tween, 1, 0.4, 0.15)
	else:
		Utils.transparent_object_between_camera_and_player(get_sprite(), tween, 0.4, 1, 0.15)

	faded = is_out


func play_animation():
	if is_animation_available():
		animation_player.play("windmill")


func is_animation_available():
	return sprite_name == "windmill_house"


func _on_Area2D_House_body_entered(body):
	if Utils.is_character_enter_collision(body):
		if !faded:
			fade(true)
		# ex: show home button
		body.ui_manager.visible_button_home(true)


func _on_Area2D_House_body_exited(body):
	if Utils.is_character_enter_collision(body):
		if faded and Utils.is_character_enter_collision(body):
			fade(false)
		# ex: hide home button
		body.ui_manager.visible_button_home(false)


func _on_Area2D_Farm_House_body_entered(_body):
	if !faded and Utils.is_character_enter_collision(_body):
		fade(true)


func _on_Area2D_Farm_House_body_exited(_body):
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)


func _on_Area2D_Medium_House_body_entered(body):
	if Utils.is_character_enter_collision(body):
		if !faded and Utils.is_character_enter_collision(body):
			fade(true)
		# ex: show home button
		body.ui_manager.visible_button_home_upgrade(true)


func _on_Area2D_Medium_House_body_exited(body):
	if Utils.is_character_enter_collision(body):
		if faded and Utils.is_character_enter_collision(body):
			fade(false)
		# ex: hide home button
		body.ui_manager.visible_button_home_upgrade(false)


func _on_Area2D_WindMill_House_body_entered(_body):
	if !faded and Utils.is_character_enter_collision(_body):
		fade(true)


func _on_Area2D_WindMill_House_body_exited(_body):
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)


func _on_Area2D_Green_House_body_entered(_body):
	if !faded and Utils.is_character_enter_collision(_body):
		fade(true)


func _on_Area2D_Green_House_body_exited(_body):
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)


func _on_Area2D_Storage_House_body_entered(_body):
	if !faded and Utils.is_character_enter_collision(_body):
		fade(true)


func _on_Area2D_Storage_House_body_exited(_body):
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)


func _on_Area2D_Dock_House_body_entered(_body):
	if !faded and Utils.is_character_enter_collision(_body):
		fade(true)


func _on_Area2D_Dock_House_body_exited(_body):
	if faded and Utils.is_character_enter_collision(_body):
		fade(false)


func is_having_pointer():
	return sprite_name == "house" or sprite_name == "medium_house"


func enable_pointer():
	if is_having_pointer():
		pointer.visible = true
		play_pointer_animation()
	else:
		pointer.visible = false


func play_pointer_animation():
	var pointer_animation = pointer.get_node_or_null("AnimationPlayer")
	if Utils.node_exists(pointer_animation):
		pointer_animation.play(sprite_name + "_pointer")
