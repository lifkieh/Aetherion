extends SceneTree
## CEK JADWAL NPC — apakah tokoh berdiri di tempat yang dikatakan kalimatnya.
##
## KENAPA UJI INI ADA
## Sesudah tata letak Ashbrook dirombak ke B', offset jadwal di `town_npcs.json`
## tak pernah dihitung ulang. Akibatnya lima belas pos jadwal semuanya mendarat di
## alun-alun: Merrit "menyalakan lampu, lalu duduk" sambil berdiri **452 px dari
## lampunya**, Halloran "memanggang dua ratus roti" 278 px dari toko rotinya.
##
## Nol dari 1.122 uji melihatnya, dan itu masuk akal — semuanya memeriksa hal yang
## memang benar: warga hidup, bergerak, bisa diajak bicara. Yang tak pernah diukur
## adalah HUBUNGAN antara teks kegiatan dan tempatnya.
##
## Uji ini mengukur tepat itu, dan ia sengaja memakai KATA KUNCI DARI TEKSNYA
## SENDIRI — bukan daftar terpisah tokoh->tempat. Daftar terpisah akan berbohong
## begitu seseorang menyunting salah satu sisi saja.

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const AMBANG := 140.0        # px; layar memuat ~640, jadi 140 masih "di tempatnya"

var _mulai := false
var _t := 0.0
var _l := 0
var _g := 0


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
		if change_scene_to_file(SCENE) != OK:
			push_error("[jadwal] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:
		return false
	quit(_ukur())
	return true


func _ukur() -> int:
	print("===== JADWAL NPC vs TEMPAT YANG DISEBUTNYA =====")
	var scn := current_scene
	if scn == null:
		print("GAGAL: scene kosong")
		return 1
	var db = root.get_node("Db")

	# Kata kunci -> titik nyata di dunia, dibaca dari KONSTANTA SCENE, bukan disalin.
	# Menyalin koordinat ke sini berarti uji ini akan tetap hijau kalau petanya
	# bergeser — persis kegagalan yang sedang diperbaiki.
	var tempat := {
		"rumah singgah": scn.MERRIT_HOUSE,
		"lampu": scn.MERRIT_HOUSE + Vector2(72, -56),
		"kamar": scn.MERRIT_HOUSE,
		"roti": scn.HALLORAN_KAKI,
		"tungku": scn.HALLORAN_KAKI,
		"bangku": Vector2(736, 816),           # bangku alun-alun paling barat
		"air mancur": scn.VC + Vector2(-38, -22),
	}

	var diuji := 0
	for p in db.town_npcs.get("ashbrook", []):
		var nama := String(p.get("name", "?"))
		if not p.has("anchor"):
			continue                            # tanpa jangkar, posisinya memang cincin
		var a: Array = p["anchor"]
		var jangkar := Vector2(float(a[0]), float(a[1]))
		for slot in p.get("schedule", {}):
			var s: Dictionary = p["schedule"][slot]
			var teks := String(s.get("do", "")).to_lower()
			var off: Array = s.get("at", [0, 0])
			var pos := jangkar + Vector2(float(off[0]), float(off[1]))
			# ⚠ "MENYEBUT" TIDAK SAMA DENGAN "BERADA DI", dan versi pertama uji ini
			#   menyamakannya lalu menuduh dua kalimat yang benar:
			#     Bram  "memandangi air mancur"  174 px — ia MEMANDANG dari bangku,
			#           dan 174 px justru jarak pandang yang masuk akal.
			#     Lyra  "jendelanya padam lebih dulu dari lampu Merrit" 869 px —
			#           itu PEMBANDING dari rumahnya, dan #218 memang merancang lampu
			#           itu terlihat dari seberang peta.
			#   Menaikkan ambang akan melemahkan uji untuk semua orang demi dua
			#   kalimat. Yang benar: kenali kata kerjanya. Kalimat yang MEMANDANG
			#   tidak dituntut berdiri di sana — ia cuma dituntut punya sasaran nyata.
			var memandang := teks.contains("memandangi") or teks.contains("melihat") \
				or teks.contains("dari ")
			for kunci in tempat:
				if not teks.contains(kunci):
					continue
				diuji += 1
				var d := pos.distance_to(tempat[kunci])
				if memandang:
					_ok("%s/%s MEMANDANG '%s' (sasaran nyata, jarak bebas)"
						% [nama, slot, kunci], true, "%.0f px" % d)
				else:
					_ok("%s/%s berada di '%s'" % [nama, slot, kunci], d <= AMBANG,
						"%.0f px (ambang %.0f)" % [d, AMBANG])

	_ok("ada pasangan teks-tempat yang benar-benar diuji", diuji > 0, str(diuji))
	print("\n===== JADWAL: %d lulus, %d gagal =====" % [_l, _g])
	return 0 if _g == 0 else 1
