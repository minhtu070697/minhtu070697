extends Node2D
class_name PointerTopArrow

onready var tween := $Tween
onready var sprite := $SpriteHolder/Sprite
onready var fade_area: Area2D = $Area2D
onready var animation_player: AnimationPlayer = $AnimationPlayer

const FLY_DIRECTION_LIMIT: Vector2 = Vector2(110, 60)


func _ready() -> void:
	var _inside_fade_area_bodies: Array = fade_area.get_overlapping_bodies()
	for _body in _inside_fade_area_bodies:
		if _body.name == "Character":
			fade(true)
			return


func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Character":
		fade(true)

func _on_Area2D_body_exited(body: Node) -> void:
	if body.name == "Character":
		fade(false)


func fade(_fade: bool) -> void:
	if _fade:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.3, 0.15)
	else:
		Utils.transparent_object_between_camera_and_player(sprite, tween, 0.3, 1, 0.15)


func fly_away() -> void:
	scale.x *= Utils.random_int(0,1) * 2 - 1
	Utils.start_tween(tween, sprite, "position", sprite.position, Vector2(3, 10), 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT_IN)
	fade_area.queue_free()
	Utils.play_animation(animation_player, "fly_away")


func free() -> void:
	queue_free()

func tween_fly_away() -> void:
	var fly_direction: Vector2 = Vector2(Utils.random_int(20, FLY_DIRECTION_LIMIT.x), - Utils.random_int(10, FLY_DIRECTION_LIMIT.y))
	Utils.start_tween(tween, sprite, "position", sprite.position, sprite.position + fly_direction, 0.75, Tween.TRANS_SINE, Tween.EASE_OUT_IN)


func move_to_target(_target: Node, _hover_height: Vector2 = Vector2(0, 0)) -> void:
	if !_target.get("sprite"):
		return
	
	var _target_sprite: Sprite = _target.sprite
	if _target.get("sprite_size"):
		global_position = Vector2(0, _target_sprite.texture.get_height() / 2.0) + _target_sprite.offset + _target_sprite.position + _target.global_position - _target.sprite_size + Vector2(0, -30) - _hover_height
	else:
		global_position = - Vector2(0, _target_sprite.texture.get_height() / 2.0) + _target_sprite.offset + _target_sprite.position + _target.global_position + Vector2(0, -30) - _hover_height


func set_pointer_scale(_scale_x: float, _scale_y: float = 99999999) -> void:
	scale.x = _scale_x
	scale.y = _scale_y if _scale_y != 99999999 else _scale_x


func set_pointer_transparent(_alpha: float) -> void:
	sprite.self_modulate.a = _alpha
