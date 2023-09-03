extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var object = get_parent()

func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	if priority >= self.priority and frequency != 0:
		self.priority = priority
		self.amplitude = amplitude
		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()
		_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	Utils.start_tween($Tween, object, "offset", object.offset, rand, $Frequency.wait_time, TRANS, EASE)

func _reset():
	Utils.start_tween($Tween, object, "offset", object.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	priority = 0


func _on_Frequency_timeout():
	_new_shake()
	


func _on_Duration_timeout():
	_reset()
	$Frequency.stop() # Replace with function body.
