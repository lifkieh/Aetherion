extends SceneTree
## Ukur apakah KORIDOR WAJIB-DILEWATI benar-benar bisa dilalui (design-time, BUKAN test).
##
## `CekJangkau.gd` menanyakan "bisakah pemain berdiri cukup dekat dengan sasaran?".
## Berkas ini menanyakan pertanyaan yang berbeda dan tak kalah mahal kalau salah:
## **bisakah pemain SAMPAI ke sana?** Tata letak boleh benar di tiap titiknya dan tetap
## mustahil dijalani, karena yang menghalangi bukan bendanya melainkan CELAH di antara
## dua benda yang masing-masing sah.
##
## Cacat jenis ini tak pernah muncul sebagai galat. Ia muncul sebagai pemain yang
## berhenti menjelajah, dan sebabnya tak bisa dibaca dari kode mana pun.
##
## Tiga koridor di bawah lahir dari laporan blockout B' (reports/BLOCKOUT_ASHBROOK.md,
## "⚠ BELUM DIUJI KAKI") — Direktur menetapkannya wajib dilewati sebelum tata letak
## baru dipercaya.
##
## Pakai:
##   run_godot.bat --headless --script res://tests/CekKoridor.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const BADAN := Vector2(30, 48)     # kotak pemain (Player.tscn)
const LANGKAH := 8.0               # rapat sampling di sepanjang koridor
const LEBAR_UJI := 96.0            # seberapa jauh ke samping dicari celah

var _started := false
var _t := 0.0


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[koridor] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:                   # beri waktu `_ready()` memasang seluruh tabrakan
		return false
	quit(0 if _ukur() == 0 else 1)
	return true


func _kotak_padat(scn: Node) -> Array:
	var out: Array = []
	for body in scn.get_children():
		if not (body is StaticBody2D):
			continue
		for cs in body.get_children():
			if not (cs is CollisionShape2D) or cs.shape == null:
				continue
			if not (cs.shape is RectangleShape2D):
				continue
			var sz: Vector2 = cs.shape.size
			out.append(Rect2(cs.global_position - sz * 0.5, sz))
	return out


func _muat(p: Vector2, padat: Array) -> bool:
	var kaki := Rect2(p - BADAN * 0.5, BADAN)
	for r in padat:
		if r.intersects(kaki):
			return false
	return true


## Untuk tiap langkah di sepanjang koridor, cari celah TERDEKAT ke samping. Yang
## dilaporkan bukan "terhalang / tidak" melainkan SEBERAPA JAUH pemain harus menyimpang.
## Simpangan 0 = jalan lurus. Simpangan besar = koridor yang secara teknis terbuka tapi
## praktis terasa buntu, dan itu justru cacat yang paling sering lolos.
func _telusur(nama: String, a: Vector2, b: Vector2, padat: Array) -> int:
	var arah := (b - a).normalized()
	var samping := Vector2(-arah.y, arah.x)
	var panjang := a.distance_to(b)
	var n := int(panjang / LANGKAH) + 1
	var buntu := 0
	var simpangan_maks := 0.0
	var titik_terburuk := Vector2.ZERO
	for i in n + 1:
		var p: Vector2 = a + arah * (float(i) * LANGKAH)
		var geser := -1.0
		for d: float in [0.0, 8.0, 16.0, 24.0, 32.0, 44.0, 56.0, 72.0, LEBAR_UJI]:
			if _muat(p + samping * d, padat) or (d > 0.0 and _muat(p - samping * d, padat)):
				geser = d
				break
		if geser < 0.0:
			buntu += 1
			titik_terburuk = p
			if buntu <= 3:
				# NAMAI PENGHALANGNYA. "Buntu di (512,592)" menyuruh pembaca menebak;
				# kotak padat yang menyentuhnya menyuruhnya memperbaiki.
				for r in padat:
					if r.intersects(Rect2(p - BADAN * 0.5, BADAN)):
						print("      penghalang di %s: %s" % [str(p), str(r)])
		elif geser > simpangan_maks:
			simpangan_maks = geser
			titik_terburuk = p
	var tanda := "LOLOS" if buntu == 0 else "BUNTU"
	print("  %-42s %s  langkah=%d  buntu=%d  simpangan_maks=%.0f px  %s"
		% [nama, tanda, n + 1, buntu, simpangan_maks,
		   ("titik=" + str(titik_terburuk)) if (buntu > 0 or simpangan_maks > 0.0) else ""])
	return buntu


func _ukur() -> int:
	var scn := current_scene
	if scn == null:
		push_error("[koridor] scene kosong")
		return 1
	var padat := _kotak_padat(scn)
	print("[koridor] %d kotak padat terpasang" % padat.size())
	print("\n=== KORIDOR WAJIB-DILEWATI (B' tahap 1) ===")
	var gagal := 0
	# 1 — SUMBU: tepi selatan alun-alun turun ke gerbang. Jalur menit pertama pemain.
	gagal += _telusur("1a sumbu: alun-alun -> gerbang",
			Vector2(960, 872), Vector2(960, 1240), padat)
	# 1b — perempatan lorong distrik x sumbu tegaknya (koreksi 4)
	gagal += _telusur("1b lorong distrik: barat -> timur",
			Vector2(140, 268), Vector2(560, 268), padat)
	gagal += _telusur("1c lorong distrik: utara -> selatan",
			Vector2(302, 196), Vector2(302, 444), padat)
	# 2 — MULUT SELATAN ALUN-ALUN: melintas tepi selatan pelataran dari barat ke timur.
	gagal += _telusur("2  mulut selatan alun-alun",
			Vector2(700, 876), Vector2(1220, 876), padat)
	# 3 — DARI JALAN DAGANG NAIK KE DISTRIK BEKAS, lewat sela deretan rumah C2 barat.
	#     ⚠ Jalur uji pertama ditarik di x=512 dan melaporkan BUNTU — tapi yang buntu
	#       jalur ujinya, bukan petanya: garis itu menabrak kaki rumah (492,650)
	#       lurus-lurus. Deretan rumah memang tak bisa ditembus; ia dilewati di
	#       SELANYA. Alat yang menyalahkan peta karena garis ujinya salah lebih
	#       berbahaya daripada tak punya alat — angkanya dipercaya, padahal bohong.
	gagal += _telusur("3  sela rumah C2 -> distrik bekas",
			Vector2(390, 700), Vector2(390, 300), padat)
	# 3b — CELAH GUDANG <-> MERRIT. Inilah yang benar-benar pernah buntu: 30 px, persis
	#      selebar badan pemain. Dipertahankan sebagai penjaga tetap — kalau salah satu
	#      dari dua bangunan itu digeser lagi, baris ini yang berteriak lebih dulu.
	gagal += _telusur("3b celah gudang <-> Merrit",
			Vector2(694, 640), Vector2(694, 300), padat)
	print("\n[koridor] %s" % ("SEMUA KORIDOR LOLOS" if gagal == 0
			else "%d LANGKAH BUNTU" % gagal))
	return gagal
