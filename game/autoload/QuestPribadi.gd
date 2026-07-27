extends Node
## QUEST PRIBADI (#291-3) — permintaan yang lahir dari MULUT NPC bernama, bukan
## papan. Empat quest gelombang 1 (putusan Direktur #291): Merrit "Perhentian yang
## Tak Masuk Akal" (Memory) · Halloran "Dua Ratus Roti" (Legacy) · Bram "Kursi
## Favorit" (Hidden) · Nyai "Kamis Sore" (Fear + lahirnya jadwal-observe).
##
## HUKUM YANG DIPEGANG:
##   E8 (#80)  — tiap quest MENGUBAH NPC-nya (baris `lines_selesai` terbuka,
##               perilaku bergeser), bukan fetch demi hadiah.
##   #122      — tak ada UI "Terima quest? [Y/N]": permintaan keluar di dialog,
##               menerima = MELAKUKANNYA.
##   D-3       — quest Nyai berujung bukti Chronicle; penemuan bukti tetap SENYAP
##               (Evidence.find yang bicara lewat notice biasa, tanpa penanda).
##
## STATE: WorldState.counters (persisted) — `qp_<id>`: 0 belum, 1 aktif, 2 selesai.
## Penghitung bantu: `qp_<id>_n` (jumlah bicara / roti terbagi).

const AKTIF := 1
const SELESAI := 2


func _ready() -> void:
	EventBus.villager_talked.connect(_on_talk)


func tahap(id: String) -> int:
	return WorldState.get_counter("qp_" + id)


func _tahapkan(id: String, t: int) -> void:
	WorldState.counters["qp_" + id] = t


# ────────────────────────────────────────────────────── pemicu dari dialog
func _on_talk(nama: String) -> void:
	match nama:
		"Merrit Fane":
			if tahap("merrit") == 0:
				WorldState.add_counter("qp_merrit_n")
				# bicara kedua: ia menitipkan surat — permintaan keluar dari dialog,
				# menerima = mengantarkannya (#122)
				if WorldState.get_counter("qp_merrit_n") >= 2:
					_tahapkan("merrit", AKTIF)
					EventBus.toast.emit("📮 Merrit menitipkan surat: \"Rute utara, perhentian terakhir. Kau akan tahu tempatnya... atau tidak.\"")
		"Halloran Muda":
			if tahap("halloran") == 0:
				_tahapkan("halloran", AKTIF)
				PlayerData.add_item("roti_halloran", 5)
				EventBus.toast.emit("🍞 Halloran menyodorkan sekeranjang: \"Bantu habiskan. Jangan tanya kenapa kubuat segini.\"")
			elif tahap("halloran") == AKTIF and nama != "Halloran Muda":
				pass
		"Old Bram":
			if tahap("bram") == 0:
				WorldState.add_counter("qp_bram_n")
				# gosip ketiga menyebut "kursi favorit" — bertanya = mencarinya
				if WorldState.get_counter("qp_bram_n") >= 3:
					_tahapkan("bram", AKTIF)
					EventBus.toast.emit("🪑 Bram: \"Kursi ini pengganti. Punya ayahku hilang waktu rumah lama kami di distrik tua runtuh. Kalau kau iseng ke sana...\"")
		"Arlen":
			# #298 chain #3 — reaksi pemain pada kegagalannya DICATAT senyap:
			# datang menemui orang yang sedang malu adalah jawaban, bukan tombol.
			if WorldState.get_counter("arlen_gagal") == 1 \
					and WorldState.get_counter("arlen_jangkar") == 0:
				WorldState.add_counter("arlen_ditemani")
			# #295 S3 — pintu pertama yang murah (chain #2): bicara ke-3, ia
			# menitipkan surat lamaran kurir Serikat yang tak pernah berani ia
			# kirim (#122: permintaan keluar dari dialog; menerima = membawanya).
			WorldState.add_counter("arlen_bicara_n")
			if WorldState.get_counter("arlen_bicara_n") >= 3 \
					and WorldState.get_counter("arlen_titipan") == 0:
				WorldState.counters["arlen_titipan"] = 1
				PlayerData.add_item("paket_arlen", 1)
				EventBus.toast.emit("📮 Arlen menitipkan amplop tipis: \"Untuk Sela. Serikat, Greenvale. ...Jangan dibaca di depanku.\"")
		_:
			# HALLORAN — membagi roti: bicara dengan penduduk mana pun sambil
			# membawa roti = memberikannya. Tiap orang menerima dengan caranya.
			if tahap("halloran") == AKTIF and PlayerData.item_count("roti_halloran") > 0 \
					and nama != "Halloran Muda":
				PlayerData.remove_item("roti_halloran", 1)
				WorldState.add_counter("qp_halloran_n")
				if WorldState.get_counter("qp_halloran_n") >= 5:
					_tahapkan("halloran", SELESAI)
					# E8: besoknya Halloran memanggang 40. Kebiasaan yang mengingat
					# kota besar baru saja mati — dan pemainlah yang "membantunya".
					# Tak ada yang mengatakan ini baik atau buruk (kejam-cuaca #229).
					EventBus.toast.emit("🍞 Keranjang kosong. Halloran mengangguk dari kejauhan.")


# ────────────────────────────────────────────────── titik dunia (dipanggil prop)
## Dipanggil Ashbrook64Prop ber-`qp_id` sesudah teksnya selesai dibaca.
## Titiknya SELALU ada di dunia (rangka bangku, tanah perhentian — mereka fakta,
## bukan penanda quest); yang berubah saat quest aktif hanyalah MAKNANYA.
func titik(id: String, pos := Vector2.ZERO) -> void:
	match id:
		"nyai_temani":
			nyai_temani(pos)
		"sora_ritual":
			sora_ritual(pos)
		"sora_makam":
			# #302 — benih busur penggusuran: menemani ritualnya DI RUMAHNYA.
			# Sekali cukup; yang dicatat bukan jasa, melainkan KESAKSIAN (senyap).
			if WorldState.get_counter("sora_pulang") == 1 \
					and WorldState.get_counter("penggusuran_saksi") == 0:
				temani_mulai("sora_makam", pos, 10.0, func():
					WorldState.counters["penggusuran_saksi"] = 1)
		"corvin_upah":
			# #298 chain #4 — MENGHAPUS JANGKAR (#122 dua sentuhan): sentuhan
			# pertama ia cuma menatap pundinya; sentuhan kedua = keputusan.
			if WorldState.get_counter("arlen_jangkar") != 1:
				return
			if WorldState.get_counter("corvin_tatap") == 0:
				WorldState.counters["corvin_tatap"] = 1
				EventBus.toast.emit("🪙 Corvin menatap pundimu lama. Tidak berkata apa-apa.")
			elif PlayerData.spend_gold(500):
				WorldState.counters["arlen_jangkar"] = 2
				EventBus.toast.emit("🪙 500G — upah tenaga tani semusim. Corvin: \"Jangan tinggal karena aku. Aku tidak sanggup jadi alasan.\"")
			else:
				EventBus.toast.emit("🪙 Tenaga tani semusim: 500G. Pundimu belum cukup.")
		"merrit_antar":
			if tahap("merrit") == AKTIF:
				_tahapkan("merrit", SELESAI)
				# E8: malam itu Merrit di bangku lampunya lebih lama; baris barunya
				# terbuka (lines_selesai di town_npcs). Hadiah = baris itu.
				EventBus.toast.emit("📮 Surat terantar. Tak ada rumah. Tak ada kotak pos. Tapi tanahnya... dikenal kakimu.")
		"bram_kursi":
			if tahap("bram") == AKTIF:
				_tahapkan("bram", SELESAI)
				EventBus.toast.emit("🪑 Rangka bangku lapuk, terkubur separuh. Ukirannya masih terbaca: inisial dua huruf.")


# ─────────────────────────────────────────────── NYAI — Kamis sore (jadwal-observe)
## Kamis sore WIB nyata (#159 jam nyata dipegang). Override `uji_kamis_sore`
## HANYA untuk harness/test (kalender nyata membuat test flake — #273).
func kamis_sore() -> bool:
	if WorldState.get_counter("uji_kamis_sore") == 1:
		return true
	var kini: Dictionary = Time.get_datetime_dict_from_unix_time(
		int(Time.get_unix_time_from_system()) + GameClock.WIB_OFFSET)
	return int(kini.get("weekday", -1)) == 4 and int(kini.get("hour", 0)) >= 15 \
		and int(kini.get("hour", 0)) < 18


# ─────────────────────────────────── SORA — ritual malam (#295 S1: dua malam)
## Rekrut = MENEMANI ritualnya (bukan menu, #122): berada dekat 10 detik saat ia
## menyalakan lampu, DUA MALAM BERBEDA (satu nisan per malam — scene statis, dan
## dua malam adalah komitmen; dua puluh detik bukan). Semuanya senyap (D-3).
func sora_ritual(pos: Vector2) -> void:
	if WorldState.get_counter("sora_kenal") == 1:
		return
	var hari := int(Time.get_unix_time_from_system() / 86400.0)
	if WorldState.get_counter("sora_hari_terakhir") == hari:
		return   # malam ini sudah ditemani — ritual berikutnya besok
	temani_mulai("sora", pos, 10.0, func():
		WorldState.counters["sora_hari_terakhir"] = hari
		WorldState.add_counter("sora_temani_n")
		if WorldState.get_counter("sora_temani_n") >= 2:
			WorldState.counters["sora_kenal"] = 1)


## KEPULANGAN SORA (#302, v0.6c — amandemen #296 dibayar). Beban yang menariknya
## ke Ashbrook adalah kota yang kehilangan orang; saat KEDUA halaman orang pulih
## dan pemain sudah mengenalnya, panggilan itu selesai — ia pulang ke Candyveil.
## Senyap total (D-3): tak ada adegan; dunia yang berubah. Dicek saat build scene.
func cek_sora_pulang() -> void:
	if WorldState.get_counter("sora_pulang") == 1:
		return
	if WorldState.get_counter("sora_kenal") != 1:
		return
	if Chronicle.state_of("person_otha_renn") == Chronicle.ST_RESTORED \
			and Chronicle.state_of("person_merrit_fane") == Chronicle.ST_RESTORED:
		WorldState.counters["sora_pulang"] = 1


## S4 — Kamis MALAM (Nyai × Sora). Override `uji_kamis_malam` khusus harness.
func kamis_malam() -> bool:
	if WorldState.get_counter("uji_kamis_malam") == 1:
		return true
	var kini: Dictionary = Time.get_datetime_dict_from_unix_time(
		int(Time.get_unix_time_from_system()) + GameClock.WIB_OFFSET)
	return int(kini.get("weekday", -1)) == 4 and int(kini.get("hour", 0)) >= 19


# ─────────────────────────────────────── MESIN TEMANI generik (jadwal-observe, #296)
## Menemani = BERADA DI DEKAT sebuah titik selama N detik — bukan dialog, bukan
## tombol. Lahir untuk Nyai (#291-3), digenerikkan untuk ritual Sora (#295 S1).
## Menjauh = mulai ulang; menemani tak bisa disambil. Selesai = callable (senyap).
var _temani := {}   # id -> {"pos": Vector2, "sisa": float, "detik": float, "beres": Callable}


func temani_mulai(id: String, pos: Vector2, detik: float, beres: Callable) -> void:
	_temani[id] = {"pos": pos, "sisa": detik, "detik": detik, "beres": beres}


## Dipanggil saat pemain menyapa Nyai di depan toko (Kamis sore).
func nyai_temani(pos: Vector2) -> void:
	if tahap("nyai") == SELESAI:
		return
	_tahapkan("nyai", AKTIF)
	temani_mulai("nyai", pos, 8.0, func():
		if tahap("nyai") == AKTIF:
			_tahapkan("nyai", SELESAI)
			# Pengamatan = bukti `orang` halaman Otha (SENYAP — D-3: notice-nya
			# narasi biasa lewat jalur Evidence, tanpa penanda apa pun).
			Evidence.find("ev_otha_nyai_tuminah_kamis"))


func _process(delta: float) -> void:
	if _temani.is_empty():
		return
	var p := get_tree().get_first_node_in_group("player")
	if p == null:
		return
	for id in _temani.keys():
		var t: Dictionary = _temani[id]
		if p.global_position.distance_to(t["pos"]) <= 120.0:
			t["sisa"] -= delta
			if t["sisa"] <= 0.0:
				_temani.erase(id)
				(t["beres"] as Callable).call()
		else:
			t["sisa"] = t["detik"]   # menjauh = mulai lagi
