extends Node2D
## CANDYVEIL (#300) — Kota Gula & Padang Permen. Dua dunia satu peta:
##   UTARA  (y 0..40)  : KOTA PERMEN-PERI — tata mockup v6 yang di-ACC Direktur
##                       (boulevard + jalan silang + spur pasar, poros kastil
##                       diapit dua menara, cincin plaza 4 toko, hunian barat/
##                       selatan berbaris, pasar kios 2x2, pinggiran PUDAR timur)
##   SELATAN (y 42..58) : padang liar lama — monster permen, Gummy Cavern,
##                       portal, keeper, world gate (sistem #287 dipertahankan)
##   TENGGARA           : LADANG GULA (papan "LAHAN PERLUASAN" — benih busur
##                       penggusuran) menutupi PEMAKAMAN TUA + GUBUK KAYU MANIS
##                       kosong. Kanon sheet #013: rumah Sora — ia belum pulang
##                       (#296 kunjungan panjang Ashbrook; kepulangan = v0.6c).
##
## Mockup = penempatan: koordinat petak di sini menyalin v6 apa adanya.
## Aset: game/assets/game/sprites/candyveil (#240, candyveil.credits.txt).

const TILE := 32
const MAP_W := 64
const MAP_H := 58
const JY := 20                 # baris boulevard (y 20-21)
const JX := 31                 # kolom jalan silang (x 31-32)
const KOTA_H := 40             # batas kota; di bawahnya padang liar
const SPAWN_TABLE := ["gummy_slime", "candyfloss_sheep", "jellybean_bunny", "choco_bear",
	"lollipop_sprite", "soda_serpent", "caramel_golem", "gummy_mimic"]
const MAX_MONSTERS := 12
const P := "res://assets/game/sprites/candyveil/"
const P_T := "res://assets/game/tiles/candyveil/"

var ground: TileMapLayer
var canvas_mod: CanvasModulate
var rain: GPUParticles2D
var player
var _monster_count := 0
var _spawn_timer := 0.0
var _shot_at := -1.0

@onready var CX := (JX + 1) * TILE   # sumbu tengah jalan silang (px)


func _ready() -> void:
	WorldState.mark_visited("candyveil")
	randomize()
	_build_ground()
	_build_boundaries()
	_sungai_soda()
	_kota()
	_ladang_dan_makam()
	_sora_pulang()
	_scatter_props()
	_dress_wild()
	_build_sky()
	_build_weather()
	_spawn_player()
	_spawn_gathering()
	_add_ui()
	_prime_monsters()
	EventBus.weather_changed.connect(_on_weather)
	Settings.changed.connect(func(): _on_weather(WorldState.weather))
	_on_weather(WorldState.weather)
	SafeZone.clear()   # kota dijaga lewat zona spawn (monster hanya y > KOTA_H+2)
	Stage.enter_region("Candyveil", "Kota gula peri — dan padang manis yang menipu di selatannya", "candyveil.ogg")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Candyveil fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())


func _process(delta: float) -> void:
	if canvas_mod:
		# AETHER_PIN_DAY: harness tangkap-layar mematok siang (pola Ashbrook64) —
		# permainan sungguhan tetap mengikuti jam WIB.
		if OS.get_environment("AETHER_PIN_DAY") == "1":
			canvas_mod.color = Color(1, 1, 1)
		else:
			canvas_mod.color = GameClock.ambient_color().lerp(Color(1.0, 0.85, 0.95), 0.15)
	if rain and player:
		rain.position = player.global_position + Vector2(0, -360)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 3.0
		if _monster_count < MAX_MONSTERS:
			_spawn_one()
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()


# ─────────────────────────────────────────────────────────────── TANAH & JALAN
func _candy_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["candy_grass_a_16", 0], ["candy_grass_b_16", 1], ["candy_path_16", 2],
			["soda_biru_a", 3], ["soda_biru_b", 4]]:
		var src := TileSetAtlasSource.new()
		src.texture = load(P_T + "%s.png" % i[0])
		src.texture_region_size = Vector2i(TILE, TILE)
		src.create_tile(Vector2i(0, 0))
		ts.add_source(src, i[1])
	return ts


func _jalan(x: int, y: int) -> void:
	ground.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))


func _build_ground() -> void:
	ground = TileMapLayer.new()
	ground.tile_set = _candy_tileset()
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground.set_cell(Vector2i(x, y), 1 if randf() < 0.14 else 0, Vector2i(0, 0))
	# BOULEVARD barat-timur (lurus — tata v6, bukan jalur berkelok liar)
	for x in range(MAP_W):
		_jalan(x, JY); _jalan(x, JY + 1)
	# JALAN SILANG utara-selatan: dari gerbang istana turun MENEMBUS padang —
	# lanjutannya adalah jalur memutar ke pemakaman (blockout #299, gabungan A+B)
	for y in range(9, 46):
		_jalan(JX, y); _jalan(JX + 1, y)
	# SPUR PASAR
	for x in range(JX, 55):
		_jalan(x, 15)
	# JALUR MEMUTAR pemakaman: belok timur DI BAWAH ladang, masuk dari barat
	for x in range(JX, 49):
		_jalan(x, 48); _jalan(x, 49)
	for y in range(49, 53):
		_jalan(48, y); _jalan(49, y)
	# PLAZA bundar di persilangan
	for tx in range(JX - 5, JX + 7):
		for ty in range(JY - 4, JY + 6):
			if pow(tx - (JX + 0.5), 2) / 30.0 + pow(ty - (JY + 0.5), 2) / 20.0 <= 1.35:
				_jalan(tx, ty)
	# SETAPAK pintu -> jalan (ubin — digambar di LAPISAN TANAH sehingga tak
	# pernah menimpa sprite bangunan; pelajaran mata mockup v6)
	for sx in [24, 40]:
		for sy in range(17, JY):
			_jalan(sx, sy)
		for sy in range(JY + 2, 26):
			_jalan(sx, sy)
	for sx in [9, 14, 19]:
		for sy in range(15, JY):
			_jalan(sx, sy)
	for sy in range(JY + 2, 27):
		_jalan(12, sy)
	for sx in range(8, 21):
		_jalan(sx, 27)
	for sx in range(26, 43):
		_jalan(sx, 31)
	for sx in [26, 37, 42]:
		_jalan(sx, 32)
	for sx in [44, 49]:
		for sy in range(13, 15):
			_jalan(sx, sy)
		for sy in range(16, 18):
			_jalan(sx, sy)
	for sy in range(13, 15):
		_jalan(53, sy)
	for sy in range(17, JY):
		_jalan(57, sy)
	for sy in range(JY + 2, 25):
		_jalan(57, sy)
	_jalan(JX, 9); _jalan(JX + 1, 9)   # ambang istana


func _sungai_soda() -> void:
	# kolom x4-5, dua ubin soda selang-seling; JEMBATAN = boulevard menerus
	for y in range(MAP_H):
		for k in range(2):
			ground.set_cell(Vector2i(4 + k, y), 3 if (y + k) % 2 == 0 else 4, Vector2i(0, 0))
	for x in [4, 5]:
		_jalan(x, JY); _jalan(x, JY + 1)
	# tanggul: sungai tak bisa diseberangi selain lewat jembatan
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	for seg in [Rect2(4 * TILE, 0, 2 * TILE, JY * TILE),
			Rect2(4 * TILE, (JY + 2) * TILE, 2 * TILE, (MAP_H - JY - 2) * TILE)]:
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = seg.size
		cs.shape = sh
		cs.position = seg.position + seg.size / 2
		body.add_child(cs)
	# tiang lampu di dua ujung jembatan
	for bx in [3 * TILE + 16, 6 * TILE + 16]:
		for by in [JY * TILE - 8, (JY + 2) * TILE + 8]:
			_put(P + "lampu_lolipop.png", Vector2(bx, by), 0.8)


# ───────────────────────────────────────────────────────────────────── KOTA
func _put(path: String, pos: Vector2, skala := 1.0, z := -1) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[candyveil] aset hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if skala != 1.0:
		s.scale = Vector2(skala, skala)
	s.position = pos - Vector2(0, s.texture.get_height() * skala * 0.5)
	s.z_index = int(pos.y) if z < 0 else z
	add_child(s)
	return s


## Bangunan = sprite (kaki di `kaki`) + tembok tabrak + pintu bicara (D-3:
## label netral, teks keluar saat ditanya). Pola Ashbrook: fasad bercerita.
func _bangunan(nama: String, kaki: Vector2, skala: float, label: String, baris: Array,
		speaker := "") -> void:
	var s := _put(P + nama + ".png", kaki, skala)
	if s == null:
		return
	var w := s.texture.get_width() * skala
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(w * 0.82, 30)
	cs.shape = sh
	cs.position = kaki - Vector2(0, 12)
	body.add_child(cs)
	var pintu := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pintu)
	pintu.global_position = kaki + Vector2(0, 10)
	pintu.setup_bicara(baris, label, speaker)


func _kota() -> void:
	# POROS UTARA — istana gula + dua menara lonceng simetris
	_bangunan("kastil_gula", Vector2(CX, 9 * TILE), 1.6, "Gerbang Istana Gula [E]", [
		"Gerbang gula-gula setinggi tiga orang. Dari dalam, samar: harpa, dan tawa.",
		"Penjaga gerbangnya gummy bear. Ia membungkuk sopan, lalu kembali mematung.",
	])
	_put(P + "menara_lonceng.png", Vector2(CX - 8 * TILE, 8 * TILE))
	_put(P + "menara_lonceng.png", Vector2(CX + 7 * TILE, 8 * TILE))

	# CINCIN PLAZA — 4 toko menghadap plaza
	# #304 — LAPOR HITUNGAN: sesudah menjadi saksi, angka itu bisa dibawa ke
	# balai. Kota tidak dilawan; kota DIBUAT CANGGUNG oleh satu angka (#122:
	# menyerahkan hitungan = membacakan barisnya di ambang pintu).
	if WorldState.get_counter("penggusuran_saksi") == 1 			and WorldState.get_counter("penggusuran_lapor") == 0:
		var balai := preload("res://scenes/world/Ashbrook64Prop.gd").new()
		add_child(balai)
		balai.global_position = Vector2(24 * TILE, 17 * TILE + 10)
		balai.set_counter = "penggusuran_lapor"
		balai.setup_bicara([
			"Petugas balai menerima hitunganmu tanpa mendongak. Lalu membacanya. Lalu mendongak.",
			"\"Empat puluh tujuh? Kau... menghitungnya? Tak ada yang pernah menghitungnya.\"",
			"Ia menaruh kertas itu di tumpukan paling atas. Tangannya pelan.",
		], "Balai Gula [E]", "")
		var s_b := _put(P + "roti_jahe.png", Vector2(24 * TILE, 17 * TILE), 1.4)
		if s_b:
			pass
		var body_b := StaticBody2D.new()
		body_b.collision_layer = 4
		body_b.collision_mask = 0
		add_child(body_b)
		var cs_b := CollisionShape2D.new()
		var sh_b := RectangleShape2D.new()
		sh_b.size = Vector2(150, 30)
		cs_b.shape = sh_b
		cs_b.position = Vector2(24 * TILE, 17 * TILE - 12)
		body_b.add_child(cs_b)
	else:
		_bangunan("roti_jahe", Vector2(24 * TILE, 17 * TILE), 1.4, "Balai Gula [E]", [
			"Balai kota dari roti jahe. Icing ambangnya diganti tiap musim — kata mereka.",
			"Papan pengumumannya penuh: festival, arisan gula, jadwal hujan sirup.",
		])
	_bangunan("toples", Vector2(40 * TILE, 17 * TILE), 1.2, "Toples Permen [E]", [
		"Toko permen. Stoknya terlihat dari luar — itulah gunanya rumah toples.",
	])
	_bangunan("cokelat_batang", Vector2(24 * TILE, 26 * TILE), 1.25, "Kedai Cokelat [E]", [
		"Kedai cokelat. Foil peraknya dikelupas pelanggan pertama tiap pagi — tradisi.",
	])
	_bangunan("es_krim", Vector2(40 * TILE, 27 * TILE), 1.3, "Kedai Es Krim [E]", [
		"Dua scoop hari ini: vanila dan stroberi. Cerinya bukan hiasan — itu cerobong.",
	])

	# HUNIAN BARAT — dua baris sejajar
	_bangunan("kincir", Vector2(9 * TILE, 15 * TILE), 1.35, "Kincir Permen [E]", [
		"Kincir menggiling gula jadi tepung salju. Bilahnya candy cane — tentu saja.",
	])
	_bangunan("makaron", Vector2(14 * TILE, 15 * TILE), 1.2, "Rumah Makaron [E]", [
		"Tiga keping makaron bertumpuk. Penghuninya tidur di keping tengah — paling empuk.",
	])
	_bangunan("permen_karet", Vector2(19 * TILE, 15 * TILE), 1.15, "Rumah Gumball [E]", [
		"Kubah kacanya penuh bola permen. Tak ada yang tahu koin sebesar apa yang memutarnya.",
	])
	_bangunan("kue_tart", Vector2(10 * TILE, 27 * TILE), 1.25, "Toko Sirup [E]", [
		"Toko sirup di tepi sungai soda. Stroberi di puncaknya asli — diganti tiap Jumat.",
	])
	_bangunan("kue_mangkuk", Vector2(15 * TILE, 27 * TILE), 1.15, "Rumah Cupcake [E]", [
		"Wrapper-nya dilipit rapi. Frosting-nya menara. Cerinya jangan dimakan — itu atap.",
	])
	_bangunan("jamur_cokelat", Vector2(19 * TILE + 16, 27 * TILE), 1.5, "Rumah Jamur Cokelat [E]", [
		"Cendawan cokelat susu. Peri tua di sini menolak pindah ke rumah kue.",
	])

	# PASAR TIMUR — kios 2x2 + pedagang + penginapan wafel (inn sungguhan)
	for kpos in [Vector2(44 * TILE, 14 * TILE), Vector2(49 * TILE, 14 * TILE),
			Vector2(44 * TILE, 18 * TILE + 16), Vector2(49 * TILE, 18 * TILE + 16)]:
		_put(P + "kios_permen.png", kpos, 1.1)
	var pedagang := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(pedagang)
	pedagang.setup("shop")
	pedagang.scale = Vector2(2, 2)
	pedagang.global_position = Vector2(46 * TILE + 16, 14 * TILE + 20)
	_put(P + "wafel.png", Vector2(53 * TILE + 16, 13 * TILE), 1.3)
	var inn := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(inn)
	inn.setup("inn")
	inn.scale = Vector2(2, 2)
	inn.global_position = Vector2(53 * TILE + 16, 13 * TILE + 28)

	# HUNIAN SELATAN — berbaris di gang
	_bangunan("donat", Vector2(26 * TILE, 33 * TILE), 1.15, "Rumah Donat [E]", [
		"Lubang donatnya adalah pintu. Penghuninya menyebutnya efisiensi; tetangganya menyebutnya nasib.",
	])
	_bangunan("kue_mangkuk", Vector2(37 * TILE, 33 * TILE), 1.1, "Rumah Cupcake [E]", [
		"Cupcake stroberi. Taburannya bertambah tiap tahun — satu untuk tiap ulang tahun.",
	])
	_bangunan("jamur_ceri", Vector2(42 * TILE, 33 * TILE), 1.6, "Rumah Jamur Ceri [E]", [
		"Cendawan merah ceri; bintik gulanya paling rapi sekampung.",
	])

	# PINGGIRAN PUDAR timur (K3 — kota yang sama, warnanya pergi duluan)
	_bangunan("donat_pudar", Vector2(57 * TILE, 17 * TILE), 1.05, "Rumah Donat [E]", [
		"Glasirnya dulu merah muda. Sekarang... kau harus percaya pada kata orang.",
	])
	_put(P + "jamur_pudar.png", Vector2(60 * TILE, 17 * TILE + 16), 1.7)
	_bangunan("kue_mangkuk_pudar", Vector2(57 * TILE, 26 * TILE), 1.0, "Rumah Cupcake [E]", [
		"Frosting-nya masih menara. Warnanya sudah turun duluan.",
	])

	# GAPURA barat & timur + AIR MANCUR SIRUP
	_put(P + "gapura.png", Vector2(8 * TILE, (JY + 2) * TILE + 10), 1.2)
	_put(P + "gapura.png", Vector2(54 * TILE, (JY + 2) * TILE + 10), 1.1)
	_put(P + "fountain_sirup.png", Vector2(CX, (JY + 1) * TILE + 8), 1.5)

	# LAMPU LOLIPOP berjarak tetap dua sisi jalan + 4 lentera plaza bercahaya
	for lx in range(10, MAP_W - 6, 5):
		if abs(lx - JX) <= 6:
			continue
		_put(P + "lampu_lolipop.png", Vector2(lx * TILE, JY * TILE - 6))
		_put(P + "lampu_lolipop.png", Vector2((lx + 2) * TILE, (JY + 2) * TILE + 26))
	for ly in range(11, 35, 6):
		if abs(ly - JY) <= 4:
			continue
		_put(P + "lampu_lolipop.png", Vector2(JX * TILE - 12, ly * TILE))
		_put(P + "lampu_lolipop.png", Vector2((JX + 2) * TILE + 12, (ly + 3) * TILE))
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var lentera_tex := ImageTexture.create_from_image(img)
	for pos in [Vector2(CX - 3 * TILE, JY * TILE - 24), Vector2(CX + 3 * TILE, JY * TILE - 24),
			Vector2(CX - 3 * TILE, (JY + 2) * TILE + 24), Vector2(CX + 3 * TILE, (JY + 2) * TILE + 24)]:
		if _put("res://assets/game/sprites/lpc32/lentera32.png", pos, 1.5):
			var pl := PointLight2D.new()
			pl.energy = 1.0
			pl.texture_scale = 5.0
			pl.color = Color(1.0, 0.84, 0.55)
			pl.texture = lentera_tex
			pl.global_position = pos + Vector2(0, -40)
			add_child(pl)

	# dua gummy plaza BERDIALOG (#304) — kota yang bisa diajak bicara
	var g1 := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(g1)
	g1.global_position = Vector2(CX - 2 * TILE, JY * TILE + 34)
	g1.setup_bicara([
		"\"Grrmlb. Mlb.\" (Ia memantul pelan, ramah.)",
		"Gummy merah. Aromanya stroberi. Sepertinya itu keseluruhan pendapatnya.",
	], "Gummy merah [E]")
	var g2 := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(g2)
	g2.global_position = Vector2(CX + TILE, (JY + 1) * TILE + 46)
	g2.setup_bicara([
		"\"Blbl. Grr... mlb?\" (Ia menunjuk air mancur sirup, lalu perutnya.)",
		"Permintaannya jelas sekaligus mustahil ditolak dan mustahil dipahami.",
	], "Gummy hijau [E]")

	# PENGHUNI GUMMY statis (LPC Candy CC0) — plaza & pasar, tempat berkumpul
	for spec in [["gummy_merah", Vector2(CX - 2 * TILE, JY * TILE + 8)],
			["gummy_hijau", Vector2(CX + TILE, (JY + 1) * TILE + 20)],
			["gummy_putih", Vector2(45 * TILE, 15 * TILE + 20)],
			["gummy_biru", Vector2(50 * TILE, 15 * TILE + 20)],
			["gummy_hijau", Vector2(CX - TILE, 10 * TILE)]]:
		_put(P + str(spec[0]) + ".png", spec[1])

	# HUTAN LOLIPOP memeluk kota — dua baris utara berjarak tetap, digelapkan
	for tx in range(0, MAP_W + 1, 2):
		var t1 := _put("res://assets/game/sprites/props/tree_candy.png",
			Vector2(tx * TILE + 16, 3 * TILE), 2.2)
		if t1:
			t1.modulate = Color(0.72, 0.72, 0.72)
		var t2 := _put("res://assets/game/sprites/props/tree_candy.png",
			Vector2(tx * TILE, int(2.5 * TILE)), 2.4)
		if t2:
			t2.modulate = Color(0.72, 0.72, 0.72)


# ──────────────────────────────────────────────── LADANG GULA & PEMAKAMAN
func _ladang_dan_makam() -> void:
	# LADANG: barisan lolipop muda — mesin penggusuran yang sopan (busur Sora)
	for lx in range(45, 62, 3):
		for ly in range(41, 47, 2):
			var c := _put("res://assets/game/sprites/props/lollipop.png",
				Vector2(lx * TILE, ly * TILE), 1.6)
			if c:
				c.modulate = Color(1.0, 0.9, 0.95)
	var papan := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(papan)
	papan.global_position = Vector2(45 * TILE, 40 * TILE + 16)
	if WorldState.get_counter("penggusuran_lapor") == 1:
		# DITUNDA, bukan dimenangkan — kota cuma tidak menyangka ada yang melihat.
		WorldState.counters["warisan:penggusuran_ditunda"] = 1   # metrik hakim (D-4)
		papan.setup_bicara([
			"PAPAN KOTA: \"PERLUASAN DITINJAU ULANG — MENUNGGU PENDATAAN.\"",
			"Kata \"pendataan\" ditulis dengan tinta yang lebih baru daripada papannya.",
		], "Papan kota [E]")
	else:
		papan.setup_bicara([
			"PAPAN KOTA: \"LAHAN PERLUASAN LADANG GULA — MUSIM DEPAN.\"",
			"Di bawahnya, huruf kecil: \"termasuk petak tenggara.\" Tak ada yang menyebut petak itu punya nama.",
		], "Papan kota [E]")

	# PEMAKAMAN TUA tersembunyi di tenggara — pagar patah, nisan aus
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = 20260727
	for gx in range(50, 62, 2):
		for gy in range(51, 56, 2):
			if rng2.randf() < 0.16:
				continue
			var n := _put("res://assets/game/sprites/props/" +
				("nisan_terbaca.png" if rng2.randf() < 0.3 else "nisan_aus.png"),
				Vector2(gx * TILE + rng2.randi_range(-6, 6), gy * TILE + rng2.randi_range(-5, 5)))
			if n:
				n.modulate = Color(0.85, 0.88, 0.85)
	for fx in range(50, 62, 2):
		_put("res://assets/game/tiles/lpc32/pagar_tiang32.png", Vector2(fx * TILE, 50 * TILE))

	# GUBUK KAYU MANIS — rumah Sora. Kosong. Menunggu. (sheet #013 + #296)
	_put(P + "roti_jahe_pudar.png", Vector2(59 * TILE, 55 * TILE), 0.8)
	var gubuk := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(gubuk)
	gubuk.global_position = Vector2(59 * TILE, 55 * TILE + 12)
	gubuk.setup_bicara([
		"Gubuk kayu manis kecil, menempel di pagar pemakaman. Pintunya tak dikunci — tak ada yang perlu dikunci.",
		"Sebuah lentera disimpan rapi di ambang jendela, sumbunya baru.",
		"Siapa pun pemiliknya, ia berniat pulang.",
	], "Gubuk kayu manis [E]")


## Jam WIB untuk keputusan build — override `uji_jam_paksa` (jam+1) khusus
## harness, counter yang sama dengan Ashbrook64 (#296, anti-flake #273).
func _wib_jam() -> int:
	var paksa := WorldState.get_counter("uji_jam_paksa")
	if paksa > 0:
		return paksa - 1
	return GameClock.wib_hour()


func _lampu_kecil(pos: Vector2) -> void:
	if _put("res://assets/game/sprites/lpc32/lentera32.png", pos) == null:
		return
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var l := PointLight2D.new()
	l.energy = 1.1
	l.texture_scale = 4.0
	l.color = Color(1.0, 0.82, 0.55)
	l.texture = ImageTexture.create_from_image(img)
	l.global_position = pos + Vector2(0, -10)
	add_child(l)


## #302 — SORA PULANG (v0.6c). Panggilan Ashbrook selesai; ia kembali ke
## gubuknya: siang di ambang gubuk, malam beritual di pemakaman kotanya
## sendiri — pemakaman yang mau digusur papan itu. Dialog = E8: kalimatnya
## bergeser lagi begitu ada saksi kedua (penggusuran_saksi).
func _sora_pulang() -> void:
	QuestPribadi.cek_sora_pulang()
	if WorldState.get_counter("sora_pulang") != 1:
		return
	var p_sora := "res://assets/game/sprites/characters/sora_idle.png"
	if not ResourceLoader.exists(p_sora):
		return
	var malam := _wib_jam() >= 19
	var pos := Vector2(55 * TILE, 53 * TILE) if malam else Vector2(58 * TILE, 55 * TILE + 20)
	var s := Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = load(p_sora)
	at.region = Rect2(0, 128, 64, 64)
	s.texture = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = pos - Vector2(0, 32)
	s.z_index = int(pos.y)
	add_child(s)
	if malam:
		_lampu_kecil(pos + Vector2(-30, 6))
		_lampu_kecil(pos + Vector2(30, -4))
	var t := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(t)
	t.global_position = pos + Vector2(0, 26)
	if WorldState.get_counter("penggusuran_lapor") == 1:
		t.setup_bicara([
			"\"'Ditinjau ulang.' Itu kata kota untuk 'kami tidak menyangka ada yang melihat.'\"",
			"\"Musim depan mereka akan coba lagi. Musim depannya lagi, aku masih di sini.\"",
			"\"...Terima kasih. Untuk ikut menghitung.\"",
		], "Sora [E]", "Sora")
	elif WorldState.get_counter("penggusuran_saksi") == 1:
		t.setup_bicara([
			"\"Kau menghitungnya juga, kan. Empat puluh tujuh.\"",
			"\"Kalau mereka datang musim depan, setidaknya ada dua orang yang tahu berapa jumlahnya.\"",
			"\"Itu bukan perlawanan. Belum. Tapi semua perlawanan mulai dari hitungan.\"",
		], "Sora [E]", "Sora")
	else:
		t.qp_id = "sora_makam"
		t.setup_bicara([
			"\"Kau. ...Jauh dari Ashbrook.\"",
			"\"Ini rumahku. Mereka semua — aku yang jaga.\"",
			"\"Kau lihat papan itu? 'Musim depan.' Mereka menghitung musim; aku menghitung nisan.\"",
		], "Sora [E]", "Sora")


# ─────────────────────────────────────────────── (sistem lama — dipertahankan)
func _build_boundaries() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-32, -32, w + 64, 32), Rect2(-32, h, w + 64, 32), Rect2(-32, 0, 32, h), Rect2(w, 0, 32, h)]:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		cs.shape = shape
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)


func _dress_wild() -> void:
	# WildDresser HANYA menyentuh padang selatan — kota & ladang/makam dilindungi.
	var spawn := Vector2(MAP_W * TILE * 0.5, MAP_H * TILE - 120)
	var avoid := [Rect2(0, 0, MAP_W * TILE, (KOTA_H + 1) * TILE),
		Rect2(43 * TILE, 40 * TILE, 21 * TILE, 18 * TILE),
		Rect2(spawn - Vector2(260, 280), Vector2(520, 440))]
	WildDresser.dress(self, "candy", MAP_W, MAP_H, avoid, [], TILE)
	var amb := Node2D.new()
	amb.set_script(load("res://scenes/systems/Ambience.gd"))
	add_child(amb)
	amb.setup("candy")


func _scatter_props() -> void:
	var props := Node2D.new()
	props.y_sort_enabled = true
	add_child(props)
	var deco := [
		P_T + "candy_gummy_bush_16.png", P_T + "candy_gummy_bush_16.png",
		P_T + "candy_mint_rock_16.png", "res://assets/game/sprites/props/gumdrop.png",
		"res://assets/game/sprites/props/lollipop.png", "res://assets/game/sprites/props/candy_cane.png",
	]
	# padang selatan tetap liar seperti dulu
	for i in range(60):
		var s := Sprite2D.new()
		s.texture = load(deco[randi() % deco.size()])
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(2, 2)
		s.position = Vector2(randf_range(48, 42 * TILE), randf_range((KOTA_H + 2) * TILE, MAP_H * TILE - 48))
		props.add_child(s)
	# kota: dekor DITATA — gumdrop penanda empat pintu plaza (v6, bukan taburan)
	for pos in [Vector2(CX - 5 * TILE, (JY + 1) * TILE), Vector2(CX + 6 * TILE, (JY + 1) * TILE),
			Vector2(CX, (JY - 4) * TILE), Vector2(CX, (JY + 6) * TILE)]:
		var g := Sprite2D.new()
		g.texture = load("res://assets/game/sprites/props/gumdrop.png")
		g.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		g.scale = Vector2(2, 2)
		g.position = pos
		props.add_child(g)
	# kolam soda animasi hanya di padang
	for i in range(6):
		var a := AnimatedSprite2D.new()
		a.sprite_frames = SheetUtil.build_strip(load(P_T + "candy_soda_f1_16.png"), 16, 1, "s", 2.0)
		a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		a.scale = Vector2(2, 2)
		a.position = Vector2(randf_range(80, 42 * TILE), randf_range((KOTA_H + 2) * TILE, MAP_H * TILE - 80))
		a.play("s")
		props.add_child(a)


func _build_sky() -> void:
	canvas_mod = CanvasModulate.new()
	add_child(canvas_mod)


func _build_weather() -> void:
	rain = GPUParticles2D.new()
	rain.amount = 90
	rain.lifetime = 0.8
	rain.z_index = 20
	rain.emitting = false
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(560, 10, 1)
	mat.gravity = Vector3(0, 700, 0)
	mat.initial_velocity_min = 220.0
	mat.initial_velocity_max = 320.0
	mat.color = Color(1.0, 0.6, 0.85)
	rain.process_material = mat
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.7, 0.9))
	rain.texture = ImageTexture.create_from_image(img)
	add_child(rain)


func _on_weather(w: String) -> void:
	if rain:
		rain.emitting = (w in ["rain", "thunderstorm"]) and not Settings.eco_mode


func _spawn_player() -> void:
	player = preload("res://scenes/actors/Player.tscn").instantiate()
	if WorldState.pending_return_pos != null:
		player.global_position = WorldState.pending_return_pos
		WorldState.pending_return_pos = null
	else:
		player.global_position = Vector2(8 * TILE, (JY + 1) * TILE)   # gerbang barat kota
	add_child(player)
	for c in player.get_children():
		if c is Camera2D:
			c.zoom = Vector2(1.0, 1.0)
			c.limit_left = 0; c.limit_top = 0
			c.limit_right = MAP_W * TILE; c.limit_bottom = MAP_H * TILE


func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
	var pm := Node.new()
	pm.set_script(load("res://scenes/systems/PetManager.gd"))
	add_child(pm)
	# portal Greenvale = pintu dagang kota, di tepi barat boulevard
	var portal := preload("res://scenes/homestead/Portal.tscn").instantiate()
	add_child(portal)
	portal.setup("res://scenes/Main.tscn", "Kembali ke Greenvale [E]")
	portal.scale = Vector2(2, 2)
	portal.global_position = Vector2(2 * TILE, (JY + 1) * TILE)
	# dunia liar selatan: dungeon + keeper + world gate
	var dungeon := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(dungeon)
	dungeon.dungeon_scene = "res://scenes/world/GummyCavern.tscn"
	dungeon.dungeon_label = "Gummy Cavern ▼ [E]"
	dungeon.setup("dungeon")
	dungeon.scale = Vector2(2, 2)
	dungeon.global_position = Vector2(24 * TILE, 52 * TILE)
	_keeper(Vector2(14 * TILE, 50 * TILE), "candyveil_palace")
	_world_gate(Vector2(10 * TILE, 52 * TILE))
	# warga istana (E6 #78) berkeliaran di pelataran kastil — bukan di padang
	TownFolk.place(self, "candyveil_palace", Vector2(CX, 13 * TILE), 95)
	MiracleSystem.manifest(self, Vector2(CX, (JY + 1) * TILE), 480.0)


func _spawn_gathering() -> void:
	var holder := Node2D.new()
	holder.y_sort_enabled = true
	add_child(holder)
	for i in range(12):
		var node := preload("res://scenes/world/GatherNode.tscn").instantiate()
		holder.add_child(node)
		node.global_position = Vector2(randf_range(96, 42 * TILE),
			randf_range((KOTA_H + 2) * TILE, MAP_H * TILE - 96))
		node.scale = Vector2(2, 2)
		node.setup("lollipop", "cv_lolli_%d" % i)


func _prime_monsters() -> void:
	for i in range(8):
		_spawn_one()


func _spawn_one() -> void:
	var species: String = Seasons.pick_species(SPAWN_TABLE)
	if not MonsterFactory.spawnable_now(species):
		return
	var inst := MonsterFactory.make(species)
	if inst.is_empty():
		return
	var m := preload("res://scenes/actors/Monster.tscn").instantiate()
	add_child(m)
	# monster HANYA di padang selatan — kota gula bukan medan buru
	var pos := Vector2(randf_range(128, 42 * TILE), randf_range((KOTA_H + 2) * TILE, MAP_H * TILE - 128))
	if player and pos.distance_to(player.global_position) < 240:
		pos += Vector2(280, 0)
	m.global_position = pos
	m.setup(inst, self)
	_monster_count += 1


func on_monster_died(_m) -> void:
	_monster_count = max(0, _monster_count - 1)


func _keeper(pos: Vector2, loc: String) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("tree_keeper"); n.keeper_location = loc; n.scale = Vector2(2, 2); n.global_position = pos


func _world_gate(pos: Vector2) -> void:
	var n := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(n); n.setup("world_gate"); n.scale = Vector2(2, 2); n.global_position = pos
