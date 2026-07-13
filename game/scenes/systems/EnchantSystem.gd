class_name EnchantSystem
extends RefCounted
## Enchant +1..+10 (v0.4.2, GDD v0.1 §3.3 profesi Enchanter + spec REPORT-04 #3).
## Layanan NPC Enchanter terbuka untuk semua (gold sink); pemain berprofesi
## Enchanter aktif dapat diskon 30% + bonus peluang dari perk.
## Gagal di target ≥ +7 = turun 1 level — TIDAK PERNAH hancur; Gulungan
## Perlindungan (protection_scroll) menahan penurunan itu (auto-terpakai).

const MAX_LEVEL := 10
const SAFE_UNTIL := 6           # gagal menuju +1..+6: level tetap
const RATES := [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.25, 0.2]   # target +1..+10

static func can_enchant(item_id: String) -> Dictionary:
	var def := Db.item(item_id)
	if not def.get("type", "") in ["weapon", "armor", "accessory"]:
		return {"ok": false, "reason": Loc.t("enchant.gear_only")}
	if PlayerData.gear_enchant(item_id) >= MAX_LEVEL:
		return {"ok": false, "reason": Loc.t("enchant.max", [MAX_LEVEL])}
	return {"ok": true, "reason": ""}

## Biaya emas: berbasis nilai item, naik per level tujuan. Diskon Enchanter aktif.
static func cost(item_id: String) -> int:
	var value := int(Db.item(item_id).get("value", 100))
	var target := PlayerData.gear_enchant(item_id) + 1
	var c := maxi(50, int(value * 0.06 * target))
	if ProfessionSystem.is_active("enchanter"):
		c = int(c * 0.7)
	return c

static func success_rate(item_id: String) -> float:
	var target: int = clampi(PlayerData.gear_enchant(item_id) + 1, 1, MAX_LEVEL)
	var r: float = RATES[target - 1]
	if ProfessionSystem.is_active("enchanter"):
		r += float(ProfessionSystem.perk_value("enchanter", "enchant_bonus"))
	return clampf(r, 0.05, 1.0)

## Returns {success, level, reason, protected}.
static func enchant(item_id: String, rng: RandomNumberGenerator = null) -> Dictionary:
	var gate := can_enchant(item_id)
	if not gate.ok:
		EventBus.toast.emit(gate.reason)
		return {"success": false, "level": PlayerData.gear_enchant(item_id), "reason": "gate"}
	if PlayerData.item_count(item_id) <= 0 and not _is_equipped(item_id):
		EventBus.toast.emit(Loc.t("enchant.not_owned"))
		return {"success": false, "level": 0, "reason": "not_owned"}
	var c := cost(item_id)
	if not PlayerData.spend_gold(c):
		EventBus.toast.emit(Loc.t("enchant.no_gold", [c]))
		return {"success": false, "level": PlayerData.gear_enchant(item_id), "reason": "gold"}

	var cur := PlayerData.gear_enchant(item_id)
	var target := cur + 1
	var roll := (rng.randf() if rng else randf())
	var meta: Dictionary = PlayerData.gear_meta.get(item_id, {})
	if roll < success_rate(item_id):
		meta["enchant"] = target
		PlayerData.gear_meta[item_id] = meta
		PlayerData.recalculate_stats()
		Audio.play_sfx("levelup" if target >= 7 else "success")
		EventBus.toast.emit(Loc.t("enchant.success", [Db.item_name(item_id), target]))
		return {"success": true, "level": target, "reason": "ok"}
	# GAGAL — tak pernah hancur (spec kunci). ≥+7 turun 1 kecuali gulungan menahan.
	var protected := false
	if target > SAFE_UNTIL:
		if PlayerData.item_count("protection_scroll") > 0:
			PlayerData.remove_item("protection_scroll", 1)
			protected = true
			EventBus.toast.emit(Loc.t("enchant.protected", [cur]))
		else:
			meta["enchant"] = maxi(0, cur - 1)
			PlayerData.gear_meta[item_id] = meta
			PlayerData.recalculate_stats()
			EventBus.toast.emit(Loc.t("enchant.fail_drop", [Db.item_name(item_id), meta["enchant"]]))
	else:
		EventBus.toast.emit(Loc.t("enchant.fail_safe", [cur]))
	Audio.play_sfx("fizzle")
	return {"success": false, "level": PlayerData.gear_enchant(item_id), "reason": "failed_roll", "protected": protected}

static func _is_equipped(item_id: String) -> bool:
	return item_id in [PlayerData.equipped_weapon, PlayerData.equipped_armor, PlayerData.equipped_accessory]
