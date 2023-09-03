extends Camera2D

# Constants
const SHAKE_CAM_MAX_RANGE: int = 500

# Shake Vfx
onready var shake_vfx = $Shake

# Hit Vfx
onready var hit_vfx: TextureRect = $HitVfx


func _ready() -> void:
	SignalManager.connect("camera_shake", self, "camera_shake")


# region: Shake Vfx
func camera_shake(duration: float = 0.2, freq: float = 15.0, amp: float = 16.0, source_pos: Vector2 = Vector2.INF, priority: int = 0) -> void:
	if source_pos != Vector2.INF:
		var distance: float = source_pos.distance_to(global_position)
		var effects: float = 1 - min(1, distance / SHAKE_CAM_MAX_RANGE)
		freq *= effects
		amp *= effects
	
	shake_vfx.start(duration, freq, amp, priority)
# endregion


# region: Hit Vfx
func activate_hit_vfx() -> void:
	pass
# endregion

