extends Panel
class_name BarnInventorySlot

onready var livestock_icon = $LivestockIcon 
onready var name_label: Label = $IconLabel
onready var amount_left_label: Label = $AmountLabel
var livestock_name: String
