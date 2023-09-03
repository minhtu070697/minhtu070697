extends Node
class_name StatsManager

var host

var stats: FighterStats
var equipment_manager : EquipmentManager
var dmg_receive_manager: DamageReceiveManager
var in_game_name: String

onready var buff_manager := $BuffManager
onready var health_states_manager := $HealthStatesManager

export(Constants.CharacterRace) var owner_race: int = Constants.CharacterRace.HUMAN
export(String, "player", "enemy", "resources") var owner_type : String = "resources"
export var owner_lvl = 1
export(Array, String) var owner_class_list = []

var owner_job_dict = {
	"fighter" : FighterStats
}

var all_class_list = []
var host_class : ClassResources

var status_color: Color = Constants.NORMAL_COLOR


func _ready():
	yield(owner,"ready")
	stats_manager_ready()


func stats_manager_ready() -> void:
	host = owner
	set_host_class(host, host.monster_info.class_list if host is Enemy else owner_class_list)
	equipment_manager = EquipmentManager.new(self)
	init(owner_type, host.lvl)
	dmg_receive_manager = DamageReceiveManager.new(host)


#pick a class from host class list and save class data -> host_class
func set_host_class(_host, _host_class: Array = []):
	all_class_list = GameResourcesLibrary.actor_class_resources_list_json
	
	var host_type_class_list = []
	for class_res_name in all_class_list:
		var class_res = all_class_list[class_res_name]
		if class_res.owner_type.has(_host.stats_manager.owner_type) and (class_res.owner_class in _host_class or _host_class.size() < 1):
			host_type_class_list.append(class_res)

	if host_type_class_list.size() == 0:
		#Set Host_class -> Null Class
		host_class = ClassResources.new(GameResourcesLibrary.actor_class_resources_list_json["null"])
	else:
		var class_number = Utils.random_int(0, host_type_class_list.size() - 1)
		host_class = ClassResources.new(host_type_class_list[class_number])


func init(_owner_type: String = "enemy", _owner_lvl: int = 1):
	owner_type = _owner_type
	owner_lvl = _owner_lvl
	stats = FighterStats.new(host, host_class)


#check and aplly all dmg the host taken
func _physics_process(_delta):
	if not dmg_receive_manager.dmg_stack.empty():
		dmg_receive_manager.inflict_dmg()
