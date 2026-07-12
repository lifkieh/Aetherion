extends Node
## ProfessionSystem (GDD v0.2 §3) — 1 MAIN + up to 2 SUB professions.
## Only main+sub earn XP. Main: +50% XP, full efficiency, tier cap MAIN_CAP, can
## craft A+ recipes. Sub: 1.0× XP, 75% efficiency, tier cap SUB_CAP (~60% of main),
## max recipe tier B. Others: no XP. Change main = gold + cooldown.
## See DEVLOG for the Fase-0 level-compression decision (levels map to GDD 1-99).

const MAIN_BONUS := 1.5
const SUB_EFFICIENCY := 0.75
const MAIN_CAP := 50           # Fase 0 compressed cap (GDD full = 99)
const SUB_CAP := 30            # ~60% of main cap (GDD sub = 60)
const CHANGE_MAIN_COST := 5000
const CHANGE_COOLDOWN := 7 * 86400   # 7 WIB days (Fase 0; GDD = 30 days)
const TIER_ORDER := ["F", "E", "D", "C", "B", "A", "S", "SS", "SSS"]
const BASIC_TIERS := ["F", "E", "D"]     # anyone can craft
const TRANSCENDENT := ["A", "S", "SS", "SSS"]  # main only

func _ready() -> void:
	EventBus.node_harvested.connect(_on_harvest)
	EventBus.block_mined.connect(func(_c, _t): award("miner", 2))
	EventBus.crop_harvested.connect(func(_i, _c, _q): award("herbalist", 5))
	EventBus.item_crafted.connect(_on_craft)
	EventBus.fish_caught.connect(func(_f): award("fisherman", 6))
	# Decision Log #32: aksi taming itu sendiri memberi XP — sukses MAUPUN percobaan
	# (main Tamer otomatis +50% via award()).
	EventBus.tame_attempted.connect(func(_s, ok, _c): award("tamer", 8 if ok else 3))

# --- roles ------------------------------------------------------------------

func main() -> String:
	return PlayerData.professions.get("main", "")

func subs() -> Array:
	return PlayerData.professions.get("sub", [])

func is_active(prof: String) -> bool:
	return prof != "" and (prof == main() or prof in subs())

func role(prof: String) -> String:
	if prof == main() and prof != "":
		return "main"
	if prof in subs():
		return "sub"
	return "none"

func efficiency(prof: String) -> float:
	match role(prof):
		"main": return 1.0
		"sub": return SUB_EFFICIENCY
		_: return 0.0

func cap(prof: String) -> int:
	match role(prof):
		"main": return MAIN_CAP
		"sub": return SUB_CAP
		_: return 1

func effective_level(prof: String) -> int:
	return mini(PlayerData.prof_level(prof), cap(prof))

# --- XP ---------------------------------------------------------------------

func award(prof: String, base: int) -> void:
	if not is_active(prof):
		return   # inactive professions earn nothing (GDD)
	if PlayerData.prof_level(prof) >= cap(prof):
		return   # at the Fase-0 cap
	var old_lvl := effective_level(prof)
	var xp := int(base * (MAIN_BONUS if prof == main() else 1.0))
	# class KEHIDUPAN (Decision Log #33): +50% EXP pada profesi domain-nya
	if prof in Db.cls(PlayerData.char_class).get("domains", []):
		xp = int(xp * 1.5)
	PlayerData.gain_prof_xp(prof, xp)
	var new_lvl := effective_level(prof)
	if new_lvl > old_lvl:
		EventBus.prof_level_up.emit(prof, new_lvl)
		EventBus.toast.emit("⚒ %s naik ke Lv %d!" % [_name(prof), new_lvl])
		for p in _perks(prof):
			if int(p.get("level", 0)) > old_lvl and int(p.get("level", 0)) <= new_lvl:
				EventBus.toast.emit("  Perk: " + p.get("desc", ""))
				Audio.play_sfx("success")

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

## Perk value already scaled by efficiency (sub gets 75%, inactive 0).
func perk_value(prof: String, type: String) -> float:
	if not is_active(prof):
		return 0.0
	var lvl := effective_level(prof)
	var total := 0.0
	for p in _perks(prof):
		if p.get("type", "") == type and int(p.get("level", 999)) <= lvl:
			total += float(p.get("value", 0))
	return total * efficiency(prof)

func _perks(prof: String) -> Array:
	return Db.professions.get(prof, {}).get("perks", [])

func _name(prof: String) -> String:
	return Db.professions.get(prof, {}).get("name", prof.capitalize())

# --- recipe access (tier gate) ----------------------------------------------

## {ok: bool, reason: String}. Basics F/E/D: anyone. C/B: active profession.
## A/S/SS/SSS (Transcendent): MAIN profession only (GDD v0.2 §2/§3).
func can_use_recipe(recipe: Dictionary) -> Dictionary:
	var prof: String = recipe.get("profession", "")
	var tier: String = recipe.get("tier", Db.item(recipe.get("result", "")).get("tier", "F"))
	if tier in BASIC_TIERS:
		return {"ok": true, "reason": ""}
	if tier in TRANSCENDENT:
		if prof == main():
			return {"ok": true, "reason": ""}
		return {"ok": false, "reason": "Resep [%s] hanya untuk profesi UTAMA %s." % [tier, _name(prof)]}
	# C / B
	if is_active(prof):
		return {"ok": true, "reason": ""}
	return {"ok": false, "reason": "Butuh profesi %s (utama/sub) untuk resep [%s]." % [_name(prof), tier]}

# --- main / sub management --------------------------------------------------

func set_main(prof: String) -> Dictionary:
	if not Db.professions.has(prof):
		return {"ok": false, "reason": "profesi tak dikenal"}
	if prof == main():
		return {"ok": false, "reason": "sudah jadi utama"}
	var cur := main()
	# first pick is free
	if cur == "":
		PlayerData.professions["main"] = prof
		_erase_sub(prof)
		EventBus.toast.emit("Profesi utama: %s" % _name(prof))
		return {"ok": true, "reason": ""}
	var now := GameClock.unix_now()
	var last: int = PlayerData.professions.get("last_main_change", 0)
	if now - last < CHANGE_COOLDOWN:
		var days := int((CHANGE_COOLDOWN - (now - last)) / 86400) + 1
		return {"ok": false, "reason": "Reawakening cooldown ~%d hari lagi." % days}
	if not PlayerData.spend_gold(CHANGE_MAIN_COST):
		return {"ok": false, "reason": "Butuh %d gold untuk ganti utama." % CHANGE_MAIN_COST}
	PlayerData.professions["main"] = prof
	PlayerData.professions["last_main_change"] = now
	_erase_sub(prof)
	EventBus.toast.emit("Reawakening! Profesi utama sekarang: %s" % _name(prof))
	return {"ok": true, "reason": ""}

func toggle_sub(prof: String) -> Dictionary:
	if prof == main():
		return {"ok": false, "reason": "sudah jadi utama"}
	var sub: Array = subs()
	if prof in sub:
		sub.erase(prof)
	elif sub.size() < 2:
		sub.append(prof)
	else:
		return {"ok": false, "reason": "Maksimal 2 sub-profesi."}
	PlayerData.professions["sub"] = sub
	return {"ok": true, "reason": ""}

func _erase_sub(prof: String) -> void:
	var sub: Array = subs()
	sub.erase(prof)
	PlayerData.professions["sub"] = sub
