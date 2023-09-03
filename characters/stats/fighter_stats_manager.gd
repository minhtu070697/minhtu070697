extends StatsManager
class_name FighterStatsManager


var dmg_dealer : DamageDealer
var attack_library : AttackLibrary
var skill_manager : ActorSkillManager
var experience_manager : CharacterExperienceManager
var regenerate_manager : RegenerateManager
var gender: int = 0


#override
func stats_manager_ready() -> void:
	.stats_manager_ready()
	dmg_dealer = DamageDealer.new(host)
	attack_library = AttackLibrary.new(self)
	skill_manager = ActorSkillManager.new(self, host)
	experience_manager = CharacterExperienceManager.new(self)
	regenerate_manager = RegenerateManager.new(self)


#test, delete when done please
func demo_init_level() -> void:
	experience_manager.earn_experience(1500 * stats.lvl)


#test, delete when done please
func _on_TestButton_button_up():
	experience_manager.earn_experience(40000 * stats.lvl)


func load_character_stats_from_save(_save_data: Dictionary):
	var _character_information: Dictionary = _save_data.information
	in_game_name = _character_information.name
	host_class = ClassResources.new(GameResourcesLibrary.actor_class_resources_list_json[_character_information.class])
	var _save_data_stats: Dictionary = _save_data.stats
	stats.lvl = _save_data_stats.lvl
	skill_manager.reload_skill_list()
	SignalManager.emit_signal("init_character_skill_tab", host)
	stats.set_experience(_save_data_stats.exp)
	stats.rarity = _save_data_stats.rarity
	stats.potential = _save_data_stats.potential
	stats.load_basic_stats_from_save(_save_data)
	stats.load_spended_stat_points_from_save(_save_data)
	stats.update_stats()
	skill_manager.load_skill_points_from_save(_save_data)
	PlayerInventory.load_inventory_from_save(_save_data)
	var player_inventory = get_parent().get_node("ui/Inventory")
	player_inventory.initialize_equips()
	host.show_equipments()
	player_inventory.initialize_inventory()
	host.show_equipments()
	
	#load cooking data
	host.ui_manager.cooking_tab.cooking_controller.load_cooking_save_data(_save_data.cooking)


func load_new_character_inventory(_data: Dictionary) -> void:
	PlayerInventory.load_inventory_from_save(_data)
	var player_inventory = get_parent().get_node("ui/Inventory")
	player_inventory.initialize_equips()
	host.show_equipments()
	player_inventory.initialize_inventory()
	host.show_equipments()
	
