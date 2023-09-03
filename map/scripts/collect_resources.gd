extends StaticResources
class_name CollectResources

signal ready_to_harvest()

enum HarvestStatus {FULL, EMPTY}

onready var harvest_timer: Timer = $HarvestTimer
var harvest_time_remain: int = 1
var harvest_status: int = HarvestStatus.EMPTY


func _init() -> void:
	resource_type = Constants.ResourceType.COLLECTABLE


func _ready() -> void:
	harvest_timer.connect("timeout", self, "_harvest_timer_time_out")


func start_harvest_wait_time(_time: float = 1):
	Utils.activate_timer(harvest_timer, _time)
	harvest_status = HarvestStatus.EMPTY


func harvest() -> void:
	if harvest_status == HarvestStatus.FULL:
		harvest_yield()
		harvest_time_remain -= 1
		if harvest_time_remain > 0:
			start_harvest_wait_time()
		else:
			run_out_of_harvest_time()
	else:
		print("not_ready_for_harvest")


func ready_to_harvest():
	harvest_status = HarvestStatus.FULL


func _harvest_timer_time_out():
	ready_to_harvest()


func run_out_of_harvest_time() -> void:
	pass


func harvest_yield():
	yield_item()
