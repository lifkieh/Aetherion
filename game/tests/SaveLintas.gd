extends Node
## SAVE/LOAD LINTAS-SESI — harness (design-time, BUKAN test suite).
##
## Suite sudah menguji `to_save()`/`from_save()` di dalam SATU proses. Yang belum:
## menulis ke DISK, menutup proses, lalu memuatnya di proses BARU. Itu jalur yang
## dipakai pemain, dan ia melewati `SaveManager` (tulis atomik, rotasi cadangan,
## `schema_version`) — bagian yang tak tersentuh uji dalam-memori.
##
## Tiga fase, masing-masing PROSES SENDIRI:
##   AETHER_SAVE_PHASE=tulis  — dunia baru, isi ruang-ingatan, simpan slot 2
##   AETHER_SAVE_PHASE=muat   — proses baru, muat slot 2, periksa isinya
##   AETHER_SAVE_PHASE=lama   — turunkan slot 2 ke schema 2 di disk, muat, periksa migrasi
##   AETHER_SAVE_PHASE=rute   — #274: save dua wilayah berbeda + lokasi usang -> tujuan benar
##
## Pakai: run_godot.bat res://tests/SaveLintas.tscn

const SLOT := 2

var _t := 0.0
var _done := false


func _process(delta: float) -> void:
	if _done:
		return
	_t += delta
	if _t < 0.5:            # beri autoload waktu siap
		return
	_done = true
	match OS.get_environment("AETHER_SAVE_PHASE"):
		"tulis": _tulis()
		"muat": _muat()
		"lama": _lama()
		"rute": _rute()
		_: print("[save] AETHER_SAVE_PHASE tak dikenal")
	get_tree().quit(0)


func _ok(label: String, cond: bool, detail: String = "") -> void:
	print("  [%s] %s%s" % ["PASS" if cond else "FAIL", label,
		"" if detail == "" else "  " + detail])


func _tulis() -> void:
	print("[save] FASE TULIS — schema %d" % PlayerData.SAVE_SCHEMA)
	PlayerData.new_game()
	WorldState.new_game()
	PlayerData.char_name = "UjiLintas"
	PlayerData.memory_held = ["place_ashbrook_besar"]
	PlayerData.elyn_burden = ["person_otha_renn"]
	PlayerData.elyn_age_spent = 120          # 134+120 = 254 -> prima_akhir (#268)
	Chronicle.record_person("person_uji_lintas", "Uji Lintas Sesi", "merrit_fane")
	Chronicle.strike("person_uji_lintas")
	var ok := SaveManager.save_game(SLOT, true)
	_ok("save_game(%d) berhasil" % SLOT, ok)
	_ok("tahap Elyn sebelum tutup = prima_akhir", PlayerData.elyn_stage() == "prima_akhir",
		PlayerData.elyn_stage())


func _muat() -> void:
	print("[save] FASE MUAT — proses baru")
	PlayerData.new_game()                     # pastikan state bersih dulu
	WorldState.new_game()
	var ok := SaveManager.load_game(SLOT)
	_ok("load_game(%d) berhasil" % SLOT, ok)
	_ok("nama pulih", PlayerData.char_name == "UjiLintas", PlayerData.char_name)
	_ok("memory_held pulih", PlayerData.memory_held == ["place_ashbrook_besar"],
		str(PlayerData.memory_held))
	_ok("elyn_burden pulih", PlayerData.elyn_burden == ["person_otha_renn"],
		str(PlayerData.elyn_burden))
	_ok("elyn_age_spent pulih", PlayerData.elyn_age_spent == 120,
		str(PlayerData.elyn_age_spent))
	# #268 — tahap hidup harus ikut pulih, bukan dihitung ulang dari nol
	_ok("tahap Elyn pulih = prima_akhir", PlayerData.elyn_stage() == "prima_akhir",
		PlayerData.elyn_stage())
	_ok("halaman tercoret ikut pulih",
		Chronicle.state_of("person_uji_lintas") == Chronicle.ST_STRUCK,
		Chronicle.state_of("person_uji_lintas"))
	_ok("halaman Ashbrook tetap ada (idempoten _ensure_world_pages)",
		Chronicle.has("place_ashbrook_besar"))


## Turunkan berkas save di DISK ke schema 2: buang tiga medan ruang-ingatan.
## Ini meniru save pemain lama yang dibuat sebelum #256.
func _lama() -> void:
	print("[save] FASE LAMA — migrasi schema 2 -> 3 dari disk")
	var path := "user://save/slot_%d.json" % SLOT
	if not FileAccess.file_exists(path):
		_ok("berkas save ada", false, path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	var raw := f.get_as_text()
	f.close()
	var data = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		_ok("save terbaca sebagai JSON", false)
		return
	var pl: Dictionary = data.get("player", {})
	pl.erase("memory_held")
	pl.erase("elyn_burden")
	pl.erase("elyn_age_spent")
	pl["save_schema"] = 2
	data["player"] = pl
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(data))
	w.close()
	_ok("save diturunkan ke schema 2 di disk", true)

	PlayerData.new_game()
	WorldState.new_game()
	var ok := SaveManager.load_game(SLOT)
	_ok("save LAMA tetap bisa dimuat (nol crash)", ok)
	_ok("memory_held default KOSONG", PlayerData.memory_held.is_empty(),
		str(PlayerData.memory_held))
	_ok("elyn_burden default KOSONG", PlayerData.elyn_burden.is_empty(),
		str(PlayerData.elyn_burden))
	_ok("elyn_age_spent default 0", PlayerData.elyn_age_spent == 0,
		str(PlayerData.elyn_age_spent))
	# pemain lama harus mulai dari tahap paling awal, bukan tahap acak
	_ok("tahap Elyn save lama = prima", PlayerData.elyn_stage() == "prima",
		PlayerData.elyn_stage())
	_ok("memory_full() tidak meledak di save lama", PlayerData.memory_full() == false)
	_ok("nama tetap pulih dari save lama", PlayerData.char_name == "UjiLintas",
		PlayerData.char_name)


# ══════════════════════════════════════════════════════════════════════════════
# #274 — ROUTING SAVE: muat ke tempat ia disimpan
# ══════════════════════════════════════════════════════════════════════════════
#
# Cacat pra-ada: `_load()` mengeraskan Main.tscn, jadi SETIAP save mendarat di
# Greenvale. Bukan cuma Ashbrook64 — semua wilayah.
#
# Fase ini menulis save dengan `location` berbeda-beda LANGSUNG ke disk (menirukan
# menyimpan di wilayah itu), lalu memeriksa ke mana `SaveManager.scene_for_slot()`
# akan mengarahkan. Tak perlu benar-benar memuat scene-nya: yang diuji **keputusan
# rute**, dan memuat enam scene cuma memperlambat tanpa menambah bukti.

const RUTE_SLOT := 3

func _tulis_lokasi(loc: String) -> void:
	PlayerData.new_game()
	WorldState.new_game()
	PlayerData.char_name = "Rute_" + loc
	SaveManager.save_game(RUTE_SLOT, true)
	# `build_payload()` mengambil lokasi dari current_scene, dan harness ini bukan
	# scene wilayah — jadi lokasinya ditulis langsung, meniru save dari wilayah itu.
	var path := "user://save/slot_%d.json" % RUTE_SLOT
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	data["location"] = loc
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(data))
	w.close()


func _rute() -> void:
	print("[save] FASE RUTE (#274) — muat ke tempat ia disimpan")

	# --- dua wilayah berbeda, keduanya harus mendarat di tempatnya sendiri ---
	for pair in [["Candyveil", "res://scenes/world/Candyveil.tscn"],
			["Ashbrook64", "res://scenes/world/Ashbrook64.tscn"],
			["Frostpeak", "res://scenes/world/Frostpeak.tscn"],
			["Main", "res://scenes/Main.tscn"]]:
		_tulis_lokasi(pair[0])
		var got := SaveManager.scene_for_slot(RUTE_SLOT)
		_ok("save di %s -> %s" % [pair[0], pair[1]], got == pair[1], got)
		_ok("  meta.location terbaca utuh",
			String(SaveManager.save_meta(RUTE_SLOT).get("location", "")) == pair[0])

	# --- lapis 2: scene yang TAK ADA (wilayah diganti nama / dihapus) ---
	_tulis_lokasi("scene_tak_ada")
	var fb := SaveManager.scene_for_slot(RUTE_SLOT)
	_ok("lokasi usang -> fallback Greenvale (nol crash)",
		fb == SaveManager.SCENE_FALLBACK, fb)
	_ok("save berlokasi usang TETAP bisa dimuat", SaveManager.load_game(RUTE_SLOT))

	# --- lapis 1: save sangat lama, tanpa medan lokasi sama sekali ---
	_tulis_lokasi("Candyveil")
	var path := "user://save/slot_%d.json" % RUTE_SLOT
	var f := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	data.erase("location")
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_string(JSON.stringify(data))
	w.close()
	_ok("tanpa medan lokasi -> Greenvale (perilaku lama dijaga)",
		SaveManager.scene_for_slot(RUTE_SLOT) == SaveManager.SCENE_FALLBACK)

	# --- penyelesai itu sendiri, tanpa berkas ---
	_ok("string kosong -> fallback",
		SaveManager.scene_for_location("") == SaveManager.SCENE_FALLBACK)
	_ok("\"?\" -> fallback",
		SaveManager.scene_for_location("?") == SaveManager.SCENE_FALLBACK)
	_ok("spasi berlebih tetap terselesaikan",
		SaveManager.scene_for_location("  Candyveil  ") == "res://scenes/world/Candyveil.tscn")
	_ok("Homestead (di luar world/) terselesaikan",
		SaveManager.scene_for_location("Homestead") == "res://scenes/homestead/Homestead.tscn")
