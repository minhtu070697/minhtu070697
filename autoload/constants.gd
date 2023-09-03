extends Node

var random_event_with_chance: RandomEventWithChance = RandomEventWithChance.new()

enum DayTime { DAY, NIGHT, DAWN, SUNSET }
const DayTimeHour := {
	DayTime.DAY: 8.0,
	DayTime.NIGHT: 19.0,
	DayTime.DAWN: 4.0,
	DayTime.SUNSET: 16.0
}

enum MapSceneType { FARM_MAP, BATTLE_MAP, BASE_MAP, MINING_MAP, BASE_UPGRADE_MAP }
enum MapInfoType { TILE_MAP, RESOURCE, DECORATION, BUILDABLE_DECORATION, WALKABLE_DECORATION, ABOVE_DECORATION, BELOW_DECORATION, TALL_DECORATION, WALL_DECORATION }
enum ResourceType	{ TREE, STONE, GOLD, DIAMOND, EMERALD, RUBY, AMBER, AMETHYST, QUARTZ, SAPPSHIRE, OTHER, BATTLE_VASE, 
						PLANT, YOUNG_PLANT, EMPTY_PLOT, LIVESTOCK_BARN, ANIMAL_DEAD_BODY, COLLECTABLE}
enum DecorationType { HOUSE, FARM_HOUSE, MEDIUM_HOUSE, WINDMILL_HOUSE, GREEN_HOUSE, STORAGE_HOUSE, DOCK_HOUSE, PET_HOUSE, TORCH, TORCH_1, TORCH_2, TORCH_3, TORCH_4,
						EDGE, EDGE_1, CORNER, CORNER_1,
						BRIDGE, BRIDGE_1, BRIDGE_2
						TABLE, TABLE_1, TABLE_2, TABLE_BILLIARDS, CHAIR, SOFA, SOFA_1, BED, BED_1,
						BOOK_CASE, BOOK_CASE_1, BOOK_CASE_2, WALL, WALL_1, WALL_2, WALL_3, WALL_4, WALL_5, WALL_6, WALL_7, DOOR,
						BOOK, BOOK_1, BOOK_2, FOOD, FOOD_1, FOOD_2,
						CHESS
						PICTURE, TV,
						SCARECROW, WELL, WATERING_CAN,
						FLOWER, GRASS, WHEAT, TELEPORT
						MINING_CAVE, STAIRS,
						HOUSE_PLANTS,
					}
enum BuildingType { RESOURCE, DECORATION, BUILDABLE_DECORATION, WALKABLE_DECORATION, ABOVE_DECORATION, BELOW_DECORATION, TALL_DECORATION, WALL_DECORATION }
enum FloorType { GROUND_FLOOR, FIRST_FLOOR, SECOND_FLOOR }
enum Direction { UP, UP_SIDE, SIDE, DOWN_SIDE, DOWN } # values = 0, 1, 2, 3, 4

enum CharacterRace {HUMAN, ELF, BEAST_MAN}
enum FarmerAction {GATHERING, FISHING}

enum Rarity {ALL, COMMON, UNCOMMON, RARE, EPIC, LEGEND}

enum WeaponSubClass {ALL, BARE_HANDS, SWORD, AXE, BOW, EMPTY}
enum ArmorSubClass {ALL, COAT, HAT, PANTS, EMPTY}
enum ConsumableSubClass {ALL, POTION, FOOD, EMPTY} 
enum ItemClass {ALL, WEAPON, ARMOR, CONSUMABLE, CHARM, SEED, OTHER, EMPTY}
enum WeaponType {MELEE, RANGED}

enum ProjectileType {NORMAL, PIERCE, INDESTRUCTABLE, NOT_HIT}
enum SkillType {ACTIVE, PASSIVE, TOGGLE}
enum EnemyType {NORMAL, CHAMPION, MINI_BOSS, BOSS}

enum Factions {NONE, PLAYERS, ENEMY_TEAM_1, GOBLINS, SLIMES, BOSS_WOLF}

enum EnvironmentType {FARM, CAVE, IN_HOUSE}

enum AnimalType {LIVESTOCK, FARM_PET}

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	CRAFTING_MAIN,
	CRAFTING_SUB,
	CRAFTING_RELEASE,
	REFORGE_ITEM,
	REFORGE_INGREDIENT,
	HAIR,
	SHIRT,
	PANTS,
	WEAPON
	ROD,
	AXE,
	PICK,
	HOE,
	COOKING_INGREDIENT,
	COOKING_ENERGY
}


const FISH_ITEM = "fish"
const WOOD_ITEM = "wood"
const STONE_ITEM = "stone"
const GOLD_ITEM = "gold"
const DIAMOND_ITEM = "diamond"
const EMERALD_ITEM = "emerald"
const RUBY_ITEM = "ruby"
const AMBER_ITEM = "amber"
const AMETHYST_ITEM = "amethyst"
const QUARTZ_ITEM = "quartz"
const SAPPHIRE_ITEM = "sapphire"
const POTION_ITEM = "potion"
const ROPE_ITEM = "rope"
const CARROT_ITEM = "carrot"
const CHILLY_ITEM = "chilly"
const PEACH_ITEM = "peach"
const CARROT_SEED_ITEM = "carrot_seed"
const CHILLY_SEED_ITEM = "chilly_seed"
const PEACH_SEED_ITEM = "peach_seed"
const BEEF_ITEM = "beef"

enum NavigatorType {LAND, WATER, COMBINED}

const DEBUG = false
const DEFAULT_WALK_SPEED = 120
const DEFAULT_CHARACTER_ACCELERATE = 5
const HIT_EFFECT_DURATION = 0.4
const HIT_EFFECT_COLOR = Color(1, 0, 0, 1)
const PROJECTILE_DEFAULT = -1

const FREEZE_EFFECT_COLOR = Color(0.44, 0.73, 1, 1)
const POISON_EFFECT_COLOR = Color(0.4, 1, 0.69, 1)
const NORMAL_COLOR = Color(1, 1, 1, 1)
const FARM_WATER_COLOR = Color(0.42, 0.64, 0.46, 0.45)

const GREEN_PROGRESS_COLOR = Color(0.74, 1, 0.71, 1)
const LIGHT_YELLOW_PROGRESS_COLOR = Color(1, 0.95, 0.71, 1)
const ORANGE_PROGRESS_COLOR = Color(0.97, 0.66, 0.41, 1)
const BROWN_PROGRESS_COLOR = Color(0.78, 0.46, 0.21, 1)
const DARK_BROWN_PROGRESS_COLOR = Color(0.33, 0.21, 0.11, 1)
const RED_PROGRESS_COLOR = Color(1, 0.45, 0.34, 1)

const A_VERY_LARGE_NUMBER = 99999999

# 9 grid displacement map, relative to middle grid (X)
# 0 1 2
# 3 X 5
# 6 7 8
# e.g: position 0 = X + Vector(-1,1)
const DisplacementMap = {
	0: Vector2(-1, 1),
	1: Vector2(-1, 0),
	2: Vector2(-1, -1),
	3: Vector2(0, 1),
	4: Vector2(0, 0),
	5: Vector2(0, -1),
	6: Vector2(1, 1),
	7: Vector2(1, 0),
	8: Vector2(1, -1),
}


# multiple lands
# (0:0) (1:0) (2:0)
# (0:1)   X   (2:1)
# (0:2) (1:2) (2:2)
const list_map_positions_default = [
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(2, 0),
	Vector2(0, 1),
	Vector2(2, 1),
	Vector2(0, 2),
	Vector2(1, 2),
	Vector2(2, 2)
]

const FarmerStaminaNeed = {
	FarmerAction.GATHERING : 0,
	FarmerAction.FISHING : 0
}

const DirectionName = {
	0: "up",
	1: "up_side",
	2: "side",
	3: "down_side",
	4: "down"
}


#for right side, for other side: -180 - this
const DirectionDegree := {
	0: -90,
	1: -30,
	2: 0,
	3: 30,
	4: 90
}


enum AttackList {BASIC_ATTACK, BASIC_CASTING, TELEPORT, JUMP_ATTACK, DASH_ATTACK, BASIC_ACTION, BASIC_BUFF}

enum SkillList {BASIC_ATTACK, FIRE_BALL, ICE_BOLT, TELEPORT, ICE_NOVA, FIRE_METEOR, SHOCK_WAVE, JUMP_ATTACK, DASH_ATTACK, GOBLIN_FIRE_BALL, TORNADO, 
CHAIN_LIGHTNING, SPREAD_LIGHTNING, WARRIOR_SPIRIT, BWOLF_TORNADO
}

const SkillNameList = {
	SkillList.BASIC_ATTACK: "basic_attack",
	SkillList.FIRE_BALL: "fire_ball",
	SkillList.ICE_BOLT: "ice_bolt",
	SkillList.TELEPORT: "teleport",
	SkillList.ICE_NOVA: "ice_nova",
	SkillList.FIRE_METEOR: "fire_meteor",
	SkillList.SHOCK_WAVE: "shock_wave",
	SkillList.JUMP_ATTACK: "jump_attack",
	SkillList.DASH_ATTACK: "dash_attack",
	SkillList.GOBLIN_FIRE_BALL: "goblin_fire_ball",
	SkillList.TORNADO: "tornado",
	SkillList.BWOLF_TORNADO: "bwolf_tornado",
	SkillList.CHAIN_LIGHTNING: "chain_lightning",
	SkillList.SPREAD_LIGHTNING: "spread_lightning",
	SkillList.WARRIOR_SPIRIT: "warrior_spirit"
}

const SkillTypeString = {
	SkillType.ACTIVE: "Active",
	SkillType.PASSIVE: "Passive",
	SkillType.TOGGLE: "Toggle"
}

const QUARTER_ANGLE_UP = Vector2(-(5 * PI / 8 - PI / 32), -(3 * PI / 8 + PI / 32))
const QUARTER_ANGLE_SIDE_RIGHT = Vector2(-(PI / 8 - PI / 32), PI / 8 - PI / 32)
const QUARTER_ANGLE_SIDE_LEFT = Vector2( 7 * PI / 8 + PI / 32, 9 * PI / 8 - PI / 32)
const QUARTER_ANGLE_NEGATIVE_SIDE_LEFT = Vector2( -(9 * PI / 8 - PI / 32), -(7 * PI / 8 + PI / 32))
const QUARTER_ANGLE_DOWN = Vector2( 3 * PI / 8 + PI / 32, 5 * PI / 8 - PI / 32)

const SPAWN_PROJECTILES_FIELD_DENSITY = 7
const SPAWN_PROJECTILES_FIELD_ANGLE = PI * 1.5

const PROJECTILES_SCENE = "res://projectiles/%s.tscn"
const ACTOR_CLASS_RESOURCES_PATH = "res://characters/class_resources/"
const ACTOR_CLASS_NULL_PATH = "res://characters/class_resources/class_null.tres"
const MONSTERS_SPRITE_PATH = "res://enemies/monster_texture/%s/%s_%s.png"
const SKILL_RESOURCES_PATH = "res://skills/resources/%s.tres"
const ITEM_TEXTURE_PATH = "res://ui/textures/items/%s.png"
const MONSTER_SCENES_PATH = "res://enemies/scenes/%s.tscn"
const PROJECTILES_RESOURCES_DIR = "res://projectiles/resources/"
const PROJECTILES_RESOURCES_PATH = "res://projectiles/resources/%s.tres"
const PROJECTILES_NULL_PATH = "res://projectiles/resources/null_proj.tres"
const MONSTER_RESOURCES_PATH = "res://enemies/resources/%s.tres"
const MONSTER_RESOURCES_DIR = "res://enemies/resources/"
const MONSTER_NULL_PATH = "res://enemies/resources/goblin.tres"
const MONSTER_NULL_NAME = "goblin"
const ITEM_STAT_RESOURCES_PATH = "res://items/stat_resources/"
const ITEM_RESOURCES_PATH = "res://items/item_resources/"
const ITEM_NULL_PATH = "res://items/item_resources/null_item.tres"
const ENEMY_SCENE_PATH = "res://enemies/scenes/enemy.tscn"
const PROJECTILE_DEATH_SOUNDS_PATH = "res://projectiles/sound_effects/%s_hit_sound.mp3"
const PROJECTILE_INIT_SOUNDS_PATH = "res://projectiles/sound_effects/%s_init_sound.mp3"
const PROJECTILE_FLYING_SOUNDS_PATH = "res://projectiles/sound_effects/%s_flying_sound.mp3"
const MONSTER_CRY_SOUNDS_PATH = "res://enemies/sound_effects/%s_cry_sound.mp3"


#Combat constants
const POISON_TICK_TIME = 0.5
const POISON_MAX_LENGTH = 5
const LIGHTNING_ADD_WATER_DMG_MULTIPLIER = 1.5
const FREEZE_UPDATE_TIME_PERCENT = 1 / 3

enum HitResult{HIT, MISSED, CRITICAL, HEAL}

const MONSTER_ITEM_LVL_GAP = 2

const ConsumeEffectDesc = {
	"antidote": "poison",
	"unfreeze": "freeze",
	"clean_all_negative" : "all"
}

const EquipmentManagerFarmingToolsNewDict = {
	"axe": {
		"range": 1,
		"p_dmg": 0,
		"m_dmg": 0
	},
	"pick": {
		"range": 1,
		"p_dmg": 0,
		"m_dmg": 0
	},
	"hoe": {
		"range": 1,
		"p_dmg": 0,
		"m_dmg": 0
	}
}


const EQUIPMENT_ITEM_CATEGORY = ["Weapon", "Axe", "Pick", "Hoe", "Hair", "Shirt", "Pants"]

const YoungPlantDefaultInfo = {
	"young_plant_name" : "",
	"growth_phase" : 3.0,
	"sprite_name" : "",
	"sprite_position": {
	  "x": 0,
	  "y": -4
	},
	"phase_time" : {
	  "1" : 0.01,
	  "2" : 0.01,
	  "3" : 0.01
	},
	"water_meter_max" : 100,
	"water_drop_speed" : 1,
	"fertilizer_meter_max" : 100,
	"fertilizer_drop_speed" : 1,
	"health_meter_max" : 100,
	"health_drop_speed" : 1,
	"decease" : [],
	"growth_plant_name": "tree"
  }

const PlantDefaultInfo = {
	"plant_name" : "carrot",
	"harvest_time" : 3.0,
	"sprite_name" : "carrot",
	"sprite_position": {
	  "x": 0,
	  "y": -1
	},
	"is_tree" : false,
	"harvest_wait_time" : 5,
	"harvest_yield" : {
	  "normal" : {
		"gold" : {
		  "quantity" : 3,
		  "chance" : 1
		},
		"stone" : {
		  "quantity" : 2,
		  "chance" : 0.5
		}
	  },
	  "perfect" :{
	  }
	}
}

const LivestockDefaultInfo = {
	"livestock_name" : "chicken",
	"sprite_name" : "chicken",
	"icon_name" : "chicken",
	"size" : {"x": 1, "y": 1},
	"in_barn_size": 1,
	"walk_speed": 30,
	"run_speed": 70,
	"action_speed": 1,
	"max_walk_distance": 7,
	"init_place": 0,
	"move_on_ground": true,
	"move_on_water": true,
	"can_fly": false,
	"min_wet_meter": 0,
	"max_wet_meter": 30,
	"wet_meter_fill_up_time": 2,
	"where_to_eat": [0],
	"where_to_sleep": [0, 1],
	"where_to_lie_down": [0, 1],
	"in_barn_time": 15,
	"scare_time": 6,
	"lifespan": 15,
	"growth_time": 4,
	"harvest_yield": {
	  "gold" : {
		"quantity" : 3,
		"chance" : 1
	  },
	  "stone" : {
		"quantity" : 2,
		"chance" : 0.0
	  }
	},
	"idle_time": 2,
	"animation_frames": {
	  "eat": 10,
	  "fast_swim": 5,
	  "flee": 5,
	  "idle" : 6,
	  "idle_swim": 6,
	  "jump": 5,
	  "run" : 5,
	  "walk": 4,
	  "die" : 5,
	  "lie_down": 8,
	  "sleep": 8,
	  "swim": 4
	},
	"cry_sound" : "hen",
	"cry_sound_amplify" : 10,
	"scare_sound" : "hen",
	"scare_sound_amplify" : 6,
	"swimming_sound": "",
	"swimming_sound_amplify": 5,
	"faction" : "livestock_chicken",
	"status_text" : {}
  }


const LivestockBarnDefaultInfo = {
	"barn_name" : "cow_barn",
	"sprite_name" : "cow_barn",
	"sprite_position": {"x": -9, "y": -49},
	"size" : {"x": 4, "y": 4},
	"barn_door_position": {"x": 3, "y": 0},
	"barn_door_width": {"x": 0, "y": 2},
	"livestock_inside": ["cow", "chicken"],
	"max_food_meter": 100,
	"barn_navigator_type": "land"
 }


const FarmPetDefaultInfo = {
	"farm_pet_name" : "farm_dog",
	"sprite_name" : "farm_dog",
	"icon_name" : "farm_dog",
	"size" : {"x": 1, "y": 1},
	"walk_speed": 40,
	"run_speed": 90,
	"action_speed": 1,
	"max_walk_distance": 7,
	"move_on_ground": true,
	"move_on_water": false,
	"can_fly": false,
	"min_wet_meter": 0,
	"max_wet_meter": 0,
	"wet_meter_fill_up_time": 2,
	"where_to_eat": [0],
	"where_to_sleep": [0],
	"where_to_lie_down": [0, 1],
	"where_to_play": [0],
	"lifespan": 60,
	"growth_time": 5,
	"idle_time": 2,
	"animation_frames": {
	 "idle" : 6,
	  "run" : 6,
	  "walk": 6,
	  "die" : 5,
	  "lie_down": 6,
	  "livestock_guide": 6,
	  "sleep": 9,
	  "belly_up": 6,
	  "jump": 2,
	  "swim": 6,
	  "fast_swim": 6,
	  "idle_swim": 6
	},
	"cry_sound" : "dog",
	"cry_sound_amplify" : 7,
	"breath_sound": "dog",
	"breath_sound_amplify": 7,
	"swimming_sound": "small_animals",
	"swimming_sound_amplify": 5,
	"faction" : "farm_pet_dog",
	"status_text" : {}
  }

const YOUNG_PLANT_WATER_DROP_TIME = 1 #seconds
const YOUNG_PLANT_FERTILIZER_DROP_TIME = 1 #seconds
const YOUNG_PLANT_HEALTH_DROP_TIME = 1 #seconds
const YOUNG_PLANT_DECEASE_TIME_MIN = 100 #seconds
const YOUNG_PLANT_DECEASE_TIME_MAX = 1000 #seconds
const YOUNG_PLANT_FERTILIZER_FILL_MULTIPLIER = 3 #young plant fills fertilizer 3 times faster than it's using speed


const LivestockBarnContainSizePerLvl = {
	1: 8,
	2: 10,
	3: 12,
	4: 16,
	5: 20
}


const ItemCategoryToSlotTypeDict: Dictionary = {
	"Hair": SlotType.HAIR,
	"Shirt": SlotType.SHIRT,
	"Pants": SlotType.PANTS,
	"Weapon": SlotType.WEAPON,
	"Fishing_Rod": SlotType.ROD,
	"Axe": SlotType.AXE,
	"Pick": SlotType.PICK,
	"Hoe": SlotType.HOE,
}


#region: character constants
#=========Charater Constants=====
const CharacterExpPerLvl = {
	1:	500.000,
	2:	2000.000,
	3:	4500.000,
	4:	8000.000,
	5:	12500.000,
	6:	18000.000,
	7:	24500.000,
	8:	32000.000,
	9:	40500.000,
	10:	50000.000,
	11:	80666.667,
	12:	96000.000,
	13:	112666.667,
	14:	130666.667,
	15:	150000.000,
	16:	170666.667,
	17:	192666.667,
	18:	216000.000,
	19:	240666.667,
	20:	266666.667,
	21:	441000.000,
	22:	484000.000,
	23:	529000.000,
	24:	576000.000,
	25:	625000.000,
	26:	676000.000,
	27:	729000.000,
	28:	784000.000,
	29:	841000.000,
	30:	900000.000,
	31:	961000.000,
	32:	1024000.000,
	33:	1089000.000,
	34:	1156000.000,
	35:	1225000.000,
	36:	1296000.000,
	37:	1369000.000,
	38:	1444000.000,
	39:	1521000.000,
	40:	1600000.000,
	41:	1681000.000,
	42:	1764000.000,
	43:	1849000.000,
	44:	1936000.000,
	45:	2025000.000,
	46:	2116000.000,
	47:	2209000.000,
	48:	2304000.000,
	49:	2401000.000,
	50:	2500000.000,
	51:	2601000.000,
	52:	2704000.000,
	53:	2809000.000,
	54:	2916000.000,
	55:	3025000.000,
	56:	3136000.000,
	57:	3249000.000,
	58:	3364000.000,
	59:	3481000.000,
	60:	3600000.000
}

const MonsterTypeExpMultiplier = {
	EnemyType.NORMAL : 1.0,
	EnemyType.CHAMPION : 1.5,
	EnemyType.MINI_BOSS : 3,
	EnemyType.BOSS : 5
}

const MonsterLvlExpMultiplier = {
	-20: 0.1,
	-15: 0.3,
	-10: 0.6,
	-5: 1,
	5: 1.2,
	10: 1.3,
	15: 1.4,
	20: 1.5
}

const MAX_EVASION_CHANCE = 1/3
const MAX_HIT_CHANCE = 1.4
const MIN_HIT_CHANCE = 0.8
const MAX_ARMOR = 0.75
const MAX_CRITICAL_CHANCE = 0.6
const STAT_POINTS_ADD_PER_LVL = 2
const SKILL_POINTS_ADD_PER_LVL = 1
const MAX_SKILL_LVL = 30
const MAX_CHARACTER_LVL = 60

const FARMER_STAMINA_RESTORE_TIME = 1 #seconds
const MANA_RESTORE_TIME = 2 #seconds
const FARMER_DEFAULT_STAMINA_RESTORE_AMOUNT = 0.1 #percent of max stamina
const DEFAULT_MANA_RESTORE_AMOUNT = 1 #percent of max mana
