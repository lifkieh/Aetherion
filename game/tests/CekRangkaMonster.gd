extends SceneTree
## CEK RANGKA MONSTER — tak boleh ada rangka kosong (#151b · #240).
##
## KENAPA UJI INI ADA
## ------------------
## `gen_monster64.py` mengganti seni monster 16 px dengan satu pose 64 px, dan
## `monsters.json` ikut ditulis `frame_size: 64`. Yang TIDAK ikut berubah: `cols: 4,
## rows: 4`. Jadi data menjanjikan lembar 256x256 sementara tiap berkas 64x64, dan
## `SheetUtil.build_directional()` memotong `Rect2(col*64, row*64, 64, 64)` menurut
## janji itu — sembilan belas dari dua puluh rangka jatuh DI LUAR gambar.
##
## Akibatnya monster terlihat HANYA saat diam menghadap bawah. Menghadap atas, kiri,
## atau kanan: hilang sama sekali. Enam puluh monster, seluruh permainan.
##
## Seni lama 16 px kebetulan LOLOS karena 16*4 = 64 — persis ukuran kanvasnya. Jadi
## kontrak ini tak pernah ditulis di mana pun, ia cuma kebetulan yang bertahan sampai
## ada yang mengubah salah satu angkanya. Kebetulan bukan kontrak, dan yang tak
## tertulis tak bisa dilanggar dengan sadar.
##
## Uji ini menutupnya dengan MENGUKUR PIKSEL, bukan membandingkan angka: ia membangun
## `SpriteFrames` yang benar-benar dipakai `Monster.gd`, lalu memeriksa tiap rangka
## punya piksel tampak. Perbandingan ukuran saja akan lolos oleh lembar 256x256 yang
## tiga perempatnya transparan.
##
## Tak ada daftar monster tulisan tangan di sini — ia menyisir SELURUH `monsters.json`,
## jadi monster yang ditambah besok ikut terjaga tanpa uji ini disentuh.

const DATA := "res://data/monsters.json"
const LANGKAH := 4                   # sampel piksel tiap 4 px; cukup untuk "ada isi"

var _l := 0
var _g := 0


func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_l += 1
	else:
		_g += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


func _berisi(im: Image) -> bool:
	if im == null or im.get_width() == 0:
		return false
	for y in range(0, im.get_height(), LANGKAH):
		for x in range(0, im.get_width(), LANGKAH):
			if im.get_pixel(x, y).a > 0.05:
				return true
	return false


func _initialize() -> void:
	var f := FileAccess.open(DATA, FileAccess.READ)
	if f == null:
		print("  [GAGAL] data tak terbaca: %s" % DATA)
		print("\n===== RANGKA MONSTER: 0 lulus, 1 gagal =====")
		quit()
		return
	var d = JSON.parse_string(f.get_as_text())
	var ent: Array = d["monsters"] if typeof(d) == TYPE_DICTIONARY and d.has("monsters") else d
	_ok("data monster terbaca", ent.size() > 0, "%d entri" % ent.size())

	var rusak: Array[String] = []
	for e in ent:
		var tex: Texture2D = load(e["sprite"])
		if tex == null:
			rusak.append("%s [tekstur hilang: %s]" % [e["id"], e["sprite"]])
			continue
		var sf := SheetUtil.build_directional(
			tex, e.get("frame_size", 16), e.get("cols", 4), e.get("rows", 4), 6.0)
		var kosong := 0
		for anim in sf.get_animation_names():
			for i in sf.get_frame_count(anim):
				if not _berisi((sf.get_frame_texture(anim, i) as AtlasTexture).get_image()):
					kosong += 1
		if kosong > 0:
			rusak.append("%s [%d rangka kosong, berkas %dx%d]" % [
				e["id"], kosong, tex.get_width(), tex.get_height()])

	_ok("tiap rangka tiap monster punya piksel tampak", rusak.is_empty(),
		"" if rusak.is_empty() else "%d bermasalah:\n      %s" % [
			rusak.size(), "\n      ".join(rusak)])

	print("\n===== RANGKA MONSTER: %d lulus, %d gagal =====" % [_l, _g])
	quit()
