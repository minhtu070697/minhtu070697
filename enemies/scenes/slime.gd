extends Enemy
class_name Slime

enum moving_states {IDLE, CRAWL_FORWARD, PULL_BACKWARD}

var moving_state = moving_states.IDLE
onready var state_machine = $States
export(String) var spawn_children_name := ""

func _ready() -> void:
	SignalManager.connect("run_finished", self, "_on_run_finished")


func _on_run_finished(_host_name: String = ""):
	if name != _host_name:
		return
	
	velocity = Vector2.ZERO
	state_machine.transition_to("idle")


func crawl_forward():
	moving_state = moving_states.CRAWL_FORWARD


func pull_backward():
	moving_state = moving_states.PULL_BACKWARD


func idle():
	moving_state = moving_states.IDLE


func seek(target_position: Vector2):
	if global_position.distance_to(target_position) <= Steering.DEFAULT_STOP_THRESHOLD:
		velocity = Vector2.ZERO
	else:
		velocity += Steering.seek(velocity, global_position, target_position, stats_manager.stats.walk_speed)
		
	
func check_and_move(delta) -> void:
	if get_combined_velocity() == Vector2.ZERO:
		return

	match moving_state:
		moving_states.CRAWL_FORWARD:
			velocity *= 2.0
		moving_states.PULL_BACKWARD:
			velocity /= 4.5
	
	if movable(delta, get_combined_velocity()):
		move()
	else:
		slide_at_disable_tile_edge(delta)
	
	match moving_state:
		moving_states.CRAWL_FORWARD:
			velocity /= 2.0


func spawn_children():
	if spawn_children_name == "":
		return
		
	GameManager.enemy_manager.enemy_generator.spawn_monsters(spawn_children_name, get_map_position(), max(1, stats_manager.stats.lvl - 5), 2)
	
