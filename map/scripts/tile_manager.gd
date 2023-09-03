class_name TileManager

var name: String
var description: Dictionary
var parent_intersection_description: Dictionary
var tile_map: TileMap
var parent: TileManager = null
var level: Vector2
var orientation_bitmap = {
	"engle-t": {"yes": [3, 6, 7], "no": [1, 5]},
	"engle-r": {"yes": [0, 1, 3], "no": [5, 7]},
	"engle-l": {"yes": [5, 7, 8], "no": [1, 3]},
	"engle-d": {"yes": [1, 2, 5], "no": [3, 7]},
	"edge-ld": {"yes": [1, 5, 7], "no": [3]},
	"edge-rd": {"yes": [1, 3, 5], "no": [7]},
	"edge-lt": {"yes": [3, 5, 7], "no": [1]},
	"edge-rt": {"yes": [1, 3, 7], "no": [5]},
	"inter-l": {"yes": [1, 3, 5, 7], "no": [0]},
	"inter-d": {"yes": [1, 3, 5, 7], "no": [6]},
	"inter-r": {"yes": [1, 3, 5, 7], "no": [7]},
	"inter-t": {"yes": [1, 3, 5, 7], "no": [2]},
	"fill": {"yes": [0, 1, 2, 3, 5, 6, 7, 8], "no": []}
}
var orientations = orientation_bitmap.keys()

func _init(
	_tile_map: TileMap,
	_description: Dictionary,
	_parent: TileManager = null,
	_level: Vector2 = Vector2(0, 1),
	_parent_intersection_description: Dictionary = {}
):
	tile_map = _tile_map
	name = tile_map.name  # this is mainly used for debugging
	description = _description
	parent = _parent
	parent_intersection_description = _parent_intersection_description
	level = _level


func prefill(noise_value: float, point: Vector2) -> bool:
	# if it has a parent, only fill if the tile is on top of parent
	if parent != null and not parent.tile_exists(point):
		return false

	var cell_index = get_tile_index("fill")
	if cell_index != null and Utils.value_between(noise_value, level):
		set_cell(point, cell_index)
		return true

	return false


func clean_up_prefill(point: Vector2):
	# this ensure no tile is placed on the parent's edges or engles
	if parent != null and parent.is_engle_or_edge(point):
		set_cell(point, -1)


func update_bitmap(point: Vector2):
	if tile_exists(point):
		for orientation in orientations:
			if bitmap_to_condition(point, orientation):
				return fill(point, orientation)


func fill(point: Vector2, orientation):
	var intersected_parent = intersects_parent(orientation, point)

	# special handling for tile that intersects parent in only 1 half
	if (
		parent
		and not parent_intersection_description.empty()
		and not intersected_parent
		and orientation == "engle-d"
	):
		if parent.tile_exists(point, Constants.DisplacementMap[3]):
			return set_cell(point, parent_intersection_description["half-intersection"])
		if parent.tile_exists(point, Constants.DisplacementMap[7]):
			return set_cell(point, parent_intersection_description["half-intersection"], true)

	# remove parent (i.e. water) under child (i.e. earth)
	if not parent_intersection_description.empty() and not intersected_parent:
		parent.set_cell(point, -1)
	var cell_index = get_tile_index(orientation, intersected_parent)
	if cell_index != null:
		set_cell(point, cell_index)


func tile_exists(point: Vector2, displacement: Vector2 = Vector2.ZERO):
	if displacement == Vector2.ZERO:
		return get_cell(Vector2(point.x, point.y)) != -1
	return get_cell(Vector2(point.x + displacement.x, point.y + displacement.y)) != -1


func get_tile_index(orientation, intersects_parent = false):
	var value = (
		description.get(orientation)
		if not intersects_parent
		else parent_intersection_description.get(orientation)
	)
	if value == null:
		value = description.get(orientation)
	if value != null:
		return value[randi() % len(value)] if typeof(value) == TYPE_ARRAY else value
	return null


func bitmap_to_condition(point: Vector2, orientation: String, custom_bitmap = {}):
	var bitmap = orientation_bitmap[orientation] if custom_bitmap.empty() else custom_bitmap
	if not bitmap:
		return false
	var condition = true
	var i = 0
	while condition and i < len(bitmap["yes"]):
		condition = condition and tile_exists(point, Constants.DisplacementMap[bitmap["yes"][i]])
		i += 1
	i = 0
	while condition and i < len(bitmap["no"]):
		condition = (condition and not tile_exists(point, Constants.DisplacementMap[bitmap["no"][i]]))
		i += 1
	return condition


func delete_lonely_cell(point: Vector2):
	var neighbors = get_neighbors(point)
	if len(neighbors) <= 3 and not is_engle(point):
		set_cell(point, -1)
		for neighbor in neighbors:
			delete_lonely_cell(neighbor)


func get_neighbors(point: Vector2):
	var neighbors = []
	for i in [0, 1, 2, 3, 5, 6, 7, 8]:
		if tile_exists(point, Constants.DisplacementMap[i]):
			neighbors.append(
				Vector2(point.x + Constants.DisplacementMap[i].x, point.y + Constants.DisplacementMap[i].y)
			)
	return neighbors


func is_engle(point: Vector2):
	return is_of_tile(point, ["engle-t", "engle-d", "engle-l", "engle-r"])


func is_engle_or_edge(point: Vector2) -> bool:
	return is_of_tile(
		point,
		["engle-t", "engle-d", "engle-l", "engle-r", "edge-ld", "edge-rd", "edge-lt", "edge-rt"]
	)


func is_of_tile(point: Vector2, _orientations: Array):
	if tile_exists(point):
		for orientation in _orientations:
			if bitmap_to_condition(point, orientation):
				return true
	return false


func intersects_parent(orientation: String, point: Vector2):
	if parent_intersection_description.empty():
		return false
	var bitmap = orientation_bitmap.duplicate(true)[orientation]
	bitmap["yes"] = bitmap["no"]
	bitmap["no"] = []
	# some special rule because of boundary
	if point.x == 0 and orientation == "engle-l":
		bitmap["yes"].erase(1)
		bitmap["yes"].erase(0)
	if point.y == 0 and orientation == "engle-r":
		bitmap["yes"].erase(5)
		bitmap["yes"].erase(8)

	var condition = parent.bitmap_to_condition(point, orientation, bitmap)
	return condition


func get_tile_orientation(point: Vector2):
	if not tile_exists(point):
		return null
	return TileDescriptions.index_to_orientation(get_cell(point), description)


func set_cell(point: Vector2, index: int, flip_h = false):
	return tile_map.set_cell(int(point.x), int(point.y), index, flip_h)


func get_cell(point: Vector2):
	return tile_map.get_cell(int(point.x), int(point.y))
