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
## `speaker_id` (opsional): KEPRIBADIAN penutur mewarnai gosipnya (#138) —
##   Extraversion tinggi  → lebih bersemangat menceritakannya
##   Agreeableness rendah → versi yang lebih PEDAS & lebih sering menyimpang
##   Neuroticism tinggi   → nada cemas
## Ini menyambung langsung ke field `accuracy` (E5 #77): dunia mengingat, tapi
## orang yang menceritakannya punya watak — dan watak itu membelokkan cerita.
static func speak(rng: RandomNumberGenerator = null, speaker_id: String = "") -> Dictionary:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	if speaker_id != "":
		return _speak_as(speaker_id, rng)
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

## Gosip yang diwarnai kepribadian penutur.
static func _speak_as(speaker_id: String, rng: RandomNumberGenerator) -> Dictionary:
	var prof := Personality.of(speaker_id)
	var agree := Personality.trait_of(prof, "agreeableness")
	var extra := Personality.trait_of(prof, "extraversion")
	var neuro := Personality.trait_of(prof, "neuroticism")
	# 1) pilih rumor seperti biasa
	var base := speak(rng)
	# 2) AGREEABLENESS rendah → dorong ke versi menyimpang (lebih pedas)
	if agree < 40 and base.get("accurate", true) and rng.randf() < (40 - agree) / 60.0:
		var rid: String = base.get("id", "")
		for r in Db.rumors:
			if r.get("id", "") == rid and not r.get("distortions", []).is_empty():
				var d: Array = r["distortions"]
				base = {"text": d[rng.randi_range(0, d.size() - 1)], "accurate": false, "id": rid}
				break
	# 3) warna nada
	var txt: String = base.get("text", "")
	if neuro > 70 and rng.randf() < 0.5:
		txt = "(Suaranya menurun.) " + txt + " ...kau juga merasa tidak enak soal ini, kan?"
	elif extra > 75 and rng.randf() < 0.5:
		txt = "Dengar ini! " + txt
	elif agree < 35 and rng.randf() < 0.5:
		txt = txt + " Terserah kau percaya atau tidak."
	base["text"] = txt
	base["speaker"] = speaker_id
	return base
