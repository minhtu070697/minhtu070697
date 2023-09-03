extends Node
class_name DamageDealer


var host
var host_stats
var dmg_calculator: DamageCalculator
var dmg_packed_content: Dictionary = {}
var host_stats_manager


func _init(_host):
	host = _host
	host_stats_manager = host.stats_manager
	host_stats = host_stats_manager.stats if host_stats_manager != null else null
	dmg_calculator = DamageCalculator.new(_host)


func send_dmg_packed(_target, _dmg_packed: DamagePacked = create_dmg_packed()) -> void:
	var _target_stats_manager = _target.get_node_or_null("StatsManager")
	if _target_stats_manager != null:
		var temp_dmg_packed: DamagePacked = _dmg_packed
		_target_stats_manager.dmg_receive_manager.receive_dmg_packed(temp_dmg_packed)


func create_dmg_packed_content() -> void:
	dmg_packed_content["atk_owner"] = host
	dmg_packed_content["faction"] = host.faction
	dmg_packed_content["p_dmg"] = dmg_calculator.p_dmg
	dmg_packed_content["m_dmg"] = dmg_calculator.m_dmg
	dmg_packed_content["accuracy_rate"] = host_stats.accuracy_rate
	dmg_packed_content["crit_rate"] = host_stats.crit_rate
	dmg_packed_content["crit_dmg"] = host_stats.crit_dmg
	dmg_packed_content["lvl"] = host_stats.lvl

	dmg_packed_content["fire_dmg"] = host_stats.fire_dmg
	dmg_packed_content["cold_dmg"] = host_stats.cold_dmg
	dmg_packed_content["poison_dmg_per_tick"] = host_stats.poison_dmg * Constants.POISON_TICK_TIME / host_stats.poison_length if host_stats.poison_length != 0 else 0.0
	dmg_packed_content["lightning_dmg"] = host_stats.lightning_dmg

	dmg_packed_content["fire_dmg_buff"] = host_stats.fire_dmg_buff
	dmg_packed_content["cold_dmg_buff"] = host_stats.cold_dmg_buff
	dmg_packed_content["lightning_dmg_buff"] = host_stats.lightning_dmg_buff
	dmg_packed_content["poison_dmg_buff"] = host_stats.poison_dmg_buff

	dmg_packed_content["freeze_length"] = host_stats.freeze_length
	dmg_packed_content["freeze_strength"] = host_stats.freeze_strength
	dmg_packed_content["poison_length"] = host_stats.poison_length
	dmg_packed_content["poison_length_buff"] = host_stats.poison_length_buff
	dmg_packed_content["freeze_length_buff"] = host_stats.freeze_length_buff


func create_dmg_packed() -> DamagePacked:
	dmg_calculator.attack_dmg_calculator()
	create_dmg_packed_content()
	return DamagePacked.new(dmg_packed_content)


func create_farming_tool_dmg_packed(_farming_tool: String) -> DamagePacked:
	dmg_calculator.farmer_dmg_calculator(_farming_tool)
	create_dmg_packed_content()
	return DamagePacked.new(dmg_packed_content)
