extends Node2D
## ANAK-ANAK ASHBROOK (#216) — **kehidupan paling murni**: desa mengecil, tapi desa
## MASIH MELAHIRKAN. Mereka berlari, mereka mengejar ayam, mereka bermain **di depan
## gudang yang kosong** — kontras hidup × mati yang diminta Hukum Tertinggi.
##
## Mereka tidak memberi quest. Mereka tidak menjelaskan apa pun. Mereka cuma ada —
## dan justru itu yang membuat Ashbrook terasa rumah, bukan makam.

const SPEED := 62.0

## Sprite LPC 64px. Dirakit `_tools/lpc_assembler` dari LPC child v3.1 (#232).
## Ketiganya BEDA — rambut, tunik, celana, nada kulit (uji_siluet.py: 53/53/60 px
## pada ambang 52 yang diskalakan ke luas badan anak).
const VARIAN := ["anak_pim", "anak_wen", "anak_toka"]
const P_ANAK := "res://assets/game/sprites/characters/"

## -1 = kotak placeholder (dunia 16px, `Ashbrook.gd`). >= 0 = sprite LPC.
## Sengaja opt-in: sprite ini 64px, memakainya di scene 16px membuat anak raksasa.
## Yang memilih adalah scene, bukan aktor — `Ashbrook.gd` TIDAK disentuh.
var varian := -1

var _spr: Sprite2D
var _chickens: Array = []
var _target: Node2D
var _t := 0.0
var _home := Vector2.ZERO

func setup(chickens: Array) -> void:
	_chickens = chickens

func place(p: Vector2) -> void:      # BUG-217g (lihat AshbrookChicken)
	global_position = p
	_home = p

func _ready() -> void:
	if _home == Vector2.ZERO:
		_home = global_position
	add_to_group("ashbrook_life")
	_spr = Sprite2D.new()
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if varian >= 0:
		var p: String = P_ANAK + str(VARIAN[varian % VARIAN.size()]) + "_idle.png"
		# BERTERIAK kalau path salah (pelajaran ayam: aset ADA, kode menunjuk folder
		# lain, dan scene diam-diam jatuh ke placeholder selama berbulan-bulan).
		if not ResourceLoader.exists(p):
			push_error("[aset] anak: sheet TAK ADA di %s — perakit belum jalan?" % p)
		else:
			var at := AtlasTexture.new()
			at.atlas = load(p)
			at.region = Rect2(0, 128, 64, 64)   # baris 2 = hadap bawah (frame_map.json)
			_spr.texture = at
			_spr.offset = Vector2(0, -20)       # kaki di titik asal node, bukan pusat sel
			add_child(_spr)
			return
	# ⚠ Kotak warna kulit = desain asli dunia 16px, bukan kegagalan muat. Tetap ada
	# supaya `Ashbrook.gd` (16px) tak ikut berubah saat dunia 64px dapat sprite.
	push_warning("[aset] AshbrookKid memakai kotak placeholder (varian=-1, dunia 16px)")
	var img := Image.create(7, 11, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.6, 0.45))
	_spr.texture = ImageTexture.create_from_image(img)
	add_child(_spr)

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0 or not is_instance_valid(_target):
		_t = randf_range(2.0, 5.0)
		_target = _chickens.pick_random() if not _chickens.is_empty() and randf() < 0.7 else null
	var goal: Vector2 = _target.global_position if is_instance_valid(_target) else _home + Vector2(randf_range(-70, 70), randf_range(-50, 50))
	var d := goal - global_position
	if d.length() > 6.0:
		global_position += d.normalized() * SPEED * delta
	z_index = int(global_position.y)
