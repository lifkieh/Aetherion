extends SceneTree
## CEK KANDANG — pagar tak boleh menembus bangunan (#151b).
##
## KENAPA UJI INI ADA
## ------------------
## Kandang domba ditambahkan atas permintaan Direktur, ditaruh di (1176,1032) dengan
## mata, dan pagarnya menembus DUA rumah: dinding tenggara di sudut barat-daya, dan
## dinding timur-tenggara di sudut timur-laut — yang terakhir melintas persis di depan
## pintu rumah itu.
##
## Seluruh 1.122 test lulus. Tak satu pun berbohong: tak satu pun MENGUKUR pagar
## terhadap bangunan, jadi tak ada yang bisa dilanggar. Cacatnya ketahuan cuma karena
## ada yang menatap tangkapan layar — dan menatap layar bukan gerbang, ia keberuntungan.
##
## Uji ini mengukur DUNIA, bukan teksnya (#151b): ia menanyai scene yang sudah jadi
## soal petak kandang yang benar-benar dibangun, lalu membandingkannya dengan setiap
## `CollisionShape2D` yang benar-benar ada.
##
## MARGIN, bukan sekadar "tidak bersinggungan". Pagar yang menempel dinding secara
## teknis tak menembus apa pun dan tetap terbaca sebagai salah pasang — dan ternak
## butuh ruang lewat di antara keduanya. 24 px = tiga perempat petak.

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const MARGIN := 24.0

var _l := 0
var _g := 0
var _mulai := false
var _t := 0.0


func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_l += 1
	else:
		_g += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


## Pola `_process`, bukan `_initialize` + `await` — disalin dari `CekMerrit.gd`.
## `extends SceneTree` di mode `--script` menjalankan loop-nya sendiri, jadi scene
## harus dimuat lewat `change_scene_to_file` lalu ditunggu beberapa frame.
func _process(delta: float) -> bool:
	if not _mulai:
		_mulai = true
		change_scene_to_file(SCENE)
		return false
	_t += delta
	if _t < 0.6:
		return false

	var s := current_scene
	if s == null:
		print("  [GAGAL] scene tak termuat: %s" % SCENE)
		print("\n===== KANDANG: 0 lulus, 1 gagal =====")
		return true

	var petak: Array = s.get("kandang_rect") if s.has_method("get") else []
	_ok("scene memaparkan kandang_rect", petak != null and petak.size() >= 2,
		"ada %d" % (0 if petak == null else petak.size()))

	# Kumpulkan SETIAP kotak padat di scene. Bukan daftar nama bangunan yang ditulis
	# tangan: daftar tulisan-tangan membusuk diam-diam tiap kali ada yang menambah
	# rumah, dan itu persis kelas kegagalan yang sedang ditambal.
	var solid: Array[Rect2] = []
	for n in s.get_children():
		if not (n is StaticBody2D):
			continue
		for c in n.get_children():
			if not (c is CollisionShape2D):
				continue
			var sz: Vector2 = c.shape.size if c.shape is RectangleShape2D else Vector2(16, 16)
			solid.append(Rect2(n.global_position + c.position - sz * 0.5, sz))
	_ok("ada kotak padat untuk dibandingkan", solid.size() > 0, "%d kotak" % solid.size())

	for i in (petak if petak != null else []).size():
		var k: Rect2 = petak[i]
		var pad := Rect2(k.position - Vector2(MARGIN, MARGIN),
			k.size + Vector2(MARGIN, MARGIN) * 2.0)
		var tabrak: Array[String] = []
		for q in solid:
			if q.intersects(pad):
				tabrak.append(str(q))
		_ok("kandang %d %s bebas bangunan (margin %d px)" % [i, k.position, int(MARGIN)],
			tabrak.is_empty(),
			"" if tabrak.is_empty() else "%d tabrakan: %s" % [tabrak.size(), ", ".join(tabrak)])

	print("\n===== KANDANG: %d lulus, %d gagal =====" % [_l, _g])
	return true
