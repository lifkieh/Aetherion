extends SceneTree
## Bisakah PEMAIN benar-benar SAMPAI ke tiap titik-periksa, berjalan dari titik lahir?
## (design-time, BUKAN test)
##
## Ini menjawab pertanyaan #151b — pertanyaan yang memulai proyek: apakah rantai inti
## bisa diselesaikan pemain dari gerbang sampai nama Ashbrook tertulis di Chronicle.
##
## KENAPA BUKAN `PlayWalk64.gd`
## ----------------------------
## Harness itu berjalan sungguhan dengan WASD — dan justru itu batasnya: `_melangkah()`
## cuma menekan tombol ke ARAH sasaran lalu menyerah sesudah 30 detik. Ia tak punya
## pencarian jalur. Jadi ia tersangkut di sudut bangunan mana pun yang menghalangi
## garis lurus, dan melaporkan "tak sampai" untuk jalur yang manusia lewati dengan
## sekali memutar. Kegagalannya tak bisa dibedakan dari halangan sungguhan, dan
## alat yang tak bisa membedakan keduanya tak boleh dipakai memvonis.
##
## KENAPA BUKAN `CekKoridor.gd`
## ----------------------------
## Ia mengukur GARIS LURUS. Jalur sungguhan berbelok.
##
## Berkas ini menjawabnya dengan cara yang tak bisa keliru: BANJIR (BFS) atas seluruh
## petak yang muat ditempati badan pemain, berangkat dari titik lahir. Kalau sebuah
## titik-periksa tak pernah tersentuh banjir, ia MUSTAHIL dicapai — bukan "sulit",
## bukan "harness kurang pintar", melainkan mustahil. Dan kalau tersentuh, ia pasti
## bisa dicapai, dengan rute yang panjangnya ikut dilaporkan.
##
## Pakai:
##   run_godot.bat --headless --script res://tests/CekJalur.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const BADAN := Vector2(30, 48)
const PETAK := 16.0                # kerapatan banjir
const JANGKAU := 48.0              # Interactable.tscn: radius interaksi
const LEBAR := 1920
const TINGGI := 1408

var _started := false
var _t := 0.0


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[jalur] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:
		return false
	quit(_ukur())
	return true


func _padat(scn: Node) -> Array:
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


func _ukur() -> int:
	var scn := current_scene
	if scn == null:
		push_error("[jalur] scene kosong")
		return 1
	var padat := _padat(scn)
	var kol := int(LEBAR / PETAK)
	var bar := int(TINGGI / PETAK)

	# Peta bisa-dipijak. Dihitung sekali; BFS sesudahnya cuma membaca.
	var bebas := PackedByteArray()
	bebas.resize(kol * bar)
	for j in bar:
		for i in kol:
			var p := Vector2((i + 0.5) * PETAK, (j + 0.5) * PETAK)
			var kaki := Rect2(p - BADAN * 0.5, BADAN)
			var ok := 1
			for r in padat:
				if r.intersects(kaki):
					ok = 0
					break
			bebas[j * kol + i] = ok

	# Titik lahir DIBACA dari pemain yang benar-benar ada, bukan dikarang.
	var pl = scn.get_tree().get_first_node_in_group("player")
	if pl == null:
		push_error("[jalur] pemain tak ada")
		return 1
	var lahir: Vector2 = pl.global_position
	var si := clampi(int(lahir.x / PETAK), 0, kol - 1)
	var sj := clampi(int(lahir.y / PETAK), 0, bar - 1)
	if bebas[sj * kol + si] == 0:
		# Titik lahir DI DALAM benda padat sudah cacat tersendiri — laporkan keras,
		# lalu cari petak bebas terdekat supaya sisa pengukuran tetap berguna.
		print("[jalur] ⚠ TITIK LAHIR di dalam benda padat: %s" % str(lahir))
		var ket := 1
		while ket < 40:
			var temu := false
			for dj in range(-ket, ket + 1):
				for di in range(-ket, ket + 1):
					var a := si + di
					var b := sj + dj
					if a < 0 or b < 0 or a >= kol or b >= bar:
						continue
					if bebas[b * kol + a] == 1:
						si = a
						sj = b
						temu = true
						break
				if temu:
					break
			if temu:
				break
			ket += 1

	# ── BANJIR ───────────────────────────────────────────────────────────────
	var jarak := PackedInt32Array()
	jarak.resize(kol * bar)
	jarak.fill(-1)
	var antre: Array[int] = [sj * kol + si]
	jarak[sj * kol + si] = 0
	var kepala := 0
	while kepala < antre.size():
		var cur: int = antre[kepala]
		kepala += 1
		var ci := cur % kol
		var cj := cur / kol
		for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
			var ni: int = ci + d[0]
			var nj: int = cj + d[1]
			if ni < 0 or nj < 0 or ni >= kol or nj >= bar:
				continue
			var idx := nj * kol + ni
			if bebas[idx] == 0 or jarak[idx] >= 0:
				continue
			jarak[idx] = jarak[cur] + 1
			antre.append(idx)

	var terjangkau := 0
	for v in jarak:
		if v >= 0:
			terjangkau += 1
	var total_bebas := 0
	for v in bebas:
		if v == 1:
			total_bebas += 1
	print("[jalur] lahir di %s -> petak %dx%d, bebas %d, TERJANGKAU %d (%.1f%%)"
		% [str(lahir), kol, bar, total_bebas, terjangkau,
		   100.0 * float(terjangkau) / maxf(1.0, float(total_bebas))])

	# ── TITIK-PERIKSA: dibaca dari node nyata, bukan dari daftar yang bisa basi ──
	#
	# ⚠ TITIK DI DALAM RUANGAN DILEWATI, dan ini bukan pelonggaran.
	#   Alat ini menguji "bisakah dicapai BERJALAN dari titik lahir" dengan flood-fill
	#   di atas peta. Kamar Merrit hidup di ruang positif DI LUAR peta dan dicapai
	#   lewat PINTU, bukan dengan berjalan — jadi flood-fill akan selalu bilang tidak,
	#   dan selalu salah. Begitu dua bukti kamar dipasang (Jalur B), alat ini mulai
	#   melaporkan dua kegagalan palsu tiap kali dijalankan.
	#   Alarm palsu yang berulang jauh lebih berbahaya daripada tak ada alarm: ia
	#   melatih pembacanya mengabaikan keluaran alat ini.
	#   Keterjangkauan kamar dijamin uji lain — `TestRunner` memeriksa kotak interior
	#   PUNYA PINTU, dan `CekMerrit` memeriksa titiknya ada serta tak berebut tombol E.
	var ruang_dalam := Rect2(scn.INTERIOR, Vector2(320, 240))
	var titik: Array = []
	var dilewat: Array = []
	for c in scn.get_children():
		if c.get("evidence_id") != null and String(c.get("evidence_id")) != "":
			if ruang_dalam.has_point(c.global_position):
				dilewat.append(String(c.get("evidence_id")))
				continue
			titik.append([String(c.get("evidence_id")), c.global_position])
	if not dilewat.is_empty():
		print("  (dilewati — di dalam ruangan, dicapai lewat pintu: %s)"
			% ", ".join(dilewat))
	titik.sort_custom(func(a, b): return String(a[0]) < String(b[0]))

	print("\n=== RANTAI INTI: bisakah dicapai BERJALAN dari titik lahir? ===")
	var gagal := 0
	for t in titik:
		var id: String = t[0]
		var p: Vector2 = t[1]
		# Cukup ada SATU petak terjangkau dalam radius interaksi.
		var langkah := -1
		var r := int(ceil(JANGKAU / PETAK))
		var pi := int(p.x / PETAK)
		var pj := int(p.y / PETAK)
		for dj in range(-r, r + 1):
			for di in range(-r, r + 1):
				var a := pi + di
				var b := pj + dj
				if a < 0 or b < 0 or a >= kol or b >= bar:
					continue
				var q := Vector2((a + 0.5) * PETAK, (b + 0.5) * PETAK)
				if q.distance_to(p) > JANGKAU:
					continue
				var dd := jarak[b * kol + a]
				if dd >= 0 and (langkah < 0 or dd < langkah):
					langkah = dd
		if langkah < 0:
			gagal += 1
			print("  %-34s ✗ TAK TERJANGKAU dari titik lahir" % id)
		else:
			print("  %-34s ✓ %d langkah (~%.0f px berjalan)" % [id, langkah, langkah * PETAK])

	print("\n[jalur] %s" % ("RANTAI INTI UTUH — tiap titik-periksa bisa dicapai berjalan"
			if gagal == 0 else "%d TITIK MUSTAHIL DICAPAI" % gagal))
	return 0 if gagal == 0 else 1
