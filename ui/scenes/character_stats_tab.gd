extends Node2D
class_name CharacterStatsTab

const TAB_BUTTON_FOCUS_COLOR_MODULATE = Color(0.45, 0.45, 0.45, 1)
const TAB_BUTTON_UNFOCUS_COLOR_MODULATE = Color(0.13, 0.13, 0.13, 1)


#var
onready var ui_manager = get_parent().get_parent()
onready var character = ui_manager.get_parent()
onready var background
onready var tween = $Tween
var stats_manager: StatsManager

onready var stats_button 
onready var close_stats_button = $ButtonClose

#stat tabs
onready var stat_tab1 := $InfoContainer/StatTab1Container
onready var stat_tab2 := $InfoContainer/StatTab2Container
onready var stat_tab3 := $InfoContainer/StatTab3Container

#info
onready var character_name = $InfoContainer/NameLevelContainer/NameAndPotential/Name/NameValue
onready var character_lvl = $InfoContainer/NameLevelContainer/LevelAndStatPoints/Level/LvlValue

onready var potential = $InfoContainer/NameLevelContainer/NameAndPotential/Potential/PotentialValue

#primary stats
onready var str_button = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Strength/StrengthButton
onready var str_text = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Strength/StrengthValue

onready var agi_button = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Agility/AgilityButton
onready var agi_text = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Agility/AgilityValue

onready var int_button = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Intelligence/IntelligenceButton
onready var int_text = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Intelligence/IntelligenceValue

onready var vit_button = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Vitality/VitalityButton
onready var vit_text = $InfoContainer/StatTab1Container/Stats/PrimaryStats/Vitality/VitalityValue

#derived stats
onready var p_armor = $InfoContainer/StatTab1Container/Stats/DerivedStats/PArmor/PArmorValue
onready var m_armor = $InfoContainer/StatTab1Container/Stats/DerivedStats/MArmor/MArmorValue
onready var accuracy = $InfoContainer/StatTab1Container/Stats/DerivedStats/Accuracy/AccuracyValue
onready var evasion = $InfoContainer/StatTab1Container/Stats/DerivedStats/Evasion/EvasionValue

onready var p_dmg = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/PDmg/PDmgValue
onready var m_dmg = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/MDmg/MDmgValue
onready var crit_rate = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/CritRate/CritRateValue
onready var crit_dmg = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/CritDmg/CritDmgValue
onready var atk_speed = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/AttackSpeed/AtkSpeedValue
onready var walk_speed = $InfoContainer/StatTab1Container/DerivedStats2/CombatStats/WalkSpeed/WalkSpeedValue

onready var craft_rating := $InfoContainer/StatTab3Container/StatTab3Container/StatTab3Container/ElementalDmgs/CraftRating/CraftRating/CraftRatingValue

onready var available_stat_point_value = $InfoContainer/NameLevelContainer/LevelAndStatPoints/AvailableStatPoint/AvailableStatPointValue
onready var available_stat_point_box = $InfoContainer/NameLevelContainer/LevelAndStatPoints/AvailableStatPoint

onready var cancel_button = $InfoContainer/StatTab1Container/Buttons/Cancel/CancelButton
onready var ok_button = $InfoContainer/StatTab1Container/Buttons/Cancel/OKButton

onready var rarity_stars: Array = $HBoxContainer.get_children()
var rarity_stars_set: bool = false

onready var tab1_button := $TabButtonsContainer/TabButton1
onready var tab2_button := $TabButtonsContainer/TabButton2
onready var tab3_button := $TabButtonsContainer/TabButton3

var stat_tab_list: Array
var tab_button_list: Array

var selecting_tab: int = 1
onready var skill_tab

var refundable_spended_stat_points: Dictionary = {
	"strength": 0,
	"agility": 0,
	"intelligence": 0,
	"vitality": 0,
}


func _ready() -> void:
	# ui
	stats_button = ui_manager.get_node_or_null("GroupHUD").get_node_or_null("StatsButton")
	background = get_parent().get_node_or_null("Background")
	skill_tab = get_parent().get_node_or_null("CharacterSkillTab")

	# logic
	str_button.connect("button_up", self, "_on_str_button_clicked")
	agi_button.connect("button_up", self, "_on_agi_button_clicked")
	int_button.connect("button_up", self, "_on_int_button_clicked")
	vit_button.connect("button_up", self, "_on_vit_button_clicked")
	cancel_button.connect("button_up", self, "_on_cancel_button_clicked")
	ok_button.connect("button_up", self, "_on_ok_button_clicked")
	tab1_button.connect("button_up", self, "_on_tab1_button_clicked")
	tab2_button.connect("button_up", self, "_on_tab2_button_clicked")
	tab3_button.connect("button_up", self, "_on_tab3_button_clicked")
	SignalManager.connect("update_character_stats_tab", self, "_on_update_character_stats_tab")
	stats_manager = character.get_node_or_null("StatsManager")
	if Utils.node_exists(stats_button): stats_button.connect("button_up", self, "_on_stats_button_clicked", [stats_button])
	close_stats_button.connect("button_up", self, "_on_stats_button_clicked", [close_stats_button])
	stat_tab_list = [stat_tab1, stat_tab2, stat_tab3]
	tab_button_list = [tab1_button, tab2_button, tab3_button]


func select_tab(_tab_num: int):
	if _tab_num - 1 >= stat_tab_list.size():
		return
	for i in stat_tab_list.size():
		if i == _tab_num - 1:
			stat_tab_list[i].visible = true
			selecting_tab = _tab_num
			set_tab_button_color(i, true)
			continue
		
		stat_tab_list[i].visible = false
		set_tab_button_color(i, false)


func set_tab_button_color(_button_num: int, _focus: bool):
	tab_button_list[_button_num].self_modulate = TAB_BUTTON_FOCUS_COLOR_MODULATE if _focus else TAB_BUTTON_UNFOCUS_COLOR_MODULATE


func set_rarity_stars():
	var _yellow_star_sprite = load("res://ui/textures/star-icon-yellow.png")
	for i in stats_manager.stats.rarity:
		rarity_stars[i].texture = _yellow_star_sprite


func update_lvl():
	character_lvl.text = Utils.to_text(stats_manager.stats.lvl)


func update_potential():
	potential.text = String(stepify(stats_manager.stats.potential, 0.01))


func update_character_stats():
	update_lvl()
	update_primary_stats()
	update_derived_stats()
	update_stat_buttons()
	if !rarity_stars_set:
		set_rarity_stars()
		rarity_stars_set = true


func update_primary_stats():
	update_str()
	update_agi()
	update_int()
	update_vit()
	update_potential()


func update_str():
	str_text.text = Utils.to_text(stats_manager.stats.strength)

func update_agi():
	agi_text.text = Utils.to_text(stats_manager.stats.agility)

func update_int():
	int_text.text = Utils.to_text(stats_manager.stats.intelligence)

func update_vit():
	vit_text.text = Utils.to_text(stats_manager.stats.vitality)


func update_derived_stats():
	update_p_armor()
	update_m_armor()
	update_accuracy()
	update_evasion()
	update_p_dmg()
	update_m_dmg()
	update_crit_rate()
	update_crit_dmg()
	update_atk_speed()
	update_walk_speed()
	update_available_stat_points()


func update_p_armor():
	p_armor.text = Utils.to_text(stats_manager.stats.p_armor_rating)

func update_m_armor():
	m_armor.text = Utils.to_text(stats_manager.stats.m_armor_rating)

func update_accuracy():
	accuracy.text = Utils.to_text(stats_manager.stats.accuracy_rate)

func update_evasion():
	evasion.text = Utils.to_text(stats_manager.stats.evasion_rate)

func update_p_dmg():
	var _p_dmg_diff = stats_manager.equipment_manager.equipment.weapon.stats.p_dmg_diff if stats_manager.equipment_manager.equipment.has("weapon") else 0.0
	p_dmg.text = Utils.to_text(stats_manager.stats.p_atk * (1 - _p_dmg_diff)) + " - " + Utils.to_text(stats_manager.stats.p_atk * (1 + _p_dmg_diff))

func update_m_dmg():
	var _m_dmg_diff = stats_manager.equipment_manager.equipment.weapon.stats.m_dmg_diff if stats_manager.equipment_manager.equipment.has("weapon") else 0.0
	m_dmg.text = Utils.to_text(stats_manager.stats.m_atk * (1 - _m_dmg_diff)) + " - " + Utils.to_text(stats_manager.stats.m_atk * (1 + _m_dmg_diff))

func update_crit_rate():
	crit_rate.text = Utils.to_text(stats_manager.stats.crit_rate)

func update_crit_dmg():
	crit_dmg.text = Utils.to_text_percent(stats_manager.stats.crit_dmg)

func update_atk_speed():
	atk_speed.text = Utils.to_text_percent(stats_manager.stats.atk_speed)

func update_walk_speed():
	walk_speed.text = Utils.to_text_percent(stats_manager.stats.walk_speed / Constants.DEFAULT_WALK_SPEED)

func update_available_stat_points():
	available_stat_point_box.visible = stats_manager.stats.available_stat_point > 0
	available_stat_point_value.text = Utils.to_text(stats_manager.stats.available_stat_point)


func update_stat_buttons():
	str_button.visible = stats_manager.stats.available_stat_point > 0
	agi_button.visible = str_button.visible
	int_button.visible = str_button.visible
	vit_button.visible = str_button.visible

func set_visible_cancel_ok_buttons(_visible: bool = true):
	cancel_button.visible = _visible
	ok_button.visible = _visible


func _on_stats_button_clicked(btn) -> void:
	if ui_manager.not_holding_build_object():
		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.75, 0.75),  0.1)

		# logic
		is_stats_tab_available()
		if Utils.is_in_buildable_map(character.map_manager.map_type): character.map_manager.check_disable_remove_item_choosing()
		

func is_stats_tab_available():
	if visible:
		hide_stats()
	else:
		show_stats()
		update_character_stats()


func show_stats():
	#animate
	self.visible = true
	background.visible = true
	skill_tab.visible = true
	skill_tab.update_character_skills()
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(tween, background, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(tween, skill_tab, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	ui_manager.is_ui_tweening = true
	yield(tween, "tween_completed")
	ui_manager.is_ui_tweening = false


func hide_stats():
	Utils.start_tween(tween, self, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(tween, background, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.start_tween(tween, skill_tab, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	ui_manager.is_ui_tweening = true
	yield(tween, "tween_completed")
	self.visible = false
	background.visible = false
	skill_tab.visible = false
	ui_manager.is_ui_tweening = false


func _on_update_character_stats_tab(_character_name):
	if _character_name != character or !visible:
		return
	
	match selecting_tab:
		1: update_character_stats()
		2: update_stat_tab_2()


func _on_str_button_clicked():
	use_stat_point("strength")
	update_character_stats()
	set_visible_cancel_ok_buttons()

func _on_agi_button_clicked():
	use_stat_point("agility")
	update_character_stats()
	set_visible_cancel_ok_buttons()

func _on_int_button_clicked():
	use_stat_point("intelligence")
	update_character_stats()
	set_visible_cancel_ok_buttons()

func _on_vit_button_clicked():
	use_stat_point("vitality")
	update_character_stats()
	set_visible_cancel_ok_buttons()

func _on_cancel_button_clicked():
	refund_stat()
	set_visible_cancel_ok_buttons(false)

func _on_ok_button_clicked():
	reset_refundable_stat()
	set_visible_cancel_ok_buttons(false)


func use_stat_point(_stat: String):
	if stats_manager.stats.available_stat_point <= 0:
		return
	
	stats_manager.stats.use_stat_point(_stat)
	refundable_spended_stat_points[_stat] += 1


func refund_stat() -> void:
	for _stat in refundable_spended_stat_points:
		stats_manager.stats.refund_stat_point(_stat, refundable_spended_stat_points[_stat])
	reset_refundable_stat()


func total_refundable_stat() -> int:
	var _total = 0
	for _stat_num in refundable_spended_stat_points.values():
		_total += _stat_num
	return _total


func reset_refundable_stat() -> void:
	for _stat in refundable_spended_stat_points:
		refundable_spended_stat_points[_stat] = 0


func _on_tab1_button_clicked() -> void:
	select_tab(1)
	update_character_stats()


func _on_tab2_button_clicked() -> void:
	select_tab(2)
	update_stat_tab_2()


func _on_tab3_button_clicked() -> void:
	select_tab(3)
	update_stat_tab_3()

#tab 2 function

func update_stat_tab_2() -> void:
	pass


func update_stat_tab_3() -> void:
	update_craft_rating()


func update_craft_rating() -> void:
	craft_rating.text = Utils.to_text(stats_manager.stats.craft_rating)


