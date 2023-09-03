extends CanvasLayer

onready var control = $Control

onready var background = $Control/Background
onready var background_tween = $Control/Background/Tween

onready var title_label = $Control/TitleLabel
onready var title_label_tween = $Control/TitleLabel/Tween

onready var title_label_custom = $Control/TitleLabelCustom
onready var title_label_custom_tween = $Control/TitleLabelCustom/Tween

var blocking_input = "res://ui/scenes/BlockingInput.tscn"
var farm_path = "res://map/scenes/MapManager.tscn"
var base_path = "res://map/scenes/base/BaseManager.tscn"
var base_upgrade_path = "res://map/scenes/base/BaseUpgradeManager.tscn"
var mining_cave_path = "res://map/scenes/cave/MiningCaveManager.tscn"

var farm_title = "NOGIAS\nLand - 01"
var mining_cave_title = "NOGIAS\nMining Cave - 01"
var base_title = "NOGIAS\nHouse - 01"
var base_upgrade_title = "NOGIAS\nMansion House - 01"
var day_title = "DAY"
var night_title = "NIGHT"
var dawn_title = "DAWN"
var sunset_title = "SUNSET"
var ground_floor_title = "GROUND - FLOOR"
var first_floor_title = "1ST - FLOOR"
var second_floor_title = "2ND - FLOOR"

var background_tween_duration = .5
var title_tween_duration = .75
var title_custom_tween_duration = .25
var show_title_delay = .25
var hide_title_delay = 1

var is_open_scene: bool = true

var blocking_input_temp
var is_blocking_input: bool


func change_scene(scene_path, title_text):
	visible_background(true)
	fade_in_background()
	yield(background_tween, "tween_completed")
	reset_old_scene_data_before_change_into_new_scene()
	get_tree().change_scene(scene_path)
	SignalManager.emit_signal("scene_changed", scene_path)
	show_title(title_text)
	fade_out_background()
	yield(title_label_tween, "tween_completed")
	hide_title()
	yield(title_label_tween, "tween_completed")
	visible_background(false)
	destroy_blocking_input()


func open_scene(title_text):
	if is_open_scene:
		visible_background(true)
		fade_out_background()
		show_title(title_text)
		yield(title_label_tween, "tween_completed")
		hide_title()
		yield(title_label_tween, "tween_completed")
		visible_background(false)
		is_open_scene = false
		destroy_blocking_input()


func visible_background(visible):
	background.visible = visible


func fade_in_background():
	Utils.start_tween(background_tween, background, "color", Color( 0, 0, 0, 0 ), Color( 0, 0, 0, 1 ), background_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func fade_out_background():
	Utils.start_tween(background_tween, background, "color", Color( 0, 0, 0, 1 ), Color( 0, 0, 0, 0 ), background_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)


func show_title(title_text):
	title_label.visible = true
	title_label.text = title_text
	title_label_tween.stop_all()
	reset_title_percent_visible()
	Utils.start_tween(title_label_tween, title_label, "percent_visible", 0, 1, title_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, show_title_delay)


func hide_title():
	Utils.start_tween(title_label_tween, title_label, "percent_visible", 1, 0, title_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, hide_title_delay)


func reset_title_percent_visible():
	title_label.percent_visible = 0


func show_title_custom(title_text, show_delay):
	title_label_custom.visible = true
	title_label_custom.text = title_text
	title_label_custom_tween.stop_all()
	reset_title_percent_visible()
	Utils.start_tween(title_label_custom_tween, title_label_custom, "percent_visible", 0, 1, title_custom_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, show_delay)


func hide_title_custom(hide_delay):
	Utils.start_tween(title_label_custom_tween, title_label_custom, "percent_visible", 1, 0, title_custom_tween_duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, hide_delay)


func reset_title_custom_percent_visible():
	title_label_custom.percent_visible = 0


func change_status_custom(title_text, show_delay, hide_delay):
	show_title_custom(title_text, show_delay)
	yield(title_label_custom_tween, "tween_completed")
	hide_title_custom(hide_delay)


func spawn_blocking_input(map_manager):
	if not Utils.node_exists(blocking_input_temp):
		blocking_input_temp = Utils.load_resource(blocking_input, "blocking_input_panel", "scene").instance()
		map_manager.add_child(blocking_input_temp)
		is_blocking_input = true


func destroy_blocking_input():
	if Utils.node_exists(blocking_input_temp): 
		blocking_input_temp.queue_free()
		is_blocking_input = false

# remove anything before get into new scene
func reset_old_scene_data_before_change_into_new_scene():
	GameManager.object_hover_manager.hovering_objects.clear()
	Utils.stop_all_tweens()
	Utils.stop_all_coroutines()
	reset_title_percent_visible()
	reset_title_custom_percent_visible()


func init_loading_scene():
	var loading_scene = load("res://ui/scenes/LoadingScene.tscn").instance()
	get_tree().root.add_child(loading_scene)


func remove_loading_scene():
	if get_tree().root.get_node_or_null("LoadingScene") != null:
		get_tree().root.get_node_or_null("LoadingScene").queue_free()
