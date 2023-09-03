extends Node

class_name MapGenerator

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
var spawn_frequency: float
var map_manager  # MapManager
var map_info: MapInfo
var tiles
var fog_tiles
var clean_up_tiles
var terrain_noise_map
var biome_noise_map
var print_noise_map = false
var tree_resource: MapObject
var stone_resource: MapObject
var gold_resource: MapObject
var other_resource: MapObject
var grass_decoration: MapObject
var teleport_decoration: MapObject
var farm_water_fish: MapObject
var farm_water_bubble: MapObject
var battlefield_decoration: MapObject
var battlefield_thuja: MapObject
var battlefield_tree: MapObject
var battlefield_grass: MapObject
var battlefield_roots: MapObject
var battlefield_vase: MapObject
var battlefield_water_bubble: MapObject

#ambience_sound
var water_ambience_sound: MapObject


func _init(_map_manager, _noise_seed, _max_size, _size, _map_position, _xrange, _yrange):
	noise_seed = _noise_seed
	map_manager = _map_manager
	map_info = map_manager.map_info
	max_size = _max_size
	size = _size
	map_position = _map_position
	xrange = _xrange
	yrange = _yrange
	spawn_frequency = cal_spawn_frequency()

	fog_tiles = map_manager.fog_tiles
	tiles = [
		map_manager.water_tile,
		map_manager.earth_tile,
		map_manager.dark_grass_tile,
		map_manager.ground_tile
	]
	clean_up_tiles = [map_manager.dark_grass_tile, map_manager.ground_tile]
	biome_noise_map = Noise.generate_default_noise_map_with_seed('biome', max_size, noise_seed + 1)

	if !map_manager.is_battlefield:
		#resources
		tree_resource = MapObject.new(
			preload("res://map/scenes/resources/Tree.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.5,
			200 * spawn_frequency,
			map_manager,
			{
				'name': 'tree',
				'noise_map': biome_noise_map,
				'threshold': 0.2
			}
		)

		stone_resource = MapObject.new(
			preload("res://map/scenes/resources/Stone.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.4,
			60 * spawn_frequency,
			map_manager,
			{
				'name': 'stone',
				'noise_map': biome_noise_map,
				'threshold': 0.3
			}
		)
		
		gold_resource = MapObject.new(
			preload("res://map/scenes/resources/Gold.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.4,
			30 * spawn_frequency,
			map_manager,
			{
				'name': 'gold',
				'noise_map': biome_noise_map,
				'threshold': 0.3
			}
		)

		other_resource = MapObject.new(
			preload("res://map/scenes/resources/Other.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.4,
			60 * spawn_frequency, 
			map_manager
		)

		#decorations
		grass_decoration = MapObject.new(
			preload("res://map/scenes/decorations/Grass.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.4,
			0 * spawn_frequency,
			map_manager
		)
		
		if GameManager.save_load_manager.is_first_time_open():
			teleport_decoration = MapObject.new(
				preload("res://map/scenes/decorations/Teleport.tscn"),
				[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
				1,
				1,
				map_manager
			)

		farm_water_fish = MapObject.new(
			preload("res://map/scenes/vfxs/WaterFish.tscn"),
			[map_manager.water_tile],
			0.4,
			100 * spawn_frequency,
			map_manager
		)

		farm_water_bubble = MapObject.new(
			preload("res://map/scenes/vfxs/FarmWaterBubble.tscn"),
			[map_manager.water_tile],
			0.4,
			100 * spawn_frequency,
			map_manager
		)

		water_ambience_sound = MapObject.new(
			preload("res://environment_sounds/scenes/water_ambience_sound.tscn"),
			[map_manager.water_tile],
			0.2,
			1,
			map_manager
		)
	else:
		#decorations: battlefield
		battlefield_decoration = MapObject.new(
			preload("res://map/scenes/decorations/BattleObject.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.25,
			10,
			map_manager
		)

		battlefield_thuja = MapObject.new(
			preload("res://map/scenes/decorations/BattleThuja.tscn"),
			[map_manager.earth_tile, map_manager.ground_tile],
			.7,
			150,
			map_manager,
			{
				'name': 'tree',
				'noise_map': biome_noise_map,
				'threshold': 0.6
			}
		)

		battlefield_roots = MapObject.new(
			preload("res://map/scenes/decorations/BattleRoots.tscn"),
			[map_manager.earth_tile, map_manager.dark_grass_tile, map_manager.ground_tile],
			0.2,
			10,
			map_manager
		)

		battlefield_water_bubble = MapObject.new(
			preload("res://map/scenes/vfxs/BattleWaterBubble.tscn"),
			[map_manager.water_tile],
			0.8,
			100,
			map_manager
		)


func generate_terrain():
	terrain_noise_map = Noise.generate_noise_map('terrain', max_size, noise_seed, noise_octaves, noise_period, noise_persistence, noise_lacunarity)
	prefill()
	fogfill()
	clean_up_prefill()
	delete_lonely_cells()
	update_bitmap()
	update_tile_map_data()
	

func generate_objects():
	if not map_manager.is_battlefield: 
		# load data from json
		GameManager.save_load_manager.build_data_temp = GameManager.save_load_manager.load_build_data()
		# spawn objects from data
		GameManager.save_load_manager.load_object_from_data()
	# fill random-objects => ex: resources,...
	fill_objects()
	# re-add_disabled_points
	map_manager.map_navigator._add_disabled_points()


func prefill():
	for x in range(0, max_size):
		for y in range(0, max_size):
			for tile in tiles:
				tile.prefill(terrain_noise_map[x][y], Vector2(x, y))


func fogfill():
	var list_map_positions_default = Constants.list_map_positions_default
	var list_map_positions = map_manager.list_map_positions
	for i in list_map_positions_default.size():
		if not list_map_positions.has(list_map_positions_default[i]):
			var xrange_temp = Utils.cal_xrange(list_map_positions_default[i], size)
			var yrange_temp = Utils.cal_yrange(list_map_positions_default[i], size)
			for x in range(xrange_temp.x, xrange_temp.y):
				for y in range(yrange_temp.x, yrange_temp.y):
					fog_tiles[i].prefill(terrain_noise_map[x][y], Vector2(x, y))


func clean_up_prefill():
	for x in range(0, max_size):
		for y in range(0, max_size):
			for tile in clean_up_tiles:
				tile.clean_up_prefill(Vector2(x, y))


func delete_lonely_cells():
	for x in range(0, max_size):
		for y in range(0, max_size):
			for tile in tiles:
				tile.delete_lonely_cell(Vector2(x, y))


func update_bitmap():
	for x in range(0, max_size):
		for y in range(0, max_size):
			for tile in tiles:
				tile.update_bitmap(Vector2(x, y))


func update_tile_map_data():
	map_info.data = Utils.make_2d_array(max_size, max_size)
	for x in range(0, max_size):
		for y in range(0, max_size):
			for tile in tiles:
				if tile.tile_exists(Vector2(x, y)):
					map_info.append_tile(tile, Vector2(x, y))


func fill_objects():
	var list_map_positions = map_manager.list_map_positions
	for i in list_map_positions.size():
		fill_objects_in_land(i, false)


func fill_objects_in_land(land_id: int, unlock_vfx: bool = false) -> void:
	var list_map_positions = map_manager.list_map_positions
	var map_pos: Vector2 = list_map_positions[land_id]
	fill_objects_in_land_pos(map_pos, unlock_vfx)


func fill_objects_in_land_pos(land_pos: Vector2, unlock_vfx: bool = false) -> void:
	var xrange_temp = Utils.cal_xrange(land_pos, size)
	var yrange_temp = Utils.cal_yrange(land_pos, size)
	for x in range(xrange_temp.x, xrange_temp.y):
		for y in range(yrange_temp.x, yrange_temp.y):
			var info := map_info.last_item(Vector2(x, y))
			var spawned_obj = fill_rate(info, x, y, unlock_vfx)
			if spawned_obj:
				if spawned_obj is StaticObjects:
					spawned_obj.created()
				
				map_manager.ysort.nogias_insert(spawned_obj)
		

func fill_objects_custom(_points:Array):
	var is_unlock = true
	for point in _points:
		var info := map_info.last_item(point)
		var spawned_obj = fill_rate(info, point.x, point.y, is_unlock)
		if spawned_obj:
			if spawned_obj is StaticObjects:
				spawned_obj.created()
			
			map_manager.ysort.nogias_insert(spawned_obj)
				
			
func fill_rate(info, x, y, is_unlock):
	var random
	var spawned_obj = null
	if !map_manager.is_battlefield:
		# farm
		random = Utils.random_int(0, 8)
		# random = 8
		match (random):
			#resources
			0:	if tree_resource.is_spawnable(info):
					spawned_obj = tree_resource.spawn(info, is_unlock)
					map_info.append_resource(spawned_obj, Constants.ResourceType.TREE, Vector2(x, y))
			1:	if stone_resource.is_spawnable(info):
					spawned_obj = stone_resource.spawn(info, is_unlock)
					map_info.append_resource(spawned_obj, Constants.ResourceType.STONE, Vector2(x, y))
			2:	if gold_resource.is_spawnable(info):
					spawned_obj = gold_resource.spawn(info, is_unlock)
					map_info.append_resource(spawned_obj, Constants.ResourceType.GOLD, Vector2(x, y))
			3:	if other_resource.is_spawnable(info):
					spawned_obj = other_resource.spawn(info, is_unlock)
					map_info.append_resource(spawned_obj, Constants.ResourceType.OTHER, Vector2(x, y))
			#decorations
			4:	if farm_water_fish.is_spawnable(info):
					spawned_obj = farm_water_fish.spawn(info, is_unlock)
					map_info.append_decoration(spawned_obj, Vector2(x, y), Constants.MapInfoType.WALKABLE_DECORATION, false)
			5:	if farm_water_bubble.is_spawnable(info):
					spawned_obj = farm_water_bubble.spawn(info, is_unlock)
					map_info.append_decoration(spawned_obj, Vector2(x, y), Constants.MapInfoType.WALKABLE_DECORATION, false)
			6:	if grass_decoration.is_spawnable(info):
					spawned_obj = grass_decoration.spawn(info, is_unlock)
					map_info.append_decoration(spawned_obj, Vector2(x, y), Constants.MapInfoType.WALKABLE_DECORATION, true)
			7:	if water_ambience_sound.is_spawnable(info):
					spawned_obj = water_ambience_sound.spawn(info, is_unlock)
					map_info.append_decoration(spawned_obj, Vector2(x, y), Constants.MapInfoType.DECORATION, false)
			8:	if GameManager.save_load_manager.is_first_time_open() and teleport_decoration.is_spawnable(info):
					spawned_obj = teleport_decoration.spawn(info, is_unlock)
					map_info.append_decoration(spawned_obj, Vector2(x, y), Constants.MapInfoType.WALKABLE_DECORATION, true)
					if spawned_obj != null:
						var scene_name = Utils.get_scene_name_from_node(spawned_obj.name)
						var origin = Vector2(x, y)
						GameManager.save_load_manager.append_build_data(
							Constants.BuildingType.WALKABLE_DECORATION,
							Constants.DecorationType.TELEPORT,
							scene_name,
							spawned_obj.sprite_name,
							spawned_obj.scale,
							spawned_obj.position,
							origin,
							true
						)
						GameManager.save_load_manager.save_build_data()
						GameManager.save_load_manager.save_first_time_open()
	else:
		# battlefield
		random = Utils.random_int(1, 4)
		match (random):
			#resources
			0:	if battlefield_vase.is_spawnable(info):
					map_info.append_resource(battlefield_vase.spawn(info, is_unlock), Constants.ResourceType.BATTLE_VASE, Vector2(x, y))
			#decorations
			1:	if battlefield_decoration.is_spawnable(info):
					map_info.append_decoration(battlefield_decoration.spawn(info, is_unlock), Vector2(x, y), Constants.MapInfoType.DECORATION, true)
			2:	if battlefield_thuja.is_spawnable(info):
					map_info.append_decoration(battlefield_thuja.spawn(info, is_unlock), Vector2(x, y), Constants.MapInfoType.DECORATION, true)
			# 3:	if battlefield_tree.is_spawnable(info):
			# 		map_info.append_decoration(battlefield_tree.spawn(info), Vector2(x, y), Constants.MapInfoType.DECORATION, true)
			3:	if battlefield_roots.is_spawnable(info):
					map_info.append_decoration(battlefield_roots.spawn(info, is_unlock), Vector2(x, y), Constants.MapInfoType.DECORATION, true)
			4:	if battlefield_water_bubble.is_spawnable(info):
					map_info.append_decoration(battlefield_water_bubble.spawn(info, is_unlock), Vector2(x, y), Constants.MapInfoType.DECORATION, false)
	
	return spawned_obj


func tile_index(x, y):
	return x + y * max_size


func cal_spawn_frequency():
	var _size: float = size # ex: 48
	var default_size: float = 48.0 / 3.0 # ex: 48 / 3 = 16
	return _size / default_size
