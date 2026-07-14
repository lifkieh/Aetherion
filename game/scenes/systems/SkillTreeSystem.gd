class_name SkillTreeSystem
extends RefCounted
## Skill Tree & TANAH ASAL (#30 → direvisi C1=(a), Decision Log #196).
##
## **Node DASAR: bisa dibuka DI MANA PUN** — dari buku, guru pengembara, atau companion.
## **Node MASTER (level ≥ `master_level`): HANYA di `unlock_location`** — untuk menjadi
## master es, kau tetap harus mendaki Frostpeak.
##
## Alasannya (REPORT-06 §C1): gating pintu menghukum pemain yang **tak sempat bepergian**,
## bukan pemain yang **belum belajar** — dan di single-player ia berubah jadi checklist
## perjalanan. Yang dikunci sekarang adalah **KEDALAMAN**, bukan **PINTU**. Identitas
## tetap: rumor & guru tetap mengarah ke tanah asal; puncaknya tetap milik tanah itu.
##
## Wilayah yang belum dibangun = `content_locked` (aktif otomatis saat wilayah dibuka).
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
	# C1 = (a), Decision Log #196: node DASAR boleh dibuka DI MANA PUN (buku, guru
	# pengembara, companion). Yang tetap terikat tanah asal adalah node MASTER (lihat
	# upgrade()). Rumor TETAP mengarah ke tanah asalnya — pohon tetap "lahir" di sana.
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

## Node MASTER hanya di tanah asal (C1=(a), #196). Node dasar: di mana pun.
static func is_master_step(id: String, next_level: int) -> bool:
	var t := tree(id)
	return next_level >= int(t.get("master_level", 99))

## Upgrade node. Node dasar boleh di mana pun; node MASTER menuntut kau berada
## di tanah asal pohon itu (`at_loc` = wilayah/kota tempat pemain berdiri).
static func upgrade(id: String, at_loc: String = "") -> Dictionary:
	var t := tree(id)
	if t.is_empty() or not owned(id):
		return {"ok": false, "reason": "Pohon belum dimiliki."}
	var lv := level(id)
	if lv >= int(t.get("max_level", 3)):
		return {"ok": false, "reason": "Sudah tingkat maksimal."}
	if is_master_step(id, lv + 1) and t.get("unlock_location", "") != at_loc:
		return {"ok": false, "reason": "🗺 Puncak ilmu ini hanya bisa dicapai di tanah asalnya. " + t.get("rumor", "")}
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
