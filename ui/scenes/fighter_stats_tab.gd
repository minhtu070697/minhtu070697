extends CharacterStatsTab
class_name FighterStatsTab


#Tab2 Vars
onready var fire_dmg := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/FireDmg/FireDmg/FireDmgValue
onready var fire_dmg_modifier := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/FireDmg/FireDmgMod/FireDmgModValue

onready var cold_dmg := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/ColdDmg/ColdDmg/ColdDmgValue
onready var cold_dmg_modifier := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/ColdDmg/ColdDmgMod/ColdDmgModValue
onready var freeze_strength := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/ColdDmg/FreezeStrength/FreezeStrengthValue
onready var freeze_length := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/ColdDmg/FreezeLength/FreezeLengthValue

onready var lightning_dmg := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/LightningDmg/LightningDmg/LightningDmgValue
onready var lightning_dmg_modifier := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/LightningDmg/LightningDmgMod/LightningDmgModValue

onready var poison_dmg := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/PoisonDmg/PoisonDmg/PoisonDmgValue
onready var poison_dmg_modifier := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/PoisonDmg/PoisonDmgMod/PoisonDmgModValue
onready var poison_length := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/ElementalDmgs/PoisonDmg/PoisonDmgLength/PoisonDmgLengthValue

onready var fire_resistance := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/Resistance/ResistanceContainer/FireResistance/FireResistanceValue
onready var cold_resistance := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/Resistance/ResistanceContainer/ColdResistance/ColdResistanceValue
onready var lightning_resistance := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/Resistance/ResistanceContainer/LightningResistance/LightningResistanceValue
onready var poison_resistance := $InfoContainer/StatTab2Container/StatTab2Container/StatTab2Container/Resistance/ResistanceContainer/PoisonResistance/PoisonResistanceValue


func _ready() -> void:
	pass


func update_stat_tab_2() -> void:
	update_elemental_dmg()
	update_elemental_dmg_modifier()
	update_cold_and_poison_effects()
	update_elemental_resistance()


func update_elemental_dmg() -> void:
	update_fire_dmg()
	update_cold_dmg()
	update_lightning_dmg()
	update_poison_dmg()


func update_elemental_dmg_modifier() -> void:
	update_fire_dmg_modifier()
	update_cold_dmg_modifier()
	update_lightning_dmg_modifier()
	update_poison_dmg_modifier()


func update_cold_and_poison_effects() -> void:
	update_freeze_length()
	update_freeze_strength()
	update_poison_length()


func update_elemental_resistance() -> void:
	update_fire_resistance()
	update_cold_resistance()
	update_lightning_resistance()
	update_poison_resistance()


func update_fire_dmg() -> void:
	fire_dmg.text = Utils.to_text(stats_manager.stats.fire_dmg * (1 + stats_manager.stats.fire_dmg_buff))

func update_cold_dmg() -> void:
	cold_dmg.text = Utils.to_text(stats_manager.stats.cold_dmg * (1 + stats_manager.stats.cold_dmg_buff))

func update_lightning_dmg() -> void:
	lightning_dmg.text = Utils.to_text(stats_manager.stats.lightning_dmg * (1 + stats_manager.stats.lightning_dmg_buff))

func update_poison_dmg() -> void:
	poison_dmg.text = Utils.to_text(stats_manager.stats.poison_dmg * (1 + stats_manager.stats.poison_dmg_buff))


func update_fire_dmg_modifier() -> void:
	fire_dmg_modifier.text = Utils.to_text_percent(stats_manager.stats.fire_dmg_buff)

func update_cold_dmg_modifier() -> void:
	cold_dmg_modifier.text = Utils.to_text_percent(stats_manager.stats.cold_dmg_buff)

func update_lightning_dmg_modifier() -> void:
	lightning_dmg_modifier.text = Utils.to_text_percent(stats_manager.stats.lightning_dmg_buff)

func update_poison_dmg_modifier() -> void:
	poison_dmg_modifier.text = Utils.to_text_percent(stats_manager.stats.poison_dmg_buff)

func update_freeze_length() -> void:
	freeze_length.text = Utils.to_text_second(stats_manager.stats.freeze_length)

func update_freeze_strength() -> void:
	freeze_strength.text = Utils.to_text_percent(stats_manager.stats.freeze_strength)

func update_poison_length() -> void:
	poison_length.text = Utils.to_text_second(stats_manager.stats.poison_length)


func update_fire_resistance() -> void:
	fire_resistance.text = Utils.to_text_percent(stats_manager.stats.fire_resist)

func update_cold_resistance() -> void:
	cold_resistance.text = Utils.to_text_percent(stats_manager.stats.cold_resist)

func update_lightning_resistance() -> void:
	lightning_resistance.text = Utils.to_text_percent(stats_manager.stats.lightning_resist)

func update_poison_resistance() -> void:
	poison_resistance.text = Utils.to_text_percent(stats_manager.stats.poison_resist)
