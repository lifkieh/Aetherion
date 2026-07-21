extends SceneTree
## Rantai kesaksian Old Bram, diukur di DUNIA yang sebenarnya (#151b).
##
## #151b berbunyi "UKUR DUNIA, BUKAN TEKSNYA" — sebabnya #217, ketika test memeriksa
## pasangan mati↔hidup di dalam string dan enam bug lolos. Karena itu berkas ini tidak
## membaca `town_npcs.json`; ia MEMUAT `Ashbrook64.tscn`, mencari Bram yang benar-benar
## berdiri di alun-alun, dan mengajaknya bicara sampai kesaksiannya keluar.
##
## Yang dibuktikan, berurutan:
##   1. Bram di dunia CUMA SATU  (dulu dua: potret bisu + Villager berwajah generik)
##   2. Yang bisa diajak bicara memakai WAJAH ASLI (`old_bram`), bukan `warga_NN`
##   3. Ia berdiri di bangkunya, bukan di titik cincin yang kebetulan
##   4. Bicara berkali-kali -> baris kelima keluar -> bukti `orang` TERCATAT
##   5. DIAM: tak ada toast/banner — `evidence_found` nol pendengar (D-3)
##   6. `place_ashbrook_besar` kini punya KEEMPAT jenis bukti
##   7. Pemulihan SEMPURNA jadi mungkin: `enough_for("self")` true
##
## Pakai:
##   run_godot.bat --headless --script res://tests/CekBram.gd

const SCENE := "res://scenes/world/Ashbrook64.tscn"
const EV := "ev_ashbrook_bram_ingat_ayahnya"
const HALAMAN := "place_ashbrook_besar"
const BANGKU := Vector2(736, 800)

var _started := false
var _t := 0.0
var _lulus := 0
var _gagal := 0


func ok(label: String, cond: bool, detail: String = "") -> void:
	if cond:
		_lulus += 1
	else:
		_gagal += 1
	print("  [%s] %s%s" % ["LULUS" if cond else "GAGAL", label,
		"" if detail == "" else "  -> " + detail])


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		if change_scene_to_file(SCENE) != OK:
			push_error("[bram] gagal memuat scene")
			quit(1)
		return false
	_t += delta
	if _t < 1.5:
		return false
	quit(_ukur())
	return true


func _ukur() -> int:
	var scn := current_scene
	if scn == null:
		push_error("[bram] scene kosong")
		return 1
	var ev = root.get_node("Evidence")
	var ch = root.get_node("Chronicle")

	print("\n===== RANTAI KESAKSIAN OLD BRAM (#151b) =====")

	# --- 1 & 2: berapa Bram, dan wajah siapa -------------------------------
	var bram: Node = null
	var jumlah := 0
	for c in scn.get_children():
		var sc = c.get_script()
		if sc == null:
			continue
		if not String(sc.resource_path).ends_with("Villager.gd"):
			continue
		if String(c.get("_name")) == "Old Bram":
			jumlah += 1
			bram = c
	ok("Old Bram yang bisa diajak bicara ADA", bram != null)
	if bram == null:
		print("\n===== BRAM: %d lulus, %d gagal =====" % [_lulus, _gagal + 1])
		return 1
	ok("cuma SATU Bram yang bicara", jumlah == 1, "ketemu %d" % jumlah)
	ok("memakai WAJAH ASLI (old_bram, bukan warga_NN)",
		String(bram.get("lpc_sheet")) == "old_bram", String(bram.get("lpc_sheet")))

	# potret bisu lamanya harus sudah tak ada di titik yang sama
	var bisu := 0
	for c in scn.get_children():
		if c is Sprite2D and c.get_script() == null:
			if c.global_position.distance_to(BANGKU) < 8.0:
				bisu += 1
	ok("nol potret bisu tersisa di bangkunya", bisu == 0, "%d sprite" % bisu)

	# --- 3: ia duduk di bangkunya ------------------------------------------
	# ⚠ Diukur dari `_home`, BUKAN dari posisi saat ini. Villager berkelana; 1,5 detik
	#   sesudah muat ia sudah 76 px dari jangkarnya, dan itu bukan kesalahan penempatan
	#   melainkan tanda ia hidup. Yang harus benar adalah TEMPAT PULANGnya.
	var rumah: Vector2 = bram.get("_home")
	var d: float = rumah.distance_to(BANGKU)
	ok("jangkarnya DI BANGKU alun-alun (bukan titik cincin)", d < 8.0, "%.0f px" % d)

	# --- 4: ajak bicara sampai kesaksiannya keluar --------------------------
	ok("bukti BELUM ada sebelum diajak bicara", not ev.has(EV))
	var putaran := 0
	while putaran < 200 and not ev.has(EV):
		bram.persona_line()          # jalur yang sama dengan `interact()`
		putaran += 1
	ok("bicara berkali-kali -> kesaksian keluar", ev.has(EV), "%d giliran" % putaran)
	# Ia tak boleh keluar di sapaan pertama: empat baris gosip adalah TANGGA.
	ok("bukan di giliran pertama (gosip mendahului kesaksian)", putaran >= 5,
		"%d giliran" % putaran)

	# --- 5: DIAM (D-3) ------------------------------------------------------
	# `evidence_found` tak boleh punya pendengar; kalau ada, ia berpotensi memunculkan
	# UI, dan seluruh maksud "yang tak memperhatikan tak akan tahu" batal.
	var pendengar := root.get_node("EventBus").get_signal_connection_list("evidence_found")
	ok("DIAM — nol pendengar `evidence_found` (D-3)", pendengar.size() == 0,
		"%d pendengar" % pendengar.size())

	# --- 6 & 7: akibatnya pada halaman -------------------------------------
	# Lima bukti sisanya dipungut langsung. Sah: `PlayWalk64` sudah membuktikan
	# keenamnya bisa dicapai BERJALAN dan tercatat lewat tombol E. Yang diuji di sini
	# bukan lagi bisa-tidaknya dijangkau, melainkan APA YANG TERJADI pada halaman
	# begitu jenis keempat akhirnya masuk.
	for lain in ["ev_ashbrook_jembatan_terlalu_lebar", "ev_ashbrook_gudang_gandum",
			"ev_ashbrook_halloran_200_roti", "ev_ashbrook_batu_fondasi",
			"ev_ashbrook_fondasi_rumput"]:
		ev.find(lain)
	var kinds: Array = ev.kinds_for(HALAMAN)
	kinds.sort()
	ok("halaman punya jenis `orang`", kinds.has("orang"), str(kinds))
	ok("KEEMPAT jenis bukti terkumpul", kinds.size() == 4, str(kinds))
	ok("pemulihan SEMPURNA mungkin (enough_for self)", ev.enough_for(HALAMAN, "self"))
	ok("jalur Elyn juga cukup", ev.enough_for(HALAMAN, "elyn"))
	# Kelahiran & pencoretan halaman terjadi di jalur boot sungguhan
	# (`WorldState._ensure_world_pages()` saat Main Baru), bukan saat scene dimuat
	# telanjang seperti di sini. `PlayLoop64` yang membuktikan bagian itu — dilaporkan
	# sebagai keterangan, bukan sebagai gerbang, supaya alat ini tak menagih sesuatu
	# yang memang bukan tugasnya.
	print("  [info ] state halaman di muat-telanjang: '%s' (lahir di jalur boot; lihat PlayLoop64)"
		% ch.state_of(HALAMAN))

	# --- 8: BUKTI TERKUAT — apakah AKHIRNYA berubah? ------------------------
	# Sampai hari ini `place_ashbrook_besar` selalu pulih dengan loss yang sama, karena
	# jenis `orang` mustahil dipungut. Loss itu dirancang sebagai HUKUMAN karena
	# melewatkan kesaksian — dan selama ia satu-satunya akhir yang ada, ia bukan
	# hukuman, ia cuma nasib. Di sini halaman dilahirkan & dicoret persis seperti yang
	# dilakukan `WorldState` di jalur boot, lalu dipulihkan dengan keempat jenis di
	# tangan, lewat jalur yang SAMA dengan tombol Kitab (`Evidence.for_page`).
	ch.record_person(HALAMAN, "Ashbrook", "cek_bram")
	ch.strike(HALAMAN, "waktu")
	var hasil: Dictionary = ch.restore_self(HALAMAN, ev.for_page(HALAMAN))
	ok("pemulihan BERHASIL", bool(hasil.get("ok", false)), String(hasil.get("reason", "")))
	var loss := String(hasil.get("loss", ""))
	print("  [loss ] \"%s\"" % loss)
	ok("loss BUKAN LAGI 'tercatat sebagai kota, bukan seribu lima ratus orang'",
		not loss.begins_with("Ashbrook tercatat sebagai kota"),
		"masih loss lama" if loss.begins_with("Ashbrook tercatat") else "berubah")

	print("\n===== BRAM: %d lulus, %d gagal =====" % [_lulus, _gagal])
	return 0 if _gagal == 0 else 1
