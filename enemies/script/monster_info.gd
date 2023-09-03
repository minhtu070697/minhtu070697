extends Node2D
class_name MonsterGenerator

#Var
var monster_list = []

var monster_info : MonsterResources

func _init(_monster_name = "") -> void:
	if _monster_name != "":
#		monster_info = GameResourcesLibrary.load_file_as_monster_resource(Constants.MONSTER_RESOURCES_PATH % _monster_name)
		monster_info = MonsterResources.new(GameResourcesLibrary.monster_resources_list_json[_monster_name])
	else:
		monster_list = GameResourcesLibrary.monster_resources_list_json

#not use at the moment but need in future
func generate_info(_monster_name):
	#Create a list of matched monster_info
	var monster_info_list = []
	#add monster_info that matched with the criteria
	for monster_res_name in monster_list:
		var monster_res = monster_list[monster_res_name]
		if monster_info_match(_monster_name, monster_res):
			monster_info_list.append(monster_res)
			
	if monster_info_list.size() == 0:
		#if we can't find the right monster, it'll be a goblin
		monster_info = MonsterResources.new(GameResourcesLibrary.monster_resources_list_json[Constants.MONSTER_NULL_NAME])
	else:
		var monster_info_number = Utils.random_int(0, monster_info_list.size() - 1)
		monster_info = MonsterResources.new(monster_info_list[monster_info_number])
		
		
func monster_info_match(_monster_name, _monster_res: Dictionary) -> bool:
	return _monster_name == _monster_res.monster_name
	



