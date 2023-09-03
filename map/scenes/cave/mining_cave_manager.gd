extends Navigation2D

class_name MiningCaveManager

export(int) var map_width = 48
export(int) var map_height = 48
export(int) var noise_seed = 0
export var is_battlefield: bool
export(int) var map_type = Constants.MapSceneType.MINING_MAP

onready var water_tile = TileManager.new($WaterTileMap, TileDescriptions.water)
onready var earth_tile = TileManager.new(
	$EarthTileMap, TileDescriptions.earth, water_tile, Vector2(0.3, 1), TileDescriptions.earth_water
)
onready var mining_tile = TileManager.new($MiningTileMap, TileDescriptions.mining)
onready var mining_ground_tile = TileManager.new($MiningGroundTileMap, TileDescriptions.mining_ground)

onready var tile_highlight = $TileHightlight

onready var ysort = $YSort

var cell_size = Vector2(46, 24)
var mining_cave_generator
var map_navigator: MapNavigatorManager
var map_info: MapInfo
var show_ui_delay = 3
var player_ready: bool = false
var environment_type: int = Constants.EnvironmentType.CAVE

export(int)var size: int = 48
export(Array, Vector2)var list_map_positions = [Vector2(0, 0)]
var max_size: int = size * 3
var map_position: Vector2 = Vector2(0, 0)
var xrange: Vector2
var yrange: Vector2

func _ready():
	# logic
	max_size = size * 3
	xrange = Vector2(map_position.x * size, map_position.x * size + size)
	yrange = Vector2(map_position.y * size, map_position.y * size + size)

	GameManager.set_map_manager(self)
	map_info = MapInfo.new(self, map_type, max_size, size, map_position)
	mining_cave_generator = MiningCaveGenerator.new(self, noise_seed, max_size, size, map_position, xrange, yrange)
	mining_cave_generator.generate_terrain()
	map_navigator = MapNavigatorManager.new(self, max_size, size, map_position)
	
	GameManager.save_load_manager.load_current_timing()
	GameManager.audio_manager.play_music(self)
	GameManager.scene_manager.open_scene(GameManager.scene_manager.mining_cave_title)
	GameManager.scene_manager.spawn_blocking_input(self)
	SignalManager.connect("character_arrived", self, "_on_character_arrived")
	SignalManager.connect("player_ready", self, "_on_player_ready")

	if not is_battlefield: spawn_character_from_save_file()
	show_private_ui()


func _process(_delta: float) -> void:
	if GameManager.daytime_manager != null and not is_battlefield:
		GameManager.daytime_manager.set_current_timing(_delta)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		if not is_click_outside_map_bounds():
			var point = $EarthTileMap.map_to_world(
				$EarthTileMap.world_to_map(get_global_mouse_position())
			)
			tile_highlight.global_position = Vector2(point.x, point.y + cell_size.y)
			tile_highlight.visible = true
			Utils.start_tween($Tween, tile_highlight, "modulate", Color("00ffffff"), Color("ffffffff"), 0.5)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
		GameManager.save_load_manager.character_save.character_save(Utils.get_current_character())


func _on_player_ready():
	player_ready = true
	GameManager.daytime_manager.run_timer()
			

func _on_character_arrived(_host_name):
	if _host_name == "Character":
		tile_highlight.visible = false


func is_click_outside_map_bounds() -> bool:
	var local_point = $EarthTileMap.world_to_map(get_global_mouse_position())
	if Utils.is_outside_of_map(list_map_positions, size, local_point):
		return true
	else:
		return false


func show_private_ui():
	yield(Utils.start_coroutine(show_ui_delay), "completed")
	var character = Utils.get_current_character()
	var ui_manager = character.get_node_or_null("ui")
	ui_manager.visible_button_farm(true)
	ui_manager.visible_buttons_in_private_scene()


# region: load character from save file
func spawn_character_from_save_file():
	for i in 1:
		var _character_name: String = "1"
		var _character_data: Dictionary
		var _load_save_character: bool = false
		var _character_race: String = ""
		if !GameResourcesLibrary.character_save_test.has(_character_name):
			_character_race = choose_character_race()
		else:
			var _character_1_save_data = GameResourcesLibrary.character_save_test[_character_name]
			_character_data = _character_1_save_data
			_character_race = _character_data.information.race
			_load_save_character = true
			
		var _farmer_character: Node
		match _character_race:
			"human":
				_farmer_character = Utils.load_resource("res://characters/scenes/character.tscn", "farmer_character", "scene").instance()
			"elf":
				_farmer_character = Utils.load_resource("res://characters/scenes/elf.tscn", "elf_character", "scene").instance()
			"beast_man":
				_farmer_character = Utils.load_resource("res://characters/scenes/beast_man.tscn", "beast_man_character", "scene").instance()
				
				
		var character_spawn_point = Vector2(xrange.x, yrange.x)
		_farmer_character.global_position = GameManager.map_manager_utils.map_to_global_position(character_spawn_point)
		ysort.add_child(_farmer_character)
		if _load_save_character:
			_farmer_character.stats_manager.load_character_stats_from_save(GameResourcesLibrary.character_save_test["4"])
		else:
			_farmer_character.stats_manager.load_new_character_inventory(GameResourcesLibrary.new_character_inventory[_character_race])


func choose_character_race() -> String:
	#when we have race selecting UI, we will update this func
	return "human"
# endregion
