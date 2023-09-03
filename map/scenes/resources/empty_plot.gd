extends ExploitResources
class_name EmptyPlot

onready var group_btn_remove = $GroupButtonRemove
onready var btn_remove = $GroupButtonRemove/ButtonRemove

var sprite_build_positions = {
	"empty_plot": Vector2(0, 0),
}
var sprite_spawn_positions = {
	"empty_plot": Vector2(0, 0),
}

onready var empty_plot_controller: EmptyPlotController = $EmptyPlotController


func _init():
	sprite_names = {
		"empty_plot": Vector2(1, 1),
	}
	texture_file = "res://map/textures/objects/plant/%s.png"
	sprite_name = Utils.random_from_dict(sprite_names)
	resource_type = Constants.ResourceType.EMPTY_PLOT
	height_point = -1


func _ready():
	load_texture()
	load_sprite_position()
	btn_remove.connect("pressed", self, "on_click_button_remove_local")

	
func load_texture():
	texture_file = "res://map/textures/objects/plant/%s.png"
	sprite.texture = Utils.load_resource(texture_file % sprite_name, "empty_plot_texture", sprite_name)
	sprite.position = sprite_build_positions[sprite_name]


func load_sprite_position():
	if is_reload:
		sprite.position = sprite_build_positions[sprite_name]
	else:
		sprite.position = sprite_spawn_positions[sprite_name]


func re_load(sprite_name, is_build):
	if is_reload:
		if is_build:
			self.sprite_name = sprite_name
		else:
			self.sprite_name = sprite_name
		load_texture()
		load_sprite_position()
	# move_pointer_arrow_to_this_empty_plot
	empty_plot_controller.move_top_arrow_pointer(self, Vector2(0, -10))


func on_hit():
	Utils.on_resource_shake($Sprite/Shake, 0.05, 20, 5, 0)

func _on_animation_finished(animation_name):
	Utils.on_resource_animation_finished(get_node("."), animation_name, vfx_hit)

func _on_death(_host_name):
	if _host_name == name:
		animation_player.play("die")


func visible_button_remove(_visible: bool):
	btn_remove.visible = _visible


func rotate_button_remove(is_build):
	if is_build:
		group_btn_remove.scale.x = -group_btn_remove.scale.x
	else:
		if scale.x == 1:
			group_btn_remove.scale.x = group_btn_remove.scale.x
		else:
			group_btn_remove.scale.x = -group_btn_remove.scale.x


func on_click_button_remove_local():
	Utils.get_current_character().ui_manager.on_click_button_remove_general(self)


func on_mouse_right_click() -> void:
	empty_plot_controller.on_mouse_right_click()


func remove_empty_plot() -> void:
	empty_plot_controller.remove_empty_plot()


func built() -> void:
	empty_plot_controller.move_top_arrow_pointer(self, Vector2(0, -10))
