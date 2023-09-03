extends Node

onready var background = $Background
onready var title = $Title
onready var description = $Description
onready var symbol = $Symbol

var list_backgrounds_path = [
		"res://ui/textures/background/1.png",
		"res://ui/textures/background/2.png",
		"res://ui/textures/background/3.png",
		"res://ui/textures/background/4.jpeg",
	]

var list_symbols_path = [
		"res://map/textures/objects/house/house.png",
		"res://map/textures/objects/house/farm_house.png",
		"res://map/textures/objects/house/medium_house.png",
		"res://map/textures/objects/house/green_house.png",
		"res://map/textures/objects/trees/tree_1.png"
	]

var list_tips = [
		"WELCOME TO NOGIAS",
		"WELCOME TO THE BEST FARMING SIMULATION GAME",
		"TIPS: PRESS TAB TO SHOW BASIC TUTORIALS",
		"TIPS: YOU CAN CHANGE TIME OF DAY\nBY PRESS 1, 2, 3, 4",
		"TIPS: UNLOCK MORE LANDS BY PRESS CTRL + 1 -> 8"
	]


func _ready():
	show_random_loading_scene()


func show_random_loading_scene():
	var random_tips = Utils.random_from_array(list_tips)
	title.text = random_tips
	var random_symbols = Utils.random_from_array(list_symbols_path)
	symbol.texture = load(random_symbols)
	var random_backgrounds = Utils.random_from_array(list_backgrounds_path)
	background.texture = load(random_backgrounds)

