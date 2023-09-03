extends Node

class_name UIManager

onready var inventory = $Inventory
onready var crafting = $Crafting
onready var reforge_tab = $ReforgeTab
onready var btn_close_reforge_tab = $ReforgeTab/ButtonClose
onready var reforge_tab_tween = $ReforgeTab/Tween
onready var cooking_tab: CookingTab = $CookingTab
onready var btn_close_cooking_tab = $CookingTab/ButtonClose
onready var cooking_tab_tween = $CookingTab/Tween
onready var crafting_tutorial = $CraftingTutorial
onready var btn_close_crafting = $Crafting/ButtonClose
onready var btn_inventory = $GroupHUD/ButtonInventory
onready var btn_close_inventory = $Inventory/ButtonClose
onready var btn_stats = $GroupHUD/StatsButton
onready var group_character_info = $GroupHUD/CharacterInfo
onready var group_hud = $GroupHUD
onready var group_hud_tween = $GroupHUD/Tween
onready var group_input = $GroupHUD/GroupInput
onready var group_input_tutorial = $GroupHUD/GroupInputTutorial
onready var group_stats = $GroupStats
onready var character_stats_tab = $GroupStats/CharacterStatsTab
onready var character_skills_tab = $GroupStats/CharacterSkillTab

onready var btn_map = $GroupHUD/ButtonMap
onready var btn_home = get_parent().get_node_or_null("GroupLocalHUD").get_node_or_null("ButtonHome")
onready var btn_home_upgrade = get_parent().get_node_or_null("GroupLocalHUD").get_node_or_null(
	"ButtonHomeUpgrade"
)
onready var btn_mining_cave = get_parent().get_node_or_null("GroupLocalHUD").get_node_or_null(
	"ButtonMiningCave"
)
onready var btn_farm = $GroupHUD/ButtonFarm

onready var btn_build = $GroupHUD/ButtonBuild
onready var group_build = $GroupBuild
onready var group_build_tween = $GroupBuild/Tween
onready var group_build_custom_tween = $GroupBuildCustom/Tween
onready var group_remove_custom_tween = $GroupRemoveCustom/Tween
onready var group_build_ingredients = $GroupBuild/GroupIngredients

onready var btn_farming = $GroupHUD/ButtonFarming
onready var group_farming = $GroupFarming
onready var group_farming_tween = $GroupFarming/Tween
onready var group_farm_ingredients = $GroupFarming/GroupIngredients

onready var list_categories = $GroupBuild/ListCategories
onready var list_houses = $GroupBuild/ListHouses
onready var list_farm_decors = $GroupBuild/ListFarmDecors
onready var list_edges = $GroupBuild/ListEdges
onready var list_bridges = $GroupBuild/ListBridges
onready var list_stairs = $GroupBuild/ListStairs
onready var list_tables = $GroupBuild/ListTables
onready var list_chairs = $GroupBuild/ListChairs
onready var list_beds = $GroupBuild/ListBeds
onready var list_cabinets = $GroupBuild/ListCabinets
onready var list_table_decors = $GroupBuild/ListTableDecors
onready var list_wall_decors = $GroupBuild/ListWallDecors
onready var list_plays = $GroupBuild/ListPlays
onready var list_walls = $GroupBuild/ListWalls
onready var list_house_plants = $GroupBuild/ListHousePlants
onready var list_resources = $GroupBuild/ListResources

onready var btn_category_house = $GroupBuild/ListCategories/ButtonHouse
onready var btn_category_farm_decor = $GroupBuild/ListCategories/ButtonFarmDecoration
onready var btn_category_edge = $GroupBuild/ListCategories/ButtonEdge
onready var btn_category_bridge = $GroupBuild/ListCategories/ButtonBridge
onready var btn_category_stairs = $GroupBuild/ListCategories/ButtonStairs
onready var btn_category_table = $GroupBuild/ListCategories/ButtonTable
onready var btn_category_chair = $GroupBuild/ListCategories/ButtonChair
onready var btn_category_bed = $GroupBuild/ListCategories/ButtonBed
onready var btn_category_cabinet = $GroupBuild/ListCategories/ButtonCabinet
onready var btn_category_table_decor = $GroupBuild/ListCategories/ButtonTableDecoration
onready var btn_category_wall_decor = $GroupBuild/ListCategories/ButtonWallDecoration
onready var btn_category_play = $GroupBuild/ListCategories/ButtonPlay
onready var btn_category_wall = $GroupBuild/ListCategories/ButtonWall
onready var btn_category_house_plant = $GroupBuild/ListCategories/ButtonHousePlant
onready var btn_category_resources = $GroupBuild/ListCategories/ButtonResources

onready var btn_build_house = $GroupBuild/ListHouses/ButtonHouse
onready var btn_build_farm_house = $GroupBuild/ListHouses/ButtonFarmHouse
onready var btn_build_medium_house = $GroupBuild/ListHouses/ButtonMediumHouse
onready var btn_build_windmill_house = $GroupBuild/ListHouses/ButtonWindMillHouse
onready var btn_build_green_house = $GroupBuild/ListHouses/ButtonGreenHouse
onready var btn_build_storage_house = $GroupBuild/ListHouses/ButtonStorageHouse
onready var btn_build_dock = $GroupBuild/ListHouses/ButtonDock

onready var btn_build_scarecrow = $GroupBuild/ListFarmDecors/ButtonScareCrow
onready var btn_build_watering_can = $GroupBuild/ListFarmDecors/ButtonWateringCan
onready var btn_build_well = $GroupBuild/ListFarmDecors/ButtonWell
onready var btn_build_pet_house = $GroupBuild/ListFarmDecors/ButtonPetHouse
onready var btn_build_torch = $GroupBuild/ListFarmDecors/ButtonTorch
onready var btn_build_torch_1 = $GroupBuild/ListFarmDecors/ButtonTorch_1
onready var btn_build_torch_2 = $GroupBuild/ListFarmDecors/ButtonTorch_2
onready var btn_build_torch_3 = $GroupBuild/ListFarmDecors/ButtonTorch_3
onready var btn_build_torch_4 = $GroupBuild/ListFarmDecors/ButtonTorch_4
onready var btn_build_grass = $GroupBuild/ListFarmDecors/ButtonGrass
onready var btn_build_flower = $GroupBuild/ListFarmDecors/ButtonFlower
onready var btn_build_wheat = $GroupBuild/ListFarmDecors/ButtonWheat
onready var btn_build_teleport = $GroupBuild/ListFarmDecors/ButtonTeleport

onready var btn_build_edge = $GroupBuild/ListEdges/ButtonEdge
onready var btn_build_edge_1 = $GroupBuild/ListEdges/ButtonEdge_1
onready var btn_build_corner = $GroupBuild/ListEdges/ButtonCorner
onready var btn_build_corner_1 = $GroupBuild/ListEdges/ButtonCorner_1

onready var btn_build_bridge = $GroupBuild/ListBridges/ButtonBridge
onready var btn_build_bridge_1 = $GroupBuild/ListBridges/ButtonBridge_1
onready var btn_build_bridge_2 = $GroupBuild/ListBridges/ButtonBridge_2

onready var btn_build_stairs = $GroupBuild/ListStairs/ButtonStairs

onready var btn_build_table = $GroupBuild/ListTables/ButtonTable
onready var btn_build_table_1 = $GroupBuild/ListTables/ButtonTable_1
onready var btn_build_table_2 = $GroupBuild/ListTables/ButtonTable_2

onready var btn_build_chair = $GroupBuild/ListChairs/ButtonChair
onready var btn_build_sofa = $GroupBuild/ListChairs/ButtonSofa
onready var btn_build_sofa_1 = $GroupBuild/ListChairs/ButtonSofa_1

onready var btn_build_bed = $GroupBuild/ListBeds/ButtonBed
onready var btn_build_bed_1 = $GroupBuild/ListBeds/ButtonBed_1

onready var btn_build_book_case = $GroupBuild/ListCabinets/ButtonBookCase
onready var btn_build_book_case_1 = $GroupBuild/ListCabinets/ButtonBookCase_1
onready var btn_build_book_case_2 = $GroupBuild/ListCabinets/ButtonBookCase_2

onready var btn_build_wall = $GroupBuild/ListWalls/ButtonWall
onready var btn_build_wall_1 = $GroupBuild/ListWalls/ButtonWall_1
onready var btn_build_wall_2 = $GroupBuild/ListWalls/ButtonWall_2
onready var btn_build_wall_3 = $GroupBuild/ListWalls/ButtonWall_3
onready var btn_build_wall_4 = $GroupBuild/ListWalls/ButtonWall_4
onready var btn_build_wall_5 = $GroupBuild/ListWalls/ButtonWall_5
onready var btn_build_wall_6 = $GroupBuild/ListWalls/ButtonWall_6
onready var btn_build_wall_7 = $GroupBuild/ListWalls/ButtonWall_7
onready var btn_build_door = $GroupBuild/ListWalls/ButtonDoor

onready var btn_build_house_plant = $GroupBuild/ListHousePlants/ButtonHousePlant

onready var btn_build_book = $GroupBuild/ListTableDecors/ButtonBook
onready var btn_build_book_1 = $GroupBuild/ListTableDecors/ButtonBook_1
onready var btn_build_book_2 = $GroupBuild/ListTableDecors/ButtonBook_2

onready var btn_build_food = $GroupBuild/ListTableDecors/ButtonFood
onready var btn_build_food_1 = $GroupBuild/ListTableDecors/ButtonFood_1
onready var btn_build_food_2 = $GroupBuild/ListTableDecors/ButtonFood_2

onready var btn_build_chess = $GroupBuild/ListPlays/ButtonChess
onready var btn_build_table_billiards = $GroupBuild/ListPlays/ButtonTable_Billiards

onready var btn_build_picture = $GroupBuild/ListWallDecors/ButtonPicture
onready var btn_build_tv = $GroupBuild/ListWallDecors/ButtonTV

onready var btn_build_mining_cave = $GroupBuild/ListResources/ButtonMiningCave

onready var list_categories_farming = $GroupFarming/ListCategories

onready var list_plantings = $GroupFarming/ListPlantings
onready var list_husbandaries = $GroupFarming/ListHusbandaries

onready var btn_category_planting = $GroupFarming/ListCategories/ButtonPlanting
onready var btn_category_husbandary = $GroupFarming/ListCategories/ButtonHusbandry

onready var btn_build_plant = $GroupFarming/ListPlantings/ButtonPlant
onready var btn_build_cow_barn = $GroupFarming/ListHusbandaries/ButtonCowBarn

onready var group_build_custom = $GroupBuildCustom
onready var group_remove_custom = $GroupRemoveCustom

onready var seed_inventory = $SeedInventory
onready var barn_inventory = $LivestockBarnInventory

onready var tween_inventory = $Inventory/Tween
onready var tween_crafting = $Crafting/Tween
onready var tween_crafting_tutorial = $CraftingTutorial/Tween

onready var group_stairs = get_parent().get_node_or_null("GroupStairs")
onready var btn_go_up = get_parent().get_node_or_null("GroupStairs").get_node_or_null("ButtonGoUp")
onready var btn_go_down = get_parent().get_node_or_null("GroupStairs").get_node_or_null(
	"ButtonGoDown"
)

onready var skill_bar = $Skillbar

var is_ui_tweening: bool
var character
var holding_item = null
var holding_slot = null

var zoom: float = 0
var zoom_intensity: float = 0.1
var is_open_map: bool = false

var cur_point_mouse_global_position
var temp_point_mouse_global_position

var list_available_build_buttons = []
var choosing_index: int = 0
var is_outside_menu: bool = true


func _ready():
	character = get_parent()
	connect_buttons_signal()


func _unhandled_input(event):
	if event.is_action_pressed("rotate_object") and GameManager.build_manager.holding_object:
		if GameManager.build_manager.is_object_balance():
			GameManager.build_manager.rotate_object()
		else:
			GameManager.build_manager.rotate_imbalance_object()
	elif event.is_action_pressed("build_cancel") and GameManager.build_manager.holding_object:
		build_canel_including_ui()

	shortcut_key_input(event)


func _input(event):
	if (
		event is InputEventKey
		and event.is_action_pressed("open_map")
		and character.map_manager.map_type == Constants.MapSceneType.FARM_MAP
		and not character.map_manager.is_battlefield
		and not GameManager.save_load_manager.remove_object_mode
	):
		open_map()
	if (not is_open_map 
		and not GameManager.build_manager.holding_object 
		and not GameManager.save_load_manager.remove_object_mode):
		camera_zoom(event)
		if event is InputEventKey and event.pressed:
			build_buttons_choosing()
			build_button_choose()


func shortcut_key_input(event):
	if not GameManager.save_load_manager.remove_object_mode:
		if event.is_action_pressed("character") and not is_ui_tweening and not_holding_build_object():
			var uis_checking = []
			uis_checking.append(inventory)
			uis_checking.append(crafting)
			uis_checking.append(group_build)
			uis_checking.append(group_farming)
			if ui_visible_checking(uis_checking):
				character_stats_tab._on_stats_button_clicked(character_stats_tab.stats_button)
				build_canel_including_ui()
		elif event.is_action_pressed("inventory") and not is_ui_tweening and not_holding_build_object():
			var uis_checking = []
			uis_checking.append(character_stats_tab)
			uis_checking.append(character_skills_tab)
			uis_checking.append(group_build)
			uis_checking.append(group_farming)
			if ui_visible_checking(uis_checking):
				on_click_button_inventory(btn_inventory)
				build_canel_including_ui()
		elif event.is_action_pressed("crafting") and not is_ui_tweening and not_holding_build_object():
			if inventory.visible:
				on_click_button_crafting(inventory.btn_crafting)
		elif event.is_action_pressed("reforging") and not is_ui_tweening and not_holding_build_object():
			if inventory.visible:
				_on_reforge_button_clicked(inventory.reforge_button)
		elif event.is_action_pressed("cooking") and not is_ui_tweening and not_holding_build_object():
			if inventory.visible:
				_on_cooking_button_clicked(inventory.cooking_button)
		elif (
			event.is_action_pressed("building")
			and not is_ui_tweening
			and not_holding_build_object()
			and character.map_manager.map_type != Constants.MapSceneType.MINING_MAP
			and not character.map_manager.is_battlefield
		):
			var uis_checking = []
			uis_checking.append(character_stats_tab)
			uis_checking.append(character_skills_tab)
			uis_checking.append(inventory)
			uis_checking.append(crafting)
			uis_checking.append(group_farming)
			if ui_visible_checking(uis_checking):
				on_click_button_build(btn_build)
				build_canel_including_ui()
		elif (
			event.is_action_pressed("farming")
			and not is_ui_tweening
			and not_holding_build_object()
			and character.map_manager.map_type == Constants.MapSceneType.FARM_MAP
			and not character.map_manager.is_battlefield
		):
			var uis_checking = []
			uis_checking.append(character_stats_tab)
			uis_checking.append(character_skills_tab)
			uis_checking.append(inventory)
			uis_checking.append(crafting)
			uis_checking.append(group_build)
			if ui_visible_checking(uis_checking):
				on_click_button_farming(btn_farming)
				build_canel_including_ui()
		elif event.is_action_pressed("ui_cancel") and not is_ui_tweening and not_holding_build_object():
			if inventory.visible:
				hide_inventory()
				hide_crafting()
				hide_reforge_tab()
				hide_cooking_tab()
			elif crafting.visible:
				hide_crafting()
			elif reforge_tab.visible:
				hide_reforge_tab()
			elif cooking_tab.visible:
				hide_cooking_tab()
			elif group_build.visible:
				reset_choosing_index()
				clear_list_available_build_buttons()
				if is_outside_menu:
					visible_group_build(false)
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				else:
					on_click_button_back_build()
			elif group_farming.visible:
				reset_choosing_index()
				clear_list_available_build_buttons()
				if is_outside_menu:
					visible_group_farming(false)
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				else:
					on_click_button_back_farming()
			elif character_stats_tab.visible:
				character_stats_tab.hide_stats()
			elif seed_inventory.visible:
				seed_inventory.hide_seed_inventory()
			elif barn_inventory.visible:
				barn_inventory.hide_barn_inventory()
		elif event.is_action_pressed("door_interact") and not_holding_build_object():
			if (
				not is_ui_tweening
				and not_holding_build_object()
				and not GameManager.scene_manager.is_blocking_input
			):
				if btn_home.visible:
					on_click_button_home()
				elif btn_home_upgrade.visible:
					on_click_button_home_upgrade()
				elif btn_mining_cave.visible:
					on_click_button_mining_cave()
				elif btn_farm.visible:
					on_click_button_farm(btn_farm)
		elif event.is_action_pressed("show_input_tutorial"):
			if (
				GameManager.map_manager.map_type == Constants.MapSceneType.FARM_MAP
				and not GameManager.map_manager.is_battlefield
			):
				visible_group_input_tutorial()


func ui_visible_checking(uis: Array):
	for i in uis.size():
		if uis[i].visible == true:
			return false
	return true


#region: general
func connect_buttons_signal():
	btn_inventory.connect("pressed", self, "on_click_button_inventory", [btn_inventory])
	btn_close_inventory.connect("pressed", self, "on_click_button_inventory", [btn_close_inventory])

	inventory.btn_crafting.connect(
		"pressed", self, "on_click_button_crafting", [inventory.btn_crafting]
	)
	btn_close_crafting.connect("pressed", self, "on_click_button_crafting", [btn_close_crafting])

	inventory.reforge_button.connect(
		"button_up", self, "_on_reforge_button_clicked", [inventory.reforge_button]
	)
	btn_close_reforge_tab.connect(
		"pressed", self, "on_click_button_close_reforge_tab", [btn_close_reforge_tab]
	)

	inventory.cooking_button.connect(
		"button_up", self, "_on_cooking_button_clicked", [inventory.cooking_button]
	)
	btn_close_cooking_tab.connect(
		"pressed", self, "on_click_button_close_cooking_tab", [btn_close_cooking_tab]
	)

	btn_map.connect("pressed", self, "open_map")


func visible_buttons_in_private_scene():
	match character.map_manager.map_type:
		Constants.MapSceneType.FARM_MAP, Constants.MapSceneType.BATTLE_MAP:
			btn_inventory.visible = true
			btn_stats.visible = true
			group_character_info.visible = true
			skill_bar.visible = true
			if not character.map_manager.is_battlefield:
				btn_build.visible = true
				btn_farming.visible = true
				btn_map.visible = true
				group_input.visible = true
		Constants.MapSceneType.BASE_MAP, Constants.MapSceneType.BASE_UPGRADE_MAP:
			btn_inventory.visible = true
			btn_stats.visible = true
			btn_build.visible = true
			group_character_info.visible = true
		Constants.MapSceneType.MINING_MAP:
			btn_inventory.visible = true
			btn_stats.visible = true
			group_character_info.visible = true


func visible_group_input_tutorial():
	if group_input_tutorial.visible:
		group_input_tutorial.visible = false
	else:
		group_input_tutorial.visible = true


func is_group_build_farming_visible():
	return is_enable_group_build() or is_enable_group_farming()


#endregion


#region: camera
func camera_zoom(event):
	zoom = character.camera.zoom.x
	if event.is_action_pressed("scroll_up"):
		if zoom < zoom_max():
			if zoom >= .6:
				zoom += (zoom_intensity * 2)
			else:
				zoom += zoom_intensity
			GameManager.map_vfx_manager.set_cloud_alpha(true, false)
		else:
			zoom = zoom_max() + 0.1
			GameManager.map_vfx_manager.set_cloud_alpha(true, true)

	elif event.is_action_pressed("scroll_down"):
		if zoom > zoom_intensity and zoom > zoom_min():
			if zoom >= .8:
				zoom -= (zoom_intensity * 2)
			else:
				zoom -= zoom_intensity
			GameManager.map_vfx_manager.set_cloud_alpha(false, false)
		else:
			zoom = zoom_min() - 0.1
			GameManager.map_vfx_manager.set_cloud_alpha(false, true)
	character.camera.zoom = Vector2(zoom, zoom)


func zoom_max():
	if (
		character.map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or character.map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
		or character.map_manager.map_type == Constants.MapSceneType.MINING_MAP
	):
		return .4
	else:
		return .9


func zoom_min():
	return .4


func open_map():
	if not is_open_map:
		is_open_map = true
		var map_zoom = Vector2(4.0, 4.0)
		character.camera.zoom = map_zoom
		character.map_manager.group_bg.scale = Vector2(4, 4)
		GameManager.map_vfx_manager.set_min_max_cloud_alpha(true)
		GameManager.map_vfx_manager.visible_map_shaders(false)
	else:
		is_open_map = false
		var normal_zoom = Vector2(.5, .5)
		character.camera.zoom = normal_zoom
		character.map_manager.group_bg.scale = Vector2.ONE
		GameManager.map_vfx_manager.set_min_max_cloud_alpha(false)
		GameManager.map_vfx_manager.visible_map_shaders(true)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn_map, Vector2(0.7, 0.7), Vector2(0.75, 0.75), 0.1)


#endregion


#region: character stats
func is_enable_group_stats():
	return character_stats_tab.visible and character_skills_tab.visible


#endregion


#region: inventory
func on_click_button_inventory(btn):
	if not_holding_build_object():
		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.75, 0.75), 0.1)

		# ui
		is_inventory_available()
		crafting.disable_input_amount_panel()

		# logic
		if Utils.is_in_buildable_map(character.map_manager.map_type):
			character.map_manager.check_disable_remove_item_choosing()


func is_inventory_available():
	if inventory.visible:
		hide_inventory()
		hide_crafting()
		hide_reforge_tab()
		hide_cooking_tab()
	else:
		show_inventory()


func show_inventory():
	#animate
	inventory.visible = true
	Utils.start_tween(
		tween_inventory,
		inventory,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	#logic
	inventory.initialize_inventory()
	inventory.initialize_equips()
	yield(tween_inventory, "tween_completed")
	is_ui_tweening = false


func hide_inventory():
	Utils.start_tween(
		tween_inventory,
		inventory,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	yield(tween_inventory, "tween_completed")
	inventory.visible = false
	inventory.hide_all_tooltip()
	is_ui_tweening = false


#endregion


#region: crafting
func on_click_button_crafting(btn):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.6, 0.6), Vector2(0.7, 0.7), 0.1)

	# ui
	is_crafting_available()
	crafting.disable_input_amount_panel()


func is_crafting_available():
	if crafting.visible:
		hide_crafting()
	else:
		show_crafting()
		hide_reforge_tab()
		hide_cooking_tab()


func show_crafting():
	#animates
	crafting.visible = true
	Utils.start_tween(
		tween_crafting,
		crafting,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	crafting_tutorial.visible = true
	Utils.start_tween(
		tween_crafting_tutorial,
		crafting_tutorial,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	is_ui_tweening = true
	yield(tween_crafting, "tween_completed")
	is_ui_tweening = false


func hide_crafting():
	Utils.start_tween(
		tween_crafting,
		crafting,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	Utils.start_tween(
		tween_crafting_tutorial,
		crafting_tutorial,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	is_ui_tweening = true
	yield(tween_crafting, "tween_completed")

	crafting.visible = false
	crafting_tutorial.visible = false
	is_ui_tweening = false


func show_where_holding_item_belong_to():
	if holding_item != null:
		var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
		if holding_item_category != "Resource":
			# equipments
			enable_equip_slots_guide(holding_item_category)
		else:
			# resources
			var holding_item_crafting_category = JsonData.item_data[holding_item.item_name]["CraftingCategory"]
			if holding_item_crafting_category == "Main":
				enable_crafing_slots_main_guide()
				disable_crafing_slots_sub_guide()
			elif holding_item_crafting_category == "Sub":
				enable_crafing_slots_sub_guide()
				disable_crafing_slots_main_guide()
	else:
		disable_equip_slots_guide()
		disable_crafing_slots_main_guide()
		disable_crafing_slots_sub_guide()


func enable_equip_slots_guide(item_category):
	var parent = inventory.equip_slots_guide
	var slots = inventory.equip_slots_guide.get_children()
	parent.visible = true
	var slot_name = item_category + "Slot"
	for i in range(slots.size()):
		if slots[i].name == slot_name:
			slots[i].get_node("AnimationPlayer").play("fade")
		else:
			slots[i].get_node("AnimationPlayer").play("disable")


func disable_equip_slots_guide():
	var parent = inventory.equip_slots_guide
	var slots = inventory.equip_slots_guide.get_children()
	parent.visible = false
	for i in range(slots.size()):
		slots[i].get_node("AnimationPlayer").stop()


func enable_crafing_slots_main_guide():
	var parent = crafting.crafting_slot_main_guide
	var slots = crafting.crafting_slot_main_guide.get_children()
	parent.visible = true
	for i in range(slots.size()):
		slots[i].get_node("AnimationPlayer").play("fade")


func disable_crafing_slots_main_guide():
	var parent = crafting.crafting_slot_main_guide
	var slots = crafting.crafting_slot_main_guide.get_children()
	parent.visible = false
	for i in range(slots.size()):
		slots[i].get_node("AnimationPlayer").stop()


func enable_crafing_slots_sub_guide():
	var parent = crafting.crafting_slot_sub_guide
	var slots = crafting.crafting_slot_sub_guide.get_children()
	parent.visible = true
	for i in range(slots.size()):
		slots[i].get_node("AnimationPlayer").play("fade")


func disable_crafing_slots_sub_guide():
	var parent = crafting.crafting_slot_sub_guide
	var slots = crafting.crafting_slot_sub_guide.get_children()
	parent.visible = false
	for i in range(slots.size()):
		slots[i].get_node("AnimationPlayer").stop()


#endregion


#region: building
func on_click_button_build(btn):
	if not_holding_build_object():
		reset_choosing_index()
		clear_list_available_build_buttons()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.75, 0.75), 0.1)

		# ui
		is_group_build_available()
		visible_list_categories(true)

		visible_list_houses(false)
		visible_list_farm_decors(false)
		visible_list_edges(false)
		visible_list_bridges(false)
		visible_list_stairs(false)
		visible_list_tables(false)
		visible_list_chairs(false)
		visible_list_beds(false)
		visible_list_cabinets(false)
		visible_list_table_decors(false)
		visible_list_wall_decors(false)
		visible_list_plays(false)
		visible_list_walls(false)
		visible_list_house_plants(false)
		visible_list_resources(false)
		show_choosing_index_arrow()

		show_inventory_ingredients_amount_temp()

		# logic
		if Utils.is_in_buildable_map(character.map_manager.map_type):
			character.map_manager.check_disable_remove_item_choosing()


func on_click_button_close_build(btn):
	if not_holding_build_object():
		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.8, 0.8), 0.1)

		# ui
		is_group_build_available()
		visible_list_categories(false)

		# reset choosing arrow index
		reset_choosing_index()
		clear_list_available_build_buttons()
		show_choosing_index_arrow()


func on_click_button_back_build():
	if not list_categories.visible:
		reset_choosing_index()
		clear_list_available_build_buttons()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

		# ui
		is_list_categories_available()
		visible_list_houses(false)
		visible_list_farm_decors(false)
		visible_list_edges(false)
		visible_list_bridges(false)
		visible_list_stairs(false)
		visible_list_tables(false)
		visible_list_chairs(false)
		visible_list_beds(false)
		visible_list_cabinets(false)
		visible_list_table_decors(false)
		visible_list_wall_decors(false)
		visible_list_plays(false)
		visible_list_walls(false)
		visible_list_house_plants(false)
		visible_list_resources(false)
		show_choosing_index_arrow()


func on_click_button_category(_index):
	if not_holding_build_object():
		clear_list_available_build_buttons()
		reset_choosing_index()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

		# ui
		is_list_categories_available()
		if character.map_manager.map_type == Constants.MapSceneType.FARM_MAP:
			match _index:
				0:
					is_list_houses_available()
				1:
					is_list_farm_decors_available()
				2:
					is_list_edges_available()
				3:
					is_list_bridges_available()
				4:
					is_list_tables_available()
				5:
					is_list_chairs_available()
				6:
					is_list_walls_available()
				7:
					is_list_resources_available()

		elif (
			character.map_manager.map_type == Constants.MapSceneType.BASE_MAP
			or character.map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
		):
			match _index:
				0:
					is_list_tables_available()
				1:
					is_list_chairs_available()
				2:
					is_list_beds_available()
				3:
					is_list_cabinets_available()
				4:
					is_list_table_decors_available()
				5:
					is_list_wall_decors_available()
				6:
					is_list_plays_available()
				7:
					is_list_walls_available()
				8:
					is_list_house_plants_available()

		show_choosing_index_arrow()


func is_group_build_available():
	if group_build.visible:
		visible_group_build(false)
		is_outside_menu = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		visible_group_build(true)
		is_outside_menu = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func is_enable_group_build():
	return group_build.visible


func is_list_categories_available():
	if list_categories.visible:
		visible_list_categories(false)
		is_outside_menu = false
	else:
		visible_list_categories(true)
		is_outside_menu = true


func is_list_houses_available():
	if list_houses.visible:
		visible_list_houses(false)
	else:
		visible_list_houses(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_houses)
		for i in list_houses.get_children():
			add_list_available_build_buttons(i)


func is_list_farm_decors_available():
	if list_farm_decors.visible:
		visible_list_farm_decors(false)
	else:
		visible_list_farm_decors(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_farm_decors)
		for i in list_farm_decors.get_children():
			add_list_available_build_buttons(i)


func is_list_edges_available():
	if list_edges.visible:
		visible_list_edges(false)
	else:
		visible_list_edges(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_edges)
		for i in list_edges.get_children():
			add_list_available_build_buttons(i)


func is_list_bridges_available():
	if list_bridges.visible:
		visible_list_bridges(false)
	else:
		visible_list_bridges(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_bridges)
		for i in list_bridges.get_children():
			add_list_available_build_buttons(i)


func is_list_stairs_available():
	if list_stairs.visible:
		visible_list_stairs(false)
	else:
		visible_list_stairs(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_stairs)
		for i in list_stairs.get_children():
			add_list_available_build_buttons(i)


func is_list_tables_available():
	if list_tables.visible:
		visible_list_tables(false)
	else:
		visible_list_tables(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_tables)
		for i in list_tables.get_children():
			add_list_available_build_buttons(i)


func is_list_chairs_available():
	if list_chairs.visible:
		visible_list_chairs(false)
	else:
		visible_list_chairs(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_chairs)
		for i in list_chairs.get_children():
			add_list_available_build_buttons(i)


func is_list_beds_available():
	if list_beds.visible:
		visible_list_beds(false)
	else:
		visible_list_beds(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_beds)
		for i in list_beds.get_children():
			add_list_available_build_buttons(i)


func is_list_cabinets_available():
	if list_cabinets.visible:
		visible_list_cabinets(false)
	else:
		visible_list_cabinets(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_cabinets)
		for i in list_cabinets.get_children():
			add_list_available_build_buttons(i)


func is_list_table_decors_available():
	if list_table_decors.visible:
		visible_list_table_decors(false)
	else:
		visible_list_table_decors(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_table_decors)
		for i in list_table_decors.get_children():
			add_list_available_build_buttons(i)


func is_list_wall_decors_available():
	if list_wall_decors.visible:
		visible_list_wall_decors(false)
	else:
		visible_list_wall_decors(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_wall_decors)
		for i in list_wall_decors.get_children():
			add_list_available_build_buttons(i)


func is_list_plays_available():
	if list_plays.visible:
		visible_list_plays(false)
	else:
		visible_list_plays(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_plays)
		for i in list_plays.get_children():
			add_list_available_build_buttons(i)


func is_list_walls_available():
	if list_walls.visible:
		visible_list_walls(false)
	else:
		visible_list_walls(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_walls)
		for i in list_walls.get_children():
			add_list_available_build_buttons(i)


func is_list_house_plants_available():
	if list_house_plants.visible:
		visible_list_house_plants(false)
	else:
		visible_list_house_plants(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_house_plants)
		for i in list_house_plants.get_children():
			add_list_available_build_buttons(i)


func is_list_resources_available():
	if list_resources.visible:
		visible_list_resources(false)
	else:
		visible_list_resources(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_resources)
		for i in list_resources.get_children():
			add_list_available_build_buttons(i)


func visible_list_categories(_visible):
	list_categories.visible = _visible

	if character.map_manager.map_type == Constants.MapSceneType.FARM_MAP:
		btn_category_house.visible = true
		btn_category_farm_decor.visible = true
		btn_category_edge.visible = true
		btn_category_bridge.visible = true
		btn_category_stairs.visible = false
		btn_category_bed.visible = false
		btn_category_cabinet.visible = false
		btn_category_wall_decor.visible = false
		btn_category_play.visible = false
		btn_category_wall.visible = true
		btn_category_house_plant.visible = false
		btn_category_table.visible = true
		btn_category_chair.visible = true
		btn_category_table_decor.visible = false
		btn_category_resources.visible = true

	elif (
		character.map_manager.map_type == Constants.MapSceneType.BASE_MAP
		or character.map_manager.map_type == Constants.MapSceneType.BASE_UPGRADE_MAP
	):
		btn_category_house.visible = false
		btn_category_farm_decor.visible = false
		btn_category_edge.visible = false
		btn_category_bridge.visible = false
		btn_category_stairs.visible = false
		btn_category_bed.visible = true
		btn_category_cabinet.visible = true
		btn_category_wall_decor.visible = true
		btn_category_play.visible = true
		btn_category_wall.visible = true
		btn_category_house_plant.visible = true
		btn_category_table.visible = true
		btn_category_chair.visible = true
		btn_category_table_decor.visible = true
		btn_category_resources.visible = false

	for i in list_categories.get_children():
		if _visible and i.visible:
			add_list_available_build_buttons(i)


func visible_list_houses(visible):
	list_houses.visible = visible


func visible_list_farm_decors(visible):
	list_farm_decors.visible = visible


func visible_list_edges(visible):
	list_edges.visible = visible


func visible_list_bridges(visible):
	list_bridges.visible = visible


func visible_list_stairs(visible):
	list_stairs.visible = visible


func visible_list_tables(visible):
	list_tables.visible = visible


func visible_list_chairs(visible):
	list_chairs.visible = visible


func visible_list_beds(visible):
	list_beds.visible = visible


func visible_list_cabinets(visible):
	list_cabinets.visible = visible


func visible_list_table_decors(visible):
	list_table_decors.visible = visible


func visible_list_wall_decors(visible):
	list_wall_decors.visible = visible


func visible_list_plays(visible):
	list_plays.visible = visible


func visible_list_walls(visible):
	list_walls.visible = visible


func visible_list_house_plants(visible):
	list_house_plants.visible = visible


func visible_list_resources(visible):
	list_resources.visible = visible


func visible_group_build(visible):
	if visible:
		group_build.visible = visible
		Utils.start_tween(
			group_build_tween,
			group_build,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		is_ui_tweening = true
		yield(group_build_tween, "tween_completed")
		is_ui_tweening = false
	else:
		Utils.start_tween(
			group_build_tween,
			group_build,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		is_ui_tweening = true
		yield(group_build_tween, "tween_completed")
		group_build.visible = visible
		is_ui_tweening = false


func show_inventory_ingredients_amount_temp():
	var wood_amount = 0
	var stone_amount = 0
	for i in PlayerInventory.inventory:
		if PlayerInventory.inventory[i][0] == "wood":
			wood_amount += PlayerInventory.inventory[i][1]
		if PlayerInventory.inventory[i][0] == "stone":
			stone_amount += PlayerInventory.inventory[i][1]
	set_inventory_ingredients_amount_temp_text(wood_amount, stone_amount)


func set_inventory_ingredients_amount_temp_text(wood_amount, stone_amount):
	group_build_ingredients.get_child(0).text = str(wood_amount)
	group_farm_ingredients.get_child(0).text = str(wood_amount)
	group_build_ingredients.get_child(2).text = str(stone_amount)
	group_farm_ingredients.get_child(2).text = str(stone_amount)


func show_building_object(building_type: int, object_type: int, is_append: bool, btn_scale):
	if not_holding_build_object():
		# logic
		# checking conditions
		GameManager.build_manager.build_condition.set_object_name(building_type, object_type)
		GameManager.build_manager.build_condition.clear_temp_data()
		if GameManager.build_manager.build_condition.is_reachable_build_conditions():
			GameManager.build_manager.show_object(
				building_type, object_type, is_append, false, Vector2.ZERO
			)

			# sfx
			GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
			Utils.button_click_scale(btn_scale, Vector2(0.9, 0.9), Vector2.ONE, 0.1)

			# ui
			if group_build.visible:
				visible_group_build(false)
			if group_farming.visible:
				visible_group_farming(false)
			show_group_building_custom()


func not_holding_build_object():
	return not GameManager.build_manager.holding_object


func show_group_building_custom():
	if not group_build_custom.visible:
		group_build_custom.visible = true
		Utils.start_tween(
			group_build_custom_tween,
			group_build_custom,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			0.15,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)


func hide_group_building_custom():
	if group_build_custom.visible:
		Utils.start_tween(
			group_build_custom_tween,
			group_build_custom,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			0.15,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		yield(group_build_custom_tween, "tween_completed")
		group_build_custom.visible = false


func show_group_remove_custom():
	if not group_remove_custom.visible:
		group_remove_custom.visible = true
		Utils.start_tween(
			group_remove_custom_tween,
			group_remove_custom,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			0.15,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)


func hide_group_remove_custom():
	if group_remove_custom.visible:
		Utils.start_tween(
			group_remove_custom_tween,
			group_remove_custom,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			0.15,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		yield(group_remove_custom_tween, "tween_completed")
		group_remove_custom.visible = false


func build_canel_including_ui():
	if GameManager.build_manager.holding_object:
		# logic
		GameManager.build_manager.build_cancel()
		# ui
		hide_group_building_custom()


func on_click_button_remove_general(_remove_object):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

	# logic
	var item = character.map_manager.item
	var item_scene_name = character.map_manager.item_scene_name
	var item_index = character.map_manager.item_index
	var map_info = Utils.get_current_map_info(character.map_manager)

	# add remove barn => split to another function
	if item.is_resource() and item.resource_type == Constants.ResourceType.LIVESTOCK_BARN:
		item.resource.remove_barn()
	elif item.is_resource() and item.resource_type == Constants.ResourceType.EMPTY_PLOT:
		item.resource.remove_empty_plot()

	map_info.remove_decoration(item, item_scene_name, item_index)

	# return ingredients
	if _remove_object.sprite_name != null:
		GameManager.build_manager.build_condition.return_ingredients_to_player_inventory(
			_remove_object.sprite_name
		)

	character.map_manager.item = null
	character.map_manager.item_temp = null
	character.map_manager.item_scene_name = null
	character.map_manager.item_scene_name_temp = null
	character.map_manager.item_index = null


func show_choosing_index_arrow():
	if list_available_build_buttons.size() > 0:
		for i in list_available_build_buttons.size():
			var btn = list_available_build_buttons[i]
			var choosing_arrow = btn.get_node_or_null("ChoosingArrow")
			var tween = btn.get_node_or_null("Tween")
			if choosing_arrow != null:
				choosing_arrow.self_modulate = Color.green
				choosing_arrow.rect_scale = Vector2(1.1, 1.1)
				if i == choosing_index:
					choosing_arrow.visible = true
				else:
					choosing_arrow.visible = false
			if btn != null:
				if i == choosing_index:
					Utils.start_tween(
						tween,
						btn,
						"rect_scale",
						Vector2.ONE,
						Vector2(1.05, 1.05),
						0.1,
						Tween.TRANS_LINEAR,
						Tween.TRANS_LINEAR
					)
					Utils.start_tween(
						tween,
						btn,
						"modulate",
						Color(0.6, 0.6, 0.6, 1),
						Color.white,
						0.1,
						Tween.TRANS_LINEAR,
						Tween.TRANS_LINEAR
					)
				else:
					Utils.start_tween(
						tween,
						btn,
						"rect_scale",
						btn.rect_scale,
						Vector2.ONE,
						0.05,
						Tween.TRANS_LINEAR,
						Tween.TRANS_LINEAR
					)
					Utils.start_tween(
						tween,
						btn,
						"modulate",
						btn.modulate,
						Color(0.6, 0.6, 0.6, 1),
						0.05,
						Tween.TRANS_LINEAR,
						Tween.TRANS_LINEAR
					)


func cal_choosing_index(next_amount: int):
	var temp = choosing_index
	temp += next_amount

	# testing calculate
	var temp_next_amount = next_amount
	var is_left_or_right: bool = false

	if temp_next_amount == 1 or temp_next_amount == -1:
		is_left_or_right = true
	if temp >= 0 and temp < list_available_build_buttons.size():
		choosing_index = temp

	# testing calculate temp is left or right if index is out of range
	else:
		if temp < 0:
			if is_left_or_right:
				choosing_index = list_available_build_buttons.size() - 1
		elif temp >= list_available_build_buttons.size():
			if is_left_or_right:
				choosing_index = 0

	show_choosing_index_arrow()


func build_buttons_choosing():
	if is_group_build_farming_visible() and not_holding_build_object():
		if Input.is_action_just_pressed("ui_up"):
			cal_choosing_index(-4)
		elif Input.is_action_just_pressed("ui_down"):
			cal_choosing_index(4)
		elif Input.is_action_just_pressed("ui_left"):
			cal_choosing_index(-1)
		elif Input.is_action_just_pressed("ui_right"):
			cal_choosing_index(1)


func build_button_choose():
	if (
		Input.is_action_just_pressed("build_object")
		and is_group_build_farming_visible()
		and not_holding_build_object()
	):
		if is_outside_menu:
			if group_build.visible:
				on_click_button_category(choosing_index)
			else:
				on_click_button_category_farming(choosing_index)
		else:
			var building_type = list_available_build_buttons[choosing_index].building_type
			var object_type = list_available_build_buttons[choosing_index].object_type
			var is_append = list_available_build_buttons[choosing_index].is_append
			show_building_object(
				building_type, object_type, is_append, list_available_build_buttons[choosing_index]
			)


func add_list_available_build_buttons(build_button):
	list_available_build_buttons.append(build_button)


func clear_list_available_build_buttons():
	list_available_build_buttons.clear()


func reset_choosing_index():
	choosing_index = 0


#endregion


#region: farming
func on_click_button_farming(btn):
	if not_holding_build_object():
		reset_choosing_index()
		clear_list_available_build_buttons()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.75, 0.75), 0.1)

		# ui
		is_group_farming_available()
		visible_list_categories_farming(true)

		visible_list_plantings(false)
		visible_list_husbandaries(false)
		show_choosing_index_arrow()

		show_inventory_ingredients_amount_temp()

		# logic
		if Utils.is_in_buildable_map(character.map_manager.map_type):
			character.map_manager.check_disable_remove_item_choosing()


func on_click_button_close_farming(btn):
	if not_holding_build_object():
		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
		Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.8, 0.8), 0.1)

		# ui
		is_group_farming_available()
		visible_list_categories_farming(false)

		# reset choosing index arrow
		reset_choosing_index()
		clear_list_available_build_buttons()
		show_choosing_index_arrow()


func on_click_button_back_farming():
	if not list_categories_farming.visible:
		reset_choosing_index()
		clear_list_available_build_buttons()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

		# ui
		is_list_categories_farming_available()
		visible_list_plantings(false)
		visible_list_husbandaries(false)
		show_choosing_index_arrow()


func on_click_button_category_farming(_index):
	if not_holding_build_object():
		clear_list_available_build_buttons()
		reset_choosing_index()

		# sfx
		GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

		# ui
		is_list_categories_farming_available()
		match _index:
			0:
				is_list_plantings_available()
			1:
				is_list_husbandaries_available()

		show_choosing_index_arrow()


func is_group_farming_available():
	if group_farming.visible:
		visible_group_farming(false)
		is_outside_menu = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		visible_group_farming(true)
		is_outside_menu = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func is_enable_group_farming():
	return group_farming.visible


func is_list_categories_farming_available():
	if list_categories_farming.visible:
		visible_list_categories_farming(false)
		is_outside_menu = false
	else:
		visible_list_categories_farming(true)
		is_outside_menu = true


func is_list_plantings_available():
	if list_plantings.visible:
		visible_list_plantings(false)
	else:
		visible_list_plantings(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_plantings)
		for i in list_plantings.get_children():
			add_list_available_build_buttons(i)


func is_list_husbandaries_available():
	if list_husbandaries.visible:
		visible_list_husbandaries(false)
	else:
		visible_list_husbandaries(true)
		GameManager.build_manager.build_condition.check_list_buildings_condition(list_husbandaries)
		for i in list_husbandaries.get_children():
			add_list_available_build_buttons(i)


func visible_list_categories_farming(_visible):
	list_categories_farming.visible = _visible
	match character.map_manager.map_type:
		Constants.MapSceneType.FARM_MAP:
			btn_category_planting.visible = true
			btn_category_husbandary.visible = true

	for i in list_categories_farming.get_children():
		if _visible and i.visible:
			add_list_available_build_buttons(i)


func visible_list_plantings(visible):
	list_plantings.visible = visible


func visible_list_husbandaries(visible):
	list_husbandaries.visible = visible


func visible_group_farming(visible):
	if visible:
		group_farming.visible = visible
		Utils.start_tween(
			group_farming_tween,
			group_farming,
			"modulate",
			Color(1, 1, 1, 0),
			Color(1, 1, 1, 1),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		is_ui_tweening = true
		yield(group_farming_tween, "tween_completed")
		is_ui_tweening = false
	else:
		Utils.start_tween(
			group_farming_tween,
			group_farming,
			"modulate",
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			0.2,
			Tween.TRANS_LINEAR,
			Tween.TRANS_LINEAR
		)
		is_ui_tweening = true
		yield(group_farming_tween, "tween_completed")
		group_farming.visible = visible
		is_ui_tweening = false


#endregion


#region: reforge
func _on_reforge_button_clicked(btn):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.6, 0.6), Vector2(0.7, 0.7), 0.1)

	# logic
	is_reforge_available()


func is_reforge_available():
	if reforge_tab.visible:
		hide_reforge_tab()
	else:
		show_reforge_tab()
		hide_crafting()
		hide_cooking_tab()


func show_reforge_tab():
	reforge_tab.visible = true
	Utils.start_tween(
		reforge_tab_tween,
		reforge_tab,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	yield(reforge_tab_tween, "tween_completed")
	is_ui_tweening = false


func hide_reforge_tab():
	Utils.start_tween(
		reforge_tab_tween,
		reforge_tab,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	yield(reforge_tab_tween, "tween_completed")
	reforge_tab.visible = false
	is_ui_tweening = false


func on_click_button_close_reforge_tab(btn):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.8, 0.8), Vector2(0.85, 0.85), 0.1)

	# ui
	_on_reforge_button_clicked(btn)


#endregion


#region: cooking
func _on_cooking_button_clicked(btn):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.6, 0.6), Vector2(0.7, 0.7), 0.1)

	# logic
	is_cooking_available()


func is_cooking_available():
	if cooking_tab.visible:
		hide_cooking_tab()
	else:
		show_cooking_tab()
		hide_crafting()
		hide_reforge_tab()


func show_cooking_tab():
	cooking_tab.visible = true
	Utils.start_tween(
		cooking_tab_tween,
		cooking_tab,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	yield(cooking_tab_tween, "tween_completed")
	is_ui_tweening = false


func hide_cooking_tab():
	Utils.start_tween(
		cooking_tab_tween,
		cooking_tab,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		0.2,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)
	is_ui_tweening = true
	yield(cooking_tab_tween, "tween_completed")
	cooking_tab.visible = false
	is_ui_tweening = false


func on_click_button_close_cooking_tab(btn):
	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.8, 0.8), Vector2(0.85, 0.85), 0.1)

	# ui
	_on_cooking_button_clicked(btn)


#endregion


#region: change scene
func on_click_button_home():
	# logic
	GameManager.save_load_manager.save_spawn_data()
	GameManager.save_load_manager.save_daytime_data()
	GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
	GameManager.scene_manager.change_scene(
		GameManager.scene_manager.base_path, GameManager.scene_manager.base_title
	)
	GameManager.scene_manager.spawn_blocking_input(character.map_manager)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

	# ui
	visible_button_home(false)


func on_click_button_home_upgrade():
	# logic
	GameManager.save_load_manager.save_spawn_data()
	GameManager.save_load_manager.save_daytime_data()
	GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
	GameManager.scene_manager.change_scene(
		GameManager.scene_manager.base_upgrade_path, GameManager.scene_manager.base_upgrade_title
	)
	GameManager.scene_manager.spawn_blocking_input(character.map_manager)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

	# ui
	visible_button_home(false)


func on_click_button_mining_cave():
	# logic
	GameManager.save_load_manager.save_spawn_data()
	GameManager.save_load_manager.save_daytime_data()
	GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
	GameManager.scene_manager.change_scene(
		GameManager.scene_manager.mining_cave_path, GameManager.scene_manager.mining_cave_title
	)
	GameManager.scene_manager.spawn_blocking_input(character.map_manager)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)

	# ui
	visible_button_mining_cave(false)


func on_click_button_farm(btn):
	# logic
	GameManager.save_load_manager.save_current_timing(GameManager.daytime_manager.time)
	GameManager.scene_manager.is_open_scene = false
	GameManager.scene_manager.spawn_blocking_input(character.map_manager)
	GameManager.scene_manager.init_loading_scene()

	var delay = 0.15
	yield(Utils.start_coroutine(delay), "completed")
	GameManager.scene_manager.change_scene(
		GameManager.scene_manager.farm_path, GameManager.scene_manager.farm_title
	)

	# sfx
	GameManager.audio_manager.play_ui_sound(GameManager.audio_manager.click)
	Utils.button_click_scale(btn, Vector2(0.7, 0.7), Vector2(0.75, 0.75), 0.1)

	# ui
	visible_button_farm(false)


func visible_button_home(visible):
	btn_home.visible = visible


func visible_button_home_upgrade(visible):
	btn_home_upgrade.visible = visible


func visible_button_farm(visible):
	btn_farm.visible = visible


func visible_button_mining_cave(visible):
	btn_mining_cave.visible = visible


func visible_group_stairs(visible):
	group_stairs.visible = visible


#endregion


#region: visible hud
func visible_hud(visible: bool):
	var color = Color.white
	var duration = 0.4
	if visible:
		color = Color(1, 1, 1, 1)
	else:
		color = Color(1, 1, 1, 0)
	Utils.start_tween(
		group_hud_tween,
		group_hud,
		"modulate",
		group_hud.modulate,
		color,
		duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

	Utils.start_tween(
		group_hud_tween,
		skill_bar,
		"modulate",
		skill_bar.modulate,
		color,
		duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR
	)

#endregion
