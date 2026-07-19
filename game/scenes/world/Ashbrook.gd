extends Node2D
## ASHBROOK — desa-bekas-kota (v0.5.0 · Decision Log #206/#216 · cetak biru
## `docs/ASHBROOK_DESIGN_v05.md` v2).
##
## ⚖ HUKUM TERTINGGI (Direktur): **ASHBROOK HARUS HIDUP, BUKAN HANYA SEDIH.**
## Tesisnya bukan "dunia sedang mati" — melainkan "dunia MASIH HIDUP meskipun
## kehilangan banyak hal". Karena itu **setiap detail keruntuhan WAJIB berpasangan
## dengan detail kehidupan di dekatnya** (`RUINS[]` di bawah: tiap entri punya
## `life`). Dijaga test `_test_ashbrook_alive()` — dua detail-mati berturut tanpa
## kehidupan di antaranya = GAGAL.
##
## ⚖ HUKUM #210: TUNJUKKAN, JANGAN PAPAN-INFORMASIKAN. Tak ada satu pun papan info
## yang menjelaskan keruntuhan. Pemain menyimpulkan sendiri — atau tidak sama sekali.

const TILE := 16
const MAP_W := 96          # diperpanjang (#218): jalan keluar butuh RUANG untuk payoff
const MAP_H := 44
const VC := Vector2(480, 352)                 # pusat desa (alun-alun)
const MERRIT_HOUSE := Vector2(232, 376)       # rumah singgah — ujung barat jalan
const INTERIOR := Vector2(-360, -260)         # kamar tempat pemain BANGUN
const FOREST_Y := 108.0                       # batas hutan (utara) — White Stag
const STAG_CHANCE := 0.005                    # 0,5% per detik saat menghadap hutan (#D-ASH-4)
const VANTAGE_X := 1000.0                     # titik-pandang: di sini pemain MENOLEH (#218)
const VANTAGE_ZOOM := 0.7                     # kamera mundur → lampu masuk layar
const EXIT_X := 1470.0                        # gerbang jalan ke Greenvale

## Tiap keruntuhan BERPASANGAN dengan kehidupan (Hukum Tertinggi).
## {ruin: apa yang ditunjukkan · life: kehidupan di sebelahnya · at: posisi}
const RUINS := [
	{"id": "jembatan", "at": [820, 372], "ruin": "jembatan batu selebar kereta dagang — kini dilintasi seekor kambing",
		"life": "kambing itu benar-benar ada, dan ia benar-benar menghalangi jalan"},
	{"id": "gudang", "at": [372, 200], "ruin": "gudang gandum untuk panen kota 1.500 jiwa; sebagian atap runtuh",
		"life": "empat ekor ayam tinggal di dalamnya — dan anak-anak mengejar mereka"},
	{"id": "alun_alun", "at": [496, 340], "ruin": "alun-alun terlalu besar; bangku terlalu banyak; air mancur kering",
		"life": "Bram duduk di salah satu bangku itu tiap hari, dan bercerita tentang orang, bukan tentang kota"},
	{"id": "rumah_kosong_1", "at": [600, 424], "ruin": "rumah gelap; nama keluarga masih terukir di pintu",
		"life": "kebun di sebelahnya masih disiangi seseorang — Lyra, tiap sore"},
	{"id": "rumah_kosong_2", "at": [672, 288], "ruin": "jendela pecah, dibiarkan; tak ada yang perlu masuk",
		"life": "tungku roti Halloran menyala di seberangnya — dua ratus roti untuk empat puluh orang"},
	{"id": "gerbang", "at": [120, 300], "ruin": "gerbang setengah runtuh — bukan dihancurkan perang, hanya tak pernah diperbaiki",
		"life": "seseorang menyandarkan sepeda kayu di situ tiap pagi; ia masih dipakai"},
	{"id": "papan_tarif", "at": [268, 400], "ruin": "papan tarif tamu rumah singgah — pudar, tak terbaca lagi",
		"life": "lampu di jendelanya menyala — siang maupun malam"},
]

var canvas_mod: CanvasModulate
var player
var _lamp: Sprite2D                 # lampu Merrit — jiwa Ashbrook
var _stag: Sprite2D
var _stag_seen_at := -999.0
var _stag_cd := 0.0
var _chickens: Array = []
var _kids: Array = []
var _in_interior := true
var _seat: Node2D
var _beacon: Sprite2D
var _last_hour := -1

func _ready() -> void:
	WorldState.mark_visited("ashbrook")     # Gerbang Penjelajah (#43) — titik-spawn (#204)
	randomize()
	_build_ground()
	_build_boundaries()
	_build_road()                            # jalan HIDUP ke Greenvale (#204)
	_build_village()
	_build_interior()
	_build_sky()
	SafeZone.set_region("ashbrook")
	_spawn_player()
	_add_ui()
	_spawn_life()                            # ayam yang mengganggu + anak-anak berlari
	_spawn_paired_life()                     # kambing di jembatan + sepeda di gerbang (#217)
	_build_windows()                         # jendela rumah lain: menyala sore, PADAM satu per satu (#218)
	_build_lamp_seat()                       # Merrit duduk membaca surat di momen lampu (#218)
	_build_vantage()                         # PAYOFF PERJALANAN — gambar-jiwa cetak biru (#218)
	_spawn_wolf_pup()                        # monster pertama: anak serigala terluka (#118)
	TownFolk.place(self, "ashbrook", VC)     # 5 NPC berkepribadian (#78) + JADWAL (#97)
	for c in get_children():                 # warga ikut dihitung sebagai KEHIDUPAN
		var sc = c.get_script()
		if sc != null and String(sc.resource_path).contains("Villager"):
			c.add_to_group("ashbrook_life")
	_maybe_opening()

# ---------------------------------------------------------------- opening
## Opening kanon (#118): Pegasus = FIRST MYSTERY. Pemain BANGUN di rumah Merrit.
func _maybe_opening() -> void:
	if WorldState.get_counter("ashbrook_intro") > 0:
		_in_interior = false
		player.global_position = MERRIT_HOUSE + Vector2(0, 46)
		return
	WorldState.add_counter("ashbrook_intro")
	Cutscene.play("opening_pegasus")

## Keluar dari kamar → kesan pertama Ashbrook. TANPA banner sambutan, tanpa "desa X jiwa".
func _leave_interior() -> void:
	_in_interior = false
	player.global_position = MERRIT_HOUSE + Vector2(0, 46)
	Stage.enter_region("Ashbrook", "", "greenvale.ogg")

# ---------------------------------------------------------------- dunia
func _tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["grass_0", 0], ["grass_1", 1], ["dirt_0", 2], ["cobble_0", 3]]:
		var src := TileSetAtlasSource.new()
		var path := "res://assets/game/tiles/%s.png" % i[0]
		if not ResourceLoader.exists(path):
			continue
		src.texture = load(path)
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i[1])
	return ts

func _build_ground() -> void:
	var g := TileMapLayer.new()
	g.tile_set = _tileset()
	add_child(g)
	for y in range(MAP_H):
		for x in range(MAP_W):
			g.set_cell(Vector2i(x, y), 1 if randf() < 0.25 else 0, Vector2i(0, 0))

## JALAN UTAMA — dulu jalur dagang Valenford ("The Kingdom of Open Roads").
## Ia membentang dari rumah Merrit (barat) ke jembatan & jalan Greenvale (timur).
func _build_road() -> void:
	var r := TileMapLayer.new()
	r.tile_set = _tileset()
	r.z_index = 1
	add_child(r)
	var ry := int(VC.y / TILE)
	for x in range(6, MAP_W):
		for dy in [-1, 0, 1]:
			r.set_cell(Vector2i(x, ry + dy), 2, Vector2i(0, 0))
	# alun-alun: cobble, terlalu besar untuk empat puluh orang
	var c := Vector2i(int(VC.x / TILE), int(VC.y / TILE))
	for y in range(c.y - 6, c.y + 5):
		for x in range(c.x - 8, c.x + 9):
			r.set_cell(Vector2i(x, y), 3, Vector2i(0, 0))

func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-16, -16, w + 32, 16), Rect2(-16, h, w + 32, 16), Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h)]:
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = rc.size
		cs.shape = sh
		cs.position = rc.position + rc.size * 0.5
		walls.add_child(cs)

func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	add_child(canvas_mod)

# ---------------------------------------------------------------- desa
func _build_village() -> void:
	# rumah singgah Merrit — dan LAMPU-nya (jiwa Ashbrook)
	_building("inn", MERRIT_HOUSE, "Rumah Singgah Merrit")
	_lamp = Sprite2D.new()
	var lp := "res://assets/game/sprites/props/lantern.png"
	if ResourceLoader.exists(lp):
		_lamp.texture = load(lp)
	else:
		var img := Image.create(6, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.86, 0.52))
		_lamp.texture = ImageTexture.create_from_image(img)
	_lamp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lamp.global_position = MERRIT_HOUSE + Vector2(18, -14)
	# z_index HARUS <= Light2D.range_z_max (1024). Dulu 4000 → lentera berada di LUAR
	# jangkauan cahayanya sendiri: dinding rumah tersorot, lenteranya tetap gelap =
	# lampu terbaca MATI dari dekat. 1000 tetap di atas segalanya yang ter-y-sort.
	_lamp.z_index = 1000
	add_child(_lamp)
	var glow := PointLight2D.new()
	# Tekstur lampu ≠ sprite. Sprite lentera mayoritas logam gelap + outline hitam;
	# dipakai sebagai tekstur cahaya, outline itu jadi lubang gelap di dalam glow.
	# lantern_glow.png = siluet hangat padat, khusus untuk ini (_tools/gen_lantern.py).
	var gp := "res://assets/game/sprites/props/lantern_glow.png"
	glow.texture = load(gp) if ResourceLoader.exists(gp) else _lamp.texture
	glow.energy = 1.5
	glow.texture_scale = 9.0
	glow.color = Color(1.0, 0.85, 0.55)
	_lamp.add_child(glow)

	# rumah-rumah kosong (jendela GELAP — tak pernah dinyalakan)
	for pos in [Vector2(600, 424), Vector2(672, 288), Vector2(560, 216)]:
		_building("house_blue", pos, "")
	# yang MASIH dihuni (kehidupan di sebelah kematian — Hukum Tertinggi)
	_building("house_green", Vector2(392, 440), "Rumah Lyra")
	_building("store", Vector2(300, 236), "Tungku Halloran")
	# gudang gandum raksasa (4 ayam tinggal di dalamnya)
	_building("inn", Vector2(372, 200), "Gudang Gandum")
	# PINTU R1+R2+R3: objek Ashbrook-besar bisa DIPERIKSA → bukti Hukum Bukti (#226).
	# Titik di depan tiap objek agar terjangkau. Nol penanda, nol ikon (D-3).
	_examine_point(Vector2(372, 234), "ev_ashbrook_gudang_gandum")
	_examine_point(Vector2(300, 268), "ev_ashbrook_halloran_200_roti")   # depan Tungku Halloran

	# jembatan yang terlalu lebar (kesan "dulu besar" #1)
	var br := ColorRect.new()
	br.color = Color(0.55, 0.53, 0.48)
	br.size = Vector2(150, 74)
	br.position = Vector2(760, 336)
	br.z_index = 0
	add_child(br)
	_examine_point(Vector2(835, 373), "ev_ashbrook_jembatan_terlalu_lebar")   # di jembatan

	# BEKAS akibat + benda (nol gambar baru: ruins.png, aset aman sudah di game/assets).
	# garis fondasi di rumput pinggiran (akibat) + batu fondasi berpahat di alun-alun (benda).
	# Dengan batu (benda), place_ashbrook_besar punya 3 jenis → JALUR SENDIRI terbuka (#228).
	_ruin_examine(Vector2(662, 452), "ev_ashbrook_fondasi_rumput", Color(0.62, 0.70, 0.45))
	_ruin_examine(Vector2(440, 300), "ev_ashbrook_batu_fondasi", Color(0.72, 0.70, 0.66))
	# Papan toko Otha yang tutup 2 musim: KOSONG + BEKAS CAT (varian 2 = bukti `akibat`).
	# Kayu pudar kecuali persegi tengah = "dulu ada tulisan". Nol penanda (D-3).
	_otha_sign(Vector2(560, 236))

	# air mancur KERING + bangku yang terlalu banyak
	var f := ColorRect.new()
	f.color = Color(0.45, 0.44, 0.42)
	f.size = Vector2(40, 28)
	f.position = VC + Vector2(-20, -14)
	add_child(f)
	for i in 8:
		var b := preload("res://scenes/world/Interactable.tscn").instantiate()
		add_child(b)
		b.setup("bench")
		b.global_position = VC + Vector2(-140 + i * 40, 70 if i % 2 == 0 else -80)

	_keeper(VC + Vector2(-150, 20), "ashbrook")       # Penjaga Pohon (#30)
	_world_gate(VC + Vector2(140, 30))                # Gerbang Penjelajah / titik-spawn (#204)

	# PORTAL: jalan NYATA ke Greenvale (kunjungan pertama = jalan kaki, #204)
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Jalan ke Greenvale [E]")
	portal.global_position = Vector2(EXIT_X, VC.y)

## Papan nama Otha (varian 2: kosong+bekas cat) — bukti akibat (ev_otha_papan_bekas_cat).
## Aset non-LPC diturunkan dari signboard.png (_tools/gen_otha_sign.py, #240).
func _otha_sign(pos: Vector2) -> void:
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/game/sprites/props/otha_sign_fadedmark.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(2, 2)
	spr.global_position = pos
	spr.z_index = int(pos.y)
	add_child(spr)
	_examine_point(pos + Vector2(0, 24), "ev_otha_papan_bekas_cat")

## Bekas fisik pakai ruins.png (aset AMAN, non-LPC, sudah di game/assets — nol gambar baru).
## Sprite terlihat + titik-periksa di depannya. Nol penanda "!" (D-3).
func _ruin_examine(pos: Vector2, ev_id: String, tint: Color) -> void:
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/game/sprites/props/ruins.png")
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.modulate = tint
	spr.global_position = pos
	spr.z_index = int(pos.y)
	add_child(spr)
	_examine_point(pos + Vector2(0, 20), ev_id)

## Titik-periksa Hukum Bukti (#226): hotspot tak terlihat di depan sebuah objek.
## Memeriksa → notice bukti muncul sbg teks periksa (Stage.say). Menandai ditemukan (R2).
func _examine_point(pos: Vector2, ev_id: String) -> void:
	var e := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(e)
	e.evidence_id = ev_id
	e.setup("examine")
	e.global_position = pos

func _building(kind: String, pos: Vector2, label: String) -> void:
	var spr := Sprite2D.new()
	var p := "res://assets/game/sprites/buildings/%s.png" % kind
	if ResourceLoader.exists(p):
		spr.texture = load(p)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.modulate = Color(0.92, 0.88, 0.82)      # kayu tua, bukan kelabu mayat
	spr.global_position = pos
	spr.z_index = int(pos.y)
	add_child(spr)
	var body := StaticBody2D.new()
	body.global_position = pos
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(58, 30)
	cs.shape = sh
	cs.position = Vector2(0, 12)
	body.add_child(cs)
	add_child(body)

## BUG-217d: API Interactable dipakai salah (kind="skill" + .location) → SCRIPT ERROR
## saat scene dimuat. Bentuk yang benar: setup("tree_keeper") + keeper_location.
func _keeper(pos: Vector2, town: String) -> void:
	var k := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(k)
	k.setup("tree_keeper")
	k.keeper_location = town
	k.global_position = pos

func _world_gate(pos: Vector2) -> void:
	var g := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(g)
	g.setup("world_gate")
	g.global_position = pos

# ---------------------------------------------------------------- kamar (bangun)
## ⚠ z KAMAR HARUS NEGATIF — dan angkanya dijepit dari DUA sisi.
##
## `Player.gd:54` melakukan `z_index = int(global_position.y)` untuk y-sort. `INTERIOR`
## ada di **koordinat negatif** `(-360,-260)`, jadi di dalam kamar z pemain jatuh ke
## **-260..-110** — dan lantai berlapis bawaan `z = 0` tergambar **DI ATASNYA**.
## Akibatnya pemain **tak terlihat** selama momen bangun: kamarnya lengkap, orangnya
## hilang, dan tak satu pun galat muncul.
##
## Batas atas: harus **di bawah -260** (z pemain paling atas di kamar ini).
## Batas bawah: harus **>= -1024**, yaitu `Light2D.range_z_min` bawaan — di luar itu
## perapian berhenti menyinarinya dan kamar jadi kotak hitam. (Pelajaran yang sama
## dengan lentera Merrit, dari arah berlawanan: dulu z TERLALU TINGGI, kini terlalu
## rendah sama merusaknya.)
##
## Ditemukan 2026-07-20 saat memasang interior Ashbrook64; dikonfirmasi sebagai
## pemain di scene 16px ini sebelum disentuh — bukan ditambal atas dugaan.
const Z_KAMAR := -900

func _build_interior() -> void:
	var room := ColorRect.new()
	room.color = Color(0.16, 0.13, 0.11)
	room.size = Vector2(220, 150)
	room.position = INTERIOR
	room.z_index = Z_KAMAR
	add_child(room)
	var fire := PointLight2D.new()          # perapian — hangat
	fire.energy = 1.2
	fire.texture_scale = 6.0
	fire.color = Color(1.0, 0.7, 0.4)
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	fire.texture = ImageTexture.create_from_image(img)
	fire.global_position = INTERIOR + Vector2(30, 40)
	add_child(fire)
	var win := ColorRect.new()              # jendela — hujan di luar
	win.color = Color(0.35, 0.42, 0.55)
	win.size = Vector2(34, 26)
	win.position = INTERIOR + Vector2(160, 24)
	win.z_index = Z_KAMAR + 1        # di atas lantai, tetap di bawah pemain
	add_child(win)
	# BUG-217e: pintu keluar memakai sinyal `interacted` yang TIDAK ADA di Interactable
	# → MOMEN BANGUN buntu (pemain terkunci di kamar). Kini: pemicu-area yang bekerja.
	var exit_zone := Area2D.new()
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(40, 20)
	cs.shape = sh
	exit_zone.add_child(cs)
	exit_zone.global_position = INTERIOR + Vector2(110, 146)
	add_child(exit_zone)
	exit_zone.body_entered.connect(func(b):
		if _in_interior and b == player:
			_leave_interior())

# ---------------------------------------------------------------- kehidupan
## Ayam yang BENAR-BENAR mengganggu jalan (bukan objek quest) + anak-anak berlari.
func _spawn_life() -> void:
	for i in 4:
		var c := Node2D.new()
		c.set_script(load("res://scenes/actors/AshbrookChicken.gd"))
		add_child(c)
		c.place(Vector2(372, 200) + Vector2(randf_range(-40, 60), randf_range(20, 70)))
		_chickens.append(c)
	for i in 3:
		var k := Node2D.new()
		k.set_script(load("res://scenes/actors/AshbrookKid.gd"))
		add_child(k)
		k.place(VC + Vector2(randf_range(-90, 90), randf_range(-40, 60)))
		k.setup(_chickens)          # anak-anak MENGEJAR ayam — hidup × mati (gudang kosong)
		_kids.append(k)

## BUG-217b: dua "kehidupan" di RUINS[] ternyata **hanya ada di teks** — kambing di
## jembatan & sepeda di gerbang tak pernah lahir di dunia. Hukum Tertinggi dilanggar
## di tempat yang justru paling terlihat (dua ujung jalan). Kini keduanya NYATA.
func _spawn_paired_life() -> void:
	# KAMBING — benar-benar menghalangi jembatan yang terlalu lebar
	var goat := Node2D.new()
	goat.set_script(load("res://scenes/actors/AshbrookChicken.gd"))
	add_child(goat)
	goat.body_radius = 9.0
	goat.wander_radius = 46.0                # ia menghalangi JEMBATAN — bukan berkelana
	goat.place(Vector2(820, 372))
	goat.scale = Vector2(2.1, 2.1)
	goat.modulate = Color(0.85, 0.82, 0.75)
	# SEPEDA KAYU di gerbang setengah runtuh — bersandar tiap pagi; masih dipakai
	var bike := ColorRect.new()
	bike.color = Color(0.55, 0.42, 0.28)
	bike.size = Vector2(18, 10)
	bike.position = Vector2(120, 300) + Vector2(14, 6)
	bike.z_index = 300
	bike.add_to_group("ashbrook_life")
	add_child(bike)

# ---------------------------------------------------------------- momen lampu (#218)
## KONTRAS DARI **PERBEDAAN**, BUKAN KETIADAAN.
## Rumah-rumah lain **menyala sore hari**, lalu **PADAM SATU PER SATU** menjelang malam
## (19.00 · 20.00 · 21.00) — sampai tersisa **satu**: lampu Merrit.
## Mata pemain harus MELIHAT jendela lain padam, bukan sekadar tak ada lampu.
func _build_windows() -> void:
	for w in [[Vector2(600, 424), 19], [Vector2(672, 288), 20], [Vector2(560, 216), 21],
			[Vector2(392, 440), 21], [Vector2(300, 236), 20]]:
		var win := Node2D.new()
		win.set_script(load("res://scenes/actors/AshbrookWindow.gd"))
		add_child(win)
		win.place(Vector2(w[0]) + Vector2(0, -8), int(w[1]))

## Merrit DUDUK MEMBACA SURAT di bawah lampunya — malam hari, tanpa dialog, tanpa
## cutscene, tanpa prompt. Pemain boleh menonton atau pergi. Isinya TIDAK dijelaskan
## (benih, bukan payoff — #216; kekuatannya ada pada penundaan).
func _build_lamp_seat() -> void:
	_seat = Node2D.new()
	add_child(_seat)
	var stool := ColorRect.new()
	stool.color = Color(0.35, 0.28, 0.2)
	stool.size = Vector2(12, 8)
	stool.position = MERRIT_HOUSE + Vector2(6, 4)
	_seat.add_child(stool)
	var letter := ColorRect.new()        # surat tua — kertas pucat, tak pernah dibuka pemain
	letter.color = Color(0.92, 0.88, 0.76)
	letter.size = Vector2(7, 5)
	letter.position = MERRIT_HOUSE + Vector2(14, 0)
	_seat.add_child(letter)
	_seat.visible = false

# ---------------------------------------------------------------- payoff perjalanan (#218)
## GAMBAR-JIWA cetak biru: *"…berjam-jam kemudian, saat pemain berjalan ke Greenvale,
## ia menoleh — dan masih bisa melihat lampu Merrit dari kejauhan."*
##
## Masalah nyata (#217): lampu 670 px dari titik keluar, sementara kamera hanya
## menampilkan ~640 px (zoom 2). Solusinya BUKAN memindahkan lampu — melainkan
## **titik-pandang**: di sini kamera MUNDUR (zoom 0.7 → tampak ~1830 px), desa
## mengecil di kejauhan, dan **satu titik cahaya tetap menyala di sana.**
func _build_vantage() -> void:
	var beacon := Sprite2D.new()          # lampu sebagai TITIK CAHAYA lintas-jarak
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.88, 0.6))
	beacon.texture = ImageTexture.create_from_image(img)
	beacon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	beacon.global_position = MERRIT_HOUSE + Vector2(18, -14)
	beacon.z_index = 4096
	beacon.scale = Vector2(1.6, 1.6)
	beacon.add_to_group("lamp_beacon")
	add_child(beacon)
	_beacon = beacon

	var zone := Area2D.new()
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(140, 120)
	cs.shape = sh
	zone.add_child(cs)
	zone.global_position = Vector2(VANTAGE_X, VC.y)
	zone.add_to_group("vantage")
	add_child(zone)
	zone.body_entered.connect(func(b):
		if b == player:
			_set_zoom(VANTAGE_ZOOM))
	zone.body_exited.connect(func(b):
		if b == player:
			_set_zoom(2.0))

func _set_zoom(z: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	for c in player.get_children():
		if c is Camera2D:
			create_tween().tween_property(c, "zoom", Vector2(z, z), 1.4)

## Apakah lampu Merrit BENAR-BENAR masuk layar dari titik-pandang? (diukur test #151b)
static func lamp_visible_from_vantage() -> bool:
	var half_view := (1280.0 / VANTAGE_ZOOM) * 0.5      # setengah lebar pandang di titik itu
	var lamp_x := MERRIT_HOUSE.x + 18.0
	return absf(VANTAGE_X - lamp_x) < half_view

# ---------------------------------------------------------------- monster pertama (#118)
## ANAK SERIGALA TERLUKA — monster gameplay PERTAMA (kanon opening).
## Boleh **dibantu**, **diabaikan**, atau **dibunuh** — ketiganya sah. Ia berdiri di
## jalan keluar, jauh dari zona aman: pertemuan pertama pemain dengan dunia liar.
func _spawn_wolf_pup() -> void:
	var inst := MonsterFactory.make("grey_wolf")
	if inst.is_empty():
		return
	inst["level"] = 1
	inst["name"] = "Anak Serigala (terluka)"
	inst["hp"] = max(1, int(inst.get("max_hp", 20)) / 4)     # terluka — bukan ancaman
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	m.global_position = Vector2(760, VC.y - 30)
	m.setup(inst, self)
	m.scale = Vector2(0.7, 0.7)
	m.add_to_group("wolf_pup")

func on_monster_died(_m) -> void:
	pass

func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	add_child(player)
	player.global_position = INTERIOR + Vector2(60, 80)

func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
	var pm := Node.new()
	pm.set_script(load("res://scenes/systems/PetManager.gd"))
	add_child(pm)

# ---------------------------------------------------------------- proses
func _process(delta: float) -> void:
	if canvas_mod:
		canvas_mod.color = GameClock.ambient_color()
	# LAMPU MERRIT: menyala siang & malam. Malam hari, ia satu-satunya yang menyala.
	var h := GameClock.wib_hour()
	if _lamp:
		_lamp.modulate = Color(1, 1, 1, 1.0 if h >= 17 or h < 6 else 0.75)
	if _seat:
		_seat.visible = h >= 19 or h < 5      # Merrit duduk membaca surat (tanpa prompt)
	if _beacon:
		var ba := 1.0 if h >= 17 or h < 6 else 0.55
		# Beacon = titik cahaya LINTAS-JARAK (#218), untuk dilihat dari titik-pandang
		# 670 px jauhnya. DARI DEKAT ia justru MENUTUPI lentera sungguhan: 6x6 px pada
		# posisi yang sama persis, z 4096 → di atas lentera, DAN di luar range_z_max
		# Light2D (1024) → tak tersentuh cahaya → terbaca sebagai KOTAK GELAP menempel
		# di kaca lentera pada malam hari. Dari dekat, lentera + glow-nya sudah bekerja
		# sendiri; beacon tak dibutuhkan. Node-nya TETAP ADA (uji #218 memeriksa grup).
		if player and player.global_position.distance_to(_beacon.global_position) < 320.0:
			ba = 0.0
		_beacon.modulate.a = ba
	if h != _last_hour:
		_last_hour = h
		for w in get_tree().get_nodes_in_group("ashbrook_window"):
			w.apply_hour(h)          # jendela PADAM satu per satu (19 · 20 · 21)
	_tick_stag(delta)

## WHITE STAG (#D-ASH-4): tanpa trigger, tanpa marker, tanpa musik, tanpa quest.
## ~0,5% per detik saat pemain berada di batas hutan. Muncul jauh & singkat, lalu
## hilang. Bila pemain melihat: bagus. Bila tidak: juga bagus — LEGENDA TIDAK WAJIB
## DITEMUKAN. Tak ada konfirmasi sistem apa pun: tak ada toast, tak ada Chronicle,
## tak ada achievement. Tujuannya satu: pemain ragu — "aku benar melihatnya?"
func _tick_stag(delta: float) -> void:
	if _stag_cd > 0.0:
		_stag_cd -= delta
		return
	if _in_interior or player == null or not is_instance_valid(player):
		return
	if player.global_position.y > FOREST_Y + 90.0:
		return
	if randf() > STAG_CHANCE * delta * 60.0:
		return
	_show_stag()

func _show_stag() -> void:
	_stag_cd = 240.0
	if _stag == null:
		_stag = Sprite2D.new()
		var img := Image.create(10, 14, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 0.9))
		_stag.texture = ImageTexture.create_from_image(img)
		_stag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_stag.z_index = 500
		add_child(_stag)
	_stag.global_position = Vector2(player.global_position.x + randf_range(-140, 140), FOREST_Y - 56)
	_stag.modulate.a = 0.0
	_stag.visible = true
	var tw := create_tween()
	tw.tween_property(_stag, "modulate:a", 0.55, 0.5)
	tw.tween_interval(1.1)
	tw.tween_property(_stag, "modulate:a", 0.0, 0.7)
	tw.tween_callback(func(): _stag.visible = false)
	# SENGAJA KOSONG: tak ada sfx, tak ada toast, tak ada Chronicle. Wonder murni.

## Dipakai test: apakah tiap keruntuhan berpasangan dengan kehidupan? (Hukum Tertinggi)
static func ruins_paired() -> bool:
	for r in RUINS:
		if String(r.get("life", "")).strip_edges() == "":
			return false
	return true
