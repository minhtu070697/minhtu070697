extends Node
class_name BuffManager

#signal
signal update_stats()


var buff_list: Dictionary = {}
var total_buff: Dictionary = {}


func _ready() -> void:
	pass


func add_buff(_buff: Dictionary, _buff_info: Dictionary) -> void:
	if !buff_list.has(_buff_info.buff_name):
		buff_list[_buff_info.buff_name] = GameResourcesLibrary.STAT_BUFF_NODE.instance()
		add_child(buff_list[_buff_info.buff_name])
		
	buff_list[_buff_info.buff_name].update_buff(_buff, _buff_info)
	update_total_buff()


func delete_buff(_buff_name: String) -> void:
	buff_list.erase(_buff_name)
	update_total_buff()


func update_total_buff() -> void:
	total_buff.clear()
	for buff_node_name in buff_list:
		var buff_node = buff_list[buff_node_name]
		var stat_buffs: Dictionary = buff_node.stat_buffs
		#for each stat in item stat list
		for buff in stat_buffs:
			if not total_buff.has(buff):
				total_buff[buff] = 0
				
			total_buff[buff] += stat_buffs[buff]
	emit_signal("update_stats")


func force_delete_buff(_buff_name: String) -> void:
	buff_list[_buff_name].queue_free()
	buff_list.erase(_buff_name)
	update_total_buff()
