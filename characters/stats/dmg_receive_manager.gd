extends Node
class_name DamageReceiveManager

#DmgStack
var dmg_stack: Array = []
var host
var dmg_calculator: DamageCalculator
var host_stats_manager


func _init(_host):
	host = _host
	host_stats_manager = host.stats_manager
	dmg_calculator = DamageCalculator.new(_host)


#get top dmg packed from dmg stack and inflict dmg to host HP
func inflict_dmg():
	var dmg_stack_temp: Array = dmg_stack
	var dmg: Array #Dmg: Array [dmg, hit_result]
	for dmg_packed in dmg_stack_temp:
		if dmg_packed is DamagePacked:
			#calculate dmg
			dmg = dmg_calculator.dmg_receive_calculator(dmg_packed)
			dmg[0] = ceil(dmg[0])
			#inflict dmg
			if host.get("floating_text"):
				show_floating_dmg_text(dmg)
					
			host_stats_manager.stats.set_hp(host_stats_manager.stats.hp - dmg[0], dmg_packed.atk_owner.get_name() if Utils.node_exists(dmg_packed.atk_owner) else "", dmg_packed.faction)
		dmg_stack.erase(dmg_packed)


func show_floating_dmg_text(_dmg_status: Array) -> void:
	if _dmg_status[0] != 0:
		if _dmg_status[1] == Constants.HitResult.HIT:
			host.floating_text.show_text(-_dmg_status[0])
		elif _dmg_status[1] == Constants.HitResult.CRITICAL:
			host.floating_text.show_text(-_dmg_status[0], true)
	elif _dmg_status[1] == Constants.HitResult.MISSED:
		host.floating_text.show_text("missed")


func receive_dmg_packed(_dmg_packed: DamagePacked):
	dmg_stack.append(_dmg_packed)


#check if farmer has enough stamina and farmer lost stamina if has enough
func farmer_stamina_check(_dmg: int) -> bool:
	if host_stats_manager.stats.hp >= _dmg:
		host_stats_manager.stats.set_hp(host_stats_manager.stats.hp - _dmg)
		return true
	
	return false


#check if host has enough hp, mana for skill requirement, if yes, consume required hp, mana
func skill_req_check(_hp_req: int = 0, _mana_req: int = 0):
	if host_stats_manager.stats.hp > _hp_req and host_stats_manager.stats.mana >= _mana_req:
		if _hp_req != 0:
			host_stats_manager.stats.set_hp(host_stats_manager.stats.hp - _hp_req)
		if _mana_req != 0:
			host_stats_manager.stats.set_mana(host_stats_manager.stats.mana - _mana_req)
			
		return true
	
	return false
