extends SceneTree
## RANTAI §0 DIJALANKAN SEBAGAI PEMAIN — LANGKAH 7 (design-time, BUKAN test).
##
## Bedanya dengan `ShotKitab.gd`: harness itu memanggil fungsi Kitab langsung.
## Berkas ini tidak. Ia memuat `Ashbrook64.tscn` yang SEBENARNYA — pemain, HUD,
## MenuUI, WorldController — lalu:
##   * menekan tombol `interact` lewat `Input.parse_input_event()`, jadi
##     `WorldController._unhandled_input()` yang memutuskan apa yang terjadi,
##     bukan harness;
##   * menekan tombol Kitab lewat `emit_signal("pressed")` pada Button aslinya,
##     jadi callback yang jalan adalah callback yang dipasang UI.
## Kalau satu sambungan putus, ia putus di sini — bukan tersembunyi di balik
## panggilan langsung.
##
## SATU HAL YANG TIDAK DITIRU: berjalan kaki. Pemain di-WARP ke depan tiap
## titik-periksa, lalu tombolnya ditekan sungguhan. Yang diuji rantainya
## (jarak → interact → Evidence → Chronicle → Kitab), bukan pathfinding.
##
## `extends SceneTree`, bukan Node: driver harus SELAMAT dari `change_scene_to_file`.
## Node di dalam scene ikut dibebaskan; SceneTree tidak. Konsekuensinya autoload
## tak boleh disebut lewat nama global (belum terdaftar saat skrip dikompilasi) —
## semuanya lewat `root.get_node()`. Pelajaran yang sama dengan ShotKitab.gd,
## dari arah sebaliknya.
##
## Pakai:
##   set AETHER_PLAY_PATH=self|elyn|penuh
##   set AETHER_SHOT_DIR=D:\2DGAME\reports\preview
##   run_godot.bat --script res://tests/PlayLoop64.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const PAGE := "place_ashbrook_besar"

## Lima titik-periksa Ashbrook di koordinat petak-32, sesuai `Ashbrook64.gd`.
## Diklaim ada oleh langkah sebelumnya — LANGKAH 7 membuktikannya dengan berdiri
## di depan tiap titik dan menekan E.
const POINTS := [
	["ev_ashbrook_gudang_gandum", Vector2(704, 480)],
	["ev_ashbrook_halloran_200_roti", Vector2(1216, 560)],
	["ev_ashbrook_jembatan_terlalu_lebar", Vector2(1856, 704)],
	["ev_ashbrook_fondasi_rumput", Vector2(1504, 1056)],
	["ev_ashbrook_batu_fondasi", Vector2(800, 856)],
]

var _dir := ""
var _path := "self"
var _t := 0.0
var _step := 0
var _pending := ""
## Satu langkah kadang butuh DUA putaran: tekan tombol di putaran pertama, periksa
## akibatnya di putaran kedua. Lihat catatan di `_press()`.
var _sub := 0
var _log: Array = []
var _fail := ""

var _ws: Node
var _pd: Node
var _ch: Node
var _ev: Node
var _stage: Node


func _initialize() -> void:
	_dir = OS.get_environment("AETHER_SHOT_DIR")
	if _dir == "":
		_dir = "user://"
	_path = OS.get_environment("AETHER_PLAY_PATH")
	if _path == "":
		_path = "self"


func _auto() -> void:
	_ws = root.get_node("WorldState")
	_pd = root.get_node("PlayerData")
	_ch = root.get_node("Chronicle")
	_ev = root.get_node("Evidence")
	_stage = root.get_node("Stage")


func _say(s: String) -> void:
	_log.append(s)
	print("[main] ", s)


func _bad(s: String) -> void:
	if _fail == "":
		_fail = s
	_say("PUTUS: " + s)


## Cari titik-periksa DI SCENE, jangan percaya tabel.
##
## ⚠ Tabel `POINTS` membeku di tata letak sebelum B'. Tiga koordinatnya berpindah
##   (gudang, roti Halloran, fondasi rumput) dan harness melaporkan RANTAI PUTUS —
##   padahal yang putus cuma tabelnya: pemain di-warp ke rumput kosong lalu menekan
##   E di depan ketiadaan. Persis tiga yang pindah gagal, dua yang tak pindah lolos;
##   korelasi sesempurna itu tanda tabelnya yang salah, bukan dunianya.
##   Membaca dari node membuat gerbang ini kebal terhadap tata ulang berikutnya.
##   Tabel tetap jadi cadangan supaya node yang HILANG tetap berteriak.
func _posisi_bukti(eid: String, cadangan: Vector2) -> Vector2:
	var scn = root.get_tree().current_scene
	if scn:
		for c in scn.get_children():
			if c.get("evidence_id") != null and String(c.get("evidence_id")) == eid:
				return c.global_position
	push_warning("[main] titik-periksa '%s' TAK ADA di scene — pakai cadangan" % eid)
	return cadangan


func _player() -> Node2D:
	return root.get_tree().get_first_node_in_group("player")


func _menu() -> Node:
	return root.get_tree().get_first_node_in_group("inventory_ui")


## Tekan TOMBOL seperti pemain — InputEventKey, bukan InputEventAction.
##
## Dua alasan, keduanya ditemukan dengan cara yang mahal:
##  1. `Stage._input()` memeriksa `event.keycode` mentah (E/Space/Enter) untuk
##     menutup teks periksa. InputEventAction tak punya keycode, jadi teksnya
##     tak pernah tertutup — dan `Interactable.interact()` diawali
##     `if Stage.is_busy(): return`. Akibatnya HANYA titik pertama yang tercatat,
##     empat sisanya melapor "tak terjangkau" padahal baik-baik saja.
##  2. Peta input memakai `physical_keycode`. Keduanya diisi supaya jalur aksi
##     (WorldController) dan jalur keycode mentah (Stage) sama-sama cocok.
##
## ⚠ TIDAK LANGSUNG: event masuk antrean, baru sampai ke `_unhandled_input()` pada
## putaran berikutnya. Memeriksa akibatnya di baris setelah menekan selalu membaca
## keadaan SEBELUM tombol bekerja. Karena itu tiap penekanan dipecah dua putaran
## (`_sub`).
const KEY_E := 69
const KEY_I := 73

func _key(code: int, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = down
	Input.parse_input_event(e)


## Cari Button menurut teksnya di seluruh MenuUI, lalu picu sinyal `pressed` —
## sinyal yang sama yang dipancarkan klik tetikus.
func _click(fragment: String) -> bool:
	var m := _menu()
	if m == null:
		return false
	var found := _find_button(m, fragment)
	if found == null:
		return false
	found.emit_signal("pressed")
	return true


func _find_button(n: Node, fragment: String) -> Button:
	if n is Button and String(n.text).contains(fragment):
		return n
	for c in n.get_children():
		var r := _find_button(c, fragment)
		if r != null:
			return r
	return null


func _label_exists(n: Node, fragment: String) -> bool:
	if n is Label and String(n.text).contains(fragment):
		return true
	for c in n.get_children():
		if _label_exists(c, fragment):
			return true
	return false


func _shot(tag: String) -> void:
	var img := root.get_texture().get_image()
	if img == null:
		_bad("viewport kosong")
		return
	var p := _dir.path_join("7_main_%s_%s.png" % [_path, tag])
	if img.save_png(p) != OK:
		_bad("gagal simpan %s" % p)
		return
	print("[main] shot ", p)


func _process(delta: float) -> bool:
	_t += delta
	if _pending != "":
		if _t < 0.35:
			return false
		_shot(_pending)
		_pending = ""
		_t = 0.0
		return false
	if _t < 0.3:
		return false
	_t = 0.0
	return _run(_step)


## Mesin langkah. Tiap cabang menetapkan `_step` BERIKUTNYA secara eksplisit,
## tak ada `_step += 1` di ekor: jalur SENDIRI melompati dua layar yang hanya
## dipunyai jalur Elyn, dan increment diam-diam membuat lompatan itu salah arah.
func _run(step: int) -> bool:
	match step:
		0:
			_auto()
			# Persis yang dilakukan CharacterCreator sebelum Intro: dunia baru.
			# Halaman Ashbrook lahir dari `_ensure_world_pages()` DAN langsung
			# tercoret — pemain tak diberi tahu apa pun (D-3).
			_pd.new_game()
			_ws.new_game()
			if not _ch.has(PAGE):
				_bad("halaman %s tak lahir dari new_game()" % PAGE)
			elif _ch.state_of(PAGE) != "struck":
				_bad("halaman lahir tapi TIDAK tercoret (state=%s)" % _ch.state_of(PAGE))
			else:
				_say("halaman lahir + tercoret senyap, by=%s" % _ch._find(PAGE).get("by", "?"))
			if change_scene_to_file(SCENE) != OK:
				_bad("gagal memuat %s" % SCENE)
				return _finish()
			_step = 1
		1:
			if _player() == null:
				_bad("Ashbrook64 tanpa pemain — grup \"player\" kosong")
				return _finish()
			if _menu() == null:
				_bad("Ashbrook64 tanpa MenuUI — grup \"inventory_ui\" kosong")
				return _finish()
			_say("scene hidup: pemain ada, MenuUI ada, %d interactable"
				% root.get_tree().get_nodes_in_group("interactable").size())
			_pending = "01_tiba"
			_step = 2
		2, 3, 4, 5, 6:
			var idx := step - 2
			var eid: String = POINTS[idx][0]
			var pos: Vector2 = _posisi_bukti(eid, POINTS[idx][1])
			if _sub == 0:
				_player().global_position = pos + Vector2(0, 28)   # berdiri di depannya
				_key(KEY_E, true)
				_sub = 1
				return false                                       # biarkan event sampai
			_key(KEY_E, false)
			if _stage.is_busy():
				_key(KEY_E, true)      # tutup teks periksa, persis seperti pemain
				return false           # tetap di _sub 1 sampai panggungnya sepi
			_sub = 0
			if not _ev.has(eid):
				_bad("titik %s tak terjangkau: E ditekan di depannya, bukti tak tercatat" % eid)
			else:
				_say("periksa %s → tercatat" % eid)
			if idx == 4:
				var kinds: Array = _ev.kinds_for(PAGE)
				_say("jenis terkumpul: %s" % str(kinds))
				if kinds.size() < 3:
					_bad("hanya %d jenis dari 5 titik — SENDIRI mustahil" % kinds.size())
				_pending = "02_bukti"
			_step = step + 1
		7:
			if _sub == 0:
				if _path == "penuh":
					# #257 — ruang pemain diisi lebih dulu; yang diuji layarnya.
					while not _pd.memory_full():
						_pd.memory_held.append("isi_%d" % _pd.memory_held.size())
					_say("ruang ingatan DIPENUHI sebelum menulis")
				_key(KEY_I, true)
				_sub = 1
				return false
			_key(KEY_I, false)
			_sub = 0
			var m := _menu()
			if m == null or not m.root.visible:
				_bad("tombol tas ditekan, menu tidak terbuka")
				return _finish()
			if not _click("Kitab"):
				_bad("tab Kitab tak ada di MenuUI")
				return _finish()
			_pending = "03_kitab_tercoret"
			_step = 8
		8:
			if not _label_exists(_menu(), "Ashbrook"):
				_bad("halaman tercoret tak muncul di Kitab")
			if not _click("Tulis ulang"):
				_bad("tombol \"Tulis ulang\" tak muncul walau 3 jenis bukti ada")
				return _finish()
			_pending = "04_pilih_jalur"
			_step = 9
		9:
			if _path == "elyn":
				if not _click("Biarkan Elyn menanggung"):
					_bad("jalur ELYN tak ditawarkan")
					return _finish()
				_pending = "05_keterbukaan_elyn"
				_step = 10
			else:
				if not _click("Simpan sendiri"):
					_bad("jalur SENDIRI tak ditawarkan")
					return _finish()
				_pending = "05_penolakan" if _path == "penuh" else "05_tulis_sendiri"
				_step = 10 if _path == "penuh" else 12
		10:
			if _path == "penuh":
				# Penolakan harus tampil, dan Elyn harus TETAP tersedia di layar itu.
				if _ch.state_of(PAGE) != "struck":
					_bad("ruang penuh tapi halaman tetap ditulis — #257 bocor")
				if not _label_exists(_menu(), "tak sanggup memikul"):
					_bad("penolakan ruang penuh tak tampil")
				if not _click("Biarkan Elyn menanggung"):
					_bad("Elyn TIDAK tersedia saat ruang penuh — #228 dilanggar")
					return _finish()
				_pending = "06_elyn_tetap_ada"
				_step = 11
			else:
				# #259 — keterbukaan harus tampil SEBELUM halaman ditulis.
				if _ch.state_of(PAGE) != "struck":
					_bad("Elyn menulis SEBELUM keterbukaan ditampilkan — #259 dilanggar")
				if not _label_exists(_menu(), "Umurnya berkurang"):
					_bad("layar keterbukaan Elyn tak tampil")
				if not _click("[ Biarkan Elyn menanggung ]"):
					_bad("konfirmasi Elyn tak ada")
					return _finish()
				_step = 12
		11:
			if not _label_exists(_menu(), "Umurnya berkurang"):
				_bad("keterbukaan Elyn tak tampil di jalur ruang-penuh")
			if not _click("[ Biarkan Elyn menanggung ]"):
				_bad("konfirmasi Elyn tak ada di jalur ruang-penuh")
				return _finish()
			_step = 12
		12:
			var st: String = _ch.state_of(PAGE)
			if st != "restored":
				_bad("halaman TIDAK pulih setelah jalur %s (state=%s)" % [_path, st])
				return _finish()
			var e: Dictionary = _ch._find(PAGE)
			_say("pulih: scribe=%s loss=%s" % [e.get("scribe", ""), e.get("loss", "")])
			if String(e.get("loss", "")) == "":
				_bad("halaman pulih tanpa loss — #226 #3 dilanggar")
			if _path == "self" and not (PAGE in _pd.memory_held):
				_bad("SENDIRI berhasil tapi ruang ingatan pemain tak terisi")
			if _path in ["elyn", "penuh"]:
				if not (PAGE in _pd.elyn_burden):
					_bad("ELYN berhasil tapi beban Elyn tak bertambah")
				if int(_pd.elyn_age_spent) <= 0:
					_bad("ELYN berhasil tapi umurnya tak berkurang")
				_say("beban Elyn=%s umur terpakai=%d" % [str(_pd.elyn_burden), _pd.elyn_age_spent])
			if not _label_exists(_menu(), "dipulihkan dari kesaksian"):
				_bad("halaman pulih tak ditandai \"dipulihkan dari kesaksian\"")
			_pending = "08_pulih_loss"
			_step = 13
		13:
			# Kembali ke dunia: lentera Merrit menyala di depan halaman yang kini pulih.
			var m2 := _menu()
			if m2:
				m2.close_menu()
			_pending = "09_kembali_ke_dunia"
			_step = 14
		14:
			return _finish()
	return false


func _finish() -> bool:
	print("\n===== RANTAI §0 — jalur %s =====" % _path)
	for l in _log:
		print("  ", l)
	if _fail == "":
		print("HASIL: rantai UTUH")
	else:
		print("HASIL: PUTUS — %s" % _fail)
	quit(0 if _fail == "" else 1)
	return true
