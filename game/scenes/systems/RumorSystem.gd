class_name RumorSystem
extends RefCounted
## RUMOR TIDAK AKURAT (E5 / D025, Decision Log #77).
## Prinsip: **World Remembers TIDAK sempurna.** Dunia mengingat — tapi mulut manusia
## yang meneruskannya bisa keliru, membesar-besarkan, atau mengarang.
##   - gosip warga (Villager) BOLEH melenceng: tiap rumor punya `accuracy`;
##     roll gagal → dipilih satu `distortions`.
##   - rumor Penjaga Pohon (SkillTreeSystem) TETAP AKURAT — ia fungsional
##     (mengarahkan pemain ke lokasi pohon); sengaja dikecualikan.
##   - keajaiban (MiracleSystem) hanya diumumkan lewat gosip ini, keesokan harinya —
##     tak pernah lewat popup.

## Pilih satu rumor. Returns {text, accurate, id}.
static func speak(rng: RandomNumberGenerator = null) -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	# gosip keajaiban kemarin lebih menarik daripada rumor biasa (60%)
	var mir := MiracleSystem.yesterday()
	if not mir.is_empty() and rng.randf() < 0.6:
		return _from_miracle(mir, rng)
	if Db.rumors.is_empty():
		return {"text": "Tak ada yang menarik hari ini.", "accurate": true, "id": ""}
	var r: Dictionary = Db.rumors[rng.randi_range(0, Db.rumors.size() - 1)]
	return _roll(r, rng)

static func _roll(r: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var acc: float = float(r.get("accuracy", 0.7))
	var distort: Array = r.get("distortions", [])
	if rng.randf() < acc or distort.is_empty():
		return {"text": r.get("truth", ""), "accurate": true, "id": r.get("id", "")}
	return {"text": distort[rng.randi_range(0, distort.size() - 1)], "accurate": false, "id": r.get("id", "")}

static func _from_miracle(mir: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var def := MiracleSystem.def(mir.get("id", ""))
	var distort: Array = def.get("gossip_false", [])
	# keajaiban paling sering diceritakan MELENCENG (justru itu intinya)
	if rng.randf() < 0.45 or distort.is_empty():
		return {"text": def.get("gossip_true", ""), "accurate": true, "id": "miracle:" + str(mir.get("id", ""))}
	return {"text": distort[rng.randi_range(0, distort.size() - 1)], "accurate": false, "id": "miracle:" + str(mir.get("id", ""))}

## Rumor akurat by id (dipakai sistem fungsional yang TIDAK boleh berbohong).
static func truth(rumor_id: String) -> String:
	for r in Db.rumors:
		if r.get("id", "") == rumor_id:
			return r.get("truth", "")
	return ""
