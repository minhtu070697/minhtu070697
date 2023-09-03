extends ItemStats
class_name WeaponStats


const DURABILITY_LOST: int = 1
const TEST_MAX_DURABILITY: int = 25 # delete in real game, use item data instead


#Information
var user_class 

#Stats

#Primary Stats
var p_dmg: float = 0 
var m_dmg: float = 0
var p_dmg_min: float
var p_dmg_max: float
var m_dmg_min: float
var m_dmg_max: float
var p_dmg_diff: float
var m_dmg_diff: float
var atk_range: float = 1.0
var hit_range: int = 0
var hit_arc: int = 0
var max_combo: int = 1

#Secondary Stats
var atk_speed: float = 1
var accuracy: float = 1

#Other Stats
var physical_percent: float
var durability: int setget set_durability
var max_durability: int = TEST_MAX_DURABILITY
var atk_animation: String = "basic_melee_attack"

#Vars
var stat_generator

#Dictionary


func _init(_item, _load_data: Dictionary = {}).(_item):
	item_class = Constants.ItemClass.WEAPON
	set_weapon_info()

	if _load_data.empty():
		init_stats()
	else:
		load_stats(_load_data)
	
	set_weapon_damage()


func init_stats() -> void:
	create_stats()
	durability = item.item_info.durability
	set_weapon_dmg_diff()


func load_stats(load_data: Dictionary) -> void:
	if load_data.info.has("item_rarity"):
		rarity = load_data.info.item_rarity
	load_stat_list(load_data)
	load_item_durability(load_data)
	set_weapon_dmg_diff(load_data)


func load_item_durability(_data: Dictionary) -> void:
	if _data.info.has("durability"):
		durability = _data.info.durability


func set_weapon_info():
	physical_percent = item.item_info.physical_percent
	atk_range = item.item_info.atk_range
	atk_speed = item.item_info.atk_speed
	hit_range = item.item_info.hit_range
	hit_arc = item.item_info.hit_arc
	max_combo = item.item_info.max_combo
	atk_animation = item.item_info.atk_animation if item.item_info.atk_animation != "" else "basic_melee_attack"
	max_durability = item.item_info.durability


func set_weapon_dmg_diff(data: Dictionary = {}) -> void:
	if data:
		p_dmg_diff = data.info["p_dmg_diff"]
		m_dmg_diff = data.info["m_dmg_diff"]
	else:
		p_dmg_diff = Utils.random_percent(0, int(item.item_info.max_dmg_diff * 100))
		m_dmg_diff = Utils.random_percent(0, int(item.item_info.max_dmg_diff * 100))


func set_weapon_damage():
	p_dmg = stat_list["p_dmg"] * item.item_info.dmg_percent
	m_dmg = stat_list["m_dmg"] * item.item_info.dmg_percent
	p_dmg_min = p_dmg * (1 - p_dmg_diff)
	p_dmg_max = p_dmg * (1 + p_dmg_diff)
	m_dmg_min = m_dmg * (1 - m_dmg_diff)
	m_dmg_max = m_dmg * (1 + m_dmg_diff)


func create_stats():
	stat_generator = ItemRandomStatsGenerator.new(self)
	var temp_stat_list = stat_generator.item_stat_list
	for _stat in temp_stat_list:
		stat_list[_stat.name] = _stat.value


func load_stat_list(stats_data: Dictionary) -> void:
	stat_list = stats_data.stats


func get_item_save_infos(_data: Dictionary) -> void:
	_data["p_dmg_diff"] = p_dmg_diff
	_data["m_dmg_diff"] = m_dmg_diff
	_data["durability"] = durability


# override
func item_use(_affect_character) -> void:
	set_durability(durability - DURABILITY_LOST)


func set_durability(_new_value: int) -> void:
	var old_dura: int = durability
	durability = max(0, _new_value)
	SignalManager.emit_signal("durability_changed", item.item_name, old_dura, durability, max_durability)
	if durability == 0:
		item.emit_signal("broken")
	else:
		item.emit_signal("item_updated")
