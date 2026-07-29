extends Node2D
## GOLDHAVEN (#319 — kota 002, Persimpangan Aurelia, Valenford).
## ENAM LINGKAR POLIGON bertembok (spek Direktur #318, mockup di-ACC):
##   L1 KERAJAAN (istana + alun-alun Menara Timbangan)  · poligon 8 sisi
##   L2 bangsawan atas (mansion Victorian)               · 12 sisi
##   L3 bangsawan rendah (deret ruko modular)            · 16 sisi
##   L4 warga elit (Serikat/Bank/Aula/Kontrak + ruko)    · 24 sisi
##   L5 rakyat (3 baris ruko + PASAR AGUNG + gudang)     · 32 sisi — tembok besar
##   L6 desa pinggiran (gubuk, kamp karavan) di luar tembok
## Gerbang 4 arah SEGARIS; jalan raya silang menembus sampai istana.
## Deret ruko = modul 3-slice (kiri + N×tengah + kanan, atap layer menyambung);
## tiap vertex = bangunan sudut. Konvensi hadap-kamera. NOL monster.
##
## Ground + tembok = pre-render 4 kuadran (gen_goldhaven_ground.py) — geometri
## verts() DI SINI = geometri generator (koordinat mockup = eksekusi).
## Gang tersegel timur-laut: teks netral, nol nama (HIDDEN, D-3).

const TILE := 32
const MAP_W := 200
const MAP_H := 200
const C := 100
const LEBAR_JALAN := 3
const RING := [[20, 8, 2], [36, 12, 2], [52, 16, 2], [70, 24, 2], [92, 32, 3]]
const P := "res://assets/game/sprites/goldhaven/"
const P_L := "res://assets/game/sprites/lpc32/"
const WARNA := ["krem", "biru", "maroon", "tan", "hijau", "abu"]

var canvas_mod: CanvasModulate
var rain: GPUParticles2D
var player
var _shot_at := -1.0

@onready var CPX := C * TILE + 16
@onready var PASAR := Vector2(CPX, CPX) + Vector2.from_angle(TAU / 8.0) * (70.0 + 11.0) * TILE


func _ready() -> void:
	WorldState.mark_visited("goldhaven")
	randomize()
	_ground()
	_batas_peta()
	_tembok_dan_gerbang()
	_lingkar1_istana()
	_lingkar2_mansion()
	_lingkar3_4_deret()
	_lingkar5_pasar()
	_lingkar6_desa()
	_gang_tersegel()
	_build_sky()
	_build_weather()
	_spawn_player()
	_add_ui()
	EventBus.weather_changed.connect(_on_weather)
	Settings.changed.connect(func(): _on_weather(WorldState.weather))
	_on_weather(WorldState.weather)
	SafeZone.clear()
	Stage.enter_region("Goldhaven", "Persimpangan Aurelia — enam lingkar, lima tembok, satu timbangan", "town.ogg")
	if OS.get_environment("AETHER_SHOT") == "1":
		_shot_at = 1.6
	if OS.get_environment("AETHER_FPS") == "1":
		get_tree().create_timer(4.0).timeout.connect(func():
			print("[fps] Goldhaven fps=%.1f nodes=%d" % [Engine.get_frames_per_second(), get_tree().get_node_count()])
			get_tree().quit())


func _process(delta: float) -> void:
	if canvas_mod:
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


## Vertex poligon dalam px — SALINAN verts() generator (rot = tau/2n:
## sisi datar tepat di 4 poros jalan, gerbang selalu di sisi lurus).
func _verts(r: float, n: int) -> Array:
	var out := []
	var rot := TAU / (2.0 * n)
	for k in n:
		out.append(Vector2(CPX, CPX) + Vector2.from_angle(rot + k * TAU / n) * r * TILE)
	return out


func _dekat_poros(p: Vector2, ambang := 5.5) -> bool:
	return abs(p.x - CPX) <= ambang * TILE or abs(p.y - CPX) <= ambang * TILE

## CATATAN #319: warga TownFolk & prop bersama menyetel z_index=int(global_pos.y);
## di peta 6400 px itu > CANVAS_ITEM_Z_MAX (4096) → galat render NON-FATAL (engine
## meng-clamp; urutan tetap benar lewat y_sort root). Sprite MILIK scene ini
## dikecilkan *0.5 di _put. Membetulkan warga/prop = menyentuh 6 kota lain, ditunda.


# ─────────────────────────────────────────────── LANTAI & TEMBOK
func _ground() -> void:
	for qy in 2:
		for qx in 2:
			var s := Sprite2D.new()
			s.texture = load(P + "ground/q%d%d.png" % [qx, qy])
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.centered = false
			# offset dari UKURAN tekstur — angka mati 2560 patah saat peta
			# naik 160→200 (kuadran jadi 3200; mata #319)
			s.position = Vector2(qx, qy) * float(s.texture.get_width())
			s.z_index = -10
			add_child(s)


func _batas_peta() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	for rc in [Rect2(-32, -32, w + 64, 32), Rect2(-32, w, w + 64, 32),
			Rect2(-32, 0, 32, w), Rect2(w, 0, 32, w)]:
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = rc.size
		cs.shape = sh
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)


## Collision tembok: tiap sisi poligon dipecah potongan ~64 px; potongan yang
## menyentuh poros jalan dilewati (itulah celah gerbang). Visual tembok sudah
## di pre-render ground.
func _tembok_dan_gerbang() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	for ring in RING:
		var r: float = ring[0]
		var n_s: int = ring[1]
		var tebal: float = ring[2]
		var vo := _verts(r + tebal, n_s)
		var vi := _verts(r, n_s)
		for k in n_s:
			var a_o: Vector2 = vo[k]
			var b_o: Vector2 = vo[(k + 1) % n_s]
			var a_i: Vector2 = vi[k]
			var b_i: Vector2 = vi[(k + 1) % n_s]
			var L: float = a_o.distance_to(b_o)
			var seg := int(L / 64.0) + 1
			for q in seg:
				var t0 := float(q) / seg
				var t1 := float(q + 1) / seg
				var tengah := (a_o.lerp(b_o, (t0 + t1) / 2.0) + a_i.lerp(b_i, (t0 + t1) / 2.0)) / 2.0
				if _dekat_poros(tengah, LEBAR_JALAN + 1.2):
					continue
				var cs := CollisionPolygon2D.new()
				cs.polygon = PackedVector2Array([a_o.lerp(b_o, t0), a_o.lerp(b_o, t1),
					a_i.lerp(b_i, t1), a_i.lerp(b_i, t0)])
				body.add_child(cs)
		# menara jaga tiap vertex + gerbang segaris 4 arah
		for v in _verts(r + tebal / 2.0, n_s):
			_put(P + "menara_sudut.png", v + Vector2(0, 40), 0.9)
		for k in 4:
			var g := Vector2(CPX, CPX) + Vector2.from_angle(k * TAU / 4.0) * (r + tebal / 2.0) * TILE
			_put(P + "gerbang_batu.png", g + Vector2(0, 46))


# ─────────────────────────────────────────────── perkakas
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
	# y-sort via z_index, tapi DIKECILKAN: peta 6400px > CANVAS_ITEM_Z_MAX 4096.
	# *0.5 tetap mempertahankan urutan kaki, muat dalam ±4096 (mata #319 hitam).
	s.z_index = clampi(int(pos.y * 0.5), -4000, 4000) if z < 0 else z
	add_child(s)
	return s


func _tabrak(pos: Vector2, w: float, h := 30.0) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	add_child(body)
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(w, h)
	cs.shape = sh
	cs.position = pos - Vector2(0, h * 0.4)
	body.add_child(cs)


func _bangunan(nama: String, kaki: Vector2, skala: float, label: String, baris: Array) -> void:
	var s := _put(P + nama + ".png", kaki, skala)
	if s == null:
		return
	_tabrak(kaki, s.texture.get_width() * skala * 0.82)
	var pintu := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pintu)
	pintu.global_position = kaki + Vector2(0, 10)
	pintu.setup_bicara(baris, label, "")


# ─────────────────────────────────────────────── LINGKAR 1 & 2
func _lingkar1_istana() -> void:
	_bangunan("istana", Vector2(CPX, (C - 6) * TILE), 1.0, "Gerbang Istana Goldhaven [E]", [
		"Istana Goldhaven. Panji timbangan berkibar di dua menara kerucutnya.",
		"Penjaga gerbang berdiri sempurna. Hanya matanya yang mengikuti karavan lewat.",
		"Dari balik tembok: gemericik air taman, dan bunyi pena — istana ini menghitung.",
	])
	var menara := _put(P + "menara_timbangan.png", Vector2(CPX, (C + 5) * TILE + 16), 1.1)
	if menara:
		_tabrak(Vector2(CPX, (C + 5) * TILE + 16), 70, 34)
	var prop := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(prop)
	prop.global_position = Vector2(CPX, (C + 5) * TILE + 44)
	prop.setup_bicara([
		"MENARA TIMBANGAN. Empat jalan raya Aurelia bertemu tepat di alun-alun ini.",
		"Lambang timbangan emasnya bukan hiasan: semua sengketa dagang dulu ditimbang di sini.",
		"Loncengnya berbunyi tiap jam — kata orang, satu-satunya yang gratis di Goldhaven.",
	], "Menara Timbangan [E]")
	for a8 in 8:
		var a := (a8 + 0.5) * TAU / 8.0
		_lentera(Vector2(CPX, CPX) + Vector2(cos(a) * 6.0, sin(a) * 5.0) * TILE)


func _lingkar2_mansion() -> void:
	var vv := _verts((20.0 + 36.0) / 2.0 + 3.4, 12)
	var kisah := [
		"Mansion bangsawan. Pagar rendah — kepercayaan diri yang hanya dimiliki lingkar dalam.",
		"Tamannya dipangkas bentuk timbangan. Tukang kebunnya dibayar lebih dari juru tulis balai.",
		"Dormer atapnya menyala semalaman. Bangsawan Goldhaven tidur larut — menghitung.",
	]
	for k in 12:
		var m: Vector2 = (vv[k] + vv[(k + 1) % 12]) / 2.0
		if _dekat_poros(m, 6.0):
			continue
		_bangunan("fasad_mansion", m, 1.0, "Mansion Bangsawan [E]", [kisah[k % 3]])


# ─────────────────────────────────────────────── DERET RUKO (L3-L5)
## Deret modul 3-slice per sisi poligon — port 1:1 dari mockup (#318).
func _deret_sisi(r_row: float, n_s: int, skala: float, benih: int, tiga := false,
		bebas_pasar := false) -> void:
	var vv := _verts(r_row, n_s)
	for k in n_s:
		var v0: Vector2 = vv[k]
		var v1: Vector2 = vv[(k + 1) % n_s]
		var L := v0.distance_to(v1)
		var arah := (v1 - v0) / L
		var warna: String = WARNA[(k + benih) % WARNA.size()]
		var pakai3 := tiga and ((k + benih) % 3 == 0)
		var awalan := "ruko3_" if pakai3 and warna in ["krem", "biru", "hijau", "abu"] else "ruko_"
		var mw := int(64 * skala)
		var m_c := int((L - 30.0) / mw)
		if m_c < 2:
			continue
		var pad := (L - m_c * mw) / 2.0
		var titik := []
		for i in m_c:
			var pp := v0 + arah * (pad + (i + 0.5) * mw)
			if _dekat_poros(pp) or (bebas_pasar and pp.distance_to(PASAR) < 8.5 * TILE):
				titik.append(null)
			else:
				titik.append(pp)
		var i := 0
		while i < m_c:
			if titik[i] == null:
				i += 1
				continue
			var j := i
			while j + 1 < m_c and titik[j + 1] != null:
				j += 1
			for q in range(i, j + 1):
				var b := "tengah"
				if q == i: b = "kiri"
				elif q == j: b = "kanan"
				elif (q - i) % 3 == 2: b = "pintu"
				var pos: Vector2 = titik[q]
				var atap_b := "atap_tengah"
				if b == "kiri": atap_b = "atap_kiri"
				elif b == "kanan": atap_b = "atap_kanan"
				var s := _put(P + awalan + warna + "_" + b + ".png", pos, skala)
				if s:
					_put(P + awalan + warna + "_" + atap_b + ".png",
						pos - Vector2(0, s.texture.get_height() * skala - 2), skala)
					_tabrak(pos, mw)
				if b == "pintu" and (q + k) % 2 == 0:
					var pr := preload("res://scenes/world/Ashbrook64Prop.gd").new()
					add_child(pr)
					pr.global_position = pos + Vector2(0, 8)
					pr.setup_bicara(_baris_lingkar(r_row), "Pintu deret [E]")
			i = j + 1
	for v in vv:
		if _dekat_poros(v) or (bebas_pasar and v.distance_to(PASAR) < 8.5 * TILE):
			continue
		var ms := _put(P + "menara_sudut.png", v + Vector2(0, 8), skala)
		if ms:
			_tabrak(v + Vector2(0, 8), 52 * skala)


func _baris_lingkar(r_row: float) -> Array:
	if r_row < 46.0:
		return ["Pintu jati berukir. Dari dalam: dentang cangkir porselen dan tawa kecil yang sopan."]
	if r_row < 64.0:
		return ["Papan kuningan kecil di ambang: nama keluarga, dan tahun mereka naik lingkar."]
	return ["Pintu deret rakyat. Bau roti, suara anak, dan cucian yang diangkat buru-buru."]


func _lingkar3_4_deret() -> void:
	_deret_sisi((36.0 + 52.0) / 2.0 - 3.4, 16, 0.82, 0)
	_deret_sisi((36.0 + 52.0) / 2.0 + 3.6, 16, 0.82, 2)
	# L4: gedung publik landmark di baris dalam + deret (selang 3 tingkat) di luar
	var publik := [
		["fasad_serikat", "Kantor Pusat Serikat Penjelajah [E]", [
			"KANTOR PUSAT SERIKAT PENJELAJAH. Papan misinya empat kali papan Greenvale — dan penuh.",
			"Petugasnya menyebut cabang-cabang: Greenvale, Thornwatch, Tidegate... daftarnya masih panjang.",
			"Di dinding: peta Aurelia. Ashbrook cuma titik kecil di sudut barat. Titik. Kecil."]],
		["fasad_bank", "Bank Goldhaven [E]", [
			"Bank Goldhaven. Pintunya dua lapis; yang dalam katanya perlu tiga kunci berbeda.",
			"Antrean penukar uang mengular. Tujuh mata uang, satu timbangan, nol senyum."]],
		["fasad_aula", "Aula Dagang [E]", [
			"Aula Dagang. Lelang pagi: rempah dan kain. Lelang sore: apa saja yang tersisa.",
			"Suara juru lelangnya terdengar sampai dua lingkar — kota menganggapnya musik."]],
		["fasad_kontrak", "Rumah Kontrak [E]", [
			"Rumah Kontrak. Semua janji kota ini ditulis, disegel, dan ditimbang di sini.",
			"Di ambang: \"LISAN TIDAK DIHITUNG.\" Hurufnya aus disentuh orang yang berharap."]],
		["fasad_balai_gh", "Balai Kota Goldhaven [E]", [
			"Balai kota. Pengumumannya bertumpuk tujuh lapis; terbawah sudah jadi sejarah.",
			"Tarif gerbang naik musim ini. Karavan mengeluh. Karavan tetap datang."]],
	]
	var vv4 := _verts((52.0 + 70.0) / 2.0 - 3.6, 24)
	var pi := 0
	for k in range(0, 24, 2):
		var m: Vector2 = (vv4[k] + vv4[(k + 1) % 24]) / 2.0
		if _dekat_poros(m, 6.0):
			continue
		var pb: Array = publik[pi % publik.size()]
		_bangunan(pb[0], m, 0.9, pb[1], pb[2])
		pi += 1
	_deret_sisi((52.0 + 70.0) / 2.0 + 3.8, 24, 0.9, 1, true)


# ─────────────────────────────────────────────── LINGKAR 5 & 6
func _lingkar5_pasar() -> void:
	_deret_sisi(70.0 + 4.5, 32, 0.72, 0, false, true)
	_deret_sisi(70.0 + 11.0, 32, 0.72, 1, true, true)
	_deret_sisi(70.0 + 17.5, 32, 0.72, 3, false, true)
	# PASAR AGUNG: kios radial + pedagang + inn + gerobak
	for i in 10:
		var aa := i * TAU / 10.0
		_put(P + ("kios_dagang" if i % 2 == 0 else "kios_dagang_b") + ".png",
			PASAR + Vector2(cos(aa) * 5.0 * TILE, sin(aa) * 4.0 * TILE), 1.1)
	for spos in [PASAR + Vector2(-2 * TILE, 24), PASAR + Vector2(2 * TILE, 24)]:
		var pedagang := preload("res://scenes/world/Interactable.tscn").instantiate()
		add_child(pedagang)
		pedagang.setup("shop")
		pedagang.scale = Vector2(2, 2)
		pedagang.global_position = spos
	var inn := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(inn)
	inn.setup("inn")
	inn.scale = Vector2(2, 2)
	inn.global_position = PASAR + Vector2(0, -3 * TILE)
	_put(P_L + "gerobak32.png", PASAR + Vector2(-2 * TILE, TILE), 1.2)
	_put(P_L + "gerobak32.png", PASAR + Vector2(3 * TILE, -2 * TILE), 1.2)
	var pr := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pr)
	pr.global_position = PASAR + Vector2(0, 5 * TILE)
	pr.setup_bicara([
		"PASAR AGUNG. Sepuluh kios, tujuh bahasa, satu aturan: timbang dulu, tawar kemudian.",
		"Kuli bergantian memanggul dari gerbang selatan. Karavan tak pernah benar-benar berhenti.",
	], "Papan pasar [E]")
	# gudang karavan dekat gerbang selatan
	_bangunan("fasad_gudang_gh", Vector2((C - 8) * TILE, (C + 86) * TILE), 1.0,
		"Gudang Karavan [E]", [
		"Gudang karavan. Nomor petak dicat besar; salah taruh peti = perang kecil.",
	])
	_bangunan("fasad_gudang_gh", Vector2((C + 8) * TILE, (C + 86) * TILE), 1.0,
		"Gudang Karavan [E]", [
		"Bau goni, tar, dan rempah. Kuli menyebutnya parfum Goldhaven.",
	])


func _lingkar6_desa() -> void:
	for i in 20:
		var a := (i + 0.5) * TAU / 20.0
		var pp := Vector2(CPX, CPX) + Vector2.from_angle(a) * (92.0 + 7.0) * TILE
		if _dekat_poros(pp) or pp.x < 4 * TILE or pp.y < 4 * TILE \
				or pp.x > (MAP_W - 4) * TILE or pp.y > (MAP_H - 4) * TILE:
			continue
		var s := _put(P + "ruko_tan_kiri.png", pp, 0.62)
		if s:
			_tabrak(pp, 40)
	for k in 4:
		var a := k * TAU / 4.0 + 0.12
		_put(P_L + "gerobak32.png",
			Vector2(CPX, CPX) + Vector2.from_angle(a) * (92.0 + 5.0) * TILE, 1.2)
	var pr := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pr)
	pr.global_position = Vector2(CPX, CPX) + Vector2.from_angle(TAU * 0.13) * 99.0 * TILE
	pr.setup_bicara([
		"Gubuk-gubuk bersandar ke tembok besar. Yang di luar selalu paling dulu kena angin.",
		"Anak-anak desa menghitung menara jaga. Katanya kalau hafal semua, boleh bermimpi masuk.",
	], "Desa pinggiran [E]")


## HIDDEN (kanon 002): pintu besi tersegel di kaki tembok besar timur-laut.
func _gang_tersegel() -> void:
	var pos := Vector2(CPX, CPX) + Vector2.from_angle(-3.0 * TAU / 8.0) * (70.0 + 6.0) * TILE
	var s := _put(P + "segel_pintu.png", pos, 1.3)
	if s:
		s.z_index = 3
	var pintu := preload("res://scenes/world/Ashbrook64Prop.gd").new()
	add_child(pintu)
	pintu.global_position = pos + Vector2(0, 14)
	pintu.setup_bicara([
		"Pintu besi tua di ujung gang. Palang bajanya dilas mati — bukan dikunci. Dilas.",
		"Engselnya dirawat. Seseorang rutin meminyaki pintu yang tak boleh dibuka.",
		"Dari celah bawahnya: udara dingin. Gang ini buntu; anginnya datang dari BAWAH.",
	], "Pintu besi tua [E]")
	_put(P_L + "gerobak32.png", pos + Vector2(-40, 30), 1.0)


func _lentera(pos: Vector2) -> void:
	if _put(P_L + "lentera32.png", pos) == null:
		return
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	var pl := PointLight2D.new()
	pl.energy = 1.0
	pl.texture_scale = 5.0
	pl.color = Color(1.0, 0.84, 0.55)
	pl.texture = ImageTexture.create_from_image(img)
	pl.global_position = pos + Vector2(0, -30)
	add_child(pl)


# ─────────────────────────────────────────────── kerangka standar
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
		# GERBANG BARAT terluar — momen kanon: lima gerbang segaris sampai istana
		player.global_position = Vector2((C - 92 - 5) * TILE, CPX)
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
	var gate := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(gate)
	gate.setup("world_gate")
	gate.scale = Vector2(2, 2)
	gate.global_position = Vector2((C - 92 - 3) * TILE, (C - 3) * TILE)
	# kerumunan: 5 persona di pasar (E6) + latar per lingkar (sheet 070..088)
	TownFolk.place(self, "goldhaven", PASAR, 70)
	TownFolk.place_latar(self, [
		{"pos": PASAR + Vector2(-3 * TILE, 2 * TILE), "r": 80.0, "n": 3},
		{"pos": Vector2(CPX, (C + 3) * TILE), "r": 90.0, "n": 2},          # alun-alun
		{"pos": Vector2(CPX - 30 * TILE, CPX), "r": 80.0, "n": 2},          # jalan barat L4
		{"pos": Vector2(CPX, CPX - 44 * TILE), "r": 80.0, "n": 2},          # jalan utara L3
		{"pos": Vector2((C - 8) * TILE, (C + 84) * TILE), "r": 70.0, "n": 2},  # kuli gudang
		{"pos": Vector2((C - 97) * TILE, CPX), "r": 64.0, "n": 2},          # desa barat
		{"pos": Vector2(CPX + 40 * TILE, CPX), "r": 80.0, "n": 1},          # jalan timur
	], 75)
	MiracleSystem.manifest(self, Vector2(CPX, CPX), 520.0)
