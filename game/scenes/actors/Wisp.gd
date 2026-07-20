extends Node2D
## WISP — cahaya yang melayang di atas kubur. ATMOSFER, bukan makhluk.
##
## Ashbrook tidak boleh terasa BESAR; ia harus terasa PERNAH besar. Tapi pemain
## kini lahir di gerbang selatan dan berjalan 640 px melewati pemakaman dan
## reruntuhan tanpa melihat satu pun yang hidup — dan kosong TOTAL terbaca
## "belum jadi", bukan "mengecil". Yang dibutuhkan bukan ternak ceria (itu melawan
## tesisnya) melainkan kehidupan yang MENEGASKAN kematian.
##
## Wisp adalah "another life" secara harfiah: hadir, terlihat, dan tak bisa diraih —
## seperti nama di batu yang sudah aus. Ia sengaja BUKAN `interactable`: menekan E
## padanya harus menghasilkan NOL, karena ingatan orang yang sudah tak diingat
## memang tak menjawab.
##
## TIGA ATURAN BENTUK, dan tiap satu punya sebab:
##   z_index TETAP, TANPA y-sort — benda yang melayang tak boleh tertutup benda yang
##     duduk di tanah. Dengan y-sort, wisp di atas nisan akan hilang di balik nisan
##     itu sendiri begitu pemain berdiri sedikit ke utara.
##   NOL bayangan — benda spektral yang menjatuhkan bayangan berhenti spektral. Itu
##     yang membuat `ghost.png` LPC ditolak: ia bermata, menyeringai, DAN berbayang.
##   LAMBAT — denyut dan hanyutnya sengaja di bawah kecepatan yang menarik mata.
##     Sesuatu yang bergerak cepat meminta diperhatikan; ini cuma boleh TERTANGKAP.

const SPRITE := "res://assets/game/sprites/props/wisp.png"
const SISI := 48
const FRAME := 4
const Z := 1500                  # > y-maks peta (1408), < Z_LAMP (2000)

## Denyut: satu putaran penuh ~3,2 detik. Napas, bukan kedip.
const DENYUT := 3.2
## Hanyut: periode berbeda dari denyut supaya keduanya tak pernah sinkron —
## gerak yang berulang seirama terbaca sebagai mesin, bukan sebagai roh.
const BOB := 2.7
const DRIFT := 7.4

@export var alfa := 0.55         # ketebalan; dipakai gradien hantu->nyata
var _spr: Sprite2D
var _t := 0.0
var _asal := Vector2.ZERO
var _fase := 0.0
var _jarak_bob := 9.0
var _jarak_drift := 14.0


func place(p: Vector2, a := 0.55, fase := 0.0) -> void:
	_asal = p
	global_position = p
	alfa = a
	_fase = fase


func _ready() -> void:
	if _asal == Vector2.ZERO:
		_asal = global_position
	add_to_group("ashbrook_life")
	if not ResourceLoader.exists(SPRITE):
		push_error("[wisp] sprite TAK ADA: %s — jalankan _tools/gen_wisp.py" % SPRITE)
		return
	_spr = Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = load(SPRITE)
	at.region = Rect2(0, 0, SISI, SISI)
	_spr.texture = at
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_spr.modulate.a = alfa
	add_child(_spr)
	z_index = Z              # TETAP — sengaja tak ikut y-sort

	# CAHAYA SUNGGUHAN, bukan sekadar sprite terang.
	#
	# Percobaan pertama cuma memasang sprite, dan di malam hari ia GAGAL: `CanvasModulate`
	# menggelapkan seluruh kanvas TERMASUK wisp-nya, jadi yang tersisa cuma bercak abu
	# yang sedikit lebih terang dari rumput. Benda yang seharusnya MEMANCAR ikut
	# diredupkan bersama benda yang menerima cahaya — dan malam justru satu-satunya
	# waktu ketika roh harus paling terbaca.
	#
	# `PointLight2D` tidak dikalikan CanvasModulate; ia menambah. Jadi wisp menyala
	# menembus malam, dan siang hari ia cuma menambah semburat lembut.
	# Preseden ada di kamar Merrit; #275 mencatat batas `range_z_min` (-1024) — z kita
	# 1500, jauh di dalam jangkauan.
	# Teksturnya WAJIB gradien radial. Percobaan pertama memakai `Image.create` putih
	# rata (pola yang dipakai kamar Merrit) dan cahayanya keluar sebagai KOTAK bersudut
	# tajam — di kamar itu tak kentara karena ia mengisi ruang persegi, di rumput
	# terbuka ia langsung terbaca sebagai bug. Cahaya tanpa falloff bukan cahaya.
	var cahaya := PointLight2D.new()
	var grad := GradientTexture2D.new()
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(1.0, 0.5)
	grad.width = 64
	grad.height = 64
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	grad.gradient = g
	cahaya.texture = grad
	cahaya.texture_scale = 2.4
	cahaya.color = Color(0.52, 0.76, 1.0)
	cahaya.energy = alfa * 1.05          # ikut gradien: makin pudar, makin redup
	add_child(cahaya)


func _process(delta: float) -> void:
	if _spr == null:
		return
	_t += delta
	# denyut 4 frame: naik-turun, bukan berputar. Urutan 0-1-2-3 lalu BALIK ke 1,
	# supaya terangnya bernapas alih-alih menghentak dari puncak ke lembah.
	var siklus := fmod((_t + _fase) / DENYUT, 1.0) * 6.0
	var f := int(siklus)
	if f > 3:
		f = 6 - f
	var at := _spr.texture as AtlasTexture
	if at:
		at.region = Rect2(clampi(f, 0, FRAME - 1) * SISI, 0, SISI, SISI)
	# melayang: bob dan hanyut berperiode beda, jadi lintasannya tak pernah persis
	# mengulang dirinya dalam rentang yang bisa diingat mata
	global_position = _asal + Vector2(
		sin((_t + _fase) / DRIFT * TAU) * _jarak_drift,
		sin((_t + _fase * 1.7) / BOB * TAU) * _jarak_bob)
