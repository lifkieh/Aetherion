extends Node2D
## BADAI PENGHAPUSAN (#304 · kanon #134/D2 — HYBRID FINAL JUDGE fase 1-3).
## Arena: pemakaman Ashbrook yang MEMUTIH. Objektif dibalik: BERTAHAN tiga
## gelombang Yang-Terhapus, lalu PENGHAKIMAN — Nirnama bertanya, dan dunia
## menjawab lewat bukti (metrik warisan; save file = argumen).
## Nirnama TIDAK dibunuh. Kemenangan bukan membunuh (kanon roadbook :188).

const TILE := 32
const MAP_W := 40
const MAP_H := 24
const GELOMBANG := [4, 5, 6]
const SPESIES := ["grey_wolf", "cave_bat", "sporeling", "forest_fox"]

var player
var canvas_mod: CanvasModulate
var _gel := 0
var _hidup := 0
var _mulai := false
var _selesai := false


func _ready() -> void:
	# tanah pucat — dunia yang sedang diputihkan
	var ground := TileMapLayer.new()
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/game/tiles/snow_0.png")   # 32px — dunia yang DIPUTIHKAN
	src.texture_region_size = Vector2i(TILE, TILE)
	src.create_tile(Vector2i(0, 0))
	ts.add_source(src, 0)
	ground.tile_set = ts
	ground.modulate = Color(0.96, 0.96, 1.0)
	add_child(ground)
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	# nisan-nisan — yang dijaga selama ini, kini garis depannya
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260727
	for gx in range(4, MAP_W - 4, 3):
		for gy in range(4, MAP_H - 4, 4):
			if rng.randf() < 0.25:
				continue
			var s := Sprite2D.new()
			s.texture = load("res://assets/game/sprites/props/" +
				("nisan_terbaca.png" if rng.randf() < 0.3 else "nisan_aus.png"))
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.modulate = Color(1.1, 1.1, 1.15)
			s.position = Vector2(gx * TILE + rng.randi_range(-8, 8), gy * TILE + rng.randi_range(-6, 6))
			s.z_index = int(s.position.y)
			add_child(s)
	# dinding arena
	var walls := StaticBody2D.new()
	walls.collision_layer = 4
	walls.collision_mask = 0
	add_child(walls)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-32, -32, w + 64, 32), Rect2(-32, h, w + 64, 32),
			Rect2(-32, 0, 32, h), Rect2(w, 0, 32, h)]:
		var cs := CollisionShape2D.new()
		var sh := RectangleShape2D.new()
		sh.size = rc.size
		cs.shape = sh
		cs.position = rc.position + rc.size / 2
		walls.add_child(cs)

	canvas_mod = CanvasModulate.new()
	canvas_mod.color = Color(1.06, 1.06, 1.1)
	add_child(canvas_mod)

	player = preload("res://scenes/actors/Player.tscn").instantiate()
	player.global_position = Vector2(w * 0.5, h * 0.65)
	add_child(player)
	for c in player.get_children():
		if c is Camera2D:
			c.zoom = Vector2(1.0, 1.0)
			c.limit_left = 0; c.limit_top = 0
			c.limit_right = w; c.limit_bottom = h

	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())
	SafeZone.clear()
	Stage.enter_region("Badai Penghapusan", "Dunia sedang diputihkan — bertahanlah", "")
	call_deferred("_buka")


func _kata(arr: Array) -> void:
	# `uji_badai_cepat`: harness melewati dialog (Stage.say menunggu input +
	# mem-pause tree — suite headless akan beku tanpa pintasan ini).
	if WorldState.get_counter("uji_badai_cepat") == 1:
		return
	await Stage.say(arr)


func _buka() -> void:
	await _kata([
		"Kabut tidak datang seperti badai. Ia datang seperti lupa — dari tepi, tanpa suara.",
		"Nisan-nisan mulai kehilangan hurufnya. Rumput kehilangan hijaunya.",
		"Sesuatu di dalam kabut menoleh kepadamu.",
	])
	_mulai = true
	_gelombang_baru()


func _gelombang_baru() -> void:
	if _gel >= GELOMBANG.size():
		_penghakiman()
		return
	var n: int = GELOMBANG[_gel]
	_gel += 1
	EventBus.toast.emit("〰 Gelombang %d — Yang-Terhapus mendekat." % _gel)
	var rng := RandomNumberGenerator.new()
	rng.seed = 100 + _gel
	for i in range(n):
		var inst := MonsterFactory.make(SPESIES[i % SPESIES.size()], 3 + _gel)
		if inst.is_empty():
			continue
		var m := preload("res://scenes/actors/Monster.tscn").instantiate()
		add_child(m)
		m.global_position = Vector2(rng.randf_range(96, MAP_W * TILE - 96),
			rng.randf_range(96, MAP_H * TILE * 0.45))
		m.setup(inst, self)
		m.modulate = Color(1.5, 1.5, 1.6, 0.9)   # terhapus: pucat, hampir bukan warna
		_hidup += 1


func on_monster_died(_m) -> void:
	_hidup = max(0, _hidup - 1)
	if _hidup == 0 and _mulai and not _selesai:
		get_tree().create_timer(1.2).timeout.connect(_gelombang_baru)


## PENGHAKIMAN — fase 3. Pertanyaan datang; jawabannya sudah ditulis pemain
## selama ini. Baris-baris bukti dipilih dari metrik, KUALITATIF (D-4).
func _penghakiman() -> void:
	_selesai = true
	var w := WorldState.counters
	var bukti: Array = []
	if int(w.get("warisan:pulih", 0)) > 0:
		bukti.append("Halaman-halaman yang tercoret... ditulis ulang. Sebagian oleh juru tulis. ")
	if int(w.get("warisan:pulih_sendiri", 0)) > 0:
		bukti.append("...dan sebagian oleh tangan yang tidak tahu caranya, tapi menolak berhenti.")
	if int(w.get("warisan:penggusuran_ditunda", 0)) == 1:
		bukti.append("Di kota gula, sebuah pemakaman masih berdiri — karena seseorang menghitungnya.")
	if int(w.get("arlen_kartu", 0)) == 1:
		bukti.append("Sebuah kartu pos menyeberangi batu penanda yang tak pernah diseberangi siapa pun.")
	if int(w.get("sora_pulang", 0)) == 1:
		bukti.append("Seorang anak berlentera pulang — dan lampunya tetap menyala di dua kota.")
	if bukti.is_empty():
		bukti.append("...")
	var snapshot := w.duplicate()
	snapshot["elyn_beban"] = PlayerData.elyn_burden.size()
	var ending: String = load("res://scenes/world/EndingScene.gd").tentukan(snapshot)
	await _kata([
		"Kabut berhenti. Semuanya berhenti.",
		"\"Semua yang kau simpan akan hilang,\" kata sesuatu yang tidak punya nama. \"Untuk apa menyimpan?\"",
	])
	await _kata(bukti)
	await _kata([
		"Kau tidak menjawab. Dunia yang menjawab — dengan semua yang sempat kau kerjakan, dan semua yang tidak.",
	])
	WorldState.pending_ending = ending
	Stage.go_to_scene("res://scenes/world/EndingScene.tscn")
