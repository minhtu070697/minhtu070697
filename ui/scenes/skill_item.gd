extends Control
class_name SkillItem

onready var cooldown_label = $Cooldown
onready var texture_rect = $TextureRect
onready var item_vfx = $VFX
onready var inactive_color = $InactiveSkillColor
onready var cooldown_timer = $CooldownTimer
onready var skill_lock_timer = $SkillLockTimer
onready var ui_manager = find_parent("ui")

var skill_info: SkillResources
var skill: Skill
var skill_name
var skill_cooldown
var skill_locking: bool = false

export(Vector2) var inactive_color_size := Vector2(20, 20)

var active = true


func _ready():
	SignalManager.connect("skill_done", self, "_on_skill_done")
	SignalManager.connect("skill_lock", self, "_on_skill_lock")


func _physics_process(_delta: float) -> void:
	if inactive_color.visible:
		if !skill_locking:
			inactive_color.set_size(Vector2(inactive_color_size.x, (cooldown_timer.time_left / skill.cooldown) * inactive_color_size.y))


func set_item(_skill: Skill):
	if skill == _skill:
		return
	skill = _skill
	skill_info = _skill.skill_info
	skill_name = skill_info.skill_name
	skill_cooldown = skill.cooldown
	texture_rect.texture = load(skill_info.icon_image)
	cooldown_label.visible = false


func show_vfx(is_show: bool):
	item_vfx.visible = is_show


func skill_active():
	SignalManager.emit_signal("skill_active", skill)
	

func skill_actived():
	cooldown_timer.start(skill.cooldown)
	disable_skill()
	cooldown_label.visible = false


func _on_CooldownTimer_timeout() -> void:
	enable_skill()
	cooldown_label.visible = false


func _on_skill_done(_host_name, _skill: Skill):
	if _skill.skill_name == skill_name and _host_name == ui_manager.character.name:
		skill_actived()


func _on_skill_lock(_host_name, _skill: Skill, _time: float):
	if _host_name != ui_manager.character.name:
		return
		
	if cooldown_timer.time_left < _time or _skill.skill_name == skill_name:
		skill_lock(_time)


func skill_lock(_time: float):
	skill_locking = true
	disable_skill()
	skill_lock_timer.wait_time = _time
	skill_lock_timer.start()


func _on_SkillLockTimer_timeout() -> void:
	skill_locking = false
	if cooldown_timer.time_left == 0:
		enable_skill()


func disable_skill():
	inactive_color.visible = true
	active = false
	

func enable_skill():
	active = true
	inactive_color.visible = false
	inactive_color.set_size(inactive_color_size)
