extends Node2D
## GOLDHAVEN (#309 — kota 002, Crossroads of Aurelia, Valenford).
## Tata CINCIN blockout #308 yang di-ACC: tembok bata + 4 gerbang karavan ->
## jalan raya silang + cincin jalan dalam -> PASAR AGUNG radial (12 kios)
## dengan MENARA TIMBANGAN di pusatnya -> cincin-1 gedung serikat/bank/balai ->
## blok hunian padat -> gudang karavan dekat gerbang selatan.
## Gang timur-laut: pintu besi TERSEGEL (HIDDEN — teks netral, nol nama, D-3).
##
## 35.000 jiwa = ILUSI KEPADATAN: fasad menjulang + kerumunan TownFolk +
## karavan/gerobak + kios radial. NOL monster — ini kota, bukan medan buru.
## Kanon 002: "pemain pertama kali menyadari dunia jauh lebih besar" — spawn
## default gerbang BARAT (arah Ashbrook), plaza & menara menjulang di depannya.
##
## Blockout = penempatan: koordinat petak menyalin _tools/mockup_goldhaven_blockout.py.
## Aset: sprites/goldhaven (#240, goldhaven.credits.txt — recolor + gambar-rakit).

const TILE := 32
const MAP_W := 80
const MAP_H := 56
const JX := 40                  # sumbu jalan utara-selatan (x 38..42)
const JY := 28                  # sumbu jalan barat-timur  (y 26..30)
const P := "res://assets/game/sprites/goldhaven/"
const P_L := "res://assets/game/sprites/lpc32/"
const P_T := "res://assets/game/tiles/lpc32/"

var ground: TileMapLayer
var canvas_mod: CanvasModulate
var rain: GPUParticles2D
var player
var _shot_at := -1.0

@onready var CX := JX * TILE + 16
@onready var CY := JY * TILE + 16


func _ready() -> void:
	WorldState.mark_visited("goldhaven")
	randomize()
	_build_ground()
	_build_boundaries()
	_tembok_kota()
	_kota()
	_pasar_agung()
	_gang_tersegel()
	_build_sky()
	_build_weather()
	_spawn_player()
	_add_ui()
	EventBus.weather_changed.connect(_on_weather)
	Settings.changed.connect(func(): _on_weather(WorldState.weather))
	_on_weather(WorldState.weather)
	SafeZone.clear()   # nol monster di scene — kota sepenuhnya aman
	Stage.enter_region("Goldhaven", "Persimpangan Aurelia — semua jalan lewat sini, dan semua ditimbang", "town.ogg")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Goldhaven fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())


func _process(delta: float) -> void:
	if canvas_mod:
		# AETHER_PIN_DAY: harness tangkap-layar mematok siang (pola Ashbrook64).
		if OS.get_environment("AETHER_PIN_DAY") == "1":
			canvas_mod.color = Color(1, 1, 1)
		else:
			canvas_mod.color = GameClock.ambient_color().lerp(Color(1.0, 0.93, 0.8), 0.12)
	if rain and player:
		rain.position = player.global_position + Vector2(0, -360)
	if _shot_at > 0.0:
		_shot_at -= delta
		if _shot_at <= 0.0:
			if DisplayServer.get_name() != "headless":
				var img := get_viewport().get_texture().get_image()
				if img: img.save_png("user://shot.png")
			get_tree().quit()


# ─────────────────────────────────────────────────────────────── TANAH & JALAN
func _tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	for i in [["grass32", 0], ["ladang_tanah32", 1], ["stone32", 2], ["cobble32", 3]]:
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
	ground.tile_set = _tileset()
	add_child(ground)
	# luar tembok = rumput; dalam tembok = tanah karavan terinjak (selang cobble)
	for y in range(MAP_H):
		for x in range(MAP_W):
			if x < 2 or x > 78 or y < 2 or y > 54:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			else:
				# tanah karavan nyaris polos — cobble 22% terbaca sebagai ubin
				# rusak belang-belang dari kamera main (mata #309), bukan tekstur
				ground.set_cell(Vector2i(x, y), 3 if randf() < 0.05 else 1, Vector2i(0, 0))
	# JALAN RAYA SILANG (blockout: x38..42, y26..30) — menembus keluar gerbang
	for y in range(MAP_H):
		for x in range(38, 43):
			_jalan(x, y)
	for x in range(MAP_W):
		for y in range(26, 31):
			_jalan(x, y)
	# CINCIN JALAN DALAM mengitari plaza (blockout: x26..54 / y16..40, lebar 2)
	for x in range(26, 55):
		_jalan(x, 16); _jalan(x, 17); _jalan(x, 39); _jalan(x, 40)
	for y in range(16, 41):
		_jalan(26, y); _jalan(27, y); _jalan(53, y); _jalan(54, y)
	# PASAR AGUNG — plaza ellipse batu (pusat 40,28; rx 11, ry 9)
	for tx in range(JX - 12, JX + 13):
		for ty in range(JY - 10, JY + 11):
			if pow(tx - 40.0, 2) / 121.0 + pow(ty - 28.0, 2) / 81.0 <= 1.0:
				_jalan(tx, ty)
	# setapak pintu -> cincin jalan (di LAPISAN TANAH — tak menimpa fasad)
	for sx in [31, 48]:
		for sy in range(18, 26):   # serikat & bank turun ke jalan barat-timur
			_jalan(sx, sy)
		for sy in range(31, 39):   # balai & rumah kontrak naik dari selatan
			_jalan(sx, sy)
	for sy in [27, 28, 29]:
		for sx in range(22, 26):   # penginapan ke cincin barat
			_jalan(sx, sy)
		for sx in range(55, 59):   # aula dagang ke cincin timur
			_jalan(sx, sy)
	# gang hunian: baris utara (y 14) dan selatan (y 42) + gang gudang (y 50)
	for x in range(10, 71):
		_jalan(x, 14)
	for x in range(10, 71):
		_jalan(x, 42)
	for x in range(10, 71):
		_jalan(x, 50)
	for y in range(14, 27):
		_jalan(14, y); _jalan(66, y)
	for y in range(30, 51):
		_jalan(14, y); _jalan(66, y)
	# gang timur-laut menuju pintu tersegel (sengaja BUNTU) — di CELAH antara
	# hunian x57 dan x65, bukan menembus rumah (mata #309)
	for y in range(9, 15):
		_jalan(61, y)


# ─────────────────────────────────────────────────────── TEMBOK & 4 GERBANG
## Tembok bata keliling (blockout: bingkai 2..78 x 2..54) dengan celah gerbang:
## utara/selatan x37..43, barat/timur y25..31. Collision per segmen.
func _tembok_kota() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	var seg := [
		# [rect petak] — dinding utara & selatan terbelah gerbang
		Rect2(2, 2, 35, 1), Rect2(44, 2, 35, 1),
		Rect2(2, 54, 35, 1), Rect2(44, 54, 35, 1),
		# barat & timur
		Rect2(2, 3, 1, 22), Rect2(2, 32, 1, 22),
		Rect2(78, 3, 1, 22), Rect2(78, 32, 1, 22),
	]
	for rc in seg:
		var px_rect := Rect2(rc.position * TILE, rc.size * TILE)
		var s := Sprite2D.new()
		s.texture = load(P_L + "wall_brick.png")
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		s.region_enabled = true
		s.region_rect = Rect2(Vector2.ZERO, px_rect.size)
		s.centered = false
		s.position = px_rect.position
		s.z_index = 2
		add_child(s)
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = px_rect.size
		cs.shape = sh
		cs.position = px_rect.position + px_rect.size / 2
		body.add_child(cs)
	# GERBANG BATU di keempat celah + gerobak karavan menunggu giliran masuk
	_put(P + "gerbang_batu.png", Vector2(JX * TILE + 16, 3 * TILE), 1.4)
	_put(P + "gerbang_batu.png", Vector2(JX * TILE + 16, 55 * TILE), 1.4)
	_put(P + "gerbang_batu.png", Vector2(3 * TILE, 32 * TILE), 1.2)
	_put(P + "gerbang_batu.png", Vector2(77 * TILE, 32 * TILE), 1.2)
	for g in [Vector2(37 * TILE, 7 * TILE), Vector2(44 * TILE, 51 * TILE),
			Vector2(8 * TILE, 27 * TILE + 16), Vector2(72 * TILE, 30 * TILE)]:
		_put(P_L + "gerobak32.png", g, 1.3)


# ───────────────────────────────────────────────────────────────────── KOTA
func _put(path: String, pos: Vector2, skala := 1.0, z := -1) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[goldhaven] aset hilang: %s" % path)
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


## Pola Candyveil: sprite (kaki di `kaki`) + tembok tabrak + pintu bicara.
## Fasad BERCERITA (D-3: label netral, teks keluar saat ditanya).
func _bangunan(nama: String, kaki: Vector2, skala: float, label: String, baris: Array) -> void:
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
	pintu.setup_bicara(baris, label, "")


func _kota() -> void:
	# CINCIN-1 — gedung menghadap plaza (nomor blockout 2-7)
	_bangunan("fasad_serikat", Vector2(31 * TILE + 16, 24 * TILE), 1.0, "Kantor Pusat Serikat Penjelajah [E]", [
		"KANTOR PUSAT SERIKAT PENJELAJAH. Papan misinya empat kali papan Greenvale — dan penuh.",
		"Petugasnya menyebut cabang-cabang: Greenvale, Thornwatch, Tidegate... daftarnya masih panjang.",
		"Di dinding: peta Aurelia. Ashbrook cuma titik kecil di sudut barat. Titik. Kecil.",
	])
	_bangunan("fasad_bank", Vector2(48 * TILE + 16, 24 * TILE), 1.0, "Bank Goldhaven [E]", [
		"Bank Goldhaven. Pintunya dua lapis; yang dalam katanya perlu tiga kunci berbeda.",
		"Antrean penukar uang mengular. Tujuh mata uang, satu timbangan, nol senyum.",
	])
	_bangunan("fasad_kontrak", Vector2(48 * TILE + 16, 38 * TILE), 1.0, "Rumah Kontrak [E]", [
		"Rumah Kontrak. Semua janji di kota ini ditulis, disegel, dan ditimbang di sini.",
		"Di ambang: \"LISAN TIDAK DIHITUNG.\" Hurufnya sudah aus disentuh orang yang berharap.",
	])
	_bangunan("fasad_balai_gh", Vector2(31 * TILE + 16, 38 * TILE), 1.0, "Balai Kota Goldhaven [E]", [
		"Balai kota. Pengumumannya bertumpuk tujuh lapis; yang terbawah sudah jadi sejarah.",
		"Tarif gerbang naik musim ini. Karavan mengeluh. Karavan tetap datang.",
	])
	_bangunan("fasad_hunian_a", Vector2(24 * TILE + 16, 24 * TILE), 1.0, "Penginapan Karavan [E]", [
		"Penginapan Karavan. Kandang di belakang, kasur di atas, cerita di ruang tengahnya.",
		"Papan tarifnya tiga bahasa. Coretan di bawahnya lebih banyak lagi.",
	])
	var inn := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(inn)
	inn.setup("inn")
	inn.scale = Vector2(2, 2)
	inn.global_position = Vector2(24 * TILE + 16, 24 * TILE + 40)
	_bangunan("fasad_aula", Vector2(56 * TILE, 30 * TILE + 16), 1.0, "Aula Dagang [E]", [
		"Aula Dagang. Lelang pagi: rempah dan kain. Lelang sore: apa saja yang tersisa.",
		"Suara juru lelangnya terdengar sampai plaza — kota ini menganggapnya musik.",
	])

	# BLOK HUNIAN — baris rapi (blockout 8-19), selang dua fasad supaya tak kembar
	var rumah_baris := [
		[Vector2(14, 12), "a"], [Vector2(22, 12), "b"], [Vector2(57, 12), "b"], [Vector2(65, 12), "a"],
		[Vector2(14, 22), "b"], [Vector2(65, 22), "a"],
		[Vector2(14, 40), "a"], [Vector2(22, 40), "b"], [Vector2(57, 40), "a"], [Vector2(65, 40), "b"],
	]
	var kisah := [
		"Hunian batu-pasir. Cucian melintang antar jendela — bendera sesungguhnya kota ini.",
		"Dari jendela atas, seorang nenek menghitung karavan. Katanya lebih jujur dari koran.",
		"Pintu ini dicat ulang tiap tahun baru. Tahun ini: merah tanah. Tahun lalu: juga.",
		"Tiga keluarga satu atap. Di Goldhaven itu bukan miskin — itu strategi.",
	]
	for i in range(rumah_baris.size()):
		var r: Array = rumah_baris[i]
		var pt: Vector2 = r[0]
		_bangunan("fasad_hunian_%s" % r[1], Vector2(pt.x * TILE + 16, pt.y * TILE), 0.85,
			"Hunian [E]", [kisah[i % kisah.size()]])
	# GUDANG KARAVAN dekat gerbang selatan (blockout 20-21)
	_bangunan("fasad_gudang_gh", Vector2(15 * TILE + 16, 49 * TILE), 1.0, "Gudang Karavan [E]", [
		"Gudang karavan. Nomor petak dicat besar; salah taruh peti di sini = perang kecil.",
	])
	_bangunan("fasad_gudang_gh", Vector2(64 * TILE + 16, 49 * TILE), 1.0, "Gudang Karavan [E]", [
		"Bau goni, tar, dan rempah. Kuli menyebutnya parfum Goldhaven.",
	])

	# LAMPU sepanjang jalan raya + lentera bercahaya di empat pintu plaza
	for lx in range(8, MAP_W - 6, 7):
		if abs(lx - JX) <= 3:
			continue
		_put(P_L + "lentera32.png", Vector2(lx * TILE, 26 * TILE - 6))
		_put(P_L + "lentera32.png", Vector2(lx * TILE + 16, 31 * TILE + 8))
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var lentera_tex := ImageTexture.create_from_image(img)
	for pos in [Vector2(CX - 10 * TILE, CY), Vector2(CX + 10 * TILE, CY),
			Vector2(CX, CY - 8 * TILE), Vector2(CX, CY + 8 * TILE)]:
		if _put(P_L + "lentera32.png", pos, 1.4):
			var pl := PointLight2D.new()
			pl.energy = 1.0
			pl.texture_scale = 5.0
			pl.color = Color(1.0, 0.84, 0.55)
			pl.texture = lentera_tex
			pl.global_position = pos + Vector2(0, -40)
			add_child(pl)


# ─────────────────────────────────────────────── PASAR AGUNG & MENARA
func _pasar_agung() -> void:
	# MENARA TIMBANGAN di pusat plaza — empat jalan bertemu di bawahnya
	var m := _put(P + "menara_timbangan.png", Vector2(CX, CY - 8), 1.5)
	if m:
		var body := StaticBody2D.new()
		body.collision_layer = 4
		body.collision_mask = 0
		add_child(body)
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = Vector2(64, 34)
		cs.shape = sh
		cs.position = Vector2(CX, CY - 26)
		body.add_child(cs)
	var menara := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(menara)
	menara.global_position = Vector2(CX, CY + 12)
	menara.setup_bicara([
		"MENARA TIMBANGAN. Empat jalan raya Aurelia bertemu tepat di bawah lengkungnya.",
		"Lambang timbangan emasnya bukan hiasan: dulu semua sengketa dagang ditimbang di sini, harfiah.",
		"Loncengnya berbunyi tiap jam. Kata orang, satu-satunya hal gratis di Goldhaven.",
	], "Menara Timbangan [E]")
	# 12 KIOS RADIAL (blockout: radius 7.5 / 6 petak) + dua pedagang sungguhan
	for i in range(12):
		var a := i * TAU / 12.0
		var kpos := Vector2(CX + cos(a) * 7.5 * TILE, CY + sin(a) * 6.0 * TILE)
		_put(P + ("kios_dagang" if i % 2 == 0 else "kios_dagang_b") + ".png", kpos, 1.15)
	for spos in [Vector2(CX - 7.5 * TILE, CY + 24), Vector2(CX + 7.5 * TILE, CY + 24)]:
		var pedagang := preload("res://scenes/world/Interactable.tscn").instantiate()
		add_child(pedagang)
		pedagang.setup("shop")
		pedagang.scale = Vector2(2, 2)
		pedagang.global_position = spos
	# gerobak bongkar-muat di tepi plaza — pasar yang sedang BEKERJA
	_put(P_L + "gerobak32.png", Vector2(CX - 4 * TILE, CY + 7 * TILE), 1.2)
	_put(P_L + "gerobak32.png", Vector2(CX + 5 * TILE, CY - 7 * TILE), 1.2)


# ────────────────────────────────────── GANG TIMUR-LAUT — PINTU TERSEGEL
## HIDDEN (kanon 002): pintu besi tua di ujung gang buntu. Teks netral,
## NOL nama, NOL penanda (D-3). Kota di atasnya tak membicarakannya.
func _gang_tersegel() -> void:
	var s := _put(P + "segel_pintu.png", Vector2(61 * TILE + 16, 8 * TILE + 16), 1.4)
	if s:
		s.z_index = 3
	var pintu := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pintu)
	pintu.global_position = Vector2(61 * TILE + 16, 9 * TILE)
	pintu.setup_bicara([
		"Pintu besi tua di ujung gang. Palang bajanya dilas mati — bukan dikunci. Dilas.",
		"Engselnya dirawat. Seseorang rutin meminyaki pintu yang tak boleh dibuka.",
		"Dari celah bawahnya: udara dingin. Gang ini buntu; anginnya datang dari BAWAH.",
	], "Pintu besi tua [E]")
	# gerobak parkir menyamarkan mulut gang — bukan penanda, kota menumpuk barang
	_put(P_L + "gerobak32.png", Vector2(60 * TILE - 12, 13 * TILE + 20), 1.0)


# ─────────────────────────────────────────────── (kerangka standar scene)
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
	mat.color = Color(0.75, 0.8, 0.9)
	rain.process_material = mat
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.85, 0.95))
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
		# GERBANG BARAT — arah Ashbrook. Momen kanon 002: dari sini plaza,
		# kios, dan menara terlihat MENJULANG sekaligus.
		player.global_position = Vector2(5 * TILE, 28 * TILE + 16)
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
	# world gate di dalam gerbang barat — pintu karavan kota
	var gate := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(gate)
	gate.setup("world_gate")
	gate.scale = Vector2(2, 2)
	gate.global_position = Vector2(6 * TILE, 26 * TILE - 16)
	# kerumunan: warga goldhaven (E6 — TEPAT 5 persona) berputar di plaza.
	# Sheet LPC warga_070..074 — rentang kosong di antara Greenvale (60..64)
	# dan Desert (90..94); indeks di luar 0..119 TIDAK punya sheet.
	TownFolk.place(self, "goldhaven", Vector2(CX, CY + 3 * TILE), 70)
	# ILUSI 35.000 JIWA: latar tanpa dialog memadati pasar & gerbang (75..88).
	# Zona menjauhi titik-periksa (aturan Ashbrook64: warga latar merebut tombol E).
	TownFolk.place_latar(self, [
		{"pos": Vector2(CX - 5 * TILE, CY - 4 * TILE), "r": 70.0, "n": 3},   # kios barat-laut
		{"pos": Vector2(CX + 5 * TILE, CY + 4 * TILE), "r": 70.0, "n": 3},   # kios tenggara
		{"pos": Vector2(CX, CY + 8 * TILE), "r": 60.0, "n": 2},              # mulut selatan plaza
		{"pos": Vector2(10 * TILE, 28 * TILE), "r": 64.0, "n": 2},           # arus gerbang barat
		{"pos": Vector2(48 * TILE + 16, 21 * TILE), "r": 56.0, "n": 2},      # antrean bank
		{"pos": Vector2(15 * TILE, 47 * TILE), "r": 60.0, "n": 2},           # kuli gudang selatan
	], 75)
	MiracleSystem.manifest(self, Vector2(CX, CY), 520.0)
