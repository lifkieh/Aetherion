class_name Hewan
extends Node2D
## HEWAN — satu aktor untuk SEMUA hewan, dibaca dari `game/data/katalog_hewan.json`.
##
## KENAPA SATU AKTOR
## ----------------
## Sebelum ini sistem hewan TERPECAH DUA dan Ashbrook memakai yang lebih buruk:
##   * `Critter.gd` — terpusat, `animals/<jenis>.png` dari nama. Dipakai `Town.gd`
##     untuk Greenvale dkk. Ashbrook TAK PERNAH memanggilnya.
##   * `AshbrookChicken.gd` — path DITANAM MATI, satu sprite, dipakai untuk ayam
##     DAN kambing (kambing = ayam yang di-`scale` 3x lalu di-`modulate` abu).
## Akibat langsungnya tiga cacat yang sudah dibayar: path salah tanpa galat (ayam
## lahir sebagai kotak berbulan-bulan), skala dikarang di sisi pemanggil (kambing
## jadi ayam raksasa), dan aset tanpa kredit.
##
## Katalog membuat ketiganya sulit ditulis: path, ukuran frame, dan SKALA datang
## dari satu berkas, bersama pack + seniman + lisensinya.
##
## SATU BENTUK: STRIP HADAP-KIRI
## -----------------------------
## Tiap hewan = strip mendatar berisi `frame` gambar `fw`x`fh` yang menghadap KIRI
## (dinormalkan `_tools/gen_hewan.py`). Bergerak ke kanan -> dibalik horizontal.
## Direktur mengizinkan hewan kiri-kanan saja; itu yang membuat penyeragaman ini
## mungkin, dan itu pula yang membuat rusa/serigala tampak-samping bisa dipakai.
##
## `AshbrookChicken.gd` SENGAJA DIBIARKAN HIDUP — dunia 16px memakainya dan dunia
## itu beku. Aktor ini opt-in, sama seperti `Villager.lpc_sheet`.

## Kecepatan berkelana. Hewan besar lebih lambat — dibaca dari katalog kalau ada.
var jenis := "ayam"
var wander_radius := 76.0
var body_radius := 7.0

var _spr: Sprite2D
var _frame := 0
var _fw := 16
var _fh := 16
var _n := 1
var _t := 0.0
var _anim := 0.0
var _dir := Vector2.ZERO
var _home := Vector2.ZERO

const SPEED := 26.0
const FLEE_RADIUS := 84.0

static var _katalog: Dictionary = {}


## Baca katalog SEKALI lalu simpan. Berkas ada di luar `game/`, jadi dimuat lewat
## Data runtime, jadi ia tinggal di `game/data/` bersama monsters.json.
static func katalog() -> Dictionary:
	if not _katalog.is_empty():
		return _katalog
	# `game/data/` — BUKAN `_tools/`. Katalog ini dibaca SAAT MAIN, dan `_tools/*`
	# ter-gitignore: menaruhnya di sana berarti berkas yang dibutuhkan permainan tak
	# pernah masuk repo, dan hewan lenyap di mesin mana pun selain yang membuatnya.
	# Data runtime tinggal bersama monsters.json dkk.
	const P := "res://data/katalog_hewan.json"
	if not FileAccess.file_exists(P):
		push_error("[hewan] katalog TAK ADA: %s — jalankan _tools/gen_hewan.py" % P)
		return {}
	var teks := FileAccess.get_file_as_string(P)
	var j = JSON.parse_string(teks)
	if typeof(j) != TYPE_DICTIONARY:
		push_error("[hewan] katalog tak terbaca sebagai JSON: %s" % P)
		return {}
	_katalog = j
	return _katalog


func setup(j: String) -> void:
	jenis = j


func place(p: Vector2) -> void:
	global_position = p
	_home = p


func _ready() -> void:
	if _home == Vector2.ZERO:
		_home = global_position
	add_to_group("ashbrook_life")
	var kat := katalog()
	var h: Dictionary = kat.get("hewan", {}).get(jenis, {})
	if h.is_empty():
		# BERTERIAK. Hewan yang diam-diam tak lahir adalah cacat berikutnya yang
		# sedang menunggu — persis cara ayam-kotak bertahan berbulan-bulan.
		push_error("[hewan] jenis '%s' tak ada di katalog_hewan.json" % jenis)
		return
	var path: String = h.get("sprite", "")
	if not ResourceLoader.exists(path):
		push_error("[hewan] '%s': sprite TAK ADA di %s" % [jenis, path])
		return
	_fw = int(h.get("fw", 16))
	_fh = int(h.get("fh", 16))
	_n = maxi(1, int(h.get("frame", 1)))
	_spr = Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = load(path)
	at.region = Rect2(0, 0, _fw, _fh)
	_spr.texture = at
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# SKALA DARI KATALOG, tak pernah dari pemanggil. Itu batas yang mencegah
	# "kambing 3x" lahir kembali di scene mana pun.
	var s: float = float(h.get("skala", 1.0))
	_spr.scale = Vector2(s, s)
	_spr.offset = Vector2(0, -_fh * 0.5)      # kaki di titik asal node
	add_child(_spr)
	z_index = int(global_position.y)


func _process(delta: float) -> void:
	if _spr == null:
		return
	_t -= delta
	if _t <= 0.0:
		_t = randf_range(0.9, 2.6)
		_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var spd := SPEED
	var pl = get_tree().get_first_node_in_group("player")
	if is_instance_valid(pl):
		var d: Vector2 = global_position - pl.global_position
		if d.length() < FLEE_RADIUS:          # lari saat didekati — bukan properti diam
			_dir = d.normalized()
			spd = SPEED * 2.4
	var calon := global_position + _dir * spd * delta
	if calon.distance_to(_home) > wander_radius:
		_dir = (_home - global_position).normalized()
		calon = global_position + _dir * spd * delta
	global_position = calon

	# hadap arah gerak: strip digambar menghadap KIRI, jadi balik saat ke kanan
	if absf(_dir.x) > 0.05:
		_spr.flip_h = _dir.x > 0.0
	# animasi jalan — hanya saat benar-benar bergerak
	_anim += delta * 8.0
	_frame = int(_anim) % _n
	var at := _spr.texture as AtlasTexture
	if at:
		at.region = Rect2(_frame * _fw, 0, _fw, _fh)
	z_index = int(global_position.y)
