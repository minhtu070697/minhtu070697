extends Node
class_name CharacterSave

var save_manager
var character_save_model: Dictionary

const CharacterRaceString: Dictionary = {
	Constants.CharacterRace.HUMAN: "human",
	Constants.CharacterRace.ELF: "elf",
	Constants.CharacterRace.BEAST_MAN: "beast_man"
}


func _init(_save_manager) -> void:
	save_manager = _save_manager
	character_save_model = save_manager.save_models.CharacterSaveModel


func character_save(_character: Character) -> void:
	if not Utils.node_exists(_character):
		return
		
	var _save_data: Dictionary = {}
	var _character_save_data: Dictionary = character_save_model.duplicate(true)
	_save_data["7"] = _character_save_data
	character_save_body_parts(_character, _character_save_data)
	character_save_equipments(_character, _character_save_data)
	character_save_informations(_character, _character_save_data)
	character_save_inventory(_character, _character_save_data)
	character_save_rarity_potential(_character, _character_save_data)
	character_save_basic_and_lvl_up_stats(_character, _character_save_data)
	character_save_stats(_character, _character_save_data)
	character_save_skills(_character, _character_save_data)
	character_save_cooking(_character, _character_save_data)
	GameResourcesLibrary.character_save_test = _save_data
	JsonData.save_data(JsonData.character_info_data_path, _save_data)


func character_save_body_parts(_character: Character, _save_data: Dictionary) -> void:
	pass


func character_save_equipments(_character: Character, _save_data: Dictionary) -> void:
	var _character_equipments: Dictionary = PlayerInventory.equips
	_save_data.equipments.clear()
	for _equipment_slot in _character_equipments:
		_save_data.equipments[String(_equipment_slot)] = _character_equipments[_equipment_slot]


func character_save_informations(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats_manager = _character.stats_manager
	_save_data.information.name = _character_stats_manager.in_game_name
	_save_data.information.race = CharacterRaceString[_character_stats_manager.owner_race]
	_save_data.information.gender = _character_stats_manager.gender
	_save_data.information.class = _character_stats_manager.host_class.owner_class


func character_save_inventory(_character: Character, _save_data: Dictionary) -> void:
	var _character_inventory: Dictionary = PlayerInventory.inventory
	_save_data.inventory.clear()
	for _inventory_slot in _character_inventory:
		_save_data.inventory[String(_inventory_slot)] = _character_inventory[_inventory_slot]


func character_save_stats(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats: FighterStats = _character.stats_manager.stats
	_save_data.stats.lvl = _character_stats.lvl
	_save_data.stats.exp = _character_stats.experience
	character_save_stat_points(_character, _save_data)


func character_save_rarity_potential(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats: FighterStats = _character.stats_manager.stats
	_save_data.stats.rarity = _character_stats.rarity
	_save_data.stats.potential = _character_stats.potential


func character_save_basic_and_lvl_up_stats(_character: Character, _save_data: Dictionary) -> void:
	character_save_basic_stats(_character, _save_data)
	character_save_lvl_up_stats(_character, _save_data)


func character_save_basic_stats(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats: FighterStats = _character.stats_manager.stats
	_save_data.stats.basic_stats.strength = _character_stats.str_basic
	_save_data.stats.basic_stats.agility = _character_stats.agi_basic
	_save_data.stats.basic_stats.intelligence = _character_stats.int_basic
	_save_data.stats.basic_stats.vitality = _character_stats.vit_basic


func character_save_lvl_up_stats(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats: FighterStats = _character.stats_manager.stats
	_save_data.stats.stats_lvl_up.strength = _character_stats.str_lvlup
	_save_data.stats.stats_lvl_up.agility = _character_stats.agi_lvlup
	_save_data.stats.stats_lvl_up.intelligence = _character_stats.int_lvlup
	_save_data.stats.stats_lvl_up.vitality = _character_stats.vit_lvlup


func character_save_stat_points(_character: Character, _save_data: Dictionary) -> void:
	var _character_stats: FighterStats = _character.stats_manager.stats
	_save_data.stats.spended_stat_points = _character_stats.spended_stat_points

	_save_data.stats.unspend_stat_points = _character_stats.available_stat_point


func character_save_skills(_character: Character, _save_data: Dictionary) -> void:
	var _character_skill_manager: ActorSkillManager = _character.stats_manager.skill_manager
	_save_data.skills.clear()
	for _skill in _character_skill_manager.skill_list.values():
		_save_data.skills[_skill.skill_name] = _skill.lvl
	_save_data.stats.unspend_skill_points = _character_skill_manager.available_skill_point


func character_save_cooking(_character: Character, _save_data: Dictionary) -> void:
	var cooking_controller: CookingController = _character.ui_manager.cooking_tab.cooking_controller
	_save_data.cooking.cooking_recipe = cooking_controller.cooking_recipe.name if not cooking_controller.cooking_recipe.empty() else ""
	_save_data.cooking.dish_amount = cooking_controller.dish_amount
	_save_data.cooking.energy_over_time = cooking_controller.energy_over_time
	_save_data.cooking.cooking_max_time = cooking_controller.cooking_max_time
	_save_data.cooking.cooking_time_left = _character.ui_manager.cooking_tab.get_cooking_timer_timeleft()
	_save_data.cooking.cooking_ingredients = cooking_controller.cooking_ingredients
