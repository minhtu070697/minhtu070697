extends Character
class_name BattleFieldCharacter

export var idle_frame: int = 1
export var run_frame: int = 1
export var basic_attack_frame: int = 1
export var casting_frame: int = 1
export var teleport_frame: int = 1


func _ready() -> void:
	animation_frames["idle"] = idle_frame
	animation_frames["run"] = run_frame
	animation_frames["basic_melee_attack"] = basic_attack_frame
	animation_frames["casting"] = casting_frame
	animation_frames["teleport"] = teleport_frame
	update_direction(Constants.Direction.DOWN)
	update_direction(Constants.Direction.DOWN_SIDE)

