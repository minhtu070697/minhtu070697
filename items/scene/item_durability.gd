extends Node2D

# Constants
enum State {HIDDEN, HIDING, SHOWED}
const HIDE_POSITION: Vector2 = Vector2(120, 0)
const SHOW_POSITION: Vector2 = Vector2(0, 0)

# Vars
var current_item_name: String = ""
var current_state: int = State.HIDDEN
var show_threshold: float = 1.0

onready var holder: Node2D = $Holder
onready var dura_meter: TextureProgress = $Holder/DurableMeter
onready var dura_label: Label = $Holder/DurableLabel
onready var item_icon: TextureRect = $Holder/ItemIcon
onready var timer: Timer = $Timer
onready var tween: Tween = $Tween


func _ready() -> void:
	SignalManager.connect("durability_changed", self, "_update_all")
	timer.connect("timeout", self, "_on_timer_timeout")


func _update_all(item_name: String, old_dura: int, new_dura: int, max_dura: int) -> void:
	if get_meter_percent(new_dura, max_dura) > show_threshold:
		return
	
	if current_state != State.SHOWED:
		activate()
	
	if item_name != current_item_name:
		current_item_name = item_name
		update_item_icon(item_name)
	
	update_item_durability(old_dura, new_dura, max_dura)
	Utils.activate_timer(timer, 2, true)


func get_meter_percent(value: int, max_val: int) -> float:
	if max_val == 0:
		return -1.0
	else:
		return float(value) / max_val


func update_item_icon(item_name: String) -> void:
	# print("up item icon: ", item_name)
	item_icon.texture = Utils.load_resource(Constants.ITEM_TEXTURE_PATH %item_name, "item_icon", item_name)


func update_item_durability(old_dura: int, new_dura: int, max_dura: int) -> void:
	dura_label.text = String(new_dura)
	dura_meter.max_value = max_dura
	dura_meter.value = new_dura


func _on_timer_timeout() -> void:
	if current_state == State.SHOWED:
		deactivate()


func deactivate() -> void:
	current_state = State.HIDING
	Utils.start_tween(tween, holder, "position", holder.position, HIDE_POSITION, 1.0, Tween.TRANS_BACK, Tween.EASE_IN)
	yield(tween, "tween_all_completed")
	
	if current_state == State.HIDING:
		visible = false
		current_state = State.HIDDEN


func activate() -> void:
	current_state = State.SHOWED
	tween.remove_all()
	visible = true
	Utils.start_tween(tween, holder, "position", holder.position, SHOW_POSITION, 0.25, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
