extends Stats
class_name ActorStats

signal health_changed()
signal mana_changed()
signal exp_changed()

var buff_manager: BuffManager

#Information
var rarity: int
var potential

var actor_class


#Primary Stats
var lvl: int = 25
var experience: int = 0 setget set_experience
var lvl_up_experience: int = 0
var experience_reward: int = 0

var str_basic: float
var agi_basic: float
var int_basic: float
var vit_basic: float

var str_lvlup: float
var agi_lvlup: float
var int_lvlup: float
var vit_lvlup: float

var strength: float
var agility: float
var intelligence: float
var vitality: float


#Derived Stats
var max_hp: float
var hp: float setget set_hp, get_hp
var max_mana: float
var mana: float setget set_mana, get_mana

var p_atk: float
var m_atk: float

var p_armor_rating: float
var m_armor_rating: float

var crit_rate: float
var crit_dmg: float

var atk_speed: float setget set_atk_speed
var walk_speed: float setget set_walk_speed

#Secondary Stats
var evasion_rate: float
var accuracy_rate: float
var speed_modifier: float setget set_speed_modifier
var speed_down_freeze: float setget set_speed_down_freeze
var total_speed: float setget set_total_speed

#Elemental Damage
var fire_dmg: float
var cold_dmg: float
var poison_dmg: float
var lightning_dmg: float

#Elemental Effect
var freeze_length: float setget set_freeze_length
var freeze_strength: float
var poison_length: float setget set_poison_length

var freeze_length_buff: float setget set_freeze_length_buff
var poison_length_buff: float setget set_poison_length_buff

var freeze_length_reduction: float
var poison_length_reduction: float

#Elemental Dmg Buff
var fire_dmg_buff: float
var cold_dmg_buff: float
var poison_dmg_buff: float
var lightning_dmg_buff: float


#Host_Equipment
var equipment_manager : EquipmentManager


#Vars
var host_class : ClassResources


#Dictionary
var rarity_potential = {
	1 : [0.8, 1],
	2 : [1.05, 1.2],
	3 : [1.25, 1.5],
	4 : [1.6, 1.8],
	5 : [1.9, 2.1]
}

var available_stat_point: int = 0 setget set_available_stat_point
var spended_stat_points: Dictionary = {
	"strength": 0,
	"agility": 0,
	"intelligence": 0,
	"vitality": 0,
}


func _init(_host, _host_class).(_host):
	lvl = _host.stats_manager.owner_lvl
	host_class = _host_class
	speed_down_freeze = 0.0
	set_host_item()
	set_rarity_potential()
	buff_manager = host.stats_manager.buff_manager
	buff_manager.connect("update_stats", self, "update_stats")
	if host is Enemy:
		experience_reward = host.monster_info.experience


func set_host_item():
	equipment_manager = host.stats_manager.equipment_manager if host.stats_manager.get("equipment_manager") else null


#Calculate Primary Stats	
func cal_primary_stat(basic_stat: float, stat_lvlup: float) -> float:
	return basic_stat + stat_lvlup * potential * lvl


func check_buff_stat(_stat: String):
	if not buff_manager.total_buff.has(_stat):
		return 0
	return buff_manager.total_buff[_stat]


func set_primary_stats():
	strength = cal_primary_stat(str_basic, str_lvlup) + spended_stat_points.strength + check_equipment_stat("strength_add") + check_buff_stat("strength_add")
	agility = cal_primary_stat(agi_basic, agi_lvlup) + spended_stat_points.agility + check_equipment_stat("agility_add") + check_buff_stat("agility_add")
	intelligence =  cal_primary_stat(int_basic, int_lvlup) + spended_stat_points.intelligence + check_equipment_stat("intelligence_add") + check_buff_stat("intelligence_add")
	vitality = cal_primary_stat(vit_basic, vit_lvlup) + spended_stat_points.vitality + check_equipment_stat("vitality_add") + check_buff_stat("vitality_add")


func set_derived_stats():
	p_atk = cal_p_atk()
	m_atk = cal_m_atk()

	p_armor_rating = cal_p_armor_rating()
	m_armor_rating = cal_m_armor_rating()
	
	max_hp = (vitality * host_class.class_hp_multiplier * (1 + lvl) + host_class.base_hp) * (1 + check_buff_stat("hp_buff"))
	max_mana = (intelligence * host_class.class_mana_multiplier * (1 + lvl) + host_class.base_mana) * (1 + check_buff_stat("mana_buff"))

	crit_rate = cal_crit_rate()
	crit_dmg = cal_crit_dmg()
	set_speed_modifier()
	evasion_rate = cal_evasion_rate()
	accuracy_rate = cal_accuracy_rate()


func set_secondary_stats():
	cold_dmg = check_equipment_stat("cold_dmg") + check_buff_stat("cold_dmg")
	fire_dmg = check_equipment_stat("fire_dmg") + check_buff_stat("fire_dmg")
	poison_dmg = check_equipment_stat("poison_dmg") + check_buff_stat("poison_dmg")
	lightning_dmg = check_equipment_stat("lightning_dmg") + check_buff_stat("lightning_dmg")
	
	fire_dmg_buff = check_equipment_stat("fire_dmg_buff") + check_buff_stat("fire_dmg_buff")
	cold_dmg_buff = check_equipment_stat("cold_dmg_buff") + check_buff_stat("cold_dmg_buff")
	poison_dmg_buff = check_equipment_stat("poison_dmg_buff") + check_buff_stat("poison_dmg_buff")
	lightning_dmg_buff = check_equipment_stat("lightning_dmg_buff") + check_buff_stat("lightning_dmg_buff")

	set_freeze_length_buff()
	set_poison_length_buff() 

	freeze_strength = check_equipment_stat("freeze_strength")

	freeze_length_reduction = check_equipment_stat("freeze_length_reduction") + check_buff_stat("freeze_length_reduction")
	poison_length_reduction = check_equipment_stat("poison_length_reduction") + check_buff_stat("poison_length_reduction")


#add more func in future
func set_speed():
	set_speed_modifier()
	

func set_freeze_length(_new_value: float = check_equipment_stat("freeze_length") * (1 + freeze_length_buff)):
	freeze_length = _new_value


func set_poison_length(_new_value: float = min(Constants.POISON_MAX_LENGTH, check_equipment_stat("poison_length")) * poison_length_buff):
	poison_length = _new_value


func set_freeze_length_buff(_new_value: float = check_equipment_stat("freeze_length_buff") + check_buff_stat("freeze_length_buff")):
	freeze_length_buff = _new_value
	set_freeze_length()


func set_poison_length_buff(_new_value: float = check_equipment_stat("poison_length_buff") + check_buff_stat("poison_length_buff")):
	poison_length_buff = _new_value
	set_poison_length()


func set_speed_down_freeze(_new_value: float):
	speed_down_freeze = _new_value
	set_speed_modifier()


func set_speed_modifier(_new_value: float = -speed_down_freeze + check_buff_stat("speed_buff")):
	speed_modifier = _new_value
	set_total_speed()
	
	
func set_total_speed(_new_value: float = (1 + speed_modifier)):
	total_speed = _new_value
	set_atk_speed()
	set_walk_speed()


func set_atk_speed(_new_value: float = cal_atk_speed()):
	atk_speed = _new_value


func set_walk_speed(_new_value: float = cal_walk_speed()):
	walk_speed = _new_value


func set_hp_mana_max():
	hp = max_hp
	mana = max_mana


func update_hp_mana_when_stat_changed(_hp_percent: float, _mana_percent: float):
	set_hp(max_hp * _hp_percent)
	set_mana(max_mana * _mana_percent)                                                       
	 

func update_stats():
	var _hp_percent: float = hp/max_hp if max_hp != 0 else 0.0
	var _mana_percent: float = mana/max_mana if max_mana != 0 else 0.0
	set_primary_stats()
	set_speed()
	set_derived_stats()
	set_secondary_stats()
	if _hp_percent > 0 and _mana_percent > 0:
		update_hp_mana_when_stat_changed(_hp_percent, _mana_percent)
	SignalManager.emit_signal("update_character_stats_tab", host)


#Calculate Derived Stats
func cal_p_atk() -> float:
	return (1 + strength * 0.03) * (strength * 0.075 + agility * 0.025 + weapon_dmg("physical") + check_equipment_stat("p_dmg_add") + check_buff_stat("p_dmg_add"))

func cal_m_atk() -> float:
	return (1 + intelligence * 0.03) * (intelligence * 0.075 + agility * 0.025 + weapon_dmg("magical") + check_equipment_stat("m_dmg_add") + check_buff_stat("m_dmg_add"))

func cal_p_armor_rating() -> float:
	return strength * 1.5 + check_equipment_stat("p_armor_rating") + check_equipment_stat("p_armor_rating_add") + check_buff_stat("p_armor_rating_add")

func cal_m_armor_rating() -> float:
	return intelligence * 1.5 + check_equipment_stat("m_armor_rating") + check_equipment_stat("m_armor_rating_add") + check_buff_stat("m_armor_rating_add")

func cal_crit_rate() -> float:
	return agility * 5 + check_equipment_stat("crit_rate_add") + check_buff_stat("crit_rate_add")

func cal_crit_dmg() -> float:
	return host_class.base_crit_dmg + check_equipment_stat("crit_dmg_add") + check_buff_stat("crit_dmg_add")

func cal_atk_speed() -> float:
	return (host_class.base_atk_speed * check_weapon_atk_speed() * (1 + check_equipment_stat("atk_speed_add") + check_buff_stat("atk_speed_add"))) * total_speed

func cal_walk_speed() -> float:
	return (Constants.DEFAULT_WALK_SPEED * (host_class.base_walk_speed  + check_equipment_stat("walk_speed_add") + check_buff_stat("walk_speed_add"))) * total_speed

func cal_evasion_rate() -> float:
	return agility * 10 / 3 + check_equipment_stat("evasion_rate_add") + check_buff_stat("evasion_rate_add")
	
func cal_accuracy_rate() -> float:
	return agility * 3 + check_equipment_stat("accuracy_rate_add") + check_buff_stat("accuracy_rate_add")

func cal_craft_rating() -> float:
	return agility * 10 + check_equipment_stat("craft_rating_add") + check_buff_stat("craft_rating_add")


func check_equipment_stat(stat: String):
	if equipment_manager == null or not equipment_manager.equipment_bonus_stat.has(stat):
		return 0
	return equipment_manager.equipment_bonus_stat[stat]

func check_weapon_atk_speed() -> float:
	if equipment_manager == null or not equipment_manager.equipment.has("weapon"):
		return 1.0
	return equipment_manager.equipment.weapon.item_info.atk_speed

func weapon_dmg(type: String = "physical"): #arg input "physical" for p_dmg, "magical" for m_dmg
	if equipment_manager == null:
		return 1.0
	return equipment_manager.weapon_p_dmg if type == "physical" else (equipment_manager.weapon_m_dmg if type == "magical" else 0.0)


func set_basic_stats():
	str_basic = host_class.str_basic * Utils.random_percent(80,120)
	agi_basic = host_class.agi_basic * Utils.random_percent(80,120)
	int_basic = host_class.int_basic * Utils.random_percent(80,120)
	vit_basic = host_class.vit_basic * Utils.random_percent(80,120)
	set_lvlup_stats()

func load_basic_stats_from_save(_save_data: Dictionary):
	var _save_basic_stats: Dictionary = _save_data.stats.basic_stats
	str_basic = _save_basic_stats.strength
	agi_basic = _save_basic_stats.agility
	int_basic = _save_basic_stats.intelligence
	vit_basic = _save_basic_stats.vitality
	load_lvlup_stats_from_save(_save_data)


func set_lvlup_stats():
	str_lvlup = host_class.str_lvlup * Utils.random_percent(80,120)
	agi_lvlup = host_class.agi_lvlup * Utils.random_percent(80,120)
	int_lvlup = host_class.int_lvlup * Utils.random_percent(80,120)
	vit_lvlup = host_class.vit_lvlup * Utils.random_percent(80,120)

func load_lvlup_stats_from_save(_save_data: Dictionary):
	var _save_lvlup_stats: Dictionary = _save_data.stats.stats_lvl_up
	str_lvlup = _save_lvlup_stats.strength
	agi_lvlup = _save_lvlup_stats.agility
	int_lvlup = _save_lvlup_stats.intelligence
	vit_lvlup = _save_lvlup_stats.vitality


func load_spended_stat_points_from_save(_save_data: Dictionary):
	spended_stat_points = _save_data.stats.spended_stat_points
	available_stat_point = _save_data.stats.unspend_stat_points


func set_rarity_potential():
	rarity = Utils.random_int(1,5)
	potential = rand_range(rarity_potential[rarity][0], rarity_potential[rarity][1])


func set_available_stat_point(_new_value: int):
	available_stat_point = _new_value
	SignalManager.emit_signal("update_character_stats_tab", host)


func set_hp(new_hp: float, _atk_owner_name = "", _faction = Constants.Factions.NONE):
	hp = clamp(new_hp, 0.0, max_hp)
	SignalManager.emit_signal("health_changed", host.get_name(), _atk_owner_name)
	emit_signal("health_changed")
	if hp <= 0:
		SignalManager.emit_signal("death", host.name)
		# print(host.name, " dead exp reward: ", experience_reward, ". Dmg from faction: ", _faction)
		if _faction != Constants.Factions.NONE and experience_reward > 0:
			var _exp_reward_multiplier = Constants.MonsterTypeExpMultiplier[host.monster_info.type] if host is Enemy else 1
			var _calculated_exp_reward = experience_reward * _exp_reward_multiplier * lvl
			SignalManager.emit_signal("exp_reward", _calculated_exp_reward, str(_faction), lvl)

		
func get_hp() -> float:
	return hp


func set_mana(new_mana: float):
	mana = clamp(new_mana, 0.0, max_mana)
	SignalManager.emit_signal("mana_changed", host.get_name())
	emit_signal("mana_changed")


func get_mana() -> float:
	return mana


func lvl_up() -> void:
	lvl += 1
	available_stat_point += Constants.STAT_POINTS_ADD_PER_LVL
	host.stats_manager.skill_manager.available_skill_point += Constants.SKILL_POINTS_ADD_PER_LVL
	update_stats()


func use_stat_point(_stat: String):
	if available_stat_point <= 0:
		return

	available_stat_point -= 1
	spended_stat_points[_stat] += 1
	update_stats()
	GameManager.save_load_manager.character_save.character_save(host)


func refund_stat_point(_stat: String, _refund_num: int):
	available_stat_point += _refund_num
	spended_stat_points[_stat] -= _refund_num
	update_stats()
	GameManager.save_load_manager.character_save.character_save(host)


func set_experience(_new_value: int):
	experience = _new_value
	SignalManager.emit_signal("update_character_stats_tab", host)
	emit_signal("exp_changed")
	if host is Character:
		GameManager.save_load_manager.character_save.character_save(host)


