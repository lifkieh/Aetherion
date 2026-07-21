extends SceneTree
## MAIN SEBAGAI PEMAIN NYATA — dari boot, dengan WASD. Bukan warp, bukan harness-jalan-pintas.
##
## Bedanya dengan `PlayLoop64.gd`: harness itu MEMINDAHKAN pemain ke tiap titik.
## Berkas ini **berjalan ke sana** — tombol arah sungguhan lewat `Input.parse_input_event`,
## `Player._physics_process` yang menggerakkannya, dan tabrakan yang sama yang dirasakan
## pemain. Kalau sebuah titik terhalang tembok, ia GAGAL di sini dan lolos di sana.
##
## Boot pun lewat menu sungguhan: Main Baru → Class → Creator → Intro → Ashbrook64.
##
## `extends SceneTree` supaya selamat dari `change_scene_to_file` (lima kali).
## Autoload lewat `root.get_node()`, bukan nama global — MainLoop dikompilasi sebelum
## autoload terdaftar.
##
## Pakai: run_godot.bat --script res://tests/PlayWalk64.gd

const KEY_W := 87
const KEY_A := 65
const KEY_S := 83
const KEY_D := 68
const KEY_E := 69
const KEY_I := 73
const KEY_ENTER := 4194309
const KEY_ESC := 4194305

## Titik-periksa Ashbrook64 — target BERJALAN, bukan tujuan warp.
##
## ⚠ DISEGARKAN. Angka-angka di sini membeku di tata letak SEBELUM B'. Sesudah tata
## ulang tak satu pun masih benar, dan akibatnya BERANTAI: pejalan tak pernah sampai
## ke papan Otha -> halaman `person_otha_renn` tak pernah tercoret -> pemeriksaan
## "jendela Otha gelap" ikut gagal, belasan langkah jauhnya dari sebabnya. Gerbang
## yang melaporkan kegagalan palsu akan diabaikan, dan sesudah itu kegagalan
## SUNGGUHAN ikut diabaikan bersamanya.
##
## Koordinat diambil dari petak berpijak yang sudah dibuktikan `CekJangkau.gd`,
## bukan dikarang ulang. Urutannya menaik dari titik lahir (gerbang selatan) karena
## pejalan di sini TAK punya pencarian jalur — urutan melompat menghasilkan
## kegagalan yang bukan kegagalan peta. Rantai naratifnya sendiri tak bergantung
## urutan: Chronicle mencatat apa pun yang ditemukan lebih dulu.
const TITIK := [
	# ⚠ Sasarannya TITIK-PERIKSA ITU SENDIRI, bukan petak berpijak di sebelahnya.
	#   `_melangkah()` berhenti pada jarak 40 px; kalau sasarannya sudah digeser 20 px
	#   dari buktinya, jarak akhir bisa mencapai 60 px — di luar radius interaksi 48,
	#   dan E ditekan tanpa apa pun dalam jangkauan. Menuju buktinya langsung membuat
	#   40 px selalu lebih kecil daripada 48.
	["1 papan Otha", Vector2(1252, 752), "ev_otha_papan_bekas_cat"],
	["2 jembatan", Vector2(1856, 704), "ev_ashbrook_jembatan_terlalu_lebar"],
	["3 roti Halloran", Vector2(1310, 500), "ev_ashbrook_halloran_200_roti"],
	["4 batu fondasi", Vector2(800, 856), "ev_ashbrook_batu_fondasi"],
	["5 gudang gandum", Vector2(578, 490), "ev_ashbrook_gudang_gandum"],
	["6 fondasi rumput", Vector2(322, 462), "ev_ashbrook_fondasi_rumput"],
]

var _dir := ""
var _step := 0
var _t := 0.0
var _sub := 0
var _log: Array = []
var _fail := 0
var _pass := 0

var _pd: Node
var _ch: Node
var _ev: Node
var _gc: Node
var _stage: Node

# --- keadaan jalan ---
var _target := Vector2.ZERO
var _walk_t := 0.0
var _walk_from := Vector2.ZERO
# --- anti-sangkut: pejalan ini tak punya pencarian jalur ---
var _sangkut_t := 0.0
var _sangkut_pos := Vector2.ZERO
var _samping := 0.0        # sisa detik melangkah menyamping
var _samping_arah := 1.0
var _shot_pending := ""


func _initialize() -> void:
	_dir = OS.get_environment("AETHER_SHOT_DIR")
	if _dir == "":
		_dir = "user://"


func _auto() -> void:
	_pd = root.get_node("PlayerData")
	_stage = root.get_node("Stage")
	_ch = root.get_node("Chronicle")
	_ev = root.get_node("Evidence")
	_gc = root.get_node("GameClock")


func ok(label: String, cond: bool, detail: String = "") -> void:
	if cond: _pass += 1
	else: _fail += 1
	var line := "  [%s] %s%s" % ["PASS" if cond else "FAIL", label,
		"" if detail == "" else "  -> " + detail]
	_log.append(line)
	print(line)


func _key(code: int, down: bool) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = down
	Input.parse_input_event(e)


func _lepas_semua() -> void:
	for k in [KEY_W, KEY_A, KEY_S, KEY_D]:
		_key(k, false)


func _player() -> Node2D:
	return root.get_tree().get_first_node_in_group("player")


func _menu() -> Node:
	return root.get_tree().get_first_node_in_group("inventory_ui")


func _tombol(n: Node, frag: String) -> Button:
	if n is Button and String(n.text).contains(frag):
		return n
	for c in n.get_children():
		var r := _tombol(c, frag)
		if r != null:
			return r
	return null


func _klik(frag: String) -> bool:
	var b := _tombol(root, frag)
	if b == null:
		return false
	b.emit_signal("pressed")
	return true


func _shot(tag: String) -> void:
	var img := root.get_texture().get_image()
	if img == null:
		return
	var p := _dir.path_join("12_jalan_%s.png" % tag)
	img.save_png(p)
	print("[shot] ", p)


## Satu langkah jalan: tekan tombol arah menuju target. Dipanggil tiap putaran.
## Mengembalikan true bila sudah sampai (atau menyerah).
func _melangkah(delta: float) -> bool:
	var p := _player()
	if p == null:
		return true
	var d: Vector2 = _target - p.global_position
	if d.length() < 40.0:
		_lepas_semua()
		return true
	_walk_t += delta
	# 45 detik, naik dari 30. Pejalan ini tak punya pencarian jalur: ia menekan
	# tombol ke ARAH sasaran dan tersangkut di tiap sudut bangunan. Keterjangkauan
	# sebenarnya dibuktikan `CekJalur.gd` (banjir BFS atas kotak padat); di sini
	# jatah waktu cuma perlu cukup longgar supaya tersangkut sesaat tak dilaporkan
	# sebagai peta yang terputus.
	if _walk_t > 45.0:
		_lepas_semua()
		return true
	# ── ANTI-SANGKUT ────────────────────────────────────────────────────────
	# Menekan tombol lurus ke sasaran membuat pejalan menempel di sudut bangunan
	# pertama yang memotong garis pandang, lalu diam di sana sampai jatah waktu
	# habis — dan itu dilaporkan sebagai "peta terputus" padahal manusia cukup
	# melangkah satu langkah ke samping. `CekJalur.gd` sudah membuktikan tiap titik
	# TERJANGKAU; yang kurang di sini cuma kemampuan memutar.
	#
	# Bukan pencarian jalur, dan sengaja bukan: kalau tersangkut lebih dari 1,2
	# detik, ia melangkah TEGAK LURUS arah sasaran selama 0,7 detik lalu mencoba
	# lagi, berganti sisi tiap kali. Cukup untuk melewati sudut; terlalu bodoh untuk
	# menyembunyikan halangan yang sungguhan.
	if _samping > 0.0:
		_samping -= delta
		var tegak := Vector2(-d.normalized().y, d.normalized().x) * _samping_arah
		_key(KEY_D, tegak.x > 0.4)
		_key(KEY_A, tegak.x < -0.4)
		_key(KEY_S, tegak.y > 0.4)
		_key(KEY_W, tegak.y < -0.4)
		return false
	if p.global_position.distance_to(_sangkut_pos) < 4.0:
		_sangkut_t += delta
		if _sangkut_t > 1.2:
			_sangkut_t = 0.0
			_samping = 0.7
			_samping_arah = -_samping_arah
			_lepas_semua()
			return false
	else:
		_sangkut_t = 0.0
		_sangkut_pos = p.global_position
	_key(KEY_D, d.x > 8.0)
	_key(KEY_A, d.x < -8.0)
	_key(KEY_S, d.y > 8.0)
	_key(KEY_W, d.y < -8.0)
	return false


func _mulai_jalan(t: Vector2) -> void:
	_target = t
	_walk_t = 0.0
	_sangkut_t = 0.0
	_samping = 0.0
	_sangkut_pos = Vector2.ZERO
	_walk_from = _player().global_position if _player() else Vector2.ZERO


func _process(delta: float) -> bool:
	_t += delta
	if _shot_pending != "":
		if _t < 0.4:
			return false
		_shot(_shot_pending)
		_shot_pending = ""
		_t = 0.0
		return false
	return _jalankan(delta)


func _jalankan(delta: float) -> bool:
	match _step:
		0:
			if _t < 0.6: return false
			_auto()
			print("\n===== BOOT LEWAT MENU SUNGGUHAN =====")
			change_scene_to_file("res://scenes/ui/MainMenu.tscn")
			_lanjut()
		1:
			if _t < 1.0: return false
			ok("MainMenu termuat", _tombol(root, "Main Baru") != null)
			ok("tombol Main Baru ditekan", _klik("Main Baru"))
			_lanjut()
		2:
			if _t < 1.2: return false
			ok("ClassSelect termuat", _tombol(root, "Lanjut") != null)
			# pilih class pertama yang tersedia lalu lanjut
			_klik("Warrior")
			ok("lanjut ke Creator", _klik("Lanjut"))
			_lanjut()
		3:
			if _t < 1.2: return false
			ok("CharacterCreator termuat", _tombol(root, "Mulai Petualangan") != null)
			ok("mulai petualangan", _klik("Mulai Petualangan"))
			_lanjut()
		4:
			if _t < 1.2: return false
			# Intro: Esc = lewati
			_key(KEY_ESC, true); _key(KEY_ESC, false)
			_lanjut()
		5:
			if _t < 2.5: return false
			var scn = root.get_tree().current_scene
			var nama: String = String(scn.name) if scn else "?"
			ok("scene aktif = Ashbrook64 (64px yang dimuat)", nama == "Ashbrook64", nama)
			ok("pemain ada", _player() != null)
			if _player():
				var sp: Vector2 = _player().global_position
				# ⚠ LAHIR DI GERBANG SELATAN, bukan di pintu Merrit. Harapan lama
				#   membeku sebelum spec D4 dijalankan; sekarang langkah pertama
				#   pemain menghadap utara dari gerbang, dan itu memang maksudnya.
				ok("lahir di gerbang selatan", sp.distance_to(Vector2(960, 1194)) < 140.0, str(sp))
			ok("halaman place_ashbrook_besar TERCORET saat tiba",
				_ch.state_of("place_ashbrook_besar") == "struck",
				_ch.state_of("place_ashbrook_besar"))
			_shot_pending = "01_tiba"
			_lanjut()
		6, 7, 8, 9, 10, 11:
			var i := _step - 6
			if _sub == 0:
				_mulai_jalan(TITIK[i][1])
				_sub = 1
				return false
			if not _melangkah(delta):
				return false
			var p := _player()
			var jarak: float = p.global_position.distance_to(TITIK[i][1])
			ok("BERJALAN sampai %s" % TITIK[i][0], jarak < 60.0, "sisa %.0f px" % jarak)
			_sub = 0
			_lanjut()
		12:
			# tekan E di titik terakhir sekadar bukti interaksi jalan kaki bekerja
			_key(KEY_E, true)
			_lanjut()
		13:
			_key(KEY_E, false)
			# ⚠ TUTUP PANELNYA. Begitu E berhasil, teks periksa terbuka dan
			#   `Stage` MEM-PAUSE pohon scene. Harness ini tak pernah menutupnya,
			#   jadi seluruh sisa pemeriksaan berjalan di dunia yang membeku:
			#   makhluk dilaporkan "patung" (gerak=0 dari 23) dan titik-pandang
			#   dilaporkan tak memundurkan kamera — dua kegagalan yang sebabnya
			#   bukan dunia melainkan panel yang menganga. Gejalanya seragam
			#   ("semuanya diam"), dan keseragaman itu petunjuknya.
			if _stage != null and _stage.is_busy():
				_key(KEY_E, true)
				_key(KEY_E, false)
				return false
			# ⚠ Diikat ke TABEL, bukan ke nama beku. Versi lama memastikan
			#   `ev_ashbrook_jembatan_terlalu_lebar` — benar HANYA selama jembatan
			#   kebetulan titik terakhir. Begitu urutan berubah, asersi ini gagal
			#   tanpa ada yang rusak, dan gerbang mulai berbohong.
			var akhir: String = String(TITIK[TITIK.size() - 1][2])
			ok("E saat berjalan mencatat bukti (%s)" % akhir, _ev.has(akhir))
			_shot_pending = "02_jembatan"
			_lanjut()
		14:
			# BATAS: jalan ke timur jauh melewati tepi
			if _sub == 0:
				_mulai_jalan(Vector2(2400, 700))
				_sub = 1
				return false
			if not _melangkah(delta):
				return false
			var px: float = _player().global_position.x
			ok("batas TIMUR menahan (x <= 1960)", px <= 1960.0, "x=%.0f" % px)
			_sub = 0
			_shot_pending = "03_batas_timur"
			_lanjut()
		15:
			if _sub == 0:
				_mulai_jalan(Vector2(1500, 1400))
				_sub = 1
				return false
			if not _melangkah(delta):
				return false
			var py: float = _player().global_position.y
			# Peta tumbuh 34 -> 44 petak (1088 -> 1408 px); yang menahan sekarang
			# tabrakan treeline di y~1324, bukan batas lama 1130.
			ok("batas SELATAN menahan (y <= 1340)", py <= 1340.0, "y=%.0f" % py)
			_sub = 0
			_lanjut()
		16:
			# KEHIDUPAN — hitung apa yang benar-benar hidup di pohon scene
			var t := root.get_tree()
			var ayam := 0
			var anak := 0
			var warga := 0
			for n in t.get_nodes_in_group("ashbrook_life"):
				warga += 1
			for n in root.get_tree().current_scene.get_children():
				var sc = n.get_script()
				if sc == null: continue
				var rp := String(sc.resource_path)
				# `AshbrookChicken.gd` sudah dipensiunkan untuk dunia 64px; semua
				# hewan kini satu aktor `Hewan.gd` yang jenisnya dibaca katalog.
				if rp.ends_with("Hewan.gd"): ayam += 1
				elif rp.ends_with("AshbrookKid.gd"): anak += 1
			ok("hewan hidup terpasang (ternak+liar+burung)", ayam >= 10, str(ayam))
			ok("3 anak hidup", anak == 3, str(anak))
			ok("NPC berjadwal + sepeda masuk grup ashbrook_life", warga >= 5, str(warga))
			ok("anak serigala (#118) ada", t.get_nodes_in_group("wolf_pup").size() >= 1)
			ok("zona titik-pandang (#218) ada", t.get_nodes_in_group("vantage").size() >= 1)
			ok("jendela terpasang", t.get_nodes_in_group("ashbrook_window").size() >= 6,
				str(t.get_nodes_in_group("ashbrook_window").size()))
			_lanjut()
		17:
			# gerakan: rekam posisi makhluk, tunggu, bandingkan
			_simpan_posisi()
			_lanjut()
		18:
			if _t < 3.0: return false
			_bandingkan_posisi()
			_lanjut()
		19:
			# TITIK-PANDANG: jalan ke zona, kamera harus mundur
			if _sub == 0:
				_mulai_jalan(Vector2(1716, 856))     # titik pandang #218 dipindah
				_sub = 1
				return false
			if not _melangkah(delta):
				return false
			_sub = 0
			_lanjut()
		20:
			if _t < 1.2: return false
			var z := -1.0
			for c in _player().get_children():
				if c is Camera2D:
					z = c.zoom.x
			ok("titik-pandang #218 memundurkan kamera (zoom < 0.9)", z > 0.0 and z < 0.9,
				"zoom=%.2f" % z)
			_shot_pending = "04_titik_pandang"
			_lanjut()
		21:
			# JENDELA-CHRONICLE dengan jam eksplisit
			var wins := root.get_tree().get_nodes_in_group("ashbrook_window")
			var biasa_padam := 0
			var otha_gelap := 0
			for w in wins:
				w.apply_hour(20)
				if String(w.page_id) == "person_otha_renn":
					if not w.visible: otha_gelap += 1
				elif not w.visible:
					biasa_padam += 1
			ok("jam 20: sebagian jendela biasa padam", biasa_padam >= 1, str(biasa_padam))
			ok("jam 20: jendela Otha gelap (kosong, bukan jam)", otha_gelap >= 2, str(otha_gelap))
			var siang_nyala := 0
			var otha_siang_gelap := 0
			for w in wins:
				w.apply_hour(18)
				if String(w.page_id) == "person_otha_renn":
					if not w.visible: otha_siang_gelap += 1
				elif w.visible:
					siang_nyala += 1
			ok("jam 18: jendela biasa MENYALA", siang_nyala >= 3, str(siang_nyala))
			ok("jam 18: jendela Otha TETAP gelap (terlupa, bukan jam)",
				otha_siang_gelap >= 2, str(otha_siang_gelap))
			_lanjut()
		22:
			return _selesai()
	return false


func _lanjut() -> void:
	_step += 1
	_t = 0.0


var _pos_lama: Array = []

func _simpan_posisi() -> void:
	_pos_lama.clear()
	for n in root.get_tree().current_scene.get_children():
		var sc = n.get_script()
		if sc == null: continue
		var rp := String(sc.resource_path)
		if rp.ends_with("AshbrookChicken.gd") or rp.ends_with("AshbrookKid.gd") \
				or rp.ends_with("Villager.gd"):
			_pos_lama.append([n, n.global_position])


func _bandingkan_posisi() -> void:
	var gerak := 0
	var diam := 0
	var jauh := 0.0
	for e in _pos_lama:
		var n = e[0]
		if not is_instance_valid(n): continue
		var d: float = n.global_position.distance_to(e[1])
		if d > 4.0: gerak += 1
		else: diam += 1
		jauh = maxf(jauh, d)
	ok("makhluk BERGERAK setelah 3 detik (bukan patung)", gerak >= 5,
		"gerak=%d diam=%d" % [gerak, diam])
	ok("jangkauan gerak terlihat hidup (>24 px dalam 3 detik)", jauh > 24.0,
		"terjauh %.0f px" % jauh)


func _selesai() -> bool:
	print("\n===== JALAN-KAKI: %d lulus, %d gagal =====" % [_pass, _fail])
	quit(1 if _fail > 0 else 0)
	return true
