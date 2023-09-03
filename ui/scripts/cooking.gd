extends Node
class_name CookingController

const COOKING_TIME_MULT_EXP: float = 0.25
const HALF_COOKED_TIME: float = 0.75
const FINE_COOKED_TIME: float = 1.0
const OVER_COOKED_TIME: float = 1.25

const OVERTIME_FOOD_DEFAULT: String = "burnt_food"

const QualityProgressColor: Dictionary = {
	"raw": Constants.NORMAL_COLOR,
	"hc": Constants.LIGHT_YELLOW_PROGRESS_COLOR,
	"fc": Constants.ORANGE_PROGRESS_COLOR,
	"oc": Constants.BROWN_PROGRESS_COLOR,
	"ot": Constants.DARK_BROWN_PROGRESS_COLOR
}

const QualityFullText: Dictionary = {
	"raw": "Raw",
	"hc": "Half Done",
	"fc": "Done",
	"oc": "Too Long",
	"ot": "Overdone"
}

var cooking_tab

#current cooking food
var cooking_recipe: Dictionary = {}
var dish_amount: int = 0
var energy_over_time: float = 0 #per second
var cooking_max_time: float = 0
var cooking_ingredients: Dictionary = {}


func _init(_cooking_tab) -> void:
	cooking_tab = _cooking_tab


func get_recipe(_ingredients: Dictionary, _total_energy: int) -> Dictionary:
	if not has_ingredient(_ingredients):
		return {}
		
	var matched_recipe_list: Array = get_matched_recipe(_ingredients)
	if matched_recipe_list.empty():
		return GameResourcesLibrary.cooking_recipe.blob if GameResourcesLibrary.cooking_recipe.has("blob") else {}
		
	var matched_recipe: Dictionary = Utils.random_from_array(matched_recipe_list)
	return matched_recipe


func cook(_ingredient_slots: Array, _energy_slots: Array) -> Dictionary:
	var ingredients: Dictionary = create_ingredients_dict(_ingredient_slots)
	var total_energy: int = cal_total_energy(_energy_slots)

	var _recipe: Dictionary = get_recipe(ingredients, total_energy) 
	if _recipe.empty():
		return {}

	var prepare_result: Dictionary = cooking_prepare(ingredients, total_energy, _recipe)
	if prepare_result.empty():
		return {}
	
	var cooked_ingredients: Dictionary = prepare_result.cooked_ingredients
	cooking_recipe = _recipe
	begin_cooking(cooked_ingredients, prepare_result.cooking_time, prepare_result.energy_over_time, prepare_result.num_of_dishes, prepare_result.cooking_time)

	var not_cooked_ingredients: Dictionary = get_not_cooked_ingredients(ingredients, cooked_ingredients)
	var keep_energy: bool = cooking_recipe.energy == 0
	return {
		"not_cooked_ingredients": not_cooked_ingredients,
		"keep_energy": keep_energy
	}


func begin_cooking(_ingredients: Dictionary, _max_time: int, _e_over_time: float, _dish_amount: int, _time_left: float) -> void:
	cooking_ingredients = _ingredients
	cooking_max_time = _max_time
	energy_over_time = _e_over_time
	dish_amount = _dish_amount
	active_cooking_timer(_time_left)


func get_recipe_by_name(_recipe_name: String) -> Dictionary:
	return GameResourcesLibrary.cooking_recipe[_recipe_name]


func load_cooking_save_data(_save_data: Dictionary) -> void:
	if _save_data.cooking_recipe == "":
		return
	cooking_recipe = get_recipe_by_name(_save_data.cooking_recipe)
	begin_cooking(_save_data.cooking_ingredients, _save_data.cooking_max_time, _save_data.energy_over_time, _save_data.dish_amount, _save_data.cooking_time_left)
	cooking_tab.switch_state_to_cooking(true)


func get_not_cooked_ingredients(_ingredients: Dictionary, _cooked_ingredients: Dictionary) -> Dictionary:
	var not_cooked_ingredients: Dictionary = {}
	for _ingredient in _ingredients:
		if not _cooked_ingredients.has(_ingredient):
			_cooked_ingredients[_ingredient] = 0
		
		not_cooked_ingredients[_ingredient] = _ingredients[_ingredient] - _cooked_ingredients[_ingredient]
		if not_cooked_ingredients[_ingredient] <= 0:
			not_cooked_ingredients.erase(_ingredient)
	
	return not_cooked_ingredients


func cooking_prepare(_ingredients: Dictionary, _total_energy: int, _recipe: Dictionary) -> Dictionary:
	var ingredients_check_result: Dictionary = cal_cooked_ingredients(_ingredients, _recipe)
	var cooked_ingredients: Dictionary = ingredients_check_result.cooked_ingredients
	var num_of_dishes: int = ingredients_check_result.num_of_dishes
	var cooking_time_mult: float = cal_cooking_time_multiplier(num_of_dishes)
	
	if num_of_dishes == 0 or not enough_energy(_recipe, _total_energy, cooking_time_mult):
		return {}
	
	var energy_over_time: float = _recipe.energy / (_recipe.time * 3600)
	var cooking_time: float = _total_energy / energy_over_time if energy_over_time > 0 else (_recipe.time * 3600 * _recipe.over_time * cooking_time_mult + 10)
	
	return {
		"cooked_ingredients": cooked_ingredients,
		"num_of_dishes": num_of_dishes,
		"cooking_time": cooking_time,
		"energy_over_time": energy_over_time
	}


func cal_cooked_ingredients(_ingredients: Dictionary, _recipe: Dictionary) -> Dictionary:
	var cooked_ingredients: Dictionary = {}
	var num_of_dishes: int = Constants.A_VERY_LARGE_NUMBER
	
	if _recipe.name == "blob":
		cooked_ingredients = _ingredients.duplicate(true)
		num_of_dishes = 1
	else:
		for _ingredient in _ingredients:
			var ingre: int = _ingredients[_ingredient]
			var recipe_ingre: int = int(_recipe.ingredients[_ingredient])
			num_of_dishes = Utils.clamp_int(ingre / recipe_ingre, 0, num_of_dishes)
		
		for _ingredient in _ingredients:
			var recipe_ingre: int = _recipe.ingredients[_ingredient]
			cooked_ingredients[_ingredient] = recipe_ingre * num_of_dishes

	return {
		"cooked_ingredients": cooked_ingredients,
		"num_of_dishes": num_of_dishes
	}


func get_matched_recipe(_ingredients: Dictionary) -> Array:
	var _recipes: Dictionary = GameResourcesLibrary.cooking_recipe
	var _matched_recipe: Array = []
	
	for _recipe in _recipes.values():
		if _ingredients.size() != _recipe.ingredients.item_need:
			continue
			
		if ingredients_match_recipe(_ingredients, _recipe.ingredients):
			_matched_recipe.append(_recipe)
			
	return _matched_recipe


func create_ingredients_dict(_ingredient_slots: Array) -> Dictionary:
	var _ingredients: Dictionary = {}
	for _ingredient in _ingredient_slots:
		if _ingredient.item == null:
			continue
		if not _ingredients.has(_ingredient.item.item_name):
			_ingredients[_ingredient.item.item_name] = 0
		_ingredients[_ingredient.item.item_name] += _ingredient.item.item_amount
	
	return _ingredients


func ingredients_match_recipe(_ingredients: Dictionary, _r_ingredients: Dictionary) -> bool:
	return _r_ingredients.has_all(_ingredients.keys())


func enough_energy(_recipe: Dictionary, _in_slots_energy: int, _multiplier: float = 1.0) -> bool:
	return _in_slots_energy >= (get_min_energy_need(_recipe) * _multiplier)


#create a special func for blob recipe that calculate needed energy by
#used ingredients, random from 35-70 energy / ingredient
func enough_blob_energy(_recipe: Dictionary, _in_slots_energy: int, _ingredient_slots: Array) -> bool:
	return _in_slots_energy >= get_blob_energy_need(_ingredient_slots)


func get_blob_energy_need(_ingredient_slots: Array) -> int:
	return 0


func cal_total_energy(_energy_slots: Array) -> int:
	var total_energy: int = 0
	for e_slot in _energy_slots:
		if e_slot.item == null:
			continue
		total_energy += e_slot.item.cooking_energy * e_slot.item.item_amount
	
	return total_energy


func get_min_energy_need(_recipe: Dictionary) -> int:
	return int(_recipe.energy * (HALF_COOKED_TIME + 0.05))


func cal_cooking_time_multiplier(_num_of_dishes: int) -> float:
	if _num_of_dishes < 1:
		return 0.0
	
	return 1.0 + (_num_of_dishes - 1)*COOKING_TIME_MULT_EXP


func has_ingredient(_ingredients: Dictionary) -> bool:
	var _has_ingredient: bool = not _ingredients.empty()

	return _has_ingredient


func release_food() -> Dictionary:
	var cooking_quality: String = get_cooking_quality()
	if cooking_quality == "raw":
		return {
			"cooked": false,
			"unused_energy": get_unused_energy()
		}

	return {
		"cooked": true,
		"food_name": get_release_food_name(cooking_quality),
		"dish_amount": dish_amount,
		"unused_energy": get_unused_energy()
	}


func get_release_food_name(_cooking_quality: String) -> String:
	if _cooking_quality == "ot":
		for _food_name in cooking_recipe.result.ot:
			if randf() <= cooking_recipe.result.ot[_food_name].chance:
				return _food_name
		
		return OVERTIME_FOOD_DEFAULT
	else:
		return cooking_recipe.result[_cooking_quality]


func get_unused_energy() -> int:
	return int(cooking_tab.get_cooking_timer_timeleft() * energy_over_time)


func get_cooking_quality() -> String:
	var time_percent: float = get_cooked_quality_time_percent()
	return time_percent_to_cooking_quality(time_percent)


func time_percent_to_cooking_quality(_time_percent: float) -> String:
	if _time_percent >= cooking_recipe.over_time:
		return "ot"
	elif _time_percent >= OVER_COOKED_TIME:
		return "oc"
	elif _time_percent >= FINE_COOKED_TIME:
		return "fc"
	elif _time_percent >= HALF_COOKED_TIME:
		return "hc"

	return "raw"


func get_cooked_time_percent() -> float:
	var cooked_time: float = cooking_max_time - cooking_tab.get_cooking_timer_timeleft()
	return cooked_time / cooking_max_time


func get_cooked_quality_time_percent() -> float:
	var cooked_time: float = cooking_max_time - cooking_tab.get_cooking_timer_timeleft()
	return cooked_time / ((cooking_recipe.time * 3600) * cal_cooking_time_multiplier(dish_amount))


func get_cooked_time_stats() -> Dictionary:
	var cooked_time: float = cooking_max_time - cooking_tab.get_cooking_timer_timeleft()
	return {
		"cooked_time_percent": cooked_time / cooking_max_time,
		"quality_percent": cooked_time / ((cooking_recipe.time * 3600) * cal_cooking_time_multiplier(dish_amount))
	}


func return_cooking_ingredients() -> void:
	# print(cooking_ingredients)
	for _ingredient in cooking_ingredients:
		if _ingredient == "item_need":
			continue
		
		PlayerInventory.add_item(_ingredient, cooking_ingredients[_ingredient])
	
	cooking_ingredients.clear()
	
	
func clean_kitchen() -> void:
	cooking_recipe = {}
	dish_amount = 0
	energy_over_time = 0 #per second
	cooking_max_time = 0
	cooking_ingredients.clear()
	deactive_cooking_timer()


func active_cooking_timer(_time: float) -> void:
	Utils.activate_timer(cooking_tab.cooking_timer, _time)


func deactive_cooking_timer() -> void:
	Utils.deactivate_timer(cooking_tab.cooking_timer)


func get_quality_full_text(_quality: String) -> String:
	if QualityFullText.has(_quality):
		return QualityFullText[_quality]
	else:
		return ''
