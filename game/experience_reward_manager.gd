extends Node
class_name ExperienceRewardManager


func _init() -> void:
	SignalManager.connect("exp_reward", self, "on_exp_reward")


func on_exp_reward(_exp_reward_value: int, _receiving_group_name, _exp_lvl: int):
	# print("++++++++=================+++++++")
	# print(" request reward EXP for group: ", _receiving_group_name, " amount: ", _exp_reward_value)
	var _receiving_group = get_tree().get_nodes_in_group(_receiving_group_name)
	var _receiving_group_size = _receiving_group.size()
	for _exp_receiver in _receiving_group:
		var _exp_reward = _exp_reward_value / _receiving_group_size
		
		if _exp_receiver.get('stats_manager'):
			var _receiver_stats_manager = _exp_receiver.stats_manager
			if _receiver_stats_manager is FighterStatsManager:
				var _calculated_exp_reward = _exp_reward * cal_lvl_exp_multiplier(_exp_lvl, _receiver_stats_manager.stats.lvl)
				_receiver_stats_manager.experience_manager.earn_experience(_calculated_exp_reward)
				# print(_exp_receiver.name, " receive EXP: ", _calculated_exp_reward)


func cal_lvl_exp_multiplier(_exp_lvl: int, _receiver_lvl: int) -> float:
	var _lvl_gap: int = _exp_lvl - _receiver_lvl
	var _lvl_mark: Array = Constants.MonsterLvlExpMultiplier.keys()
	for i in _lvl_mark.size():
		if _lvl_gap < _lvl_mark[i]:
			if i == 0:
				return 0.0
			return Constants.MonsterLvlExpMultiplier[_lvl_mark[i-1]]

	return Constants.MonsterLvlExpMultiplier[_lvl_mark[-1]]
