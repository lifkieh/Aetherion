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
## Kecepatan per JENIS, dibaca katalog. Ayam menyambar, domba merumput — memberi
## keduanya 26 px/s membuat domba tampak meluncur di atas rumput.
var _kecepatan := 26.0
## LIAR — hewan yang tak lagi dipelihara siapa pun. Bedanya dengan ternak bukan
## jenisnya melainkan JARAKNYA: ternak membiarkan orang mendekat karena orang yang
## memberinya makan; yang liar sudah lupa manusia pernah ramah, jadi ia kabur lebih
## awal, lebih jauh, dan lebih cepat. Jarak itulah yang bercerita, bukan spritenya.
var liar := false
const FLEE_LIAR := 116.0

## IKUT — anjing yang MENGIKUTI pemain sebentar, lalu berhenti.
##
## Ini satu-satunya hewan di peta yang mendekat alih-alih kabur, dan seluruh
## maksudnya ada pada BERHENTINYA. Anjing dulu setia pada seseorang; yang tersisa
## sekarang cuma kebiasaan setia itu, tanpa orangnya. Ia mengikuti karena itu yang
## selalu ia lakukan, lalu berhenti karena kau bukan orang yang ditunggunya.
##
## ⚠ Jatah tak diisi ulang selama pemain masih dekat. Tanpa aturan itu ia akan
##   mengikuti selamanya dalam siklus ikut-bingung-ikut, dan anjing yang mengikuti
##   selamanya adalah COMPANION — sistem yang berbeda, janji yang berbeda, dan
##   janji yang tak bisa ditepati Ashbrook.
var ikut := false
const IKUT_JANGKAU := 168.0     # sejauh ini ia menyadari ada orang
const IKUT_JEDA := 52.0         # sedekat ini ia berhenti — tak pernah menempel
const IKUT_JATAH := 5.0         # detik mengikuti sebelum ia kehilangan alasannya
const IKUT_BINGUNG := 4.0       # berdiri diam sesudahnya, memandang
var _ikut_sisa := IKUT_JATAH
var _bingung := 0.0

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
	_kecepatan = float(h.get("kecepatan", SPEED))
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
		# DIAM adalah bagian dari berkelana, bukan kebalikannya. Sebelum ini hewan
		# TAK PERNAH berhenti — ia meluncur tanpa jeda seumur hidupnya, dan itu
		# terbaca sebagai mainan berputar, bukan makhluk. Ternak sungguhan berdiri
		# jauh lebih lama daripada berjalan; JEDA yang membuatnya hidup, bukan
		# geraknya. Diam juga lebih lama daripada jalan (1,6-4,2 vs 1,2-3,4).
		if _dir == Vector2.ZERO:
			_t = randf_range(1.2, 3.4)
			_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		else:
			_t = randf_range(1.6, 4.2)
			_dir = Vector2.ZERO
	var spd := _kecepatan
	var pl = get_tree().get_first_node_in_group("player")
	if ikut and is_instance_valid(pl):
		var ke: Vector2 = pl.global_position - global_position
		var jauh := ke.length()
		if _bingung > 0.0:
			_bingung -= delta                        # berdiri diam, memandang
			_dir = Vector2.ZERO
		elif jauh < IKUT_JANGKAU and _ikut_sisa > 0.0:
			_ikut_sisa -= delta
			_dir = ke.normalized() if jauh > IKUT_JEDA else Vector2.ZERO
			spd = _kecepatan * 1.7
			_t = maxf(_t, 0.4)
			if _ikut_sisa <= 0.0:
				_bingung = IKUT_BINGUNG              # alasannya habis
		elif jauh >= IKUT_JANGKAU:
			_ikut_sisa = IKUT_JATAH                  # isi ulang HANYA setelah ditinggal
	elif is_instance_valid(pl):
		var d: Vector2 = global_position - pl.global_position
		if d.length() < (FLEE_LIAR if liar else FLEE_RADIUS):
			_dir = d.normalized()                    # lari — bukan properti diam
			spd = _kecepatan * (3.2 if liar else 2.4)
			_t = maxf(_t, 0.7)                       # jangan berhenti di tengah kabur
	var calon := global_position + _dir * spd * delta
	# Tali kekang dilonggarkan SELAMA mengikuti — kalau tidak, anjing tertarik pulang
	# di tengah langkah dan berhenti sebelum sempat bercerita. Yang membatasinya
	# tetap ada, cuma pindah: bukan jarak dari rumah, melainkan JATAH WAKTU.
	var kekang := wander_radius * (2.8 if (ikut and _ikut_sisa > 0.0) else 1.0)
	if calon.distance_to(_home) > kekang:
		_dir = (_home - global_position).normalized()
		calon = global_position + _dir * spd * delta
	global_position = calon

	# hadap arah gerak: strip digambar menghadap KIRI, jadi balik saat ke kanan
	if absf(_dir.x) > 0.05:
		_spr.flip_h = _dir.x > 0.0
	# animasi jalan — HANYA saat benar-benar bergerak. Kaki yang terus melangkah di
	# tempat lebih buruk daripada patung: patung cuma diam, sedangkan kaki yang
	# melangkah tanpa maju mengabarkan bahwa yang hidup gambarnya, bukan hewannya.
	if _dir == Vector2.ZERO:
		_frame = 0
	else:
		_anim += delta * 8.0
		_frame = int(_anim) % _n
	var at := _spr.texture as AtlasTexture
	if at:
		at.region = Rect2(_frame * _fw, 0, _fw, _fh)
	z_index = int(global_position.y)
