extends Node
class_name DamagePacked

# Vars
var atk_owner = null
var faction: int = Constants.Factions.NONE
var p_dmg = 0
var m_dmg = 0
var accuracy_rate: float = 0
var crit_rate: float = 0
var crit_dmg: float = 0
var lvl: int = 1

# Elemental dmgs
# Fire
var fire_dmg: float = 0
var fire_dmg_buff: float = 0

# Cold
var cold_dmg: float = 0
var cold_dmg_buff: float = 0
var freeze_strength: float = 0
var freeze_length: float = 0
var freeze_length_buff: float = 0

# Poison
var poison_dmg_per_tick: float = 0
var poison_dmg_buff: float = 0
var poison_length: float = 0
var poison_length_buff: float = 0

# Lightning
var lightning_dmg: float = 0
var lightning_dmg_buff: float = 0

var target_force_to_state

# Direct_dmg
var direct_dmg: float = 0


#Packed_content
var content

func _init(_content: Dictionary = {}):
	content = _content
	extract_content()


func extract_content():
	for item in content:
		set(item, content[item])
			
