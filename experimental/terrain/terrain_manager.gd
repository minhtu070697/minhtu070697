extends Node

export(int) var world_size = 48
export(int) var map_size = 48
export(int) var max_world_levels = 20

export(int) var noise_seed = 0
export(Vector2) var land_position = Vector2.ZERO
export(float) var scale = 1
export(int) var octaves = 4
export(float) var persistence = 0.5
export(float) var lacunarity = 2
export(float) var height_multiplier = 1
export(Curve) var curve: Curve

export(bool) var fill_bottoms = true

onready var map_layers = $MapLayers

var water_tile
var earth_tile
var dark_earth_tile
var dark_grass_tile
var ground_tile
var stones_tile
var floor_tile
var wall_tile
var mining_tile
var mining_ground_tile
var fog_tile

var cell_size = Vector2(46, 24)


var tile_maps = {}
var noise_map

var max_height = 0
var min_height = 1
var num_levels
var level_height

func _ready():
	# TODO:
	# 1- Raise water level
	# 2- Increase general terrain heights
	noise_map = Noise.generate_default_noise_map('terrain', world_size)
	
	for x in range(map_size):
		for y in range(map_size):
			var height_value = height(noise_map[x][y])
			if height_value > max_height:
				max_height = height_value
			if height_value < min_height:
				min_height = height_value

	level_height =  height(1.0) / max_world_levels
	num_levels = int((max_height - min_height) / level_height)
	for i in range(num_levels):
		tile_maps[i] = create_tile_map(i)
	generate_map()
	
func generate_map():
	for x in range(map_size):
		for y in range(map_size):
			var noise_value = noise_map[x][y]
			var height_value = height(noise_value)
			
			var level = noise_value_to_level(height_value-min_height)
			
			if fill_bottoms:
				for i in range(level):                
					var tile_index = noise_value_to_terrain(noise_value - (level-i) * level_height)
					tile_maps[i].set_cell(x, y, tile_index)
			else:
				var tile_index = noise_value_to_terrain(noise_value)
				tile_maps[level].set_cell(x, y, tile_index)
			
	
func noise_value_to_level(value):
	var level = int(floor(value/level_height))
	if level == num_levels:
		level -= 1
	return level
	
func height(value):
	return Noise.noise_to_height(value, height_multiplier)
	
func noise_value_to_terrain(value):
	if value <= .1:
		return 0 # deep sea
	elif value <= .3:
		return 1 # sea
	elif value <= .4:
		return 2 # beach
	elif value <= .7:
		return 3 # grass
	elif value <= .85:
		return 4 # hill
	elif value <= .95:
		return 5 # mountain
	elif value <= 1:
		return 6 # snow
	
func create_tile_map(i):
	var tile_map = TileMap.new()
	tile_map.mode = TileMap.MODE_ISOMETRIC
	tile_map.cell_size = cell_size
	tile_map.tile_set = Utils.load_resource("res://experimental/terrain/test-tiles.tres", "test_tiles", "tres")
	tile_map.position = Vector2(0, -10 * i)
	map_layers.add_child(tile_map)
	return tile_map
