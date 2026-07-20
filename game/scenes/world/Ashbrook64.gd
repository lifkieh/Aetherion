extends Node2D
## ASHBROOK — versi LPC (#254). Desa-bekas-kota, wajah baru, LOGIKA SAMA.
##
## ⚠ `Ashbrook.tscn`/`Ashbrook.gd` (16px) **TIDAK DISENTUH** dan tetap scene yang
## dimainkan sampai versi ini terbukti utuh. Ini kandidat pengganti, bukan pengganti.
##
## ═══ SKALA — dan kenapa `TILE = 32`, bukan 64 ═══
## Standar LPC = **ubin dunia 32×32** + **frame karakter 64×64**. Angka 64 mengacu
## pada kanvas karakter, bukan petak dunia; tak ada tileset LPC 64px dan tak akan ada
## (diverifikasi: seluruh terrain LPC di gudang berkisi 32px, dan halaman LPC Tile Atlas
## menyatakannya eksplisit). Jadi migrasi ini = petak **16→32** dan karakter **32→64 frame**.
## `const TILE` di 5 berkas wilayah LAIN sengaja TIDAK disentuh — batas tugas: Ashbrook saja.
##
## ═══ YANG TIDAK BERUBAH (#151b — wajah berubah, logika tidak) ═══
## Titik-periksa memakai `Interactable.tscn` + `Evidence` yang SAMA PERSIS dengan scene 16px.
## Lima bukti, id identik. Kalau core loop pecah di sini, itu bug wajah — bukan bug logika.
##
## Sumber dunia: Mage City Arcanos (Hyptosis, **CC0**) → `_tools/gen_lpc32_slices.py`.
## Sumber karakter: ULPC → `_tools/lpc_assembler/assemble.py` (6 tokoh, #231 hook berbeda).

const TILE := 32                    # petak LPC (BUKAN 64 — lihat catatan skala di atas)
const MAP_W := 60
const MAP_H := 34
const VC := Vector2(960, 704)       # pusat alun-alun (koordinat dihitung ulang untuk petak 32)
const MERRIT_HOUSE := Vector2(464, 752)
## Kamar Merrit diletakkan DI LUAR peta, tapi di koordinat **POSITIF** — dan itu
## bukan selera.
##
## `Player.gd:54` melakukan `z_index = int(global_position.y)` untuk y-sort. Di
## koordinat negatif (preseden `Ashbrook.gd:20` memakai `(-360,-260)`) z pemain jadi
## **negatif**, dan ia tergambar DI BAWAH lantainya sendiri: kamar tampak lengkap,
## pemainnya hilang, dan tak satu pun galat muncul. Ruang positif membuat y-sort
## bekerja apa adanya untuk lantai, perabot, dan pemain sekaligus.
##
## Batas tanah tak menghalangi: ia empat dinding tipis di tepi peta, bukan kurungan
## penuh — dan pemain sampai ke sini lewat pintu, bukan berjalan.
const INTERIOR := Vector2(2100, 160)
const ZOOM := 1.0                   # 16px zoom 2 -> layar memuat 40x22 petak.
                                    # petak 32 pada zoom 1.4 -> ~28x16 petak: alun-alun
                                    # 17x11 MUAT, dan karakter 64px tetap terbaca.

const P_T := "res://assets/game/tiles/lpc32/"
const P_S := "res://assets/game/sprites/lpc32/"
const P_C := "res://assets/game/sprites/characters/"
const P_OLD := "res://assets/game/sprites/props/"

## z_index: y-sort dipakai untuk dunia, tapi PLAFON GODOT = 4096.
## y-maks di sini = MAP_H*TILE = 1088 → aman. Konstanta di bawah sengaja dipisah
## jauh di ATAS y-maks supaya tak pernah tertimpa objek ber-y besar (bug yang
## dipetakan sesi lalu: lamp z=1000 tenggelam saat y>1000).
const Z_LAMP := 2000
const Z_BEACON := 4000              # < 4096, dan > semua y-sort
var _lamp: Sprite2D
var _chickens: Array = []
var _kids: Array = []
var _stag: Sprite2D
var _stag_cd := 0.0
var _last_hour := -1
var _beacon: Sprite2D
var _canvas_mod: CanvasModulate
var _player: Node2D


func _ready() -> void:
	WorldState.mark_visited("ashbrook")
	SafeZone.set_region("ashbrook")
	_canvas_mod = CanvasModulate.new()
	# Siang dipatok HANYA untuk harness tangkap-layar (hasil sama tiap dijalankan).
	# Di permainan sungguhan langit ikut GameClock — kalau tidak, Ashbrook tak pernah
	# malam, dan lentera Merrit tak pernah jadi satu-satunya yang menyala. Payoff #218
	# butuh gelap; siang abadi diam-diam membatalkannya.
	_canvas_mod.color = Color(1, 1, 1)
	add_child(_canvas_mod)
	_ground()
	_build_boundaries()
	_village()
	_props_and_evidence()
	_pintu_dan_interior()
	_folk()
	_spawn_player()
	_add_ui()
	_kehidupan()


## Sampai LANGKAH 7, scene ini adalah DIORAMA: nol pemain, nol UI, nol pengendali —
## satu-satunya cara melihatnya adalah harness tangkap-layar. Titik-periksanya ada,
## tapi tak seorang pun bisa menekan E di depannya.
##
## Tiga hal yang membuatnya jadi tempat yang bisa dimainkan:
##   Player      — `Interactable` mencari grup "player" untuk jarak & label
##   WorldController — yang mengubah tombol E jadi `interact()`
##   MenuUI      — tab Kitab, tempat halaman ditulis ulang
## Tanpa ketiganya rantai §0 putus di sambungan pertama.
func _spawn_player() -> void:
	var p := preload("res://scenes/actors/Player.tscn").instantiate()
	add_child(p)
	_player = p
	p.global_position = MERRIT_HOUSE + Vector2(96, 64)   # di depan pintu Merrit
	# Kamera Player dipatok 2.0 untuk dunia 16px. Di petak 32 itu memperbesar dua
	# kali lipat: layar cuma memuat ~14x8 petak dan alun-alun tak lagi muat.
	# ZOOM di berkas ini adalah angka yang sudah dinilai pada 5b — pakai itu.
	for c in p.get_children():
		if c is Camera2D:
			c.zoom = Vector2(ZOOM, ZOOM)


func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())


# ---------------------------------------------------------------- tabrakan
## Semua tabrakan dunia memakai LAPIS 4 — sama dengan `Ashbrook.gd:141-142`, dan
## `Player.tscn` menyaring tepat lapis itu (`collision_mask = 4`). Angka ini bukan
## selera: salah lapis = pemain menembus tembok tanpa satu pun galat muncul.
const SOLID_LAYER := 4

var _solids: StaticBody2D


func _solid_body() -> StaticBody2D:
	if _solids == null:
		_solids = StaticBody2D.new()
		_solids.collision_layer = SOLID_LAYER
		_solids.collision_mask = 0
		add_child(_solids)
	return _solids


## Satu kotak padat. `rect` dalam koordinat dunia.
func _solid(rect: Rect2) -> void:
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = rect.size
	cs.shape = sh
	cs.position = rect.position + rect.size * 0.5
	_solid_body().add_child(cs)


## Batas tanah — preseden `Ashbrook.gd:140-153`.
##
## Tanpa ini pemain berjalan keluar peta ke kekosongan: nol ubin, nol apa pun, dan
## tak ada yang memberitahunya ia sudah di luar dunia. Empat dinding 16 px MENGELILINGI
## petak 60x34 (1920x1088), diletakkan di LUAR tepi supaya tak memakan ruang main.
func _build_boundaries() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-16, -16, w + 32, 16), Rect2(-16, h, w + 32, 16),
			Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h)]:
		_solid(rc)


# ---------------------------------------------------------------- tanah
func _tile(path: String, rect: Rect2, z: int) -> void:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] ubin hilang: %s" % path)
		return
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, rect.size)
	s.centered = false
	s.position = rect.position
	s.z_index = z
	add_child(s)


func _ground() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	_tile(P_T + "grass32.png", Rect2(0, 0, w, h), 0)
	# jalan dagang lama — membentang barat→timur, terlalu lebar untuk empat puluh orang
	_tile(P_T + "stone32.png", Rect2(0, VC.y - 48, w, 96), 1)
	# alun-alun berperkerasan
	_tile(P_T + "cobble32.png", Rect2(VC.x - 272, VC.y - 176, 544, 352), 2)


func _put(path: String, pos: Vector2, z := -1) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] aset hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = pos
	s.z_index = int(pos.y) if z < 0 else z
	add_child(s)
	return s


# ---------------------------------------------------------------- desa
## Fasad ditambatkan pada KAKI, bukan pusat: `pos` = titik bangunan menyentuh tanah.
## Dua sebabnya. (1) y-sort: bangunan setinggi 7 petak yang diurutkan menurut
## pusatnya akan tampak di belakang orang yang berdiri di depannya. (2) Menaruh
## bangunan jadi soal "di mana ia berdiri", bukan aritmetika tinggi.
func _building(path: String, foot: Vector2) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] fasad hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.centered = false
	var wdt: float = s.texture.get_width()
	s.position = foot - Vector2(wdt * 0.5, s.texture.get_height())
	s.z_index = int(foot.y)
	add_child(s)
	# Tabrakan hanya di KAKI, bukan setinggi fasad. Fasad 7 petak yang padat penuh
	# akan menghalangi pemain jauh sebelum ia "menyentuh" bangunannya, dan merusak
	# y-sort yang justru membuat orang bisa berdiri di depan rumah.
	_solid(Rect2(foot.x - wdt * 0.5, foot.y - BUILDING_FOOT_H, wdt, BUILDING_FOOT_H))
	return s


## Setinggi apa kaki bangunan yang padat. 40 px = sedikit di atas tinggi pemain (30x48
## badan), jadi ia jelas "tak bisa lewat" tanpa memakan petak di depan pintu.
const BUILDING_FOOT_H := 40.0

func _village() -> void:
	_building(P_S + "fasad_inn.png", MERRIT_HOUSE)                 # rumah singgah Merrit
	_building(P_S + "fasad_gudang.png", Vector2(704, 400))         # gudang gandum
	_building(P_S + "fasad_shop.png", Vector2(1216, 480))          # toko Otha — tutup dua musim
	_building(P_S + "fasad_kosong.png", Vector2(1408, 800))        # rumah kosong
	_building(P_S + "fasad_rumah.png", Vector2(640, 992))          # rumah Lyra (masih dihuni)
	for p in [Vector2(320, 384), Vector2(1600, 352), Vector2(1728, 1024), Vector2(224, 1088)]:
		_put(P_S + "tree_lpc.png", p)
	var fnt := VC + Vector2(0, -32)
	_put(P_S + "fountain.png", fnt)                                # air mancur KERING
	_solid(Rect2(fnt.x - 26, fnt.y - 10, 52, 34))                  # cekungannya, bukan seluruh sprite
	for i in 8:                                                     # bangku terlalu banyak
		var bp: Vector2 = VC + Vector2(-224 + i * 64, 112 if i % 2 == 0 else -112)
		_put(P_S + "bench_lpc.png", bp)
		_solid(Rect2(bp.x - 14, bp.y - 4, 28, 16))                  # dudukannya saja
	for tp in [Vector2(320, 384), Vector2(1600, 352), Vector2(1728, 1024), Vector2(224, 1088)]:
		_solid(Rect2(tp.x - 10, tp.y - 6, 20, 14))                  # batang, bukan tajuk


# ------------------------------------------------- prop cerita + HUKUM BUKTI (#226)
func _props_and_evidence() -> void:
	# LAMPU MERRIT — jiwa Ashbrook. Menyala siang & malam.
	_lamp = _put(P_OLD + "lantern.png", MERRIT_HOUSE + Vector2(72, -56), Z_LAMP)
	if _lamp:
		_lamp.scale = Vector2(2, 2)                                 # 12x20 -> 24x40, seskala LPC
		var glow := PointLight2D.new()
		var gp := P_OLD + "lantern_glow.png"
		if not ResourceLoader.exists(gp):
			# FALLBACK BERTERIAK (#aset): placeholder senyap = bug berikutnya yang menunggu.
			push_warning("[aset] gagal muat: %s — cahaya lentera memakai tekstur lentera" % gp)
		glow.texture = load(gp) if ResourceLoader.exists(gp) else _lamp.texture
		glow.energy = 0.9          # siang: lentera menyala tapi tak membakar layar
		glow.texture_scale = 7.0
		glow.color = Color(1.0, 0.85, 0.55)
		_lamp.add_child(glow)
	# titik cahaya lintas-jarak (#218) — z di bawah plafon, di atas seluruh y-sort
	var beacon := Sprite2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.88, 0.6))
	beacon.texture = ImageTexture.create_from_image(img)
	beacon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	beacon.global_position = MERRIT_HOUSE + Vector2(72, -56)
	beacon.z_index = Z_BEACON
	beacon.modulate.a = 0.0                                         # siang: lentera sendiri sudah cukup
	beacon.add_to_group("lamp_beacon")
	add_child(beacon)
	_beacon = beacon

	# PAPAN OTHA — kosong + BEKAS CAT (bukti `akibat`). Diskalakan 4x supaya
	# persegi bekasnya TETAP TERBACA pada petak 32 (16x14 -> 64x56).
	var sign := _put(P_OLD + "otha_sign_fadedmark.png", Vector2(1216, 608))
	if sign:
		sign.scale = Vector2(4, 4)
	_examine(Vector2(1216, 664), "ev_otha_papan_bekas_cat")

	# reruntuhan: garis fondasi di rumput + batu fondasi berpahat di alun-alun
	# ⚠ URUTAN PENTING (#batas): titik ini DULU di y=1152 — di LUAR tanah 34 petak
	# (1088 px). Memasang batas tanpa memindahkannya akan MEMUTUS jalur bukti:
	# pemain tak bisa lagi menjangkaunya, dan `ev_ashbrook_fondasi_rumput` jadi
	# mustahil dikumpulkan. Reruntuhannya ikut naik supaya keduanya tetap sepasang.
	_put(P_S + "wall_ruin.png", Vector2(1504, 1024))
	_examine(Vector2(1504, 1056), "ev_ashbrook_fondasi_rumput")
	# batu fondasi berpahat — memakai batu LPC, BUKAN ruins.png 16px (bentrok gaya)
	var stone := _put(P_S + "wall_ruin.png", VC + Vector2(-176, 96))
	if stone:
		stone.scale = Vector2(0.5, 0.5)
	_examine(VC + Vector2(-160, 152), "ev_ashbrook_batu_fondasi")

	# tiga pintu periksa Ashbrook-besar
	_examine(Vector2(704, 480), "ev_ashbrook_gudang_gandum")
	_examine(Vector2(1216, 560), "ev_ashbrook_halloran_200_roti")
	_examine(Vector2(1856, 704), "ev_ashbrook_jembatan_terlalu_lebar")


func _examine(pos: Vector2, ev_id: String) -> void:
	var e := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(e)
	e.evidence_id = ev_id
	e.setup("examine")
	e.global_position = pos


# ---------------------------------------------------------------- KEHIDUPAN
## Dipindahkan dari `Ashbrook.gd` 16px (keputusan Direktur: 64px jadi utama).
##
## ⚠ KOORDINAT DIHITUNG ULANG, BUKAN DISALIN. Petak 16px → 32px berarti dunia dua
## kali lebih besar dalam piksel, dan tata letak Ashbrook64 memang berbeda: alun-alun
## di `VC`, jembatan di timur, gerbang di barat. Menyalin angka 16px mentah-mentah
## akan menaruh ayam di dalam tembok. Setiap penempatan di bawah ditambatkan ke
## **penanda Ashbrook64**, bukan ke angka lama.
##
## Radius berkelana juga digandakan: makhluk yang berkelana 40 px di dunia 16px
## menempuh 2,5 petak; di petak 32 itu cuma 1,25 petak — terlihat lumpuh.
func _kehidupan() -> void:
	_hidup_ayam_anak()
	_hidup_berpasangan()
	_jendela()
	_titik_pandang()
	_anak_serigala()


## Ayam yang benar-benar menghalangi jalan + anak-anak yang mengejarnya.
## Hidup × mati: mereka bermain di depan gudang yang isinya empat ekor ayam.
func _hidup_ayam_anak() -> void:
	for i in 4:
		var c := Node2D.new()
		c.set_script(load("res://scenes/actors/AshbrookChicken.gd"))
		add_child(c)
		c.body_radius = 7.0
		c.wander_radius = 76.0
		c.place(Vector2(704, 470) + Vector2(randf_range(-70, 90), randf_range(20, 90)))
		c.scale = Vector2(1.6, 1.6)
		_chickens.append(c)
	for i in 3:
		var k := Node2D.new()
		k.set_script(load("res://scenes/actors/AshbrookKid.gd"))
		# varian DIPASANG SEBELUM add_child: `_ready()` jalan di dalam add_child, dan
		# yang dipasang sesudahnya tak pernah terbaca. (Pertama kali salah urutan,
		# ketiga anak diam-diam jatuh ke kotak placeholder — log yang menangkapnya.)
		k.varian = i                 # tiga anak BERBEDA, bukan tiga salinan
		add_child(k)
		k.place(VC + Vector2(randf_range(-150, 150), randf_range(-70, 100)))
		k.setup(_chickens)
		# skala 1.6 dulu membesarkan kotak 7x11. Sprite LPC sudah 64px — 1.6 akan
		# membuat anak lebih besar daripada orang dewasa di alun-alun yang sama.
		_kids.append(k)


## Kambing di jembatan + sepeda di gerbang — dua ujung jalan dagang lama.
func _hidup_berpasangan() -> void:
	var goat := Node2D.new()
	goat.set_script(load("res://scenes/actors/AshbrookChicken.gd"))
	add_child(goat)
	goat.body_radius = 14.0
	goat.wander_radius = 60.0          # ia MENGHALANGI jembatan, bukan berkelana
	goat.place(Vector2(1790, VC.y + 8))
	goat.scale = Vector2(3.0, 3.0)
	goat.modulate = Color(0.85, 0.82, 0.75)

	var bike := ColorRect.new()        # sepeda kayu bersandar di gerbang; masih dipakai
	bike.color = Color(0.55, 0.42, 0.28)
	bike.size = Vector2(30, 16)
	bike.position = Vector2(150, VC.y - 26)
	bike.z_index = int(VC.y)
	bike.add_to_group("ashbrook_life")
	add_child(bike)


## #218 — kontras dari PERBEDAAN, bukan ketiadaan. Jendela lain menyala sore lalu
## PADAM satu per satu (19·20·21) sampai tersisa lampu Merrit.
##
## DAN yang 16px tak bisa: satu jendela gelap karena **halamannya tercoret**, bukan
## karena jam. Toko Otha punya halamannya sendiri (`person_otha_renn`), dan selama
## halaman itu tercoret jendelanya **tak pernah menyala** — siang maupun malam.
## Kota mengabarkan pelupaannya lewat jendela.
func _jendela() -> void:
	# [posisi, jam padam, id halaman (kosong = jendela biasa)]
	for w in [
		[Vector2(608, 992), 19, ""],          # rumah Lyra — masih dihuni
		[Vector2(672, 992), 21, ""],
		[Vector2(1392, 800), 20, ""],         # rumah kosong — padam paling awal terasa
		[Vector2(1424, 800), 19, ""],
		[Vector2(1200, 480), 21, "person_otha_renn"],   # TOKO OTHA — gelap karena TERLUPA
		[Vector2(1232, 480), 21, "person_otha_renn"],
	]:
		var win := Node2D.new()
		win.set_script(load("res://scenes/actors/AshbrookWindow.gd"))
		add_child(win)
		win.place(Vector2(w[0]) + Vector2(0, -96), int(w[1]), String(w[2]))
		win.scale = Vector2(2.0, 2.0)


## #218 PAYOFF PERJALANAN — pemain berjalan menjauh, MENOLEH, dan lampu Merrit masih
## di sana. Kamera mundur supaya lampu masuk layar dari jarak itu.
func _titik_pandang() -> void:
	var zone := Area2D.new()
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(280, 240)
	cs.shape = sh
	zone.add_child(cs)
	zone.global_position = Vector2(1480, VC.y)
	zone.add_to_group("vantage")
	add_child(zone)
	zone.body_entered.connect(func(b):
		if b == _player:
			_zoom_kamera(0.55))
	zone.body_exited.connect(func(b):
		if b == _player:
			_zoom_kamera(ZOOM))


func _zoom_kamera(z: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	for c in _player.get_children():
		if c is Camera2D:
			create_tween().tween_property(c, "zoom", Vector2(z, z), 0.6)


## #118 — monster pertama: anak serigala TERLUKA. Boleh dibantu, diabaikan, atau
## dibunuh. Semuanya sah; dunia tak menghakimi pilihannya.
func _anak_serigala() -> void:
	var m = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(m)
	m.setup(MonsterFactory.make("grey_wolf", 2, 1))
	m.global_position = Vector2(1700, 980)
	m.add_to_group("wolf_pup")


## WHITE STAG (#D-ASH-4) — tanpa pemicu, tanpa penanda, tanpa musik, tanpa quest.
## Muncul jauh & singkat di tepi hutan, lalu hilang. Kalau pemain melihatnya: bagus.
## Kalau tidak: juga bagus. **Legenda tidak wajib ditemukan.**
func _tick_rusa(delta: float) -> void:
	if _stag != null and is_instance_valid(_stag):
		_stag_cd -= delta
		if _stag_cd <= 0.0:
			_stag.queue_free()
			_stag = null
		return
	if _player == null or not is_instance_valid(_player):
		return
	if _player.global_position.y > 460.0:      # hanya di dekat tepi hutan utara
		return
	if randf() > 0.005 * delta * 60.0:
		return
	_stag = Sprite2D.new()
	var img := Image.create(6, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.96, 0.96, 0.92))
	_stag.texture = ImageTexture.create_from_image(img)
	_stag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_stag.scale = Vector2(3, 3)
	_stag.global_position = Vector2(_player.global_position.x + randf_range(-260, 260), 190)
	_stag.z_index = 500
	_stag.modulate.a = 0.85
	add_child(_stag)
	_stag_cd = 2.2


# ------------------------------------------------- pintu & interior
const PROP := preload("res://scenes/world/Ashbrook64Prop.gd")


func _prop(pos: Vector2) -> Node2D:
	var n := Node2D.new()
	n.set_script(PROP)
	add_child(n)
	n.global_position = pos
	return n


## `z` SELALU eksplisit. Tak ada mode-otomatis di sini — justru sentinel
## "negatif berarti hitung dari y" di `_put()` yang sudah sekali menenggelamkan
## perabot kamar ini. Lantai dan dinding hidup di z rendah tetap (0-3); apa pun yang
## bisa dilalui pemain memakai y-sort biasa dan otomatis berada di atasnya.
func _kotak(pos: Vector2, size: Vector2, col: Color, z: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = col
	r.size = size
	r.position = pos
	r.z_index = z
	add_child(r)
	return r


## SATU interior yang bermakna, sisanya pintu yang bercerita.
##
## Kenapa bukan interior untuk semua: rumah kosong generik **melemahkan** dunia.
## Pemain yang membuka lima pintu dan menemukan lima ruangan kosong belajar bahwa
## pintu tak berarti apa-apa. Pintu tertutup yang mengatakan sesuatu justru menjaga
## dunia tetap padat — dan lebih jujur, karena isinya memang belum ditulis.
##
## Merrit dapat ruangan sungguhan karena payoff menuntutnya: ia yang menulis halaman
## Ashbrook (#261) dan ia yang menyalakan lentera itu. Kalau rumahnya tak bisa
## dimasuki, satu-satunya alasan pemain percaya ia "repot" adalah karena kita
## mengatakannya — bukan karena ia melihatnya.
func _pintu_dan_interior() -> void:
	_bangun_kamar_merrit()
	_gerbang_keluar()

	# pintu MASUK — di kaki fasad Merrit, tempat pintunya digambar
	var masuk := _prop(MERRIT_HOUSE + Vector2(0, -8))
	masuk.setup_pindah(INTERIOR + Vector2(150, 170), true, "Masuk rumah Merrit [E]")

	# --- PINTU YANG BERCERITA (nol interior, nol bukti) ---
	# Toko Otha. #269: Otha adalah D3 — tak pernah tercatat. Teksnya tak boleh
	# menyebut namanya; yang tersisa cuma pintu dan musim yang lewat.
	var otha := _prop(Vector2(1216, 472))
	otha.setup_bicara([
		"Terkunci. Debu di ambangnya rata — tak ada yang membukanya sejak dua musim.",
		"Tak ada papan nama. Cuma persegi yang catnya lebih gelap, tempat sesuatu dulu tergantung.",
	], "Pintu toko [E]")

	# Rumah kosong. #269: DITINGGALKAN (D2) — pernah ada penghuninya, dan itu harus
	# terbaca. "Belum jadi" akan membuatnya D3, dan itu kematian yang berbeda.
	var kosong := _prop(Vector2(1408, 792))
	kosong.setup_bicara([
		"Pintunya tak terkunci. Engselnya masih diminyaki — seseorang merawatnya sampai hari terakhir.",
		"Di dalam gelap. Perabotnya masih ada, tertata, menunggu orang yang tak pulang.",
	], "Rumah kosong [E]")

	# Gudang gandum — pintunya, bukan titik-periksanya (yang itu tetap bukti #226)
	var gudang := _prop(Vector2(704, 392))
	gudang.setup_bicara([
		"Palang pintunya dilepas sejak lama. Di dalam, empat ekor ayam dan ruang untuk empat ratus karung.",
	], "Pintu gudang [E]")

	# Rumah Lyra — masih dihuni; pintunya menolak dengan sopan
	var lyra := _prop(Vector2(640, 984))
	lyra.setup_bicara([
		"Ada suara di dalam. Seseorang sedang memasak, dan tak menyadari kau berdiri di sini.",
	], "Rumah Lyra [E]")


## JALAN KELUAR (BAGIAN 3) — Ashbrook64 berhenti jadi penjara.
##
## Diletakkan di ujung BARAT jalan dagang lama — jalan yang sudah digambar `_ground()`
## membentang barat→timur. Keluar lewat jalan yang memang menuju ke luar, bukan lewat
## pintu ajaib di tengah rumput.
##
## ⚠ SEMENTARA ia kembali ke MENU, bukan ke Greenvale. Alasannya bukan malas:
## `TravelUI` + `regions.json` adalah alur dunia PERMANEN, dan Direktur menetapkan
## putusan "Ashbrook64 ganti vs dampingi 16px" menunggu playtest. Menyambungkannya
## sekarang berarti menjawab pertanyaan yang belum ditanyakan.
func _gerbang_keluar() -> void:
	var g := _prop(Vector2(96, VC.y))
	g.setup_gerbang("Jalan keluar Ashbrook [E]")
	# penanda visual: batu penjuru yang sudah aus, bukan portal berkilau (D-3)
	var b := _put(P_S + "wall_ruin.png", Vector2(96, VC.y + 8))
	if b:
		b.scale = Vector2(0.4, 0.4)


## Kamar Merrit — kecil, dan setiap benda di dalamnya menjawab satu pertanyaan:
## kenapa orang ini repot mengingat sebuah kota yang sudah selesai.
func _bangun_kamar_merrit() -> void:
	var o := INTERIOR
	# ⚠ z NEGATIF, dan sengaja. `_put()` menurunkan z dari koordinat-y, dan kamar ini
	# duduk di koordinat NEGATIF (di luar peta) — jadi perabotnya akan mendarat di z
	# sekitar −420 dan tenggelam DI BAWAH lantainya sendiri. Semua benda kamar
	# karena itu diberi z eksplisit, berlapis, dan seluruhnya di bawah 0 supaya
	# pemain (z 0) selalu tergambar di atasnya.
	_kotak(o, Vector2(320, 240), Color(0.17, 0.14, 0.11), 0)                   # lantai
	_kotak(o + Vector2(0, -14), Vector2(320, 14), Color(0.10, 0.08, 0.07), 1)   # dinding
	_kotak(o + Vector2(28, 52), Vector2(40, 34), Color(0.34, 0.19, 0.11), 2)    # perapian

	# Perapian = satu-satunya cahaya, dan ia menyala. `CanvasModulate` menggelapkan
	# seisi scene pada malam WIB; tanpa lampu ini kamarnya jadi kotak hitam.
	var api := PointLight2D.new()
	api.energy = 2.6
	api.texture_scale = 13.0
	api.color = Color(1.0, 0.74, 0.45)
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	api.texture = ImageTexture.create_from_image(img)
	api.global_position = o + Vector2(48, 70)
	add_child(api)

	# isian lembut supaya sudut jauh tak hilang total — tetap redup, tetap satu ruangan
	var isi := PointLight2D.new()
	isi.energy = 1.5
	isi.texture_scale = 26.0
	isi.color = Color(0.95, 0.80, 0.62)
	isi.texture = api.texture
	isi.global_position = o + Vector2(160, 120)
	add_child(isi)

	# Perabot memakai y-sort biasa `_put()` — di ruang positif itu sudah benar, dan
	# pemain (yang juga y-sort, `Player.gd:54`) otomatis lewat di depan/belakangnya.
	_put(P_S + "table_lpc.png", o + Vector2(160, 120))
	_put(P_S + "bench_lpc.png", o + Vector2(120, 156))
	_put(P_S + "barrel_lpc.png", o + Vector2(272, 96))

	# SURAT di meja — yang ia tunggu empat puluh tahun (A3 / companion_11)
	var surat := _prop(o + Vector2(160, 112))
	surat.setup_bicara([
		"Sepucuk surat, dibuka dan dilipat kembali sampai lipatannya menipis.",
		"Tanggalnya empat puluh tahun lalu. Isinya cuma satu kalimat: \"Tunggu aku, jangan pindah.\"",
		"Tak ada nama pengirim. Merrit tak pernah menyebutkannya kepada siapa pun.",
	], "Surat di meja [E]")

	# BOTOL MINYAK — bukti kerja, bukan penjelasan
	_kotak(o + Vector2(232, 150), Vector2(64, 18), Color(0.26, 0.30, 0.28), 3)
	var botol := _prop(o + Vector2(264, 146))
	botol.setup_bicara([
		"Botol minyak lampu, kosong semua, berjajar rapi menurut tahun.",
		"Kau berhenti menghitung di baris ketiga. Ada lebih banyak botol di sini daripada orang di Ashbrook.",
	], "Botol berjajar [E]")

	# pintu KELUAR
	var keluar := _prop(o + Vector2(150, 205))
	keluar.setup_pindah(MERRIT_HOUSE + Vector2(0, 36), false, "Keluar [E]")


# ---------------------------------------------------------------- penduduk
## Enam wajah LPC. Hook siluet berbeda per #231 (uji hitam: reports/preview/siluet231.png).
## 5 NPC berkepribadian + JADWAL (#78/#97) — sama dengan 16px. Ini yang membuat
## kota terasa punya penghuni, bukan patung. Enam wajah statis di bawah TETAP ada:
## mereka tokoh bernama di tempat tetapnya (Merrit di rumahnya, Otha di tokonya).
func _folk_berjadwal() -> void:
	TownFolk.place(self, "ashbrook", VC)
	for c in get_children():
		var sc = c.get_script()
		if sc != null and String(sc.resource_path).contains("Villager"):
			c.add_to_group("ashbrook_life")


func _folk() -> void:
	_folk_berjadwal()
	for spec in [
		["merrit_fane", MERRIT_HOUSE + Vector2(48, 96)],
		["halloran", Vector2(1216, 688)],
		["old_bram", VC + Vector2(-224, 96)],
		["nyai", VC + Vector2(160, 128)],
		["otha_renn", Vector2(1280, 672)],
		["sora", Vector2(672, 1024)],
	]:
		var p := P_C + str(spec[0]) + "_idle.png"
		if not ResourceLoader.exists(p):
			push_warning("[ash64] NPC belum dirakit: %s" % spec[0])
			continue
		var s := Sprite2D.new()
		var at := AtlasTexture.new()
		at.atlas = load(p)
		at.region = Rect2(0, 128, 64, 64)      # baris 2 = hadap bawah (frame_map.json)
		s.texture = at
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.global_position = spec[1]
		s.z_index = int(s.global_position.y)
		add_child(s)


## Langit & lentera mengikuti jam WIB — aturan yang SAMA dengan `Ashbrook.gd`
## (#218). Diulang, bukan diwarisi: dua scene ini sengaja tak berbagi induk sampai
## salah satunya dipensiunkan, dan menyalin 12 baris lebih jujur daripada membuat
## kelas dasar untuk sesuatu yang akan dihapus.
##
## `AETHER_PIN_DAY=1` mematok siang untuk harness tangkap-layar.
func _process(_delta: float) -> void:
	var h := GameClock.wib_hour()
	if h != _last_hour:
		_last_hour = h
		for w in get_tree().get_nodes_in_group("ashbrook_window"):
			w.apply_hour(h)      # desa TERTIDUR satu per satu — dan satu menolak
	_tick_rusa(_delta)
	if OS.get_environment("AETHER_PIN_DAY") == "1":
		return
	if _canvas_mod:
		_canvas_mod.color = GameClock.ambient_color()
	if _lamp:
		# Lentera Merrit menyala siang & malam. Malam hari ia satu-satunya yang menyala.
		_lamp.modulate = Color(1, 1, 1, 1.0 if h >= 17 or h < 6 else 0.75)
	if _beacon:
		var ba := 1.0 if h >= 17 or h < 6 else 0.55
		# Dari dekat beacon MENUTUPI lenteranya (6x6 px, z di atas segalanya, di luar
		# jangkauan Light2D → kotak gelap menempel di kaca). Pelajaran yang sudah
		# dibayar di scene 16px; jangan bayar dua kali.
		if _player and is_instance_valid(_player) 				and _player.global_position.distance_to(_beacon.global_position) < 320.0:
			ba = 0.0
		_beacon.modulate.a = ba
