extends Panel
class_name ItemSlot

onready var default_tex = Utils.load_resource("res://ui/textures/item_slot_selected_background.png", "item_slot", "selected_background")
onready var empty_tex = Utils.load_resource("res://ui/textures/item_slot_default_background.png", "item_slot", "default_background")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null

onready var ItemClass = Utils.load_resource("res://ui/scenes/InventoryItem.tscn", "inventory_item", "scene")
var item = null setget set_item
var slot_index
var enable_tooltip: bool = true

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
	CRAFTING_MAIN,
	CRAFTING_SUB,
	CRAFTING_RELEASE,
	REFORGE_ITEM,
	REFORGE_INGREDIENT,
	HAIR,
	SHIRT,
	PANTS,
	WEAPON
	ROD,
	AXE,
	PICK,
	HOE
}

var slotType = null

func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	empty_style.texture = empty_tex
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	refresh_style()


func set_item(new_item) -> void:
	if item:
		disconnect_item_signals()
	
	item = new_item

	if item:
		connect_item_signals()


func refresh_style():
	if item == null:
		set('custom_styles/panel', empty_style)
	else:
		set('custom_styles/panel', default_style)
		
func pickFromSlot():
	remove_child(item)
	find_parent("ui").add_child(item)
	#NUYG: hide tooltip when pick item
	hide_item_tooltip()
	set_item(null)
	refresh_style()
	
func putIntoSlot(new_item):
	set_item(new_item)
	item.position = Vector2(0, 0)
	find_parent("ui").remove_child(item)
	add_child(item)
	refresh_style()

func removeFromSlot(holding_item):
	holding_item.queue_free()
	holding_item = null
	refresh_style()

func removeFromCraftingSlot(slot):
	slot.item = null
	slot.get_child(0).queue_free()
	refresh_style()

func removeSlotItem():
	if item:
		disconnect_item_signals()
		item.queue_free()
		set_item(null)
		PlayerInventory.remove_item(self)
		refresh_style()


func initialize_item(item_name, item_amount, data: Dictionary = {}, _item_lvl: int = 3):
	if item == null:
		set_item(ItemClass.instance())
		add_child(item)
		item.set_item(item_name, item_amount, data, _item_lvl)
		connect_item_signals()
	else:
		item.set_item(item_name, item_amount, data, _item_lvl)
	refresh_style()


func connect_item_signals() -> void:
	if item and not item.is_connected("amount_changed", self, "_on_item_amount_changed"):
		item.connect("amount_changed", self, "_on_item_amount_changed")
		item.connect("item_updated", self, "_on_item_updated")


func disconnect_item_signals() -> void:
	if item and item.is_connected("amount_changed", self, "_on_item_amount_changed"):
		item.disconnect("amount_changed", self, "_on_item_amount_changed")
		item.disconnect("item_updated", self, "_on_item_updated")


#NUYG: Tooltip function
func _on_mouse_entered():
	if !enable_tooltip:
		return
	show_item_tooltip()


func _on_mouse_exited():
	if !enable_tooltip:
		return
	hide_item_tooltip()


func show_item_tooltip():
	if !item:
		return
	if item.item_info == null:
		return
	
	item.update_tooltip()
	item.tooltip.visible = true

func hide_item_tooltip():
	if !item:
		return
	item.tooltip.visible = false


func _on_item_amount_changed(amount: int, new_amount) -> void:
	PlayerInventory.add_item_amount(self, amount)
	if new_amount <= 0:
		removeSlotItem()


func _on_item_updated(new_stats: Dictionary) -> void:
	PlayerInventory.update_item(self, new_stats)
