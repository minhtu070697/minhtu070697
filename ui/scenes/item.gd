extends Node2D
class_name InventoryItem


# Signals
signal amount_changed(amount_change, new_amount)
signal item_updated(new_stats)


# Vars
onready var amount_label = $Amount
onready var texture_rect = $TextureRect
onready var item_vfx = $VFX
onready var character := find_parent("Character")

var item_name
var item_amount
var cooking_energy: int = 0

var item_info: Item setget set_item_info

#NUYG: tooltip var
onready var tooltip := $Tooltip
onready var tt_item_name := $Tooltip/VBoxContainer/VBoxContainer/ItemName
onready var tt_item_desc := $Tooltip/VBoxContainer/VBoxContainer/ItemDesc
onready var tt_item_lvl := $Tooltip/VBoxContainer/VBoxContainer/ItemLvl
onready var tt_item_rarity := $Tooltip/VBoxContainer/VBoxContainer/ItemRarity
onready var tt_item_atk_range := $Tooltip/VBoxContainer/VBoxContainer/ItemAtkRange
onready var tt_item_atk_speed := $Tooltip/VBoxContainer/VBoxContainer/ItemAtkSpeed
onready var tt_item_p_dmg := $Tooltip/VBoxContainer/VBoxContainer/ItemPDmg
onready var tt_item_m_dmg := $Tooltip/VBoxContainer/VBoxContainer/ItemMDmg
onready var tt_item_reforge_time := $Tooltip/VBoxContainer/VBoxContainer/ItemReforgeTime
onready var tt_item_durability: Label = $Tooltip/VBoxContainer/VBoxContainer/ItemDurability

onready var tt_item_cooking_energy: Label = $Tooltip/VBoxContainer/VBoxContainer/ItemCEnergy
onready var tt_item_lvl_require := $Tooltip/VBoxContainer/VBoxContainer2/ItemLvlRequire

onready var tooltip_container := $Tooltip/VBoxContainer
onready var tt_item_stats_box := $Tooltip/VBoxContainer/ItemStatsBox
onready var item_icon_texture := $TextureRect

var item_stat_labels : Dictionary = {}
var item_buff_labels : Dictionary = {}
var item_consume_effect_labels: Dictionary = {}
var ignore_stats: Array = ["p_dmg", "m_dmg"]
var percent_stats: Array = ["atk_speed_add", "crit_dmg_add", "walk_speed_add", "freeze_strength"]

var tt_buff_length_label: Label


# Constants
enum tooltip_stat_type {NORMAL, PERCENT}


func _ready():
	tooltip.rect_size.y = 10


func set_item_info(new_item_info) -> void:
	if item_info:
		disconnect_item_info_signals()
	
	item_info = new_item_info

	if item_info:
		connect_item_info_signals()


func connect_item_info_signals() -> void:
	if item_info and not item_info.is_connected("broken", self, "_on_an_item_broken"):
		item_info.connect("broken", self, "_on_an_item_broken")
		item_info.connect("item_updated", self, "_on_item_updated")


func disconnect_item_info_signals() -> void:
	if item_info and item_info.is_connected("broken", self, "_on_an_item_broken"):
		item_info.disconnect("broken", self, "_on_an_item_broken")
		item_info.disconnect("item_updated", self, "_on_item_updated")


#lam tiep o day, dua them load data vao
#NUYG: add _item_lvl to generate item with this lvl, para come with default value so it doesn't affect other calls
func set_item(_name, amount, data: Dictionary = {}, _item_lvl: int = 1):
	item_name = _name
	item_amount = amount
	texture_rect.texture = Utils.load_resource(Constants.ITEM_TEXTURE_PATH %item_name, "item_icon", item_name)
	check_show_vfx(_name)
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		amount_label.visible = false
	else:
		amount_label.visible = true
		amount_label.text = String(item_amount)
		
	load_cooking_energy(data)

	if not JsonData.item_data[item_name].has("ItemInfo"):
		return
	
	if (item_info != null and item_info.item_name == JsonData.item_data[item_name]["ItemInfo"]):
		return
	#create item stat
	set_item_info(Item.new(JsonData.item_data[item_name]["ItemInfo"], data, _item_lvl))
	connect_item_info_signals()
	create_tooltip_stats()
	update_tooltip()


func load_cooking_energy(data: Dictionary) -> void:
	if data.empty() or not data.info.has("cooking_energy"):
		if JsonData.item_data[item_name].has("CookingEnergy"):
			cooking_energy = JsonData.item_data[item_name]["CookingEnergy"]
		else:
			cooking_energy = 0
	else:
		cooking_energy = data.info.cooking_energy


func get_item_stats() -> Dictionary:
	var _stats: Dictionary = {}
	if not item_info == null:
		_stats = item_info.get_item_stats()
	
	if cooking_energy > 0:
		_stats["info"]["cooking_energy"] = cooking_energy
	# print(item_name, " stats: ", _stats)
	return _stats


func add_item_amount(amount_to_add):
	item_amount += amount_to_add
	emit_signal("amount_changed", amount_to_add, item_amount)
	amount_label.text = String(item_amount)


func decrease_item_amount(amount_to_remove):
	item_amount -= amount_to_remove
	amount_label.text = String(item_amount)


func set_item_amount(amount_to_set):
	item_amount = amount_to_set
	amount_label.text = String(item_amount)


func check_show_vfx(item_name):
	var item_category = String(JsonData.item_data[item_name]["ItemCategory"])
	if item_category == "Hair" or item_category == "Shirt" or item_category == "Pants" or item_category == "Weapon" or item_category == "Fishing_Rod" or item_category == "Axe" or item_category == "Pick" or item_category == "Hoe":
		show_vfx(true)


func show_vfx(is_show: bool):
	item_vfx.visible = is_show


#NUYG: Tooltip function
func update_tooltip():
	tooltip.rect_size.y = 10
	tt_item_name.text = item_info.item_info.item_name.capitalize()
	tt_item_desc.text = item_info.item_info.item_desc
	tt_item_rarity.text = "Rarity: " + Utils.to_text(item_info.item_rarity)
	
	if item_info.reforge_time > 0:
		tt_item_reforge_time.text = "Reforged: " + Utils.to_text(item_info.reforge_time)
		tt_item_reforge_time.visible = true
	else:
		tt_item_reforge_time.visible = false
	
	if item_info.item_class == Constants.ItemClass.OTHER:
		tt_item_lvl.visible = false
		tt_item_lvl_require.visible = false
	else:
		tt_item_lvl.text = "Lvl: " + Utils.to_text(item_info.lvl)
		tt_item_lvl_require.text = "Lvl Require: " + Utils.to_text(item_info.lvl_require)
		
	if item_info.item_class == Constants.ItemClass.WEAPON:
		tt_item_atk_range.text = "Atk Range: " + Utils.to_text(item_info.item_info.atk_range)
		tt_item_atk_speed.text = "Atk Speed: " + Utils.to_text_float(item_info.item_info.atk_speed, 2)
		tt_item_p_dmg.text = "P Dmg: " + Utils.to_text(item_info.stats.p_dmg_min) + " - " + Utils.to_text(item_info.stats.p_dmg_max)
		tt_item_m_dmg.text = "M Dmg: " + Utils.to_text(item_info.stats.m_dmg_min) + " - " + Utils.to_text(item_info.stats.m_dmg_max)
		tt_item_durability.text = "Durability: " + Utils.to_text(item_info.stats.durability)
	else:
		tt_item_atk_range.visible = false
		tt_item_atk_speed.visible = false
		tt_item_p_dmg.visible = false
		tt_item_m_dmg.visible = false
		tt_item_durability.visible = false
	
	if cooking_energy > 0:
		tt_item_cooking_energy.text = "C. Energy: " + String(cooking_energy)
	else:
		tt_item_cooking_energy.visible = false

	update_tooltip_stats()
	
	if item_info.item_class == Constants.ItemClass.CONSUMABLE:
		update_tooltip_buff_stats()
		update_tooltip_consume_effects_stats()
	
	set_tooltip_position()


func set_tooltip_position():
	tooltip.rect_position.y = -7 - tooltip_container.rect_size.y/2


func create_tooltip_stats():
	item_stat_labels.clear()
	if item_info == null:
		return

	create_tooltip_item_stats()

	if item_info.item_class == Constants.ItemClass.CONSUMABLE:
		create_tooltip_buff_stats()
		create_tooltip_consume_effects_stats()


func create_tooltip_item_stats():
	for _stat in item_info.stats.stat_list:
		if item_stat_labels.has(_stat):
			continue
		if _stat in ignore_stats:
			continue
		if _stat in percent_stats:
			item_stat_labels[_stat] = [create_tooltip_stat(_stat), tooltip_stat_type.PERCENT]
			continue
		if item_info.stats.stat_list[_stat] >= 1:
			item_stat_labels[_stat] = [create_tooltip_stat(_stat), tooltip_stat_type.NORMAL]


func create_tooltip_buff_stats():
	item_buff_labels.clear()
	for _buff_stat_name in item_info.stats.item_buff:
		item_buff_labels[_buff_stat_name] = create_tooltip_stat(_buff_stat_name)
		
	if item_buff_labels.size() > 0:
		tt_buff_length_label = create_tooltip_stat("buff_last")


func create_tooltip_stat(_stat_name: String) -> Label:
	var _dmg_label = GameResourcesLibrary.TOOLTIP_LABEL.instance()
	_dmg_label.name = _stat_name
	tt_item_stats_box.add_child(_dmg_label)
	return _dmg_label


func update_tooltip_stats():
	for _stat_label_name in item_stat_labels:
		item_stat_labels[_stat_label_name][0].text = _stat_label_name.capitalize() + ": " + Utils.to_text(item_info.stats.stat_list[_stat_label_name] * (1 if item_stat_labels[_stat_label_name][1] == tooltip_stat_type.NORMAL else 100)) + ("%" if item_stat_labels[_stat_label_name][1] == tooltip_stat_type.PERCENT else "")


func update_tooltip_buff_stats():
	for _buff_label_name in item_buff_labels:
		var _multiplier: int = 100 if _buff_label_name.ends_with("_buff") else 1
		var _percent_text: String = "%" if _buff_label_name.ends_with("_buff") else ""
		var _stat: String = Utils.to_text(item_info.stats.item_buff[_buff_label_name] * _multiplier) + _percent_text
		item_buff_labels[_buff_label_name].text = _buff_label_name.capitalize() + ": %s" %_stat
	
	if item_buff_labels.size() > 0:
		tt_buff_length_label.text = "Buff Last: " + Utils.to_text(item_info.stats.item_buff_info.buff_length) + " seconds"


func create_tooltip_consume_effects_stats():
	item_consume_effect_labels.clear()
	for _consume_effects_name in item_info.stats.consume_effects:
		item_consume_effect_labels[_consume_effects_name] = create_tooltip_stat(_consume_effects_name)


func update_tooltip_consume_effects_stats():
	for _consume_effect_label_name in item_consume_effect_labels:
		var _label_value = item_info.stats.consume_effects[_consume_effect_label_name]
		
		if typeof(_label_value) == TYPE_REAL:
			if abs(_label_value) <= 1.0:
				item_consume_effect_labels[_consume_effect_label_name].text = _consume_effect_label_name.capitalize() + ": " + Utils.to_text_percent(_label_value)
				continue
		
		#khuc nay sai qua sai, sau demo quay lai coi lien
		elif typeof(_label_value) == TYPE_BOOL:
			if _label_value:
				item_consume_effect_labels[_consume_effect_label_name].text = "removes %s effect" %Constants.ConsumeEffectDesc[_label_value]
			else:
				item_consume_effect_labels[_consume_effect_label_name].visible = false
			continue
		
		item_consume_effect_labels[_consume_effect_label_name].text = _consume_effect_label_name.capitalize() + ": " + Utils.to_text(_label_value)


func reforge_item():
	item_info.reforge_time += 1
	create_tooltip_item_stats()
	update_tooltip()


func _on_an_item_broken() -> void:
	add_item_amount(-1)


func _on_item_updated() -> void:
	emit_signal("item_updated", get_item_stats())
