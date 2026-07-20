extends SceneTree
## PETA TABRAKAN + BANJIR-ISI (design-time, BUKAN test).
##
## Menjawab tiga pertanyaan yang tak bisa dijawab dengan membaca kode, dan yang
## harness ber-warp juga tak bisa jawab karena ia melompati jalannya:
##   1. CELAH  — adakah lubang tak-disengaja di antara dua benda padat?
##   2. KURUNGAN — adakah petak yang bisa dimasuki tapi tak bisa dikeluari, atau
##      kantong berpijak yang terputus dari tempat pemain lahir?
##   3. PIJAK  — apakah tiap titik-periksa punya petak berpijak yang TERSAMBUNG ke
##      tempat lahir, bukan sekadar "ada ruang di sekitarnya"?
##
## Caranya: seluruh peta dirasterkan jadi kisi; satu petak disebut BERPIJAK bila
## kotak badan pemain (30x48) muat di sana tanpa menyentuh benda padat. Lalu
## banjir-isi dari titik lahir. Yang tak tersentuh banjir adalah jawabannya.
##
## ⚠ BATAS ALAT INI, dan harus dibaca sebelum hasilnya dipercaya: ia menguji
## KETERSAMBUNGAN GEOMETRIS, bukan rasa berjalan. Ia tak tahu apakah lorong selebar
## satu petak terasa sempit, apakah pemain akan menemukan jalannya, atau apakah
## tersangkut di sudut. Itu kaki Direktur, bukan alat.
##
## Pakai:
##   run_godot.bat --script res://tests/CekPeta.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const SEL := 16                       # sisi petak raster (px)
const BADAN := Vector2(30, 48)
const RADIUS_INTERAKSI := 48.0
const OUT := "res://../reports/preview/62_peta_tabrakan.png"

var _t := 0.0
var _mulai := false


func _process(delta: float) -> bool:
	if not _mulai:
		_mulai = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[peta] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.6:
		return false
	_ukur()
	quit(0)
	return true


func _padat(scn: Node) -> Array:
	var out: Array = []
	for body in scn.get_children():
		if not (body is StaticBody2D):
			continue
		for cs in body.get_children():
			if cs is CollisionShape2D and cs.shape is RectangleShape2D:
				var sz: Vector2 = cs.shape.size
				out.append(Rect2(cs.global_position - sz * 0.5, sz))
	return out


func _ukur() -> void:
	var scn := current_scene
	if scn == null:
		push_error("[peta] scene kosong")
		return
	var W: int = int(scn.MAP_W) * int(scn.TILE)
	var H: int = int(scn.MAP_H) * int(scn.TILE)
	var kw := int(W / SEL)
	var kh := int(H / SEL)
	var padat := _padat(scn)
	print("[peta] %dx%d px · kisi %dx%d · %d kotak padat" % [W, H, kw, kh, padat.size()])

	# --- raster: berpijak?
	var pijak := PackedByteArray()
	pijak.resize(kw * kh)
	var n_pijak := 0
	for gy in kh:
		for gx in kw:
			var p := Vector2(gx * SEL + SEL * 0.5, gy * SEL + SEL * 0.5)
			var kaki := Rect2(p - BADAN * 0.5, BADAN)
			var bebas := kaki.position.x >= 0.0 and kaki.position.y >= 0.0 \
					and kaki.end.x <= float(W) and kaki.end.y <= float(H)
			if bebas:
				for r in padat:
					if r.intersects(kaki):
						bebas = false
						break
			pijak[gy * kw + gx] = 1 if bebas else 0
			if bebas:
				n_pijak += 1

	# --- banjir-isi dari tempat lahir pemain
	var pl = root.get_tree().get_first_node_in_group("player")
	if pl == null:
		push_error("[peta] pemain tak ada")
		return
	var lahir: Vector2 = pl.global_position
	var sx := clampi(int(lahir.x / SEL), 0, kw - 1)
	var sy := clampi(int(lahir.y / SEL), 0, kh - 1)
	if pijak[sy * kw + sx] == 0:
		# titik lahir sendiri tak berpijak — cari petak berpijak terdekat
		print("[peta] ⚠ titik lahir TIDAK berpijak (%s) — mencari terdekat" % str(lahir))
		var best := -1
		for gy in kh:
			for gx in kw:
				if pijak[gy * kw + gx] == 1:
					var d := absi(gx - sx) + absi(gy - sy)
					if best < 0 or d < best:
						best = d
						sx = gx
						sy = gy
	var capai := PackedByteArray()
	capai.resize(kw * kh)
	var antre: Array[int] = [sy * kw + sx]
	capai[sy * kw + sx] = 1
	var n_capai := 1
	while not antre.is_empty():
		var i: int = antre.pop_back()
		var cx := i % kw
		var cy := int(i / kw)
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = cx + d.x
			var ny: int = cy + d.y
			if nx < 0 or ny < 0 or nx >= kw or ny >= kh:
				continue
			var j: int = ny * kw + nx
			if capai[j] == 1 or pijak[j] == 0:
				continue
			capai[j] = 1
			n_capai += 1
			antre.append(j)

	print("[peta] berpijak %d petak · tercapai dari lahir %d (%.1f%%) · TERKURUNG %d" %
		[n_pijak, n_capai, 100.0 * n_capai / maxi(1, n_pijak), n_pijak - n_capai])

	# --- kantong terkurung: kelompokkan yang berpijak tapi tak tercapai
	var kantong: Array = []
	var lihat := PackedByteArray()
	lihat.resize(kw * kh)
	for gy in kh:
		for gx in kw:
			var i0 := gy * kw + gx
			if pijak[i0] == 0 or capai[i0] == 1 or lihat[i0] == 1:
				continue
			var q: Array[int] = [i0]
			lihat[i0] = 1
			var anggota: Array[int] = []
			while not q.is_empty():
				var i: int = q.pop_back()
				anggota.append(i)
				var cx := i % kw
				var cy := int(i / kw)
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = cx + d.x
					var ny: int = cy + d.y
					if nx < 0 or ny < 0 or nx >= kw or ny >= kh:
						continue
					var j: int = ny * kw + nx
					if lihat[j] == 1 or pijak[j] == 0 or capai[j] == 1:
						continue
					lihat[j] = 1
					q.append(j)
			kantong.append(anggota)
	kantong.sort_custom(func(a, b): return a.size() > b.size())
	print("\n=== KANTONG TERKURUNG (berpijak tapi tak tersambung ke tempat lahir) ===")
	if kantong.is_empty():
		print("  NOL — seluruh ruang berpijak tersambung.")
	for k in kantong.slice(0, 8):
		var i0: int = k[0]
		print("  %4d petak · contoh (%d, %d) px" % [k.size(), (i0 % kw) * SEL, int(i0 / kw) * SEL])

	# --- titik-periksa: ada petak berpijak TERCAPAI dalam jangkauan?
	print("\n=== TITIK-PERIKSA: tersambung ke tempat lahir? ===")
	var gagal := 0
	for c in scn.get_children():
		var ev = c.get("evidence_id")
		if ev == null or String(ev) == "":
			continue
		var p: Vector2 = c.global_position
		var ok := false
		var rr := int(RADIUS_INTERAKSI / SEL) + 1
		var bx := int(p.x / SEL)
		var by := int(p.y / SEL)
		for dy in range(-rr, rr + 1):
			for dx in range(-rr, rr + 1):
				var nx: int = bx + dx
				var ny: int = by + dy
				if nx < 0 or ny < 0 or nx >= kw or ny >= kh:
					continue
				if capai[ny * kw + nx] == 0:
					continue
				if Vector2(nx * SEL + 8, ny * SEL + 8).distance_to(p) <= RADIUS_INTERAKSI:
					ok = true
					break
			if ok:
				break
		if not ok:
			gagal += 1
		print("  %-36s %s  %s" % [String(ev), str(p), "OK" if ok else "TAK TERSAMBUNG"])

	# --- gambar peta
	var img := Image.create(kw, kh, false, Image.FORMAT_RGB8)
	for gy in kh:
		for gx in kw:
			var i := gy * kw + gx
			var col := Color(0.16, 0.15, 0.18)          # padat / luar peta
			if pijak[i] == 1:
				col = Color(0.30, 0.62, 0.34) if capai[i] == 1 else Color(0.85, 0.30, 0.25)
			img.set_pixel(gx, gy, col)
	var abs_out := ProjectSettings.globalize_path("res://").path_join(
		"../reports/preview/62_peta_tabrakan.png").simplify_path()
	img.resize(kw * 3, kh * 3, Image.INTERPOLATE_NEAREST)
	img.save_png(abs_out)
	print("\n[peta] hijau=tercapai · MERAH=berpijak tapi terkurung · gelap=padat/luar")
	print("[peta] -> %s" % abs_out)
	if gagal > 0:
		print("[peta] %d titik-periksa TAK TERSAMBUNG" % gagal)
