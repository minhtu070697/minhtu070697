extends Node

class_name Noise

const NOISE_FILE_TEMPLATE = "res://save/%s-noise.save"

const default_seed = 0
const default_scale = 1
const default_octaves = 4
const default_persistence = 0.5
const default_lacunarity = 2


static func generate_default_noise_map_with_seed(noise_map_name, size, noise_seed):
		return generate_noise_map(noise_map_name, size, noise_seed, default_scale, default_octaves, default_persistence, default_lacunarity)

static func generate_default_noise_map(noise_map_name:String, size:int):
	return generate_noise_map(noise_map_name, size, default_seed, default_scale, default_octaves, default_persistence, default_lacunarity)


static func generate_noise_map(noise_map_name:String, size:int, noise_seed:int, scale:float, octaves:float, persistence:float, lacunarity:float, load_from_save=true):
	var noise_map
	
	if load_from_save:
		noise_map = load_noise_map(noise_map_name, size, noise_seed, scale, octaves, persistence, lacunarity)
		if noise_map:
			return noise_map
	
	var noise = OpenSimplexNoise.new()
	noise.seed = noise_seed
	noise.octaves = 1
	noise_map = Utils.make_2d_array(size, size)
	var octave_offsets = []
  
	for _i in range(octaves):
		var offset_x = Utils.random_int_with_seed(-100000, 100000, noise_seed)
		var offset_y = Utils.random_int_with_seed(-100000, 100000, noise_seed)
		octave_offsets.append(Vector2(offset_x, offset_y))
  
	if scale <= 0:
		scale = 0.00001
  
	var half_size = size / 2.0
	var max_noise_height = -999.0
	var min_noise_height = 999.0
  
	for y in range(size):
		for x in range(size):
			var amplitude:float = 1
			var frequency:float = 1
			var noise_height = 0
	  
			for i in range(octaves):
				var nx = (x - half_size) / scale * frequency + octave_offsets[i].x
				var ny = (y - half_size) / scale * frequency + octave_offsets[i].y
				var noise_value = noise.get_noise_2d(nx, ny)
				noise_height += noise_value * amplitude
				amplitude *= persistence
				frequency *= lacunarity

			noise_map[x][y] = noise_height
			if noise_height > max_noise_height:
				max_noise_height = noise_height
			if noise_height < min_noise_height:
				min_noise_height = noise_height

	for y in range(size):
		for x in range(size):
			noise_map[x][y] = inverse_lerp(min_noise_height, max_noise_height, noise_map[x][y])
	
	save_noise_map(noise_map_name, noise_map, size, noise_seed, scale, octaves, persistence, lacunarity)
  
	return noise_map


static func generate_height_map(size, noise_map, height_multiplier):
	var height_map = Utils.make_2d_array(size, size)
	for x in range(size):
		for y in range(size):
			height_map[x][y] = noise_map[x][y] * height_multiplier
	return height_map


static func noise_to_height(noise_value, height_multiplier):
	return noise_value * height_multiplier


static func get_noise_save_file(noise_map_name):
	return NOISE_FILE_TEMPLATE % noise_map_name


static func save_noise_map(noise_map_name, noise_map, size, noise_seed, scale, octaves, persistence, lacunarity):
	var file = File.new()
	var file_name = get_noise_save_file(noise_map_name)
	file.open(file_name, File.WRITE)
	file.store_var({
		'size': size,
		'seed': noise_seed,
		'scale': scale,
		'octaves': octaves,
		'persistence': persistence,
		'lacunarity': lacunarity,
		'noise_map': noise_map
	})
	file.close()


static func load_noise_map(noise_map_name, size, noise_seed, scale, octaves, persistence, lacunarity):
	var file = File.new()
	var file_name = get_noise_save_file(noise_map_name)
	if not file.file_exists(file_name):
		return null
	file.open(file_name, File.READ)
	var noise_map = file.get_var(true)
	if noise_map['size'] == size and noise_map['seed'] == noise_seed and noise_map['scale'] == scale \
		and noise_map['octaves'] == octaves and noise_map['persistence'] == persistence and noise_map['lacunarity'] == lacunarity:
		file.close()
		return noise_map['noise_map']
	file.close()
	return null
