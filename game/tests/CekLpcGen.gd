extends SceneTree
## CEK LpcGen — perakit karakter LPC saat main.
##
## Yang diuji bukan "apakah gambarnya bagus" melainkan janji-janji yang bisa diukur:
##   1. tiap build menawarkan pilihan yang BUKAN kosong
##   2. tiap pilihan yang ditawarkan benar-benar punya BERKAS — pilihan yang tak bisa
##      dirakit lebih buruk daripada pilihan yang tak ada, karena ia baru gagal
##      SESUDAH pemain memilihnya
##   3. `rapikan()` menyembuhkan config yang tak sah alih-alih meloloskannya
##   4. hasil rakitnya berukuran kanon 832x2944 dan benar-benar berisi piksel

var _l := 0
var _g := 0


func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_l += 1
	else:
		_g += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


var _mulai := false
var _t := 0.0


## POLA `_process`, BUKAN `_initialize`. Autoload BELUM terpasang saat `_initialize()`
## berjalan — `root.get_node("LpcGen")` mengembalikan null dan uji ini menuduh
## autoload-nya tak terdaftar padahal ia terdaftar. Menunggu beberapa frame lebih
## dulu adalah syarat, bukan kehati-hatian berlebih.
func _process(delta: float) -> bool:
	if not _mulai:
		_mulai = true
		return false
	_t += delta
	if _t < 0.6:
		return false
	_jalan()
	return true


func _jalan() -> void:
	print("===== LpcGen — PERAKIT KARAKTER PEMAIN =====")
	var g = root.get_node_or_null("LpcGen")
	_ok("autoload LpcGen terdaftar", g != null)
	if g == null:
		quit(1)
		return
	_ok("manifes chargen.json termuat", g.siap())
	if not g.siap():
		quit(1)
		return

	var builds: Array = g.builds()
	_ok("tujuh build tersedia", builds.size() == 7, str(builds))

	# 1+2 — tiap pilihan yang DITAWARKAN harus punya berkasnya
	var hilang: Array = []
	var kosong: Array = []
	for b in builds:
		if g.kulit(b).is_empty():
			kosong.append("%s/kulit" % b)
		if g.rambut(b).is_empty():
			kosong.append("%s/rambut" % b)
		for k in g.kulit(b):
			var p := "res://assets/game/sprites/chargen/body_%s_%s.png" % [b, k]
			if not ResourceLoader.exists(p):
				hilang.append(p)
		for slot in ["torso", "legs", "feet"]:
			var opsi: Array = g.pakaian(b, slot)
			if opsi.is_empty():
				kosong.append("%s/%s" % [b, slot])
			for o in opsi:
				var q := "res://assets/game/sprites/chargen/%s_%s_%s.png" % [slot, o[0], o[1]]
				if not ResourceLoader.exists(q):
					hilang.append(q)
	_ok("nol slot kosong di build mana pun", kosong.is_empty(), str(kosong.slice(0, 4)))
	_ok("tiap pilihan yang ditawarkan punya berkasnya", hilang.is_empty(),
		"%d hilang: %s" % [hilang.size(), str(hilang.slice(0, 3))])

	# 3 — rapikan() menyembuhkan config mustahil
	var kotor := {"build": "child", "kulit": "tidak_ada_nada_ini",
		"rambut": "swoop_gold", "torso": ["longsleeve", "navy"]}
	var bersih: Dictionary = g.rapikan(kotor)
	_ok("rapikan() menolak kulit yang tak ada", bersih["kulit"] in g.kulit("child"),
		str(bersih.get("kulit")))
	_ok("rapikan() menolak rambut dewasa di badan anak",
		bersih["rambut"] in g.rambut("child"), str(bersih.get("rambut")))
	_ok("rapikan() menolak torso yang bukan milik build itu",
		bersih["torso"] in g.pakaian("child", "torso"), str(bersih.get("torso")))

	# 4 — hasil rakit nyata
	var cfg: Dictionary = g.rapikan({"build": "male"})
	var tex = g.sheet(cfg)
	_ok("sheet() menghasilkan tekstur", tex != null)
	if tex != null:
		var img: Image = tex.get_image()
		_ok("ukuran kanon 832x2944",
			img.get_width() == 832 and img.get_height() == 2944,
			"%dx%d" % [img.get_width(), img.get_height()])
		# baris walk (8..11) harus BERISI — lembar kosong lolos uji ukuran
		var isi := 0
		for y in range(8 * 64, 12 * 64, 7):
			for x in range(64, 640, 7):
				if img.get_pixel(x, y).a > 0.0:
					isi += 1
		_ok("baris walk benar-benar berisi piksel", isi > 200, str(isi))

	# 5 — acak() selalu menghasilkan config yang bisa dirakit
	var gagal_acak := 0
	for i in 12:
		var c: Dictionary = g.acak()
		if g.sheet(c) == null:
			gagal_acak += 1
	_ok("12 config acak semuanya bisa dirakit", gagal_acak == 0, str(gagal_acak))

	print("\n===== LpcGen: %d lulus, %d gagal =====" % [_l, _g])
	quit(0 if _g == 0 else 1)
