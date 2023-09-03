extends State
class_name ActorState

var fallback_states = []
var non_fallbackable_states = ["hurt", "death", "attack"]

var character
var map_navigator

var remove_target_position = null


func _ready():
	SignalManager.connect("death", self, "_on_death")
	SignalManager.connect("skill_done", self, "_on_skill_done")


func transition_to_previous():
	state_machine.transition_to(previous_state if previous_state != null else "idle", previous_msg)


func physics_process(_delta):
	if character.velocity != Vector2.ZERO:
		var direction = Utils.angle_to_direction(character.velocity.angle())
		character.update_direction(direction)
	update_location()


func is_moved():
	return character.get_map_position() != character.previous_local_position


#Disable/Enable path point at _position with size(x,y), _disable = false for enable
func disable_points(_size: Vector2, _position: Vector2, _disable: bool = true):
	for x in range(_size.x):
		for y in range(_size.y):
			var _point = _position + Vector2(x, y)
			map_navigator.set_point_disabled(map_navigator.point_to_index(_point), _disable, character.current_navigator_use)


#Check host's local position and disable only the point where host stands
func update_location():
	map_navigator = character.map_manager.map_navigator
	if map_navigator == null:
		return

	#check if host moved
	if is_moved():
		character.global_position = character.convert_out_side_to_map(character.global_position)
		character.update_inside_map_position()
		character.previous_local_position = character.get_map_position()
		
		update_nogias_ysort()


func is_position_disabled_tiles_path(_local_position: Vector2, map_info) -> bool:
	return !map_info.is_walkable(_local_position, character.current_navigator_use)


func _on_death(_host_name):
	if _host_name == character.name and self == state_machine.state:
		character.dead = true
		state_machine.transition_to("die")


func _on_skill_done(_host_name, _skill: Skill):
	if _host_name != character.name or state_machine.state != self:
		return
	character.skill_activating = null


func character_stop():
	character.velocity = Vector2.ZERO


func update_nogias_ysort() -> void:
	character.update_sort_position(false)

