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


var _nyai_pos := Vector2.ZERO
var _nyai_t := 0.0

## Dipanggil saat pemain menyapa Nyai di depan toko (Kamis sore). Menemani =
## BERADA DI DEKATNYA beberapa saat — bukan dialog, bukan tombol.
func nyai_temani(pos: Vector2) -> void:
	if tahap("nyai") == SELESAI:
		return
	_tahapkan("nyai", AKTIF)
	_nyai_pos = pos
	_nyai_t = 8.0


func _process(delta: float) -> void:
	if _nyai_t <= 0.0:
		return
	var p := get_tree().get_first_node_in_group("player")
	if p == null:
		return
	if p.global_position.distance_to(_nyai_pos) <= 120.0:
		_nyai_t -= delta
		if _nyai_t <= 0.0 and tahap("nyai") == AKTIF:
			_tahapkan("nyai", SELESAI)
			# Pengamatan = bukti `orang` halaman Otha (SENYAP — D-3: notice-nya
			# narasi biasa lewat jalur Evidence, tanpa penanda apa pun).
			Evidence.find("ev_otha_nyai_tuminah_kamis")
	else:
		_nyai_t = 8.0   # menjauh = mulai lagi; menemani tak bisa disambi
