class_name MapInfoItem

var type  # MapInfoType enum
var name: String
var point: Vector2
var size = Vector2(1, 1)
var origin

# TILE_MAP
var tile: TileManager

# RESOURCE
var resource_type  # ResourceType enum
var resource: Node

# DECORATION
var decoration: Node

func is_tile():
	return type == Constants.MapInfoType.TILE_MAP

func is_resource():
	return type == Constants.MapInfoType.RESOURCE

func is_clickable_resource():
	if is_resource():
		return (resource_type == Constants.ResourceType.LIVESTOCK_BARN or is_empty_plot())

func is_decoration():
	return type == Constants.MapInfoType.DECORATION

func is_above_decoration():
	return type == Constants.MapInfoType.ABOVE_DECORATION

func is_below_decoration():
	return type == Constants.MapInfoType.BELOW_DECORATION

func is_tall_decoration():
	return type == Constants.MapInfoType.TALL_DECORATION

func is_wall_decoration():
	return type == Constants.MapInfoType.WALL_DECORATION

func is_walkable_decoration():
	return type == Constants.MapInfoType.WALKABLE_DECORATION

func is_buildable_decoraion():
	return type == Constants.MapInfoType.BUILDABLE_DECORATION

func is_walkable():
	return is_tile() 

func is_empty_plot() -> bool:
	return resource_type == Constants.ResourceType.EMPTY_PLOT and !resource.empty_plot_controller.has_young_plant
