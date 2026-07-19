extends Node2D
## LAYAR BUKTI #253 — sudut Ashbrook di 16px (kiri) vs 64px (kanan), SATU layar.
##
## ⚠ INI BUKAN MIGRASI DAN BUKAN SCENE PRODUKSI.
## `Ashbrook.tscn` / `Ashbrook.gd` TIDAK DISENTUH. Scene ini berdiri sendiri, tak di-wire
## ke mana pun, tak masuk alur permainan. Tugasnya satu: menjawab pertanyaan Direktur
## "apakah 64px cukup lebih indah untuk membenarkan membangun ulang 148 aset?"
##
## KENAPA DUA PARUH DALAM SATU SCENE, bukan dua tangkapan layar yang ditempel:
## supaya pembandingannya JUJUR. Satu kamera, satu zoom, satu CanvasModulate, satu
## lampu. Kalau kiri dan kanan difoto terpisah, beda jam (GameClock = jam WIB NYATA)
## sudah cukup membuat yang satu gelap dan yang lain terang — dan itu, bukan skalanya,
## yang akan dinilai mata.
##
## Ambient DIPATOK (bukan GameClock) supaya hasilnya sama tiap dijalankan (#240).
##
## Isi tiap paruh:
##   KIRI  16px — ubin cobble_0/dirt_path lama · inn.png 74x98 · lantern.png 12x20
##                · karakter _charsys 32px (CharGen)
##   KANAN 64px — ubin t64/* DIGAMBAR NATIF di 64px (_tools/gen_tiles64.py)
##                · inn + lentera lama DINAIKKAN 4x (sengaja: memperlihatkan apa yang
##                  didapat kalau aset lama sekadar digemukkan — yaitu tak ada detail baru)
##                · Merrit LPC 64px asli (_tools/lpc_assembler/assemble.py)

const TILE16 := 16
const TILE64 := 64
const HALF := 480.0                 # lebar tiap paruh dalam piksel dunia
const VIEW_H := 540.0
const AMBIENT := Color(0.52, 0.50, 0.62)   # senja dipatok — lentera terbaca, seni tetap terlihat

const P_SPRITES := "res://assets/game/sprites/"
const P_TILES := "res://assets/game/tiles/"


func _ready() -> void:
	var cm := CanvasModulate.new()
	cm.color = AMBIENT
	add_child(cm)
	_build_half_16()
	_build_half_64()
	_divider()
	_labels()
	var cam := Camera2D.new()
	cam.zoom = Vector2(2, 2)          # zoom main (Player.gd:33)
	cam.make_current()
	add_child(cam)


## Hamparan tanah: satu Sprite2D ber-region + texture_repeat, bukan ribuan node.
func _ground(tex_path: String, rect: Rect2, z: int) -> void:
	if not ResourceLoader.exists(tex_path):
		push_warning("[bukti64] ubin hilang: %s" % tex_path)
		return
	var s := Sprite2D.new()
	s.texture = load(tex_path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(0, 0, rect.size.x, rect.size.y)
	s.centered = false
	s.position = rect.position
	s.z_index = z
	add_child(s)


func _sprite(path: String, pos: Vector2, z: int, scale_mult := 1.0) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[bukti64] aset hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2(scale_mult, scale_mult)
	s.position = pos
	s.z_index = z
	add_child(s)
	return s


# ------------------------------------------------------------------ paruh 16px
func _build_half_16() -> void:
	# rumput di atas, alun-alun cobble di bawah — dua ubin per paruh
	_ground(P_TILES + "storm_grass.png", Rect2(-HALF, -270, HALF, 190), 0)
	_ground(P_TILES + "cobble_0.png", Rect2(-HALF, -80, HALF, 350), 0)
	_ground(P_TILES + "dirt_path.png", Rect2(-HALF, -96, HALF, 16), 1)
	_sprite(P_SPRITES + "buildings/inn.png", Vector2(-330, -140), 10)
	var lamp := _sprite(P_SPRITES + "props/lantern.png", Vector2(-286, -168), 20)
	if lamp:
		_glow(lamp, P_SPRITES + "props/lantern_glow.png", 9.0)
	# karakter dunia hari ini: _charsys 32px, frame diam menghadap bawah
	var cs := Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = CharGen.sheet_texture(CharGen.default_config())
	at.region = Rect2(CharGen.CW, 0, CharGen.CW, CharGen.CH)
	cs.texture = at
	cs.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cs.position = Vector2(-300, 40)
	cs.z_index = 30
	add_child(cs)


# ------------------------------------------------------------------ paruh 64px
func _build_half_64() -> void:
	_ground(P_TILES + "t64/grass64.png", Rect2(0, -270, HALF, 190), 0)
	_ground(P_TILES + "t64/cobble64.png", Rect2(0, -80, HALF, 350), 0)
	_ground(P_TILES + "t64/dirt64.png", Rect2(0, -144, HALF, 64), 1)
	_sprite(P_SPRITES + "t64/inn64_upscaled.png", Vector2(180, -60), 10)
	# lentera menempel di dinding penginapan (z di atas bangunan), seperti lampu Merrit
	var lamp := _sprite(P_SPRITES + "t64/lantern64_upscaled.png", Vector2(72, -196), 20)
	if lamp:
		_glow(lamp, P_SPRITES + "t64/lantern_glow64_upscaled.png", 9.0)
	# Merrit LPC 64px — baris 2 = menghadap bawah (frame_map.json dir_order)
	var mp := P_SPRITES + "characters/merrit_fane_idle.png"
	if ResourceLoader.exists(mp):
		var m := Sprite2D.new()
		var mat := AtlasTexture.new()
		mat.atlas = load(mp)
		mat.region = Rect2(0, 128, 64, 64)
		m.texture = mat
		m.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		m.position = Vector2(80, 120)
		m.z_index = 30
		add_child(m)
	else:
		push_warning("[bukti64] Merrit belum dirakit — jalankan assemble.py")


func _glow(parent: Sprite2D, glow_path: String, scale_v: float) -> void:
	var g := PointLight2D.new()
	g.texture = load(glow_path) if ResourceLoader.exists(glow_path) else parent.texture
	g.energy = 1.5
	g.texture_scale = scale_v
	g.color = Color(1.0, 0.85, 0.55)
	parent.add_child(g)


func _divider() -> void:
	var line := ColorRect.new()
	line.color = Color(0.95, 0.85, 0.45)
	line.size = Vector2(2, VIEW_H)
	line.position = Vector2(-1, -VIEW_H * 0.5)
	line.z_index = 4000
	add_child(line)


func _labels() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	for spec in [
		["16 px  —  SEKARANG", 0.14, Color(0.6, 0.9, 0.6)],
		["64 px  —  USULAN #253", 0.60, Color(1.0, 0.75, 0.45)],
	]:
		var l := Label.new()
		l.text = str(spec[0])
		l.add_theme_font_size_override("font_size", 22)
		l.add_theme_color_override("font_color", spec[2])
		l.add_theme_constant_override("outline_size", 6)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.anchor_left = spec[1]
		l.anchor_top = 0.04
		l.offset_left = 0
		l.offset_top = 0
		layer.add_child(l)
