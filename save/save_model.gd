extends Node
class_name SaveModels

const CharacterSaveModel: Dictionary = {
	"body_parts" : {
	  "body": 1,
	  "head": 1,
	  "eyes": 1,
	  "pants": 1,
	  "coat": 1,
	  "hair": 1,
	  "tail": 0,
	  "ears": 0,
	  "tool": 0
	},
	"equipments" : {
	  "0": ["basic_hair", 1],
	  "1": ["basic_coat", 1],
	  "2": ["basic_pants", 1],
	  "3": ["iron_sword", 1]
	},
	"information": {
	  "name": "testsave1",
	  "race": "beast_man",
	  "gender": 0,
	  "class": "beast_man"
	},
	"inventory": {
	  "0": ["wood", 10],
	  "1": ["stone", 10], 
	  "2": ["rope", 10],
	  "3": ["gold", 10],
	  "4": ["fish", 10],  
	  "5": ["potion", 10],
	  "7": ["carrot_seed", 1],
	  "8": ["chilly_seed", 10],
	  "13": ["peach_seed", 50]
	},
	"stats": {
	  "lvl": 10,
	  "exp": 3,
	  "rarity": 3,
	  "potential": 1.4,
	  "basic_stats": {
		"strength": 12,
		"agility": 12,
		"intelligence": 12,
		"vitality": 12
	  },
	  "stats_lvl_up": {
		"strength": 1,
		"agility": 1.2,
		"intelligence": 1.4,
		"vitality": 0.8
	  },
	  "spended_stat_points": {
		"strength": 5,
		"agility": 3,
		"intelligence": 2,
		"vitality": 8
	  },
	  "unspend_stat_points": 1,
	  "unspend_skill_points": 2
	},
	"skills": {
	  "fire_ball": 3,
	  "ice_nova": 4,
	  "fire_meteor": 2
	},
	"cooking": {
		"cooking_recipe": "",
		"dish_amount": 0,
		"energy_over_time": 0,
		"cooking_max_time": 0,
		"cooking_time_left": 0,
		"cooking_ingredients": {

		}
	}
}
