class_name StatusFx
extends RefCounted
## Status effect system (v0.4.1 — GDD v0.1 §6.4): Burn/Freeze/Paralyze/Poison/Blind
## untuk monster (kedua mode) + pemain, dengan interaksi SAINS yang sudah didesain:
##   • basah memadamkan/menahan Burn; air menghapus Burn (pemadaman)
##   • target basah lebih mudah beku; Lightning HANYA melumpuhkan target basah (konduksi)
##   • Freeze + pukulan Fire = THERMAL SHOCK ×1.5 dan es pecah (ekspansi termal)
##   • Poison memotong efek heal 50% (dosis)
##   • Blind memangkas akurasi 30%
## Entitas cukup punya: `statuses: Dictionary`, `take_status_damage(dmg, elem)`.

const DEFS := {
	"burn":     {"dur": 4.0, "dps_pct": 0.02, "icon": "🔥"},
	"freeze":   {"dur": 1.3, "icon": "❄"},
	"paralyze": {"dur": 1.5, "icon": "⚡"},
	"poison":   {"dur": 5.0, "dps_pct": 0.01, "icon": "☠"},
	"blind":    {"dur": 4.0, "icon": "🌫"},
}

# element damage -> {status: chance}; interaksi basah dihitung di on_hit
const ON_HIT := {
	"fire":      {"burn": 0.25},
	"ice":       {"freeze": 0.20},
	"lightning": {"paralyze": 0.25},   # hanya jika target basah (konduksi)
	"poison":    {"poison": 0.30},
	"light":     {"blind": 0.20},
}

static func apply(entity, id: String) -> void:
	if entity == null or not ("statuses" in entity) or not DEFS.has(id):
		return
	entity.statuses[id] = {"t": DEFS[id].dur}

static func has(entity, id: String) -> bool:
	return entity != null and ("statuses" in entity) and entity.statuses.has(id)

## Roll status application from a landed hit. `is_wet` = target basah.
static func on_hit(entity, result: Dictionary, is_wet: bool) -> void:
	if entity == null or not ("statuses" in entity) or result.get("damage", 0) <= 0:
		return
	# explicit skill/trait poison (apply_status) = pasti kena
	if result.get("apply_status", "") == "poison":
		apply(entity, "poison")
	var elem: String = result.get("element", "none")
	var rolls: Dictionary = ON_HIT.get(elem, {})
	for sid in rolls:
		var chance: float = rolls[sid]
		match sid:
			"burn":
				if is_wet: continue                 # sains: basah tak terbakar
			"freeze":
				if is_wet: chance += 0.15           # sains: air membeku lebih mudah
			"paralyze":
				if not is_wet: continue             # sains: konduksi butuh air
		if randf() < chance:
			apply(entity, sid)
	# sains: serangan air memadamkan Burn
	if elem == "water" and has(entity, "burn"):
		entity.statuses.erase("burn")

## Pre-damage interaction — THERMAL SHOCK: pukulan Fire pada target beku ×1.5,
## es pecah. Panggil di take_hit SEBELUM damage dihitung. Mengembalikan result.
static func pre_hit(entity, result: Dictionary) -> Dictionary:
	if has(entity, "freeze") and result.get("element", "") == "fire" and result.get("damage", 0) > 0:
		result = result.duplicate()
		result["damage"] = int(result["damage"] * 1.5)
		result["thermal_shock"] = true
		entity.statuses.erase("freeze")
		if entity is Node2D and entity.is_inside_tree():
			Vfx.impact(entity.get_parent(), entity.global_position, "ice", true)
			EventBus.toast.emit("💥 Thermal Shock! (es pecah ×1.5)")
	return result

## Tick durations + DoT. Entity harus punya take_status_damage(dmg, elem) & max_hp.
static func tick(entity, delta: float) -> void:
	if entity == null or not ("statuses" in entity) or entity.statuses.is_empty():
		return
	var mhp: int = entity.max_hp if ("max_hp" in entity) else 100
	for sid in entity.statuses.keys().duplicate():
		var st: Dictionary = entity.statuses[sid]
		st["t"] = float(st.get("t", 0.0)) - delta
		st["dot_acc"] = float(st.get("dot_acc", 0.0)) + float(DEFS[sid].get("dps_pct", 0.0)) * mhp * delta
		if st["dot_acc"] >= 1.0 and entity.has_method("take_status_damage"):
			var d := int(st["dot_acc"])
			st["dot_acc"] -= d
			entity.take_status_damage(d, "fire" if sid == "burn" else "poison")
		if st["t"] <= 0.0:
			entity.statuses.erase(sid)
		else:
			entity.statuses[sid] = st

static func is_stunned(entity) -> bool:
	return has(entity, "freeze")

static func is_attack_locked(entity) -> bool:
	return has(entity, "freeze") or has(entity, "paralyze")

## Akurasi ×0.7 saat Blind (dipakai penyerang yang buta).
static func acc_mult(entity) -> float:
	return 0.7 if has(entity, "blind") else 1.0

## Heal ×0.5 saat Poison (dosis menghambat pemulihan).
static func heal_mult(entity) -> float:
	return 0.5 if has(entity, "poison") else 1.0

static func icons_text(entity) -> String:
	if entity == null or not ("statuses" in entity):
		return ""
	var s := ""
	for sid in entity.statuses:
		s += DEFS[sid].get("icon", "?")
	return s
