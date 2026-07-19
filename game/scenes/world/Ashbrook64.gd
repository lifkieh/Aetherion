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
	_village()
	_props_and_evidence()
	_folk()
	_spawn_player()
	_add_ui()


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
	s.position = foot - Vector2(s.texture.get_width() * 0.5, s.texture.get_height())
	s.z_index = int(foot.y)
	add_child(s)
	return s


func _village() -> void:
	_building(P_S + "fasad_inn.png", MERRIT_HOUSE)                 # rumah singgah Merrit
	_building(P_S + "fasad_gudang.png", Vector2(704, 400))         # gudang gandum
	_building(P_S + "fasad_shop.png", Vector2(1216, 480))          # toko Otha — tutup dua musim
	_building(P_S + "fasad_kosong.png", Vector2(1408, 800))        # rumah kosong
	_building(P_S + "fasad_rumah.png", Vector2(640, 992))          # rumah Lyra (masih dihuni)
	for p in [Vector2(320, 384), Vector2(1600, 352), Vector2(1728, 1024), Vector2(224, 1088)]:
		_put(P_S + "tree_lpc.png", p)
	_put(P_S + "fountain.png", VC + Vector2(0, -32))               # air mancur KERING
	for i in 8:                                                     # bangku terlalu banyak
		_put(P_S + "bench_lpc.png", VC + Vector2(-224 + i * 64, 112 if i % 2 == 0 else -112))


# ------------------------------------------------- prop cerita + HUKUM BUKTI (#226)
func _props_and_evidence() -> void:
	# LAMPU MERRIT — jiwa Ashbrook. Menyala siang & malam.
	_lamp = _put(P_OLD + "lantern.png", MERRIT_HOUSE + Vector2(72, -56), Z_LAMP)
	if _lamp:
		_lamp.scale = Vector2(2, 2)                                 # 12x20 -> 24x40, seskala LPC
		var glow := PointLight2D.new()
		var gp := P_OLD + "lantern_glow.png"
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
	_put(P_S + "wall_ruin.png", Vector2(1504, 1088))
	_examine(Vector2(1504, 1152), "ev_ashbrook_fondasi_rumput")
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


# ---------------------------------------------------------------- penduduk
## Enam wajah LPC. Hook siluet berbeda per #231 (uji hitam: reports/preview/siluet231.png).
func _folk() -> void:
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
	if OS.get_environment("AETHER_PIN_DAY") == "1":
		return
	if _canvas_mod:
		_canvas_mod.color = GameClock.ambient_color()
	var h := GameClock.wib_hour()
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
