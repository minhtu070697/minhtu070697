extends Node2D

# Constants
enum State {HIDDEN, HIDING, SHOWED}

# Vars
onready var hp_bar: TextureProgress = $HealthBar
onready var hp_bar_under: TextureProgress = $HealthBarUnder
onready var tween: Tween = $Tween
onready var timer: Timer = $Timer

var host
var stats_manager: FighterStatsManager
var current_state: int = State.HIDDEN


func _ready() -> void:
	host = get_parent()
	yield(host, "ready")
	set_up_stats_manager()
	timer.connect("timeout", self, "_on_timer_timeout")


func set_up_stats_manager() -> void:
	stats_manager = host.get("stats_manager")
	if stats_manager == null:
		queue_free()
		return
	connect_stats_signals()


func connect_stats_signals() -> void:
	if not stats_manager.stats.is_connected("health_changed", self, "_on_health_changed"):
		stats_manager.stats.connect("health_changed", self, "_on_health_changed")


func disconnect_stats_signals() -> void:
	if stats_manager.stats.is_connected("health_changed", self, "_on_health_changed"):
		stats_manager.stats.disconnect("health_changed", self, "_on_health_changed")


func update_hp_bar(val: float) -> void:
	if current_state != State.SHOWED:
		activate()
	hp_bar.value = val
	Utils.start_tween(tween, hp_bar_under, "value", hp_bar_under.value, val, 0.4)
	Utils.activate_timer(timer, 2, true)


func get_meter_percent(value: int, max_val: int) -> float:
	if max_val == 0:
		return -1.0
	else:
		return float(value) / max_val 


func _on_health_changed() -> void:
	var val: float = get_meter_percent(stats_manager.stats.hp, stats_manager.stats.max_hp) * 100
	update_hp_bar(val)


func _on_timer_timeout() -> void:
	if current_state == State.SHOWED:
		deactivate()


func deactivate() -> void:
	current_state = State.HIDING
	Utils.start_tween(tween, self, "modulate:a", modulate.a, 0, 0.7)
	yield(tween, "tween_all_completed")
	
	if current_state == State.HIDING:
		visible = false
		current_state = State.HIDDEN


func activate() -> void:
	current_state = State.SHOWED
	tween.remove_all()
	visible = true
	Utils.start_tween(tween, self, "modulate:a", modulate.a, 1.0, 0.7)
