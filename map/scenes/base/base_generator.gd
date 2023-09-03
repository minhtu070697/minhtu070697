extends Node

class_name BaseGenerator

var max_size: int # vd: 144
var size: int # vd: 48
var map_position: Vector2 # (0,0) , (1,1)
var xrange: Vector2
var yrange: Vector2

var noise_seed
var noise_octaves = 4
var noise_period = 20
var noise_persistence = .5
var noise_lacunarity = 2
var map_manager  # MapManager
var map_info: MapInfo
var map_info_1: MapInfo
var map_info_2: MapInfo
var tiles
var terrain_noise_map
var print_noise_map = false
var table_decoration: MapObject


func _init(_map_manager, _noise_seed, _max_size, _size, _map_position, _xrange, _yrange):
	noise_seed = _noise_seed
	map_manager = _map_manager
	map_info = map_manager.map_info
	map_info_1 = map_manager.map_info_1st
	map_info_2 = map_manager.map_info_2nd
	max_size = _max_size
	size = _size
	map_position = _map_position
	xrange = _xrange
	yrange = _yrange

	tiles = [
		map_manager.floor_tile,
		map_manager.wall_tile,
		map_manager.floor_1_tile,
		map_manager.wall_1_tile,
		map_manager.floor_2_tile,
		map_manager.wall_2_tile
	]

	table_decoration = MapObject.new(
			preload("res://map/scenes/decorations/Table.tscn"),
			[map_manager.floor_tile, map_manager.wall_tile, map_manager.floor_1_tile, map_manager.wall_1_tile, map_manager.floor_2_tile, map_manager.wall_2_tile],
			1,
			0,
			map_manager
		)


func generate_terrain():
	terrain_noise_map = Noise.generate_noise_map('terrain', max_size, noise_seed, noise_octaves, noise_period, noise_persistence, noise_lacunarity)
	prefill()
	delete_lonely_cells()
	update_bitmap()
	update_tile_map_data()
	
	
func generate_objects():
	# load data from json
	GameManager.save_load_manager.build_data_temp = GameManager.save_load_manager.load_build_data()
	# spawn objects from data
	GameManager.save_load_manager.load_object_from_data()
	# fill random-objects => ex: resources,...
	# fill_objects()
	# re-add_disabled_points
	map_manager.map_navigator._add_disabled_points()


func prefill():
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				tile.prefill(terrain_noise_map[x][y], Vector2(x, y))


func delete_lonely_cells():
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				tile.delete_lonely_cell(Vector2(x, y))


func update_bitmap():
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				tile.update_bitmap(Vector2(x, y))


func update_tile_map_data():
	map_info.data = Utils.make_2d_array(max_size, max_size)
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				if tile.tile_exists(Vector2(x, y)):
					map_info.append_tile(tile, Vector2(x, y))

	map_info_1.data = Utils.make_2d_array(max_size, max_size)
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				if tile.tile_exists(Vector2(x, y)):
					map_info_1.append_tile(tile, Vector2(x, y))
					
	map_info_2.data = Utils.make_2d_array(max_size, max_size)
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			for tile in tiles:
				if tile.tile_exists(Vector2(x, y)):
					map_info_2.append_tile(tile, Vector2(x, y))


func fill_objects():
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			var info := map_info.last_item(Vector2(x, y))
			fill_rate(info, x, y)

	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			var info := map_info_1.last_item(Vector2(x, y))
			fill_rate(info, x, y)

	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			var info := map_info_2.last_item(Vector2(x, y))
			fill_rate(info, x, y)
		
			
func fill_rate(info, x, y) -> void:
	if table_decoration.is_spawnable(info):
		map_info.append_decoration(table_decoration.spawn(info, false), Vector2(x, y), Constants.MapInfoType.BELOW_DECORATION, true)
	

func tile_index(x, y):
	return x + y * max_size
