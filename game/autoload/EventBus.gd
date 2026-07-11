extends Node
## EventBus — global signal hub for decoupling systems (Fase0 §2).
## No logic here; only signal declarations. Any system emits/subscribes.

# --- Time & sky ---
signal minute_passed(wib: Dictionary)          # emitted each in-game/real minute tick
signal hour_passed(hour: int)
signal day_started()
signal night_started()
signal golden_hour()
signal full_moon_began()
signal new_moon_began()
signal moon_phase_changed(phase_index: int)     # 0..7 sprite frame
signal sky_event(name: String)                  # from sky_calendar.json

# --- Weather ---
signal weather_changed(weather: String)         # "sunny","rain","thunderstorm","blizzard","blood_moon"

# --- Combat ---
signal damage_dealt(attacker, target, amount: int, is_crit: bool, elem: String)
signal monster_killed(species_id: String, monster)
signal monster_spawned(monster)
signal player_leveled_up(new_level: int)
signal player_died()
signal skill_learned(skill_id: String)
signal player_hp_changed(cur: int, max: int)
signal player_mp_changed(cur: int, max: int)
signal player_exp_changed(cur: int, needed: int)

# --- World counters / progression ---
signal counter_changed(key: String, value: int)
signal item_gained(item_id: String, qty: int)
signal gold_changed(amount: int)
signal achievement_unlocked(id: String, name: String, title: String)
signal codex_discovered(kind: String, id: String)

# --- Taming / pets ---
signal tame_attempted(species_id: String, success: bool, chance: float)
signal pet_added(instance: Dictionary)

# --- Gathering / crafting ---
signal node_harvested(node_type: String, item_id: String, qty: int)
signal prof_xp_gained(profession: String, total: int)
signal prof_level_up(profession: String, level: int)
signal fish_caught(fish_id: String)
signal block_mined(cell: Vector2i, block_type: String)
signal dungeon_entered(id: String)
signal dungeon_exited(id: String)
signal item_crafted(item_id: String, success: bool)
signal board_visited()                           # player opened the Quest Board (onboarding)

# --- Homestead ---
signal crop_planted(plot_index: int, crop_id: String)
signal crop_harvested(plot_index: int, crop_id: String, qty: int)

# --- Scenario ---
signal scenario_triggered(scenario_id: String)
signal scenario_resolved(scenario_id: String, success: bool)

# --- UI / general ---
signal toast(message: String)                   # transient on-screen message
signal sky_report_ready(report: Dictionary)
signal save_completed(slot: int)
signal game_loaded(slot: int)
