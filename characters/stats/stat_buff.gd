extends Node
class_name StatBuff

onready var life_timer = $Timer

onready var buff_manager: BuffManager = get_parent()
var stat_buffs: Dictionary = {}
var buff_name: String
var life_time: float


func _ready() -> void:
	life_timer.connect("timeout", self, "_on_buff_time_out")


func update_buff(_buffs: Dictionary, _buff_info: Dictionary):
	buff_name = _buff_info.buff_name
	life_time = _buff_info.buff_length
	stat_buffs = _buffs
	buff_start()


func buff_start():
	life_timer.start(life_time)


func _on_buff_time_out():
	buff_manager.delete_buff(buff_name)
	queue_free()
