extends SceneTree
## CEK MONSTER LIAR ASHBROOK — di luar tembok, dan TETAP di luar (#151b · UI/UX §4).
##
## KENAPA UJI INI ADA
## ------------------
## Tiga cacat ditemukan sekaligus waktu monster liar dipasang, dan tak satu pun
## terlihat oleh 1.122 test yang ada:
##
##   1. ZONA AMAN SALAH SKALA. `towns.json` masih memakai koordinat era 16 px
##      (`center [480, 352]`, persis separuh `VC`). Poligonnya menutupi x160..800,
##      y132..602 — pojok barat-laut yang kosong — sementara ALUN-ALUNNYA SENDIRI
##      di luar zona. Monster apa pun yang dimunculkan akan berjalan ke pasar.
##   2. ANAK SERIGALA #118 SALAH KELAS. Ia `DungeonMonster` — platformer sisi-samping
##      dengan `GRAVITY = 900.0`. Di peta atas-bawah ia jatuh 330 px dalam 4 detik
##      sampai tersangkut treeline. `PlayWalk64` tetap hijau karena ia cuma bertanya
##      "grup `wolf_pup` ada?", tak pernah "di mana ia berakhir?".
##   3. AGGRO MENEMPEL GARIS. Percobaan pertama menaruh babi 136 px dari titik lahir,
##      sementara `wild_boar` beraggro 140 — mereka menyerbu lalu bergetar di tepi
##      zona yang tak bisa ditembus, tepat di depan pemain yang baru lahir.
##
## Ketiganya punya bentuk yang sama: yang diperiksa selama ini KEBERADAAN, bukan
## AKIBAT. "Monsternya ada" lolos untuk monster yang jatuh, monster yang menyerbu
## kaca, dan zona yang melindungi tanah kosong.
##
## Maka uji ini MENJALANKAN dunianya beberapa detik lalu mengukur hasilnya, bukan
## membaca daftar node sesaat sesudah lahir.

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const JEDA := 6.0                 # detik simulasi sebelum diukur
const HANYUT_MAKS := 160.0        # px; gravitasi menyeret jauh lebih dari ini
const JARAK_AMAN := 200.0         # px dari titik lahir — di atas aggro terbesar (160)

var _l := 0
var _g := 0
var _mulai := false
var _t := 0.0
var _awal := {}
var _lahir := Vector2.ZERO


func _ok(label: String, cond: bool, detail := "") -> void:
	if cond:
		_l += 1
	else:
		_g += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


func _process(delta: float) -> bool:
	if not _mulai:
		_mulai = true
		change_scene_to_file(SCENE)
		return false
	_t += delta
	if _t < 0.5:
		return false

	var SZ = root.get_node_or_null("/root/SafeZone")
	if SZ == null:
		print("  [GAGAL] autoload SafeZone tak ada")
		print("\n===== MONSTER LIAR: 0 lulus, 1 gagal =====")
		return true

	var liar := get_nodes_in_group("liar_ashbrook")
	var pup := get_nodes_in_group("wolf_pup")

	if _awal.is_empty():
		for m in liar + pup:
			_awal[m] = m.global_position
		var pl = get_first_node_in_group("player")
		if pl:
			_lahir = pl.global_position
		return false

	if _t < JEDA:
		return false

	# ── zona aman harus benar-benar melindungi DESANYA ────────────────────────
	_ok("zona aman aktif", SZ.is_active(), "%d titik" % SZ.polygon().size())
	_ok("alun-alun di dalam zona aman", SZ.contains(Vector2(960, 704)))
	_ok("titik lahir di dalam zona aman", SZ.contains(_lahir), str(_lahir))

	# Tiap titik jadwal tiap warga — inilah yang menangkap cacat skala 16 px.
	var f := FileAccess.open("res://data/town_npcs.json", FileAccess.READ)
	var npc: Array = (JSON.parse_string(f.get_as_text()) as Dictionary).get("ashbrook", [])
	var luar: Array[String] = []
	for e in npc:
		var an: Array = e.get("anchor", [0, 0])
		for fase in (e.get("schedule", {}) as Dictionary):
			var at: Array = e["schedule"][fase].get("at", [0, 0])
			var p := Vector2(an[0] + at[0], an[1] + at[1])
			if not SZ.contains(p):
				luar.append("%s/%s %s" % [e.get("name", "?"), fase, p])
	_ok("tiap titik jadwal warga di dalam zona aman", luar.is_empty(),
		"" if luar.is_empty() else "%d di luar: %s" % [luar.size(), ", ".join(luar)])

	# ── monster liar: ada, di luar, dan TETAP di luar ─────────────────────────
	_ok("ada monster liar", liar.size() >= 2, "%d ekor" % liar.size())
	# Langkah tutorial pertama menuntut DUA bangkai, dan peta ini tak punya spawner —
	# satu monster berarti menunggu respawn yang tak pernah datang.
	var bisa_dibunuh := 0
	for m in liar:
		if m.inst.get("ai", "") != "skittish":
			bisa_dibunuh += 1
	_ok("cukup monster untuk langkah tutorial 'kalahkan 2'", bisa_dibunuh >= 2,
		"%d non-skittish" % bisa_dibunuh)

	var masuk: Array[String] = []
	var hanyut: Array[String] = []
	var dekat: Array[String] = []
	for m in _awal:
		if not is_instance_valid(m):
			continue
		var sp: String = m.inst.get("species_id", "?")
		if SZ.contains(m.global_position):
			masuk.append("%s %s" % [sp, m.global_position])
		var h: float = _awal[m].distance_to(m.global_position)
		if h > HANYUT_MAKS:
			hanyut.append("%s hanyut %.0f px" % [sp, h])
		if _lahir != Vector2.ZERO and _lahir.distance_to(_awal[m]) < JARAK_AMAN:
			dekat.append("%s lahir %.0f px dari pemain" % [sp, _lahir.distance_to(_awal[m])])
	_ok("nol monster menembus zona aman setelah %.0f detik" % JEDA, masuk.is_empty(),
		"" if masuk.is_empty() else "%d masuk: %s" % [masuk.size(), ", ".join(masuk)])
	# HANYUT menangkap kelas fisika yang salah: monster platformer di peta atas-bawah
	# JATUH, dan jatuhnya jauh melebihi apa pun yang bisa dihasilkan berkelana.
	_ok("nol monster hanyut > %.0f px (kelas fisika benar)" % HANYUT_MAKS, hanyut.is_empty(),
		"" if hanyut.is_empty() else ", ".join(hanyut))
	_ok("nol monster lahir dalam jangkauan aggro titik lahir", dekat.is_empty(),
		"" if dekat.is_empty() else ", ".join(dekat))

	print("\n===== MONSTER LIAR: %d lulus, %d gagal =====" % [_l, _g])
	return true
