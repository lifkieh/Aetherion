class_name RasiSystem
extends RefCounted
## 12 RASI AGUNG (Addendum A5, Decision Log #91) — aset 12 rasi akhirnya dipakai.
## Pilar (Hukum #1): **WONDER** (langit punya suara: rasi naik berganti tiap minggu
## nyata, ramalannya = teka-teki yang menunjuk konten yang benar-benar aktif minggu
## itu) + **LEGACY ringan** (rasi kelahiran = jejak tanggal kau memulai).
## Bonus rasi kelahiran sengaja KECIL (2–3%): identitas, bukan power spike.

static func all() -> Array:
	return Db.rasi

static func by_id(id: String) -> Dictionary:
	for r in Db.rasi:
		if r.get("id", "") == id:
			return r
	return {}

## Rasi kelahiran pemain (dari bulan pembuatan karakter; PlayerData.birth_sign
## menyimpan NAMA-nya).
static func birth() -> Dictionary:
	var n: String = PlayerData.birth_sign
	for r in Db.rasi:
		if r.get("name", "") == n:
			return r
	return {}

## RASI NAIK: berganti tiap minggu nyata — langit yang sama untuk semua pemain.
static func ascendant() -> Dictionary:
	if Db.rasi.is_empty():
		return {}
	return Db.rasi[GameClock.week_index() % Db.rasi.size()]

## Bonus tematik rasi kelahiran (kecil). Dibaca PlayerData.recalculate_stats.
static func birth_bonus(field: String) -> float:
	var b: Dictionary = birth().get("bonus", {})
	if b.get("field", "") == field:
		# Trial of the Rasi (#101) menggandakan bonus rasi kelahiran
		return float(b.get("value", 0.0)) * AdvancedClass.rasi_multiplier()
	return 0.0

## Ramalan mingguan: teka-teki rasi naik + kaitan ke konten yang AKTIF minggu ini
## (skenario tersembunyi yang memenuhi syarat, keajaiban semalam, musim berjalan).
static func weekly_prophecy() -> String:
	var asc := ascendant()
	if asc.is_empty():
		return "Langit sunyi minggu ini."
	var lines: Array = ["\"%s\"" % asc.get("riddle", "")]
	var mir := MiracleSystem.yesterday()
	if not mir.is_empty():
		var d := MiracleSystem.def(mir.get("id", ""))
		lines.append("Langit semalam bergerak. Warga membicarakannya — sebagian keliru.")
		if d.get("name", "") != "":
			lines.append("(%s)" % d.get("name", ""))
	var scs: Array = Db.scenarios.filter(func(s): return s.has("hint"))
	if not scs.is_empty():
		var pick: Dictionary = scs[GameClock.week_index() % scs.size()]
		lines.append("Bisikan lain: \"%s\"" % pick.get("hint", ""))
	return "\n".join(lines)
