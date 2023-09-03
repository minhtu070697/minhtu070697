extends Node
class_name DamageCalculator

var host
var host_stats
var host_equipment: Dictionary

#Attacking_Var
var p_dmg: float
var m_dmg: float
var p_dmg_diff: float = 0
var m_dmg_diff: float = 0


#Defending_Var
var p_armor: float = 0
var m_armor: float = 0
var evasion_chance: float
var dmg_receive: float

#Defending_Signal
signal freezing(_strength, _length)
signal poisoning(_poison_dmg_per_tick, _length, _faction)
signal burning()
signal lightning_shocking(_lightning_dmg, _faction)


#Damage Packed
var dmg_packed : DamagePacked


func _init(_host):
	host = _host
	host_stats = host.stats_manager.stats
	host_equipment = host.stats_manager.equipment_manager.equipment
	check_and_get_weapon_dmg_diff()


func check_and_get_weapon_dmg_diff() -> void:
	if (host_equipment.size() > 0 and host_equipment.has("weapon")):
		p_dmg_diff = host_equipment["weapon"].stats.p_dmg_diff
		m_dmg_diff = host_equipment["weapon"].stats.m_dmg_diff


func attack_dmg_calculator() -> void:
	if host_stats != null:
		p_dmg = Utils.random_dmg(host_stats.p_atk, p_dmg_diff)
		m_dmg = Utils.random_dmg(host_stats.m_atk, m_dmg_diff)


func farmer_dmg_calculator(_farming_tool: String) -> void:
	var _tool_dmg_diff_array: Array = check_and_get_farming_tool_dmg_diff(_farming_tool)
	if host_stats != null:
		p_dmg = Utils.random_dmg(host_stats.p_atk, _tool_dmg_diff_array[0])
		m_dmg = Utils.random_dmg(host_stats.m_atk, _tool_dmg_diff_array[1])


func check_and_get_farming_tool_dmg_diff(_farming_tool: String) -> Array:
	if (host_equipment.size() > 0 and host_equipment.has(_farming_tool)):
		var _p_dmg_diff = host_equipment[_farming_tool].stats.p_dmg_diff
		var _m_dmg_diff = host_equipment[_farming_tool].stats.m_dmg_diff
		return [_p_dmg_diff, _m_dmg_diff]
	return []


# check if attack hit, after that, calculate final dmg, return [dmg, hit_result]
func dmg_receive_calculator(_dmg_packed: DamagePacked) -> Array:
	dmg_packed = _dmg_packed
	if dmg_packed.direct_dmg > 0:
		return [dmg_packed.direct_dmg, Constants.HitResult.HIT]
	elif dmg_packed.direct_dmg < 0:
		return [dmg_packed.direct_dmg, Constants.HitResult.HEAL]
		
	if is_hit():
		cal_armor()
		return cal_total_dmg_receive()
		
	return [0.0, Constants.HitResult.MISSED]


#check if attack hit
func is_hit() -> bool:
	evasion_chance = min(Constants.MAX_EVASION_CHANCE, host_stats.evasion_rate / dmg_packed.lvl)
	var hit_chance = min(Constants.MAX_HIT_CHANCE, (Constants.MIN_HIT_CHANCE + dmg_packed.accuracy_rate / host_stats.lvl / 100)) * (1 - evasion_chance)
	return randf() < hit_chance


#calculate host %armor
func cal_armor():
	p_armor = min(Constants.MAX_ARMOR, host_stats.p_armor_rating / dmg_packed.lvl)
	m_armor = min(Constants.MAX_ARMOR, host_stats.m_armor_rating / dmg_packed.lvl)


# calculate final dmg receive
func cal_total_dmg_receive() -> Array:
	var _hit_result = Constants.HitResult.HIT
	var dmg_multiplier = 1
	
	if is_crit():
		dmg_multiplier = dmg_packed.crit_dmg
		_hit_result = Constants.HitResult.CRITICAL
	
	dmg_receive = (dmg_packed.p_dmg * (1 - p_armor) + dmg_packed.m_dmg * (1 - m_armor))
	
	dmg_receive = inflict_fire_dmg(dmg_receive)
	dmg_receive = inflict_cold_dmg(dmg_receive)
	dmg_receive = inflict_lightning_dmg(dmg_receive)
	inflict_poison_dmg()
	
	dmg_receive *= dmg_multiplier
	return [dmg_receive, _hit_result]


# check if attack is critical
func is_crit() -> bool:
	var crit_chance = min(Constants.MAX_CRITICAL_CHANCE, dmg_packed.crit_rate / host_stats.lvl)
	return randf() < crit_chance


func inflict_fire_dmg(_dmg_receive) -> float:
	if dmg_packed.fire_dmg != 0:
		_dmg_receive += dmg_packed.fire_dmg * (1 + dmg_packed.fire_dmg_buff) * (1 - host_stats.fire_resist)
		emit_signal("burning")
	
	return _dmg_receive


func inflict_cold_dmg(_dmg_receive) -> float:
	if dmg_packed.cold_dmg != 0:
		_dmg_receive += dmg_packed.cold_dmg * (1 + dmg_packed.cold_dmg_buff) * (1 - host_stats.cold_resist)
		var _freeze_strength = dmg_packed.freeze_strength
		var _freeze_length = dmg_packed.freeze_length * (1 + dmg_packed.freeze_length_buff) * (1 - host_stats.freeze_length_reduction) 
		emit_signal("freezing", _freeze_strength, _freeze_length)
		
	return _dmg_receive


func inflict_lightning_dmg(_dmg_receive) -> float:
	if dmg_packed.lightning_dmg != 0: 
		emit_signal("lightning_shocking", dmg_packed.lightning_dmg * (1 + dmg_packed.lightning_dmg_buff) * (1 - host_stats.lightning_resist), String(dmg_packed.faction))

	return _dmg_receive


func inflict_poison_dmg() -> void:
	if dmg_packed.poison_dmg_per_tick != 0:
		var _poison_dmg_per_tick = dmg_packed.poison_dmg_per_tick * (1 + dmg_packed.poison_dmg_buff) * (1 - host_stats.poison_resist)
		var _poison_length = dmg_packed.poison_length * (1 + dmg_packed.poison_length_buff) * (1 - host_stats.poison_length_reduction) 
		emit_signal("poisoning", _poison_dmg_per_tick, _poison_length, String(dmg_packed.faction))

