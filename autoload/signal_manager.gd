extends Node

signal character_arrived
signal basic_action_finished
signal attack_finished
signal run_finished
signal resource_hit
signal die_finished
signal water_finished

signal casting_finished

signal teleport_finished

signal jump_attack_finished
signal jump_finished

signal fishing_throw_finished
signal fishing_waiting_finished
signal fishing_biting_finished
signal fishing_pull_finished
signal fishing_catch_finished
signal fishing_jump_finished

signal health_changed
signal mana_changed
signal exp_changed(host_name)

signal death
signal target_clicked
signal enemy_moving
signal stuck_detect

#skill_active

signal skill_slot_actived(slot)

signal skill_active(skill)

signal skill_done(host_name, skill)

signal skill_finished(host_name)

signal melee_hit(host_name, skill, target)

signal spawn_proj(host_name, skill, target)

signal teleport(host_name, skill)

signal skill_break_point(host_name, skill)

signal skill_lock(host_name, skill, time)

signal player_ready

signal update_character_stats_tab(character_name)

signal update_character_skill_tab(character, update_all_skill_icon)
signal init_character_skill_tab(character)

signal exp_reward(exp_reward_value, receiving_group_name, _exp_lvl)

signal skill_create(skill, host)

signal skill_remove(skill, host)

signal return_to_barn_call(_barn)

#environment_events
signal wind_blow(wind)

# emit when change scene
signal scene_changed(_new_scene_path)

signal mouse_left_clicked()
signal mouse_right_clicked()

# barn delete
signal update_overlap_bodies(_sender)

# monster amount
signal update_monster_amount()

# equipment durability update
signal durability_changed(item_name, old_dura, new_dura, max_dura)

# Day - Night
signal day()
signal sunset()
signal night()
signal dawn()


signal character_dead

# Camera Vfxs
signal camera_shake
