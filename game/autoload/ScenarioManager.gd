extends Node
## ScenarioManager (M7) — the sacred Hidden Scenario engine (Fase0 §6).
## Counters rise silently in WorldState; when a trigger_action fires and all
## conditions match, the player is pulled into the scenario. no_fail: results
## are written permanently to the save (cleared/failed).

const DEBUG_ENV := "AETHER_DEBUG_SCENARIO"

var active_scenario := ""
var rabbits_killed_in_scenario := 0

func _debug() -> bool:
	return OS.get_environment(DEBUG_ENV) == "1"

func find(id: String) -> Dictionary:
	for sc in Db.scenarios:
		if sc.get("id", "") == id:
			return sc
	return {}

func threshold(sc: Dictionary) -> int:
	if _debug() and sc.has("debug_counters"):
		return int(sc.debug_counters.get("rabbits_killed", 10))
	return int(sc.get("counters", {}).get("rabbits_killed", 10000))

## Pure check: which scenario would trigger for this action right now (or "").
func would_trigger(action: String) -> String:
	for sc in Db.scenarios:
		if sc.get("trigger_action", "") != action:
			continue
		var id: String = sc.get("id", "")
		var flag: String = PlayerData.scenario_flags.get(id, "")
		if flag == "cleared" or flag == "failed":
			continue   # no_fail: permanent, never re-triggers
		if WorldState.get_counter("rabbits_killed") < threshold(sc):
			continue
		var needs_full: bool = sc.get("sky", {}).get("full_moon", false)
		if needs_full and not GameClock.is_full_moon() and not _debug():
			continue
		return id
	return ""

## Attempt to trigger; enters the scenario scene if conditions met.
func try_trigger(action: String) -> bool:
	var id := would_trigger(action)
	if id == "":
		return false
	var sc := find(id)
	active_scenario = id
	rabbits_killed_in_scenario = 0
	EventBus.scenario_triggered.emit(id)
	EventBus.toast.emit("✦ Sesuatu menarikmu ke tempat lain...")
	get_tree().change_scene_to_file(sc.get("scene", "res://scenes/Main.tscn"))
	return true

## Pure result application (flags + rewards). Returns the reward summary.
func apply_result(id: String, success: bool) -> Dictionary:
	var sc := find(id)
	var summary := {"item": "", "trait": ""}
	if success:
		PlayerData.scenario_flags[id] = "cleared"
		var item: String = sc.get("reward_item", "")
		if item != "":
			PlayerData.add_item(item, 1)
			summary.item = item
		var trait_id: String = sc.get("reward_trait", "")
		if trait_id != "":
			if trait_id == "moon_marked" and not ("moon" in PlayerData.mastered_elements):
				PlayerData.mastered_elements.append("moon")
			if not (trait_id in PlayerData.titles):
				PlayerData.titles.append(trait_id)
			summary.trait = trait_id
	else:
		PlayerData.scenario_flags[id] = "failed"
	return summary

## Called by a scenario scene when finished.
func resolve(success: bool) -> void:
	if active_scenario == "":
		return
	var id := active_scenario
	var summary := apply_result(id, success)
	if success:
		var msg := "✦ Skenario selesai!"
		if summary.item != "":
			msg += " Kamu memperoleh %s" % Db.item_name(summary.item)
		EventBus.toast.emit(msg)
		Audio.play_sfx("secret")
	else:
		EventBus.toast.emit("✦ Skenario GAGAL — terkunci permanen bagi karaktermu.")
	EventBus.scenario_resolved.emit(id, success)
	active_scenario = ""
	SaveManager.save_game(SaveManager.current_slot)   # no_fail: persist immediately
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func note_rabbit_killed_in_scenario() -> void:
	rabbits_killed_in_scenario += 1
