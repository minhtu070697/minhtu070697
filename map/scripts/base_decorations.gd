extends Decorations
class_name BaseDecorations

var	sprite_positions = {}
var collisions = []

#region: collisions
func fade(body, is_out:bool):
	if body.get_name() == "Character":
		if is_out:
			Utils.transparent_object_between_camera_and_player(sprite, tween, 1, 0.4, 0.15)
		else:
			Utils.transparent_object_between_camera_and_player(sprite, tween, 0.4, 1, 0.15)

func disable_collisions():
	for i in range(collisions.size()):
		collisions[i].disabled = true

#endregion
