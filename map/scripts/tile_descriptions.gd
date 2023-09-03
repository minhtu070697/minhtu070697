extends Node

var water
var earth
var earth_water
var dark_earth
var dark_earth_water
var dark_grass
var ground
var stones
var floors
var mining
var mining_ground
var wall
var fog

var layer_1_default = {
	# engles
	"engle-t": 0,
	"engle-r": 1,
	"engle-l": 2,
	"engle-d": 3,
	# half
	"half-t": 4,
	"half-r": 5,
	"half-l": 6,
	"half-d": 7,
	# edges
	"edge-ld": [8, 9, 10],
	"edge-rd": [11, 12, 13],
	"edge-lt": [14, 15, 16],
	"edge-rt": [17, 18, 19],
	# intersections
	"inter-l": 20,
	"inter-d": 21,
	"inter-t": 22,
	"inter-r": 23,
	# fill
	"fill": [24],
}
var layer_2_default = {
	# engles
	"engle-t": 33,
	"engle-r": 34,
	"engle-l": 35,
	"engle-d": 36,
	# half
	"half-t": 37,
	"half-r": 38,
	"half-l": 39,
	"half-d": 40,
	# edges
	"edge-ld": [41, 42, 43],
	"edge-rd": [44, 45, 46],
	"edge-lt": [47, 48, 49],
	"edge-rt": [50, 51, 52],
	# intersections
	"inter-l": 53,
	"inter-d": 54,
	"inter-t": 55,
	"inter-r": 56,
	# fill
	"fill": [57, 58, 59, 60, 61, 62, 63, 64, 65],
	"half-intersection": 66
}

var layer_1_custom = {
	# engles
	"engle-t": 0,
	"engle-r": 1,
	"engle-l": 2,
	"engle-d": 3,
	# half
	"half-t": 4,
	"half-r": 5,
	"half-l": 6,
	"half-d": 7,
	# edges
	"edge-ld": [8, 9, 10],
	"edge-rd": [11, 12, 13],
	"edge-lt": [14, 15, 16],
	"edge-rt": [17, 18, 19],
	# intersections
	"inter-l": 20,
	"inter-d": 21,
	"inter-t": 22,
	"inter-r": 23,
	# fill
	"fill": [24, 25, 26, 27, 28, 29, 30, 31, 32]
}
var layer_3_default = {
	# engles
	"engle-t": 3,
	"engle-r": 6,
	"engle-l": 2,
	"engle-d": 7,
	# half
	"half-t": 7,
	"half-r": 7,
	"half-l": 7,
	"half-d": 7,
	# edges
	"edge-ld": 7,
	"edge-rd": 7,
	"edge-lt": [0, 1],
	"edge-rt": [4, 5],
	# intersections
	"inter-l": 7,
	"inter-d": 7,
	"inter-t": 7,
	"inter-r": 7,
	# fill
	"fill": 7
}


func _init():
	water = generate_description(layer_1_default)
	dark_grass = generate_description(layer_1_default)
	dark_earth = generate_description(layer_1_default)
	ground = generate_description(layer_1_default, true)

	earth = generate_description(layer_1_default)

	water["fill"] = [24, 25, 26, 27, 28]
	earth["fill"] = [24, 25, 26, 27, 28, 29, 30, 31, 32]
	dark_grass["fill"] = [24, 25, 26, 27, 28, 29, 30, 32]
	ground["fill"] = [24, 25, 26, 27, 28, 29, 30, 31, 32]

	# we want stones to have round edges
	stones = generate_description(layer_1_default, true)

	# we also want earth - water intersection to be rounded
	earth_water = generate_description(layer_2_default, true)
	dark_earth_water = generate_description(layer_2_default, true)

	# we want full mining - when players in Mining Cave
	mining = generate_description(layer_1_default)
	mining_ground = generate_description(layer_1_custom)
	
	# we want full floors - when players in their Base
	floors = generate_description(layer_1_custom)
	wall = generate_description(layer_3_default)

	fog = generate_description(layer_1_default)


func generate_description(default, rounded_corner = false):
	var description = default.duplicate(true)
	if rounded_corner:
		description["engle-t"] = description["half-t"]
		description["engle-r"] = description["half-r"]
		description["engle-l"] = description["half-l"]
		description["engle-d"] = description["half-d"]
	return description


func index_to_orientation(index: int, description: Dictionary):
	var keys = description.keys()
	for key in keys:
		var value = description[key]
		var is_array = typeof(value) == TYPE_ARRAY
		if (is_array && index in value) or (not is_array && index == value):
			return key
	return null
