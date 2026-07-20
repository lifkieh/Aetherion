extends SceneTree
## Ukur KETERJANGKAUAN titik-periksa & anak (design-time, BUKAN test).
##
## Playtest jalan-kaki melaporkan dua cacat yang harness ber-warp TIDAK BISA melihat:
## titik-periksa di dalam tembok, dan anak menembus dinding. Warp menaruh pemain
## tepat di depan sasaran, jadi ia melompati justru bagian yang rusak — jalan menuju
## ke sana.
##
## Berkas ini tak menebak koordinat dari kode. Ia memuat scene SUNGGUHAN, membaca
## bentuk tabrakan yang benar-benar terpasang, lalu untuk tiap sasaran menanyakan:
##   (a) apakah titiknya sendiri berada DI DALAM benda padat?
##   (b) adakah petak yang bisa DIPIJAK dalam jangkauan interaksi?
## Jawaban (b) yang menentukan — pemain tak perlu berdiri di atas bukti, ia cuma
## perlu bisa berdiri cukup dekat.
##
## Pakai:
##   run_godot.bat --script res://tests/CekJangkau.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const RADIUS_INTERAKSI := 48.0     # Interactable.tscn: jarak label & interact
const BADAN := Vector2(30, 48)     # kotak pemain (Player.tscn)

var _t := 0.0
var _started := false


func _initialize() -> void:
	pass


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[jangkau] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:
		return false
	_ukur()
	quit(0)
	return true


func _kotak_padat(scn: Node) -> Array:
	"""Semua Rect2 padat yang BENAR-BENAR terpasang di scene."""
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


func _bisa_dipijak(p: Vector2, padat: Array) -> bool:
	return _bisa_dipijak_kotak(p, padat, BADAN, Vector2.ZERO)


func _bisa_dipijak_kotak(p: Vector2, padat: Array, ukuran: Vector2, geser: Vector2) -> bool:
	var kaki := Rect2(p + geser - ukuran * 0.5, ukuran)
	for r in padat:
		if r.intersects(kaki):
			return false
	return true


func _ukur() -> void:
	var scn := current_scene
	if scn == null:
		push_error("[jangkau] scene kosong")
		return
	var padat := _kotak_padat(scn)
	print("[jangkau] %d kotak padat terpasang" % padat.size())

	# --- titik-periksa: dibaca dari node Interactable yang nyata, bukan dari konstanta
	var titik: Array = []
	for c in scn.get_children():
		if c.get("evidence_id") != null and String(c.get("evidence_id")) != "":
			titik.append([String(c.get("evidence_id")), c.global_position])
	titik.sort_custom(func(a, b): return String(a[0]) < String(b[0]))

	var gagal := 0
	print("\n=== TITIK-PERIKSA (%d) ===" % titik.size())
	for t in titik:
		var id: String = t[0]
		var p: Vector2 = t[1]
		var di_dalam := not _bisa_dipijak(p, padat)
		# cari petak berpijak dalam jangkauan interaksi
		var pijak := 0
		var contoh := Vector2.ZERO
		for sudut in 16:
			var a := TAU * float(sudut) / 16.0
			for jarak: float in [20.0, 32.0, 44.0]:
				var q: Vector2 = p + Vector2.from_angle(a) * jarak
				if jarak <= RADIUS_INTERAKSI and _bisa_dipijak(q, padat):
					if pijak == 0:
						contoh = q
					pijak += 1
		var tanda := "OK" if pijak > 0 else "TAK TERJANGKAU"
		if pijak == 0:
			gagal += 1
		print("  %-34s %s  titik_di_dalam_padat=%s  petak_berpijak=%d %s"
			% [id, str(p), str(di_dalam), pijak,
			   ("contoh=" + str(contoh)) if pijak > 0 else ""])

	# --- anak
	print("\n=== ANAK ===")
	for c in scn.get_children():
		var sc = c.get_script()
		if sc == null or not String(sc.resource_path).ends_with("AshbrookKid.gd"):
			continue
		var p: Vector2 = c.global_position
		# kotak ANAK, bukan dewasa: mengukur anak dengan badan 30x48 akan menyatakan
		# "menembus" untuk anak yang sebenarnya cuma berdiri di sebelah bangku.
		var ok := _bisa_dipijak_kotak(p, padat, Vector2(16, 18), Vector2(0, -9))
		if not ok:
			gagal += 1
		print("  anak varian=%s %s  bisa_dipijak=%s"
			% [str(c.get("varian")), str(p), str(ok)])

	print("\n[jangkau] %s" % ("SEMUA TERJANGKAU" if gagal == 0 else "%d SASARAN BERMASALAH" % gagal))
