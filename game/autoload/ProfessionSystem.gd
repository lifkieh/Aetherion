extends Node
## NOTE: see DEVLOG 2026-07-11 for the profession system rollout.
## ProfessionSystem (GDD v0.2 §3) — awards profession XP from existing activity
## signals, applies the +50% main-profession bonus, announces level-ups + perk
## unlocks, and exposes perk values other systems query.

const MAIN_BONUS := 1.5

func _ready() -> void:
	EventBus.node_harvested.connect(_on_harvest)
	EventBus.block_mined.connect(func(_c, _t): award("miner", 2))
	EventBus.crop_harvested.connect(func(_i, _c, _q): award("herbalist", 5))
	EventBus.item_crafted.connect(_on_craft)
	EventBus.fish_caught.connect(func(_f): award("fisherman", 6))
	EventBus.tame_attempted.connect(func(_s, ok, _c): if ok: award("tamer", 8))

func _on_harvest(kind: String, _item: String, _qty: int) -> void:
	if kind == "tree":
		award("lumberjack", 5)
	elif kind == "ore":
		award("miner", 6)

func _on_craft(result: String, success: bool) -> void:
	if not success:
		return
	for r in Db.recipes:
		if r.get("result", "") == result:
			award(r.get("profession", "carpenter"), 6)
			return

func award(prof: String, base: int) -> void:
	if prof == "":
		return
	var old_lvl := PlayerData.prof_level(prof)
	var main: String = PlayerData.professions.get("main", "")
	var xp := int(base * (MAIN_BONUS if prof == main else 1.0))
	PlayerData.gain_prof_xp(prof, xp)
	var new_lvl := PlayerData.prof_level(prof)
	if new_lvl > old_lvl:
		EventBus.prof_level_up.emit(prof, new_lvl)
		EventBus.toast.emit("⚒ %s naik ke Lv %d!" % [_name(prof), new_lvl])
		for p in _perks(prof):
			if p.get("level", 0) > old_lvl and p.get("level", 0) <= new_lvl:
				EventBus.toast.emit("  Perk: " + p.get("desc", ""))
				Audio.play_sfx("success")

## Total value of unlocked perks of `type` for a profession (queried by systems).
func perk_value(prof: String, type: String) -> float:
	var lvl := PlayerData.prof_level(prof)
	var total := 0.0
	for p in _perks(prof):
		if p.get("type", "") == type and int(p.get("level", 999)) <= lvl:
			total += float(p.get("value", 0))
	return total

func _perks(prof: String) -> Array:
	return Db.professions.get(prof, {}).get("perks", [])

func _name(prof: String) -> String:
	return Db.professions.get(prof, {}).get("name", prof.capitalize())
