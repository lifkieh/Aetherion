class_name SkillTreeSystem
extends RefCounted
## Skill Tree TERIKAT LOKASI (Decision Log #30): pohon hanya bisa DIBUKA di
## `unlock_location`-nya (perjalanan untuk membuka); node lanjutan boleh
## di-upgrade DI MANA PUN setelah pohon dimiliki. Pohon luar-lokasi tampil
## sebagai RUMOR berarah di Penjaga Pohon. Lokasi yang wilayahnya belum
## dibangun = `content_locked` (aktif otomatis saat wilayah dibuka).
## Pohon Celestial: hanya terlihat di Menara Astrologer, butuh clear
## Hidden Scenario (requires_scenario) — sinkron desain elemen Tier 4.

const UPGRADE_COST_MULT := 0.6   # biaya per node = cost * mult * level_berikut

static func tree(id: String) -> Dictionary:
	return Db.skill_trees.get(id, {})

static func all() -> Array:
	return Db.skill_trees.values()

static func at_location(loc: String) -> Array:
	return all().filter(func(t): return t.get("unlock_location", "") == loc)

static func level(id: String) -> int:
	return int(PlayerData.skill_trees.get(id, 0))

static func owned(id: String) -> bool:
	return level(id) > 0

## Pohon domain class kehidupan (Decision Log #33): diskon 50% + 1 node gratis.
static func is_domain_tree(id: String) -> bool:
	return id in Db.cls(PlayerData.char_class).get("tree_domain", [])

static func unlock_cost(id: String) -> int:
	var c := int(tree(id).get("cost", 0))
	return int(c * 0.5) if is_domain_tree(id) else c

## Boleh dibuka? Mengembalikan {ok, reason} — reason berisi RUMOR saat lokasi salah.
static func can_unlock(id: String, at_loc: String) -> Dictionary:
	var t := tree(id)
	if t.is_empty():
		return {"ok": false, "reason": "Pohon tidak dikenal."}
	if owned(id):
		return {"ok": false, "reason": "Sudah dimiliki — node bisa di-upgrade di mana pun."}
	if t.get("content_locked", false):
		return {"ok": false, "reason": "🔒 Wilayah ini belum terbuka. " + t.get("rumor", "")}
	if t.get("unlock_location", "") != at_loc:
		return {"ok": false, "reason": "🗺 RUMOR: " + t.get("rumor", "Ilmu ini diajarkan di tempat lain.")}
	var req: String = t.get("requires_scenario", "")
	if req != "" and PlayerData.scenario_flags.get(req, "") != "cleared":
		return {"ok": false, "reason": "📖 Butuh buku dari sebuah Skenario Tersembunyi... langit tahu yang mana."}
	if PlayerData.gold < unlock_cost(id):
		return {"ok": false, "reason": "Gold kurang (%d G)." % unlock_cost(id)}
	return {"ok": true, "reason": ""}

## Buka pohon DI lokasinya (level 1; pohon domain class kehidupan = level 2, #33).
static func unlock(id: String, at_loc: String) -> Dictionary:
	var chk := can_unlock(id, at_loc)
	if not chk.ok:
		return chk
	var t := tree(id)
	PlayerData.add_gold(-unlock_cost(id))
	var domain := is_domain_tree(id)
	PlayerData.skill_trees[id] = 2 if domain else 1   # domain: 1 node GRATIS
	PlayerData.recalculate_stats()
	EventBus.toast.emit("🌳 Pohon dibuka: %s!%s" % [t.get("name", id), " (domain jalurmu: diskon + node gratis)" if domain else ""])
	Audio.play_sfx("levelup", 1.1)
	return {"ok": true, "reason": ""}

## Upgrade node — BOLEH DI MANA PUN setelah pohon dimiliki (bukan bolak-balik).
static func upgrade(id: String) -> Dictionary:
	var t := tree(id)
	if t.is_empty() or not owned(id):
		return {"ok": false, "reason": "Pohon belum dimiliki — buka dulu di lokasinya."}
	var lv := level(id)
	if lv >= int(t.get("max_level", 3)):
		return {"ok": false, "reason": "Sudah tingkat maksimal."}
	var cost := int(t.get("cost", 100) * UPGRADE_COST_MULT * (lv + 1))
	if PlayerData.gold < cost:
		return {"ok": false, "reason": "Gold kurang (%d G)." % cost}
	PlayerData.add_gold(-cost)
	PlayerData.skill_trees[id] = lv + 1
	PlayerData.recalculate_stats()
	EventBus.toast.emit("🌳 %s → tingkat %d" % [t.get("name", id), lv + 1])
	Audio.play_sfx("success")
	return {"ok": true, "reason": ""}

static func upgrade_cost(id: String) -> int:
	return int(tree(id).get("cost", 100) * UPGRADE_COST_MULT * (level(id) + 1))

## Total bonus satu field dari SEMUA pohon yang dimiliki (level × per-level).
static func bonus_total(field: String) -> float:
	var s := 0.0
	for id in PlayerData.skill_trees:
		var t := tree(id)
		s += float(t.get("bonus", {}).get(field, 0.0)) * level(id)
	return s
