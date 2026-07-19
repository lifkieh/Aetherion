extends Node2D
## LAYAR BUKTI #254 — sudut Ashbrook dengan KARAKTER **dan** DUNIA sama-sama LPC.
##
## ⚠ BUKAN MIGRASI, BUKAN SCENE PRODUKSI. `Ashbrook.tscn`/`Ashbrook.gd` (16px)
## TIDAK DISENTUH dan tetap jadi scene yang dimainkan. Scene ini berdiri sendiri,
## tak di-wire ke alur permainan mana pun. Satu layar, untuk satu keputusan.
##
## ═══ TEMUAN YANG MENGUBAH ARTI "#254 DUNIA 64px" ═══
## **Tak ada tileset LPC 64px.** Standar LPC = **ubin dunia 32×32** + **frame
## karakter 64×64**. Angka 64 mengacu pada kanvas karakter, bukan petak dunia.
## Seluruh terrain keluarga LPC di gudang berkisi 32px — diverifikasi satu per satu.
##
## Maka scene ini menampilkan **tampilan LPC kanonik**: petak 32px, Merrit berframe
## 64px (badan tampak ~34×47). Inilah wujud sesungguhnya dari "LPC = sumber tunggal
## karakter DAN dunia". Bukan 4× dari 16px — melainkan 2× petak, 2× karakter.
##
## Sumber dunia: Mage City Arcanos (Hyptosis, **CC0**) — dipotong oleh
## `_tools/gen_lpc32_slices.py` (#240). Merrit dirakit `_tools/lpc_assembler/assemble.py`
## dari `characters/merrit_fane.json` (botak, overall, hook `__bare__` #231).

const TILE := 32                       # petak LPC — BUKAN 64
const VIEW_W := 480.0
const VIEW_H := 270.0
const AMBIENT := Color(1, 1, 1)        # siang penuh; dipatok agar hasilnya sama tiap dijalankan

const P_TILES := "res://assets/game/tiles/lpc32/"
const P_LPC := "res://assets/game/sprites/lpc32/"
const P_CHAR := "res://assets/game/sprites/characters/"

var _merrit: Sprite2D
var _walk_t := 0.0


func _ready() -> void:
	var cm := CanvasModulate.new()
	cm.color = AMBIENT
	add_child(cm)
	_ground()
	_village()
	_characters()
	_labels()
	var cam := Camera2D.new()
	cam.zoom = Vector2(2, 2)           # zoom main (Player.gd:33)
	cam.make_current()
	add_child(cam)


func _tile(path: String, rect: Rect2, z: int) -> void:
	if not ResourceLoader.exists(path):
		push_warning("[bukti254] ubin hilang: %s" % path)
		return
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, rect.size)
	s.centered = false
	s.position = rect.position
	s.z_index = z
	add_child(s)


func _put(path: String, pos: Vector2, z: int) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[bukti254] aset hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = pos
	s.z_index = z
	add_child(s)
	return s


func _ground() -> void:
	_tile(P_TILES + "grass32.png", Rect2(-VIEW_W, -VIEW_H, VIEW_W * 2, VIEW_H * 2), 0)
	# alun-alun berperkerasan — terlalu besar untuk empat puluh orang (#206)
	_tile(P_TILES + "cobble32.png", Rect2(-224, -32, 448, 224), 1)


func _village() -> void:
	_put(P_LPC + "wall_inn.png", Vector2(-150, -110), 10)      # rumah singgah Merrit
	_put(P_LPC + "wall_inn.png", Vector2(150, -110), 10)       # rumah kosong di seberang
	_put(P_LPC + "fountain.png", Vector2(0, 40), 20)           # air mancur (kini kering di kanon)
	for x in [-96, -32, 32, 96]:
		_put(P_LPC + "bench_lpc.png", Vector2(x, 128), 25)     # bangku terlalu banyak
	_put(P_LPC + "barrel_lpc.png", Vector2(-196, 96), 25)


func _characters() -> void:
	# MERRIT — frame 64×64, baris 2 = menghadap bawah (frame_map.json dir_order)
	var ip := P_CHAR + "merrit_fane_idle.png"
	if not ResourceLoader.exists(ip):
		push_warning("[bukti254] Merrit belum dirakit — jalankan assemble.py")
		return
	_merrit = Sprite2D.new()
	var at := AtlasTexture.new()
	at.atlas = load(ip)
	at.region = Rect2(0, 128, 64, 64)
	_merrit.texture = at
	_merrit.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_merrit.position = Vector2(-64, 96)
	_merrit.z_index = 40
	add_child(_merrit)

	# Pembanding jalan: lembar walk 512×256 (8 frame × 4 arah) dipakai hidup,
	# supaya terlihat animasinya memang ada — bukan cuma satu pose diam.
	var wp := P_CHAR + "merrit_fane_walk.png"
	if ResourceLoader.exists(wp):
		var w := Sprite2D.new()
		var wa := AtlasTexture.new()
		wa.atlas = load(wp)
		wa.region = Rect2(64 * 2, 64 * 3, 64, 64)   # frame 2, baris 3 = menghadap kanan
		w.texture = wa
		w.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		w.position = Vector2(64, 96)
		w.z_index = 40
		add_child(w)


func _labels() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	for spec in [
		["LPC 64px — karakter DAN dunia (#254)", 0.02, 0.03, 22, Color(1.0, 0.82, 0.45)],
		["petak dunia 32px  ·  frame karakter 64px  —  ini tampilan LPC kanonik", 0.02, 0.085, 14, Color(0.88, 0.9, 0.88)],
		["dunia: Mage City Arcanos (Hyptosis, CC0)  ·  Merrit: assemble.py + eulpc", 0.02, 0.93, 12, Color(0.75, 0.78, 0.8)],
	]:
		var l := Label.new()
		l.text = str(spec[0])
		l.add_theme_font_size_override("font_size", int(spec[3]))
		l.add_theme_color_override("font_color", spec[4])
		l.add_theme_constant_override("outline_size", 6)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.anchor_left = spec[1]
		l.anchor_top = spec[2]
		layer.add_child(l)
