extends Node
## MIRACLE SYSTEM v1 (E7, Decision Log #79) — peristiwa langka yang TIDAK dipicu pemain.
## Filosofi: keajaiban menumbuhkan Wonder justru karena kau tidak mengendalikannya, dan
## karena kau sering MELEWATKANNYA. Karena itu:
##   - roll harian deterministik dari tanggal WIB (seed = hash tanggal) — dunia yang
##     memutuskan, bukan pemain; hari yang sama = keajaiban yang sama.
##   - TIDAK PERNAH ada popup/notifikasi. Satu-satunya pengumuman = gosip NPC
##     keesokan harinya ("kudengar semalam...") — lewat RumorSystem, boleh melenceng.
##   - efeknya ringan: bunga purba yang bisa dipetik, kawanan yang lewat, pelangi
##     ganda (buff kecil 10 menit), bintang jatuh (serpihan di titik jatuh).

const DAILY_CHANCE := 0.28      # peluang ADA keajaiban pada satu hari

var _today: Dictionary = {}     # {id, date, spawned:bool}
var _yesterday: Dictionary = {}

func _ready() -> void:
	_refresh()

func def(id: String) -> Dictionary:
	for m in Db.miracles:
		if m.get("id", "") == id:
			return m
	return {}

## Keajaiban hari ini ({} = tidak ada). Auto-roll saat tanggal WIB berganti.
func today() -> Dictionary:
	_refresh()
	return _today

## Keajaiban KEMARIN — inilah yang digosipkan warga hari ini.
func yesterday() -> Dictionary:
	_refresh()
	return _yesterday

func _refresh() -> void:
	var date := GameClock.date_string()
	if WorldState.miracle_log.get("date", "") == date:
		_today = WorldState.miracle_log.get("today", {})
		_yesterday = WorldState.miracle_log.get("yesterday", {})
		return
	# hari berganti: keajaiban kemarin = keajaiban "hari" yang tercatat sebelumnya
	var prev: Dictionary = WorldState.miracle_log.get("today", {})
	_yesterday = prev
	_today = roll(date)
	WorldState.miracle_log = {"date": date, "today": _today, "yesterday": _yesterday}

## Roll deterministik untuk satu tanggal. Dipakai test/harness juga.
func roll(date: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("miracle:" + date)
	if rng.randf() >= DAILY_CHANCE:
		return {}
	var total := 0
	for m in Db.miracles:
		total += int(m.get("weight", 1))
	if total <= 0:
		return {}
	var pick := rng.randi_range(1, total)
	for m in Db.miracles:
		pick -= int(m.get("weight", 1))
		if pick <= 0:
			return {"id": m.get("id", ""), "date": date, "spawned": false}
	return {}

## Dipanggil scene dunia saat _ready: mewujudkan keajaiban hari ini di dunia
## (sekali per hari per scene — visual + item; tak ada teks apa pun).
func manifest(host: Node2D, area_center: Vector2, area_radius: float = 220.0) -> void:
	var m := today()
	if m.is_empty():
		return
	var d := def(m.get("id", ""))
	if d.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(m.get("id", "") + str(m.get("date", "")) + host.name)
	match m.get("id", ""):
		"ancient_bloom":
			_spawn_pickup(host, area_center + _off(rng, area_radius), "ancient_bloom", Color(0.9, 0.75, 1.0))
		"falling_star":
			if GameClock.is_night() and not WorldState.is_wet_weather():
				_streak(host, area_center + _off(rng, area_radius * 1.5))
			_spawn_pickup(host, area_center + _off(rng, area_radius), "star_fragment", Color(1.0, 0.95, 0.6))
		"migration":
			_flock(host, area_center, rng)
		"double_rainbow":
			_rainbow(host, area_center)
			PlayerData.apply_buff("miracle_rainbow", d.get("buff", {"duration": 600.0}))

func _off(rng: RandomNumberGenerator, r: float) -> Vector2:
	return Vector2(rng.randf_range(-r, r), rng.randf_range(-r, r))

func _spawn_pickup(host: Node2D, pos: Vector2, item_id: String, _tint: Color) -> void:
	LootDrop.spawn(host, pos, item_id, 1)

func _flock(host: Node2D, center: Vector2, rng: RandomNumberGenerator) -> void:
	var flock := Node2D.new()
	flock.set_script(load("res://scenes/systems/MiracleFlock.gd"))
	host.add_child(flock)
	flock.global_position = center + Vector2(-600, rng.randf_range(-260, -120))

func _streak(host: Node2D, pos: Vector2) -> void:
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = Color(1.0, 0.95, 0.7, 0.9)
	line.points = PackedVector2Array([pos + Vector2(-160, -120), pos])
	line.z_index = 400
	host.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 2.5)
	tw.tween_callback(line.queue_free)

func _rainbow(host: Node2D, center: Vector2) -> void:
	var bow := Node2D.new()
	bow.set_script(load("res://scenes/systems/MiracleRainbow.gd"))
	host.add_child(bow)
	bow.global_position = center + Vector2(0, -180)
