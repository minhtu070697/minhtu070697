extends Node

class_name MiningCaveGenerator

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
var tiles
var terrain_noise_map
var biome_noise_map
var print_noise_map = false
var diamond_resource: MapObject
var emerald_resource: MapObject
var ruby_resource: MapObject
var amber_resource: MapObject
var amethyst_resource: MapObject
var quartz_resource: MapObject
var sapphire_resource: MapObject
var torch_decoration: MapObject


var def_rate = 0.6
var def_amount = 100



func _init(_map_manager, _noise_seed, _max_size, _size, _map_position, _xrange, _yrange):
	noise_seed = _noise_seed
	map_manager = _map_manager
	map_info = map_manager.map_info
	max_size = _max_size
	size = _size
	map_position = _map_position
	xrange = _xrange
	yrange = _yrange

	tiles = [
		map_manager.mining_tile,
		map_manager.mining_ground_tile
	]
	biome_noise_map = Noise.generate_default_noise_map_with_seed('biome', max_size, noise_seed + 1)

	#resources
	diamond_resource = MapObject.new(
		preload("res://map/scenes/resources/Diamond.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	emerald_resource = MapObject.new(
		preload("res://map/scenes/resources/Emerald.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	ruby_resource = MapObject.new(
		preload("res://map/scenes/resources/Ruby.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	amber_resource = MapObject.new(
		preload("res://map/scenes/resources/Amber.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	amethyst_resource = MapObject.new(
		preload("res://map/scenes/resources/Amethyst.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	quartz_resource = MapObject.new(
		preload("res://map/scenes/resources/Quartz.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	sapphire_resource = MapObject.new(
		preload("res://map/scenes/resources/Sapphire.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate,
		def_amount,
		map_manager
	)

	torch_decoration = MapObject.new(
		preload("res://map/scenes/decorations/Torch.tscn"),
		[map_manager.mining_tile, map_manager.mining_ground_tile],
		def_rate * .3,
		def_amount,
		map_manager
	)


func generate_terrain():
	terrain_noise_map = Noise.generate_noise_map('terrain', max_size, noise_seed, noise_octaves, noise_period, noise_persistence, noise_lacunarity)
	prefill()
	delete_lonely_cells()
	update_bitmap()
	update_tile_map_data()
	fill_objects()


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


func fill_objects():
	for x in range(xrange.x, xrange.y):
		for y in range(yrange.x, yrange.y):
			var info := map_info.last_item(Vector2(x, y))
			fill_rate(info, x, y)
		
			
func fill_rate(info, x, y) -> void:
	var random = Utils.random_int(0, 7)
	match (random):
		#resources
		0:	if diamond_resource.is_spawnable(info):
				map_info.append_resource(diamond_resource.spawn(info, false), Constants.ResourceType.DIAMOND, Vector2(x, y))
		1:	if emerald_resource.is_spawnable(info):
				map_info.append_resource(emerald_resource.spawn(info, false), Constants.ResourceType.EMERALD, Vector2(x, y))
		2:	if ruby_resource.is_spawnable(info):
				map_info.append_resource(ruby_resource.spawn(info, false), Constants.ResourceType.RUBY, Vector2(x, y))
		3:	if amber_resource.is_spawnable(info):
				map_info.append_resource(amber_resource.spawn(info, false), Constants.ResourceType.AMBER, Vector2(x, y))
		4:	if amethyst_resource.is_spawnable(info):
				map_info.append_resource(amethyst_resource.spawn(info, false), Constants.ResourceType.AMETHYST, Vector2(x, y))
		5:	if quartz_resource.is_spawnable(info):
				map_info.append_resource(quartz_resource.spawn(info, false), Constants.ResourceType.QUARTZ, Vector2(x, y))
		6:	if sapphire_resource.is_spawnable(info):
				map_info.append_resource(sapphire_resource.spawn(info, false), Constants.ResourceType.SAPPSHIRE, Vector2(x, y))
		7:	if torch_decoration.is_spawnable(info):
				map_info.append_decoration(torch_decoration.spawn(info, false), Vector2(x, y), Constants.MapInfoType.DECORATION, true)


func tile_index(x, y):
	return x + y * max_size
