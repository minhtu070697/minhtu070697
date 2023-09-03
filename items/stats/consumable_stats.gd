extends ItemStats
class_name ConsumableStats


#Information
var item_buff: Dictionary = {}
var item_buff_info: Dictionary = {}

var consume_effects: Dictionary = {}



func _init(_item).(_item):
	item_class = Constants.ItemClass.CONSUMABLE
	load_item_buffs()
	load_consume_effects()


func load_item_buffs():
	if item.item_info.buffs != "":
		var _buff_data : Dictionary = GameResourcesLibrary.stat_buff_list_json[item.item_info.buffs] 
		var _got_name: bool = false
		var _got_buff_length: bool = false
		for _buff in _buff_data:
			if !_got_name:
				if _buff == "buff_name":
					item_buff_info[_buff] = _buff_data[_buff]
					_got_name = true
					continue
			
			if _buff.begins_with("base_"):
				var _stat_buff_name = _buff.replacen("base_", "")

				if !_got_buff_length:
					if _stat_buff_name == "buff_length":
						item_buff_info[_stat_buff_name] = _buff_data[_buff] + _buff_data[_stat_buff_name + "_lvl_up"] * (lvl - 1)
						_got_buff_length = true
						continue
				
				item_buff[_stat_buff_name] = _buff_data[_buff] + _buff_data[_stat_buff_name + "_lvl_up"] * (lvl - 1)


func load_consume_effects():
	if item.item_info.consume_effects != "":
		consume_effects = GameResourcesLibrary.consumable_stats_resource[item.item_info.consume_effects]


func item_use(_affect_character):
	consume(_affect_character)
	item.emit_signal("broken")


func consume(_affect_character):
	activate_consume_effect(_affect_character)
	yield(Utils.start_coroutine(0.01), "completed")
	activate_buffs(_affect_character)


func activate_consume_effect(_affect_character):
	var _affect_character_stat = _affect_character.stats_manager.stats
	if consume_effects.has("hp_recover"):
		var _hp_max_recover: int = consume_effects.hp_max_recover if consume_effects.has("hp_max_recover") else Constants.A_VERY_LARGE_NUMBER
		var _hp_min_recover: int = consume_effects.hp_min_recover if consume_effects.has("hp_min_recover") else 0
		var _hp_recover: int = int(Utils.clamp_int(consume_effects.hp_recover * _affect_character_stat.max_hp, _hp_min_recover, _hp_max_recover))
		_affect_character.stats_manager.dmg_receive_manager.receive_dmg_packed(Utils.create_direct_dmg_packed(-_hp_recover, ""))
	if consume_effects.has("mana_recover"):
		var _mana_max_recover: int = consume_effects.mana_max_recover if consume_effects.has("mana_max_recover") else Constants.A_VERY_LARGE_NUMBER
		var _mana_min_recover: int = consume_effects.mana_min_recover if consume_effects.has("mana_min_recover") else 0
		var _mana_recover: int = int(Utils.clamp_int(consume_effects.mana_recover * _affect_character_stat.max_mana, _mana_min_recover, _mana_max_recover))
		_affect_character_stat.set_mana(_affect_character_stat.mana + _mana_recover)
	if consume_effects.has("antidote"):
		_affect_character.stats_manager.health_states_manager.emit_signal("antidoting")
	if consume_effects.has("unfreeze"):
		_affect_character.stats_manager.health_states_manager.emit_signal("unfreezing")


func activate_buffs(_affect_character):
	if item_buff.size() > 0:
		_affect_character.stats_manager.buff_manager.add_buff(item_buff, item_buff_info)
