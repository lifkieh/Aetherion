extends Node2D
## ASHBROOK — versi LPC (#254). Desa-bekas-kota, wajah baru, LOGIKA SAMA.
##
## ⚠ `Ashbrook.tscn`/`Ashbrook.gd` (16px) **TIDAK DISENTUH** dan tetap scene yang
## dimainkan sampai versi ini terbukti utuh. Ini kandidat pengganti, bukan pengganti.
##
## ═══ SKALA — dan kenapa `TILE = 32`, bukan 64 ═══
## Standar LPC = **ubin dunia 32×32** + **frame karakter 64×64**. Angka 64 mengacu
## pada kanvas karakter, bukan petak dunia; tak ada tileset LPC 64px dan tak akan ada
## (diverifikasi: seluruh terrain LPC di gudang berkisi 32px, dan halaman LPC Tile Atlas
## menyatakannya eksplisit). Jadi migrasi ini = petak **16→32** dan karakter **32→64 frame**.
## `const TILE` di 5 berkas wilayah LAIN sengaja TIDAK disentuh — batas tugas: Ashbrook saja.
##
## ═══ YANG TIDAK BERUBAH (#151b — wajah berubah, logika tidak) ═══
## Titik-periksa memakai `Interactable.tscn` + `Evidence` yang SAMA PERSIS dengan scene 16px.
## Lima bukti, id identik. Kalau core loop pecah di sini, itu bug wajah — bukan bug logika.
##
## Sumber dunia: Mage City Arcanos (Hyptosis, **CC0**) → `_tools/gen_lpc32_slices.py`.
## Sumber karakter: ULPC → `_tools/lpc_assembler/assemble.py` (6 tokoh, #231 hook berbeda).

const TILE := 32                    # petak LPC (BUKAN 64 — lihat catatan skala di atas)
const MAP_W := 60
## KANVAS DITUMBUHKAN ASIMETRIS — inti TIDAK dipindahkan.
##
## Alun-alun (`VC`) sudah TEPAT di tengah mendatar sejak awal: x=960 = 1920/2.
## Yang meleset cuma sumbu tegak — ia 22 petak dari tepi utara tapi cuma 12 dari
## selatan. Membuatnya pusat bisa lewat dua jalan:
##
##   (a) GESER isi ke tengah kanvas baru — ditolak. Isi tersebar di ~40 titik
##       penempatan dengan tiga aturan berbeda (rumput tanpa offset, isi dengan
##       offset, kamar INTERIOR di ruang terpisah), dan beberapa sistem menulis
##       `global_position` sendiri sehingga transform induk tak menolong. Satu titik
##       terlewat = rantai payoff putus tanpa satu galat pun. Pergeseran 90 px sudah
##       pernah melakukannya.
##   (b) TUMBUHKAN kanvas ke arah yang kurang, sampai inti berakhir di tengah.
##       NOL node bergeser, NOL koordinat disentuh.
##
## Dipakai (b): tinggi 34 -> 44 petak, seluruh 10 petak baru tumbuh KE SELATAN.
## Hasilnya 22 petak di atas VC dan 22 di bawah — inti jadi pusat sejati tanpa
## pernah bergerak.
##
## KENAPA TIDAK 50 PETAK: itu menuntut 25 petak di atas VC, sementara yang ada 22.
## Sisanya harus tumbuh ke ATAS, yaitu ke koordinat Y NEGATIF — dan `z_index =
## int(global_position.y)` membuat y negatif menggambar node DI BAWAH lantainya
## sendiri. #275 sudah membayar cacat itu sekali (kamar berkoordinat negatif menelan
## pemainnya, nol galat muncul). Radius terbesar yang bisa dicapai tanpa menyentuh
## apa pun = 22 petak.
const MAP_H := 44
const VC := Vector2(960, 704)       # pusat alun-alun (koordinat dihitung ulang untuk petak 32)

## ── TATA LETAK B' (reports/BLOCKOUT_ASHBROOK.md) ─────────────────────────────
## Kaki bangunan dikumpulkan JADI SATU TEMPAT, dan itu bukan kerapian: pintu,
## jendela, titik-periksa, ayam, dan zona warga semuanya ditambatkan ke angka yang
## sama. Waktu koordinat masih tersebar di lima fungsi, memindahkan satu bangunan
## berarti mengejar enam pengikutnya dengan tangan — dan file ini sendiri sudah
## memperingatkan apa yang terjadi kalau satu terlewat: rantai payoff putus tanpa
## satu galat pun muncul.
##
## KOREKSI 3 — ketiganya di sisi UTARA alun-alun supaya pintu-selatan fasad repo
## otomatis menghadap ke dalam, dan ketiganya BERDIRI DI GARIS BERBEDA. Barisan
## rata mengabarkan "dibangun sekaligus"; tiga garis berbeda mengabarkan tiga
## dasawarsa berbeda. Balai paling maju, Merrit paling mundur.
const BALAI_KAKI := Vector2(966, 478)       # maju — bangunan terakhir yang mampu bayar tanah depan
const HALLORAN_KAKI := Vector2(1232, 452)   # mundur 26
const MERRIT_HOUSE := Vector2(790, 440)     # mundur 38
## KOREKSI 4 — gudang keluar dari inti, berdiri di TEPI distrik bekas barat-laut.
## ⚠ 578, bukan 600. `CekKoridor.gd` membuktikan celah gudang<->Merrit di x=600 cuma
##   30 px — PERSIS selebar badan pemain (30x48), jadi ia tak bisa dilewati sama sekali.
##   Celah selebar badan adalah cacat terburuk jenisnya: ia TERLIHAT seperti lorong dari
##   kamera main, pemain mencoba lewat, dan tertahan tanpa sebab yang kelihatan. Digeser
##   22 px ke barat -> celah jadi 52 px. Ditemukan alat, bukan mata.
const GUDANG_KAKI := Vector2(578, 450)
## KOREKSI 6 — toko Otha turun ke C2 timur, di sisi utara jalan dagang.
const OTHA_KAKI := Vector2(1252, 660)
## Kamar Merrit diletakkan DI LUAR peta, tapi di koordinat **POSITIF** — dan itu
## bukan selera.
##
## `Player.gd:54` melakukan `z_index = int(global_position.y)` untuk y-sort. Di
## koordinat negatif (preseden `Ashbrook.gd:20` memakai `(-360,-260)`) z pemain jadi
## **negatif**, dan ia tergambar DI BAWAH lantainya sendiri: kamar tampak lengkap,
## pemainnya hilang, dan tak satu pun galat muncul. Ruang positif membuat y-sort
## bekerja apa adanya untuk lantai, perabot, dan pemain sekaligus.
##
## Batas tanah tak menghalangi: ia empat dinding tipis di tepi peta, bukan kurungan
## penuh — dan pemain sampai ke sini lewat pintu, bukan berjalan.
const INTERIOR := Vector2(2100, 160)
const ZOOM := 1.0                   # 16px zoom 2 -> layar memuat 40x22 petak.
                                    # petak 32 pada zoom 1.4 -> ~28x16 petak: alun-alun
                                    # 17x11 MUAT, dan karakter 64px tetap terbaca.

const P_T := "res://assets/game/tiles/lpc32/"
const P_S := "res://assets/game/sprites/lpc32/"
const P_C := "res://assets/game/sprites/characters/"
const P_OLD := "res://assets/game/sprites/props/"
const P_A := "res://assets/game/sprites/animals/"

## z_index: y-sort dipakai untuk dunia, tapi PLAFON GODOT = 4096.
## y-maks di sini = MAP_H*TILE = 1408 (sesudah kanvas tumbuh ke selatan) → tetap jauh
## di bawah Z_LAMP 2000, jadi lampu tak tertimpa. Konstanta di bawah sengaja dipisah
## jauh di ATAS y-maks supaya tak pernah tertimpa objek ber-y besar (bug yang
## dipetakan sesi lalu: lamp z=1000 tenggelam saat y>1000).
const Z_LAMP := 2000
const Z_BEACON := 4000              # < 4096, dan > semua y-sort
var _lamp: Sprite2D
var _chickens: Array = []
var _kids: Array = []
var _stag: Sprite2D
var _stag_cd := 0.0
var _last_hour := -1
var _beacon: Sprite2D
var _canvas_mod: CanvasModulate
var _player: Node2D


func _ready() -> void:
	WorldState.mark_visited("ashbrook")
	SafeZone.set_region("ashbrook")
	_canvas_mod = CanvasModulate.new()
	# Siang dipatok HANYA untuk harness tangkap-layar (hasil sama tiap dijalankan).
	# Di permainan sungguhan langit ikut GameClock — kalau tidak, Ashbrook tak pernah
	# malam, dan lentera Merrit tak pernah jadi satu-satunya yang menyala. Payoff #218
	# butuh gelap; siang abadi diam-diam membatalkannya.
	_canvas_mod.color = Color(1, 1, 1)
	add_child(_canvas_mod)
	_ground()
	_build_boundaries()
	_village()
	_pinggir_jejak()
	_variasi_tanah()
	_dekorasi()
	_gerbang_selatan()
	_pemakaman_dan_kabut()
	_props_and_evidence()
	_pintu_dan_interior()
	_folk()
	_spawn_player()
	_add_ui()
	_kehidupan()


## Sampai LANGKAH 7, scene ini adalah DIORAMA: nol pemain, nol UI, nol pengendali —
## satu-satunya cara melihatnya adalah harness tangkap-layar. Titik-periksanya ada,
## tapi tak seorang pun bisa menekan E di depannya.
##
## Tiga hal yang membuatnya jadi tempat yang bisa dimainkan:
##   Player      — `Interactable` mencari grup "player" untuk jarak & label
##   WorldController — yang mengubah tombol E jadi `interact()`
##   MenuUI      — tab Kitab, tempat halaman ditulis ulang
## Tanpa ketiganya rantai §0 putus di sambungan pertama.
func _spawn_player() -> void:
	var p := preload("res://scenes/actors/Player.tscn").instantiate()
	add_child(p)
	_player = p
	# LAHIR DI GERBANG SELATAN (spec D4), bukan di tengah desa.
	#
	# Dulu pemain lahir di depan pintu Merrit — sudah DI DALAM desa, jadi ketimpangan
	# yang jadi seluruh tesis Ashbrook (kota untuk 1500, dihuni 40) baru terbaca kalau
	# ia kebetulan berjalan ke pinggir. Lahir di gerbang membalik urutannya: langkah
	# pertama menghadap ke UTARA, dan yang dilihat lebih dulu adalah pemakaman yang
	# terlalu besar, denah rumah yang tak berisi, lalu barulah alun-alun yang ramai.
	# Ketimpangan dibaca sebagai perjalanan, bukan sebagai penemuan kebetulan.
	#
	# y 1222: dua syarat sekaligus. (1) cukup jauh di utara tabrakan pilar (1298)
	# supaya pemain lahir di ruang berpijak lapang, tidak terjepit batu gerbangnya
	# sendiri. (2) LEBIH DARI 72 px (`Ashbrook64Prop.NEAR`) dari prop gerbang (1288) — pada jarak 158 px
	# label "Jalan keluar Ashbrook [E]" muncul di frame pertama, dan langkah nol
	# yang menawarkan PERGI membatalkan seluruh maksud lahir-di-gerbang. Pemain
	# harus melihat desanya dulu; pintu keluar menunggu, tak memanggil. Jarak kini 94 px.
	p.global_position = Vector2(VC.x, float(MAP_H * TILE) - 214.0)
	# Kamera Player dipatok 2.0 untuk dunia 16px. Di petak 32 itu memperbesar dua
	# kali lipat: layar cuma memuat ~14x8 petak dan alun-alun tak lagi muat.
	# ZOOM di berkas ini adalah angka yang sudah dinilai pada 5b — pakai itu.
	for c in p.get_children():
		if c is Camera2D:
			c.zoom = Vector2(ZOOM, ZOOM)


func _add_ui() -> void:
	add_child(preload("res://scenes/ui/HUD.tscn").instantiate())
	add_child(preload("res://scenes/ui/MenuUI.tscn").instantiate())
	add_child(preload("res://scenes/systems/WorldController.tscn").instantiate())


# ---------------------------------------------------------------- tabrakan
## Semua tabrakan dunia memakai LAPIS 4 — sama dengan `Ashbrook.gd:141-142`, dan
## `Player.tscn` menyaring tepat lapis itu (`collision_mask = 4`). Angka ini bukan
## selera: salah lapis = pemain menembus tembok tanpa satu pun galat muncul.
const SOLID_LAYER := 4

var _solids: StaticBody2D


func _solid_body() -> StaticBody2D:
	if _solids == null:
		_solids = StaticBody2D.new()
		_solids.collision_layer = SOLID_LAYER
		_solids.collision_mask = 0
		add_child(_solids)
	return _solids


## Satu kotak padat. `rect` dalam koordinat dunia.
func _solid(rect: Rect2) -> void:
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = rect.size
	cs.shape = sh
	cs.position = rect.position + rect.size * 0.5
	_solid_body().add_child(cs)


## Adakah kotak padat yang menyentuh kotak seukuran `ukuran` di titik `p`?
##
## Dipakai KELAHIRAN, bukan gerak. `_terhalang()` di aktor cuma menjaga langkah —
## makhluk yang sudah LAHIR di dalam bangku tak pernah melangkah keluar darinya,
## karena setiap arah terhalang. `CekJangkau` menandai cacat ini 1 dari 6 putaran,
## dan sisanya lolos karena undian, bukan karena benar.
##
## Aman dipanggil dari `_kehidupan()`: ia berjalan PALING AKHIR di `_ready()`, jadi
## seluruh `_solid()` dari `_village()` & kawan-kawan sudah terpasang.
func _padat_menyentuh(p: Vector2, ukuran: Vector2, geser := Vector2.ZERO) -> bool:
	if _solids == null:
		return false
	var kaki := Rect2(p + geser - ukuran * 0.5, ukuran)
	for cs in _solids.get_children():
		if not (cs is CollisionShape2D) or cs.shape == null:
			continue
		if not (cs.shape is RectangleShape2D):
			continue
		var sz: Vector2 = cs.shape.size
		if Rect2(cs.position - sz * 0.5, sz).intersects(kaki):
			return true
	return false


## Batas tanah — preseden `Ashbrook.gd:140-153`.
##
## Tanpa ini pemain berjalan keluar peta ke kekosongan: nol ubin, nol apa pun, dan
## tak ada yang memberitahunya ia sudah di luar dunia. Empat dinding 16 px MENGELILINGI
## petak 60x34 (1920x1088), diletakkan di LUAR tepi supaya tak memakan ruang main.
func _build_boundaries() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	for rc in [Rect2(-16, -16, w + 32, 16), Rect2(-16, h, w + 32, 16),
			Rect2(-16, 0, 16, h), Rect2(w, 0, 16, h)]:
		_solid(rc)


# ---------------------------------------------------------------- tanah
func _tile(path: String, rect: Rect2, z: int) -> void:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] ubin hilang: %s" % path)
		return
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, rect.size)
	s.centered = false
	s.position = rect.position
	s.z_index = z
	add_child(s)


## `_tile` + modulate. Dipakai treeline C4: kedalaman dibuat dengan MENGGELAPKAN
## lapisan yang lebih jauh, bukan dengan menambah ruang. Mata membaca gelap sebagai
## jarak jauh sebelum ia membaca ukuran.
func _tile_mod(path: String, rect: Rect2, z: int, warna: Color) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] ubin hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	s.region_rect = Rect2(Vector2.ZERO, rect.size)
	s.centered = false
	s.position = rect.position
	s.z_index = z
	s.modulate = warna
	add_child(s)
	return s


func _ground() -> void:
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	_tile(P_T + "grass32.png", Rect2(0, 0, w, h), 0)
	# jalan dagang lama — membentang barat→timur, terlalu lebar untuk empat puluh orang
	_tile(P_T + "stone32.png", Rect2(0, VC.y - 48, w, 96), 1)
	# alun-alun berperkerasan
	_tile(P_T + "cobble32.png", Rect2(VC.x - 272, VC.y - 176, 544, 352), 2)
	# PELATARAN MELINGKAR di sekeliling air mancur (gen_pelataran.py, #240).
	# Pusat desa diberi TEPI, bukan sekadar objek yang lebih besar: sebelum ini air
	# mancur duduk di tengah persegi batu rata, dan mata tak punya alasan berhenti
	# di sana. Satu lentera di pinggir kota lebih memerintah daripada pusatnya.
	_setapak_cakram(VC + Vector2(0, -32), 3)

	# SETAPAK BERCABANG — jalan dagang timur-barat tadinya satu-satunya jalur di peta,
	# dan tiap rumah duduk di rumput di sebelahnya tanpa tersambung apa pun. Kaki orang
	# meninggalkan jejak; rumah yang dihuni bertahun-tahun punya jalan ke pintunya.
	# Cabang ini juga memecah grid: jalan utama berhenti jadi satu garis lurus tunggal.
	var jalan_atas := VC.y - 48
	var jalan_bawah := VC.y + 48
	# Tiga bangunan bernama menempel tepi UTARA alun-alun: setapaknya pendek, dan
	# pendeknya itu yang bercerita — pintu yang jaraknya dua langkah dari ruang publik
	# adalah pintu yang dulu sering dibuka.
	_setapak(Vector2(BALAI_KAKI.x, BALAI_KAKI.y + 10), Vector2(BALAI_KAKI.x, VC.y - 176))
	_setapak(Vector2(MERRIT_HOUSE.x, MERRIT_HOUSE.y + 10), Vector2(MERRIT_HOUSE.x, VC.y - 176))
	_setapak(Vector2(HALLORAN_KAKI.x, HALLORAN_KAKI.y + 10), Vector2(HALLORAN_KAKI.x, VC.y - 176))
	# Gudang gandum tak lagi menempel alun-alun: ia di C3, dan jalannya turun ke jalan
	# dagang. Jarak itu bagian dari koreksi 4 — gudang harus terasa DI LUAR.
	_setapak(Vector2(GUDANG_KAKI.x, GUDANG_KAKI.y + 10), Vector2(GUDANG_KAKI.x, jalan_atas))
	_setapak(Vector2(OTHA_KAKI.x, OTHA_KAKI.y + 6), Vector2(OTHA_KAKI.x, jalan_atas))
	_setapak(Vector2(1408, jalan_bawah), Vector2(1408, 812))       # rumah kosong -> jalan
	# rumah Lyra jauh dari jalan: DUA ruas dengan siku, bukan satu garis lurus. Jalan
	# setapak sungguhan menghindar, bukan menembus.
	_setapak(Vector2(640, jalan_bawah), Vector2(640, 900))
	_setapak(Vector2(640, 900), Vector2(700, 900))
	_setapak(Vector2(700, 900), Vector2(700, 1004))

	# SETAPAK YANG MEMUDAR — dulu menuju sesuatu, kini menuju ketiadaan. Ia menyempit
	# ruas demi ruas lalu berhenti di rumput, tanpa pernah sampai ke apa pun. Inilah
	# satu-satunya bentuk "jalan" yang bisa mengabarkan D2 spasial: jalan yang MASIH
	# ADA membuktikan ada tujuan, dan tujuan itulah yang hilang. Jalan yang dihapus
	# bersih tak membuktikan apa-apa (itu D3 — seolah tak pernah ada).
	_setapak(Vector2(1408, 860), Vector2(1408, 908), 26.0)
	_setapak(Vector2(1408, 908), Vector2(1452, 908), 20.0)
	_setapak(Vector2(1452, 908), Vector2(1470, 924), 13.0)
	_setapak(Vector2(1470, 924), Vector2(1484, 930), 7.0)


## Prop pinggir dari pustaka 16px lama: kecil untuk dunia berpetak 32 & tokoh 64,
## jadi diperbesar seperti ayam (#BAGIAN1, skala 1.6). 2.0 dipilih supaya jejak masih
## terbaca di zoom 0.55 tanpa menyaingi bangunan.
const SKALA_JEJAK := 2.0

func _jejak(nama: String, pos: Vector2, skala := SKALA_JEJAK) -> Sprite2D:
	# ubin pinggir (gen_pinggir.py) hidup di P_T, prop 16px lama di P_OLD
	var akar := P_T if nama.ends_with("32.png") else P_OLD
	var s := _put(akar + nama, pos)
	if s:
		s.scale = Vector2(skala, skala)
	return s


## PINGGIR SEBAGAI JEJAK-KEHILANGAN, bukan pinggir yang diisi penuh.
##
## Penilaian visual: bagian selatan & tenggara peta hamparan rumput kosong, dan
## kekosongan itu AMBIGU — tak bisa dibedakan antara "Ashbrook mengecil" (D2 spasial:
## sesuatu pernah di sini lalu pergi) dan "belum digarap". Dua hal itu terlihat sama.
##
## Obatnya BUKAN mengisi. Desa yang mengecil memang sepi; mengisinya sampai ramai
## justru menghapus tesisnya. Yang kurang bukan kepadatan, melainkan BUKTI bahwa
## kepadatan itu pernah ada. Maka: sedikit objek, masing-masing menyisakan bentuk
## dari sesuatu yang sudah tak ada.
##
## Semua aset dipakai dari yang TERBUKTI terbaca (audit: ruins/fence/tree_dead/stump/
## log_fallen/dead_bush/rock/hay). Nol aset baru, nol `tree_lpc.png` yang rusak.
## GERBANG SELATAN — jalan keluar. Megah, berkarat, TAK BERPENJAGA.
##
## Ketiganya harus terbaca sekaligus, dan tak satu pun boleh ditulis sebagai teks:
##   megah        — dua pilar batu 3x, lebih tinggi dari apa pun di dekatnya
##   berkarat     — dimodulasi ke cokelat-oksida, bukan abu batu bersih
##   tak berpenjaga — NOL prop penjaga, nol pos, nol pintu. Cuma bukaan.
##
## Ia menghadap ke selatan, ke tanah yang baru lahir: satu-satunya arah keluar yang
## dipunyai desa, dan tak seorang pun berdiri di sana lagi. Setapak yang menuju ke
## sana sengaja MEMUDAR sebelum sampai — jalan ke luar masih ada, kebiasaan
## memakainya yang hilang.
func _gerbang_selatan() -> void:
	var gy := float(MAP_H * TILE) - 96.0          # sedikit di dalam batas selatan
	for dx in [-52.0, 52.0]:
		var pilar := _put(P_OLD + "stone_gate.png", Vector2(VC.x + dx, gy))
		if pilar:
			pilar.scale = Vector2(3.0, 3.0)
			pilar.modulate = Color(0.82, 0.70, 0.55)   # oksida, bukan batu bersih
			_solid(Rect2(VC.x + dx - 22, gy - 14, 44, 28))
	# jalan menuju gerbang: melebar dari desa lalu BERHENTI 2 petak sebelum bukaan.
	# Jalan yang menyentuh gerbang berkata "masih dilewati"; jalan yang berhenti
	# sebelum sampai berkata "dulu dilewati".
	# ⚠ PANGKALNYA DINAIKKAN ke tepi selatan alun-alun (VC.y + 176), bukan lagi
	#   VC.y + 320. Dulu ada JURANG RUMPUT 144 px antara ujung jalan dan pelataran:
	#   jalan gerbang berpangkal di ketiadaan, jadi ia tak pernah terbaca sebagai
	#   "jalan menuju alun-alun" — cuma sepotong batu di rumput selatan. Yang
	#   diceritakan ujung selatannya (berhenti sebelum bukaan) baru bekerja kalau
	#   ujung utaranya BERPANGKAL pada sesuatu.
	_setapak(Vector2(VC.x, VC.y + 176), Vector2(VC.x, gy - 160), 44.0)


## C4 TEPI HANTU — pemakaman yang BISA dicapai, kabut yang TIDAK.
##
## Dua aturan proyek bertabrakan di cincin ini, dan penyelesaiannya adalah GARIS,
## bukan kompromi:
##   §2 anti-kosong  — tiap tujuan jauh harus berujung pada sesuatu, atau pemain
##                     belajar bahwa menjauh tak berbuah lalu berhenti menjelajah.
##   tepi-hantu      — kekuatannya pada KETIDAKLENGKAPAN; yang tak tercapai membuat
##                     dunia terasa lebih besar dari petanya (teknik Tunic/HLD).
##
## Garisnya: PEMAKAMAN adalah tujuan — bisa dimasuki, bisa dijalani, berbuah.
## KABUT bukan tujuan — ia tembok, dan harus terbaca sebagai tembok sejak jauh.
## Kalau pemain bisa MASUK kabut mengharap sesuatu lalu tak menemukan apa-apa, itu
## janji yang diingkari, dan itu lebih buruk daripada tepi yang jujur tertutup.
##
## Karena itu kabut diberi TABRAKAN PENUH selebar peta. Ia dilihat, tak pernah
## dimasuki. Yang membuatnya bekerja: garis fondasi samar TERLIHAT DI DALAMNYA —
## bentuk rumah yang jelas ada dan jelas tak bisa dicapai. Kota lama membentang
## lebih jauh daripada yang boleh dijelajahi, dan pemain tahu itu tanpa diberi tahu.
func _pemakaman_dan_kabut() -> void:
	var h := float(MAP_H * TILE)

	# ── PEMAKAMAN ────────────────────────────────────────────────────────────
	# Ditaruh di tepi TERLUAR ruang selatan: makin jauh dari inti = makin mundur
	# waktunya. Barat dari gerbang, supaya koridor gerbang tetap lapang.
	var pm := Vector2(624, 1216)
	var lebar := 460.0
	var tinggi := 190.0

	# RUANG DULU: batasnya dulu, batunya menyusul. Pemakaman dikenali dari TEPI —
	# sama seperti alun-alun dikenali dari pelataran, bukan dari air mancurnya.
	# Tiang pagar saja, tanpa ruas: pagar utuh berkata "dirawat".
	for i in 9:
		var fx: float = pm.x - lebar * 0.5 + i * (lebar / 8.0)
		_jejak("pagar_tiang32.png", Vector2(fx, pm.y - tinggi * 0.5), 1.0)
		if i % 3 != 1:                          # sisi selatan BOLONG — sudah tak dijaga
			_jejak("pagar_tiang32.png", Vector2(fx, pm.y + tinggi * 0.5), 1.0)

	# NISAN. Jumlahnya yang bicara: desa berpenduduk empat puluh tak pernah butuh
	# sebanyak ini. Barisnya sengaja TAK RAPI dan jaraknya berubah-ubah — pemakaman
	# yang digali bertahun-tahun tumbuh berantakan; yang digali sekaligus berbaris
	# lurus, dan baris lurus akan menceritakan bencana, bukan kemunduran perlahan.
	#
	# Perbandingan D2:D3 kira-kira 1:2 — yang masih terbaca LEBIH SEDIKIT daripada
	# yang sudah aus. Itu arah waktunya (#269/#270): nama habis lebih dulu daripada
	# batunya, dan batu aus tak bisa dipulihkan, cuma dilahirkan sekali.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260721                          # tetap tiap muat, bukan acak ulang
	for baris in 6:
		var by: float = pm.y - tinggi * 0.5 + 26.0 + baris * 30.0
		var n := 13 + (baris % 3)
		for kol in n:
			if rng.randf() < 0.12:               # petak kosong — belum semua terisi
				continue
			var px: float = pm.x - lebar * 0.5 + 22.0 + kol * ((lebar - 44.0) / float(n - 1))
			var p := Vector2(px + rng.randf_range(-5.0, 5.0), by + rng.randf_range(-6.0, 6.0))
			_jejak("nisan_terbaca.png" if rng.randf() < 0.34 else "nisan_aus.png", p, 1.0)

	# ⚠ TEMPAT SORA (#013 penjaga kubur) DISIAPKAN, BELUM DI-WIRE.
	#    Sudut timur-laut pemakaman sengaja dikosongkan dari nisan — di sanalah ia
	#    akan berdiri. Menempatkannya sekarang butuh sesi tokoh (dialog, jadwal,
	#    siluet #231), dan tokoh yang lahir setengah lebih buruk daripada tempat
	#    yang menunggu. Koordinat: pm + Vector2(lebar * 0.5 - 40, -tinggi * 0.5 + 18)

	# ── TREELINE: TEMBOK YANG INDAH ──────────────────────────────────────────
	# Menggantikan pita kabut. Kabut lama terbaca RATA dan TERANG — dua sifat yang
	# membunuh kedalaman, dan tak satu pun bisa disembuhkan dengan menebalkannya.
	# Massa pohon gelap punya tiga hal yang tak dimiliki pita: siluet, tumpang-tindih,
	# dan gelap. Kedalaman datang dari SUSUNAN, bukan dari ruang — jadi ia muat di
	# ~98 px sisa tanpa menggeser pemakaian sepetak pun.
	#
	# EMPAT LAPIS, dari jauh ke dekat. Urutannya yang bekerja, bukan jumlahnya:
	var w := float(MAP_W * TILE)
	var dasar := h - 8.0

	# (1) FONDASI PALING DULU, paling jauh, dan DIGELAPKAN. Ia digambar sebelum
	#     apa pun menutupinya, lalu tertutup sebagian — itulah yang membuat mata
	#     membacanya "di dalam hutan" alih-alih "di depan hutan". Trik Tunic/HLD:
	#     kota lama terlihat membentang lebih jauh daripada yang boleh dijelajahi.
	for fx in [416.0, 880.0, 1248.0, 1600.0]:
		var f := _tile_mod(P_T + "fondasi32.png", Rect2(fx, dasar - 116.0, 104.0, 52.0),
				700, Color(0.46, 0.50, 0.47))
		if f:
			pass

	# (2) KANOPI JAUH — dihamparkan penuh selebar peta, digelapkan paling dalam.
	_tile_mod(P_T + "pinus_isi.png", Rect2(0, dasar - 72.0, w, 72.0), 720,
			Color(0.44, 0.50, 0.45))
	# (3) KANOPI TENGAH — digeser turun 20 px. Pergeseran itulah tumpang-tindihnya;
	#     tepi bergerigi lapis atas terbaca sebagai puncak pohon di belakangnya.
	_tile_mod(P_T + "pinus_atas.png", Rect2(0, dasar - 52.0, w, 32.0), 740,
			Color(0.52, 0.58, 0.53))
	_tile_mod(P_T + "pinus_isi.png", Rect2(0, dasar - 24.0, w, 32.0), 741,
			Color(0.52, 0.58, 0.53))

	# (4) BARIS DEPAN — pohon utuh, warna penuh, berjarak TAK RATA. Baris pohon yang
	#     rapi terbaca sebagai pagar tanaman; yang tak rata terbaca sebagai hutan.
	#     Dicampur pinus hidup & pohon GUNDUL: kota mati dikelilingi hutan mati.
	#     Hutan berdaun saja akan mengabarkan "alam sehat mengambil alih" — cerita
	#     yang berbeda, dan bukan cerita Ashbrook.
	var rngp := RandomNumberGenerator.new()
	rngp.seed = 20260721
	var px := 24.0
	while px < w:
		var gundul := rngp.randf() < 0.42
		var s := _put(P_OLD + ("pohon_gundul.png" if gundul else "pinus_pohon.png"),
				Vector2(px, dasar - (34.0 if gundul else 14.0)), 760)
		if s:
			s.scale = Vector2(1.0, 1.0)
			if not gundul:
				s.modulate = Color(0.78, 0.84, 0.80)   # masih di belakang, belum penuh
		px += rngp.randf_range(58.0, 104.0)

	# TABRAKAN PENUH selebar peta — pemain berhenti DI DEPAN treeline, tak pernah di
	# dalamnya. Inilah yang membedakan "tepi yang jujur tertutup" dari "janji yang
	# diingkari": kalau ia bisa dimasuki dan tak ada apa-apa, tepi ini merusak
	# kepercayaan yang dibangun §2 anti-kosong.
	_solid(Rect2(0, dasar - 76.0, w, 40.0))

	# ── WISP: GRADIEN HANTU -> NYATA ─────────────────────────────────────────
	# Tiga di pemakaman, satu di C3, NOL di inti. Gradiennya adalah tesisnya:
	# di tepi, yang hidup cuma cahaya yang tak bisa diraih; makin ke dalam, kehidupan
	# menjadi daging — ayam yang berbunyi, warga yang bisa diajak bicara. Kota untuk
	# 1500 menyusut jadi 40, dan perjalanan dari gerbang ke alun-alun MENEMPUH
	# penyusutan itu, bukan sekadar menceritakannya.
	#
	# Alfa ikut menurun ke dalam (0,50 -> 0,44 -> 0,38 -> 0,26): yang terjauh dari
	# inti paling tebal, yang mendekat paling pudar. Fase diacak beda supaya ketiganya
	# tak bernapas seirama — roh yang berdenyut serempak terbaca sebagai lampu hias.
	for wp in [
		{"pos": Vector2(pm.x - 118.0, pm.y - 34.0), "a": 0.50, "f": 0.0},
		{"pos": Vector2(pm.x + 46.0, pm.y + 26.0), "a": 0.44, "f": 1.9},
		{"pos": Vector2(pm.x + 152.0, pm.y - 58.0), "a": 0.38, "f": 3.4},
		# C3 — separuh jalan antara inti dan pemakaman.
		# ⚠ KOORDINATNYA TAK DISENTUH (perintah Direktur: wisp tak dibongkar), tapi
		#   ALASANNYA sudah bergeser: ia dulu melayang di atas ladang yang berhenti
		#   digarap, dan ladang itu pindah ke timur waktu jalan gerbang disambungkan.
		#   Sekarang ia melayang di rumput kosong. Masih sah sebagai gradien C3, tapi
		#   jangkarnya hilang — putusan memindahkannya milik Direktur, bukan efek
		#   samping perbaikan jalan.
		{"pos": Vector2(872.0, 1006.0), "a": 0.26, "f": 2.6},
	]:
		var wsp := Node2D.new()
		wsp.set_script(load("res://scenes/actors/Wisp.gd"))
		add_child(wsp)
		wsp.place(wp["pos"], wp["a"], wp["f"])


func _pinggir_jejak() -> void:
	# 1. DUA FONDASI RUMAH YANG SUDAH TAK ADA. Yang digambar bukan reruntuhan
	#    bertumpuk, melainkan DENAHNYA: batu sudut + sisa garis dinding. Mata membaca
	#    persegi di rumput sebagai "ada bangunan di sini", lalu menyadari isinya hilang.
	#
	#    C3 DIUKUR SEBAGAI BUSUR, BUKAN CINCIN. Sisiran arah atas delapan jejak lama:
	#    selatan 8, utara 0, timur 0, barat 0. Dari dalam desa, "yang mati" tampak
	#    cuma di satu sisi — dan kota yang mengecil tidak mengecil ke satu arah.
	#    Lima denah baru menutup keliling: utara, timur-laut, timur, barat, barat-laut.
	#    Ukurannya sengaja BERAGAM — rumah yang sama besar berarti dibangun sekaligus
	#    oleh satu tangan; kota yang tumbuh bertahun-tahun tak pernah serapi itu.
	# ⚠ SISIRAN LAMA DIBALIK (koreksi 4). Tujuh denah dulu ditaburkan MENGELILINGI desa
	#   supaya "yang mati" tak cuma tampak di satu sisi — niatnya benar, hasilnya bukan.
	#   Sebaran merata cuma bisa mengabarkan "beberapa rumah roboh". Yang harus
	#   dikabarkan jauh lebih tajam: INTI YANG SEKARANG BUKAN INTI YANG DULU. Kota tak
	#   menyusut ke tengah — ia menyusut MENJAUH dari tempat ia lahir.
	#
	#   Karena itu sepuluh fondasi dirapatkan jadi SATU DISTRIK di barat-laut, dengan
	#   lorong sempit yang masih terbaca di antaranya (digambar di bawah). Yang membuat
	#   mata membaca "distrik" bukan jumlah puingnya melainkan JALAN di antaranya —
	#   puing tanpa jalan tetap puing, berapa pun banyaknya.
	for denah in [
		# baris utara
		{"pos": Vector2(176, 210), "w": 108.0, "h": 70.0},
		{"pos": Vector2(300, 204), "w": 92.0,  "h": 64.0},
		{"pos": Vector2(424, 212), "w": 118.0, "h": 74.0},
		{"pos": Vector2(548, 206), "w": 86.0,  "h": 62.0},
		# baris tengah
		{"pos": Vector2(168, 318), "w": 90.0,  "h": 66.0},
		{"pos": Vector2(286, 322), "w": 116.0, "h": 78.0},
		{"pos": Vector2(420, 316), "w": 98.0,  "h": 68.0},
		# baris selatan
		{"pos": Vector2(186, 424), "w": 118.0, "h": 72.0},
		{"pos": Vector2(322, 428), "w": 94.0,  "h": 64.0},
		{"pos": Vector2(452, 420), "w": 104.0, "h": 68.0},
		# TIGA PENYINTAS yang meluruh ke luar distrik. Batas distrik yang tajam terbaca
		# sebagai DINDING — sesuatu yang sengaja memagari. Yang meluruh terbaca sebagai
		# kota yang habis pelan-pelan, dan itu yang benar.
		{"pos": Vector2(742, 556), "w": 76.0,  "h": 58.0},
		{"pos": Vector2(238, 528), "w": 84.0,  "h": 60.0},
		{"pos": Vector2(596, 132), "w": 68.0,  "h": 52.0},
	]:
		var c: Vector2 = denah["pos"]
		var w: float = denah["w"]
		var h: float = denah["h"]
		# RUANG DULU, OBJEK MENYUSUL. Petak fondasi memberi BENTUK rumah yang hilang;
		# batu sudut cuma menjelaskan bentuk itu. Percobaan pertama membalik urutannya —
		# cuma batu di empat sudut — dan dari zoom 0.55 terbaca "puing tersebar", bukan
		# "rumah pernah berdiri di sini". Percobaan kedua memakai `stone32` (batu jalan)
		# sebagai lantai: bentuknya terbaca, tapi warnanya sama dengan jalan, jadi ia
		# terbaca "pelataran kecil" — masih hidup, bukan ditinggalkan. `fondasi32`
		# digelapkan & berlubang: batu yang tak lagi diinjak, dimakan kembali tanah.
		_tile(P_T + "fondasi32.png", Rect2(c.x - w * 0.5, c.y - h * 0.5, w, h), 1)
		# ⚠ BATUNYA DIKURUSKAN waktu tujuh denah tersebar jadi tiga belas denah RAPAT.
		#   Resep lama (4 batu sudut skala 1,6 + 3 sisa dinding skala 1,8) benar untuk
		#   denah yang berdiri sendirian di rumput. Dipakai di distrik padat ia jadi
		#   91 batu dalam satu layar, dan tangkap-layar membuktikannya: yang terbaca
		#   bukan "fondasi berbaris" melainkan hamparan batu putih — mirip pemakaman,
		#   yaitu tempat lain di peta yang sama. Kepadatan mengubah arti resep yang
		#   sama, dan itu tak bisa dilihat dari daftar koordinat.
		#   Sekarang: sudut 1,25 + SATU sisa dinding. Bentuk petaknya yang bercerita;
		#   batu cuma menjelaskan bentuk itu, dan penjelasan yang terlalu banyak
		#   menenggelamkan yang dijelaskan.
		for sudut in [Vector2(-w, -h), Vector2(w, -h), Vector2(-w, h), Vector2(w, h)]:
			_jejak("ruins.png", c + sudut * 0.5, 1.25)
		# sisa garis dinding — sengaja TERPUTUS. Dinding utuh berarti rumah kosong;
		# dinding terputus berarti rumah yang batunya sudah diambili orang.
		_jejak("rock.png", c + Vector2(w * 0.22, h * 0.5), 1.5)

	# LORONG DISTRIK — digambar SESUDAH fondasi supaya ia terbaca di ATAS batu, seperti
	# jalan yang masih dilewati di antara rumah yang sudah tidak. Digelapkan jauh di
	# bawah jalan dagang: ini jalan yang tak lagi diinjak, dan warnanya harus berkata
	# begitu sebelum bentuknya sempat berkata apa pun.
	#
	# ⚠ LURUS, dan itu SEMENTARA. B' meminta lorong bengkok berlebar tak rata; `_setapak`
	#   dan `_tile` cuma bisa `Rect2` bersumbu. Membengkokkannya menuntut alat gambar
	#   jalan baru — itu TAHAP 2, bukan penyesuaian angka di sini.
	for lorong in [Rect2(126, 258, 434, 20), Rect2(140, 362, 460, 20),
			Rect2(292, 190, 20, 260)]:
		_tile_mod(P_T + "stone32.png", lorong, 3, Color(0.60, 0.62, 0.58))

	# 2. LADANG YANG BERHENTI DIGARAP — sekali lagi RUANG DULU.
	#    Petak tanah bajakan memberi bentuk "ini pernah ladang"; rumput liar yang
	#    ditumpuk DI ATASNYA memberi waktunya — tanah yang mulai ditutupi kembali.
	#    Satu petak tanah polos cuma "kebun". Tanah bajak + rumput yang menyerbu =
	#    "kebun yang ditinggalkan", dan itu yang perlu terbaca.
	#    Ubin dari LPC Farming (daneeklu, CC-BY-SA, sah sejak #277 — kredit di
	#    ASSET_LOG.md + <ubin>.credits.txt).
	# digeser ke timur dari (700,1000): di sana petaknya tertimpa rumah Lyra, dan
	# ladang yang setengah masuk ke dalam rumah membaca sebagai cacat, bukan jejak.
	# ⚠ DIPINDAH KE TIMUR (900 -> 1170) dan disempitkan (320 -> 300).
	#   Sebabnya ditemukan tangkap-layar, bukan dibayangkan: begitu jalan gerbang
	#   disambungkan sampai tepi selatan alun-alun, pita batunya MEMBELAH ladang ini
	#   dari utara ke selatan. Ladang yang dilintasi jalan raya berhenti mengabarkan
	#   "berhenti digarap" — ia mengabarkan "petak yang lupa dihapus".
	#   ⚠ PERCOBAAN PERTAMA memindahkannya ke TIMUR (1170,1000) — dan tangkap-layar
	#     menolaknya juga: di sana fasad rumah (1120,1152) tergambar DI ATAS petaknya.
	#     Sisi timur peta sudah penuh; yang tampak lapang di peta kotak ternyata
	#     tertutup massa fasad yang tingginya 192 px, dan massa itu tak muncul di
	#     blockout karena blockout menggambar KAKI, bukan bayangan bangunan.
	#   Tempatnya sekarang: celah barat-daya antara rumah Lyra dan pemakaman. Ia di
	#   TEPI (spec), menempel satu-satunya rumah yang masih dihuni, dan tak dilintasi
	#   apa pun. Petaknya disempitkan (320x160 -> 280x120) supaya muat tanpa menyenggol
	#   kaki Lyra di utara maupun pagar pemakaman di selatan.
	var ladang := Vector2(470, 1050)
	var lw := 280.0
	var lh := 120.0
	_tile(P_T + "ladang_tanah32.png", Rect2(ladang.x - lw * 0.5, ladang.y - lh * 0.5, lw, lh), 1)
	# Rumput liar sengaja TAK BERPOLA. Percobaan pertama menghamparkannya sebagai pita
	# selebar ladang — hasilnya jadi GARIS-GARIS RAPI, dan mata membacanya sebagai
	# BARISAN TANAMAN. Ladang yang tampak ditanami rapi mengabarkan "masih digarap",
	# yaitu kebalikan persis dari yang harus diceritakan. Rumput yang merebut tanah
	# tak pernah tumbuh dalam baris.
	#
	# Petak tak-beraturan, menebal di tepi (di sanalah rumput masuk lebih dulu) dan
	# menyisakan tengah yang masih telanjang — bekas garapan terakhir yang belum kalah.
	for petak in [
		Rect2(ladang.x - lw * 0.5, ladang.y - lh * 0.5, 96, 64),
		Rect2(ladang.x - lw * 0.5 + 64, ladang.y - lh * 0.5, 64, 32),
		Rect2(ladang.x + lw * 0.5 - 128, ladang.y - lh * 0.5, 128, 96),
		Rect2(ladang.x + lw * 0.5 - 64, ladang.y - 32, 64, 96),
		Rect2(ladang.x - lw * 0.5, ladang.y + lh * 0.5 - 64, 64, 64),
		Rect2(ladang.x - lw * 0.5 + 96, ladang.y + lh * 0.5 - 32, 96, 32),
		Rect2(ladang.x - 32, ladang.y - 16, 64, 32),
	]:
		_tile(P_T + "ladang_semak32.png", petak, 2)

	#    PAGARNYA BERLUBANG, bukan utuh. Pagar utuh mengabarkan "milik seseorang";
	#    pagar berlubang mengabarkan "DULU milik seseorang". Lubangnya yang bercerita.
	#    Di dua tempat ruasnya hilang tapi TIANGNYA masih berdiri — itu bedanya lapuk
	#    (roboh sendiri, tiang bertahan) dengan dibongkar (semua diangkut).
	for i in 10:
		var fx: float = ladang.x - lw * 0.5 + 16 + i * 32
		if i in [3, 7]:
			_jejak("pagar_tiang32.png", Vector2(fx, ladang.y - lh * 0.5 - 10), 1.0)
			continue
		_jejak("pagar_h32.png", Vector2(fx, ladang.y - lh * 0.5 - 10), 1.0)
	for i in 5:
		if i == 2:
			continue
		_jejak("pagar_tiang32.png",
				Vector2(ladang.x - lw * 0.5 - 8, ladang.y - lh * 0.5 + 16 + i * 32), 1.0)
	_jejak("hay.png", ladang + Vector2(lw * 0.5 - 30, -lh * 0.5 + 24), 1.8)

	# 3. POHON MATI di tepi ladang — kebun yang tak lagi disiram. Aset pohon SUNGGUHAN
	#    (tree_dead_*), bukan `tree_lpc.png` yang ternyata potongan salah-krop.
	#    Disebar mengelilingi, sama alasannya dengan denah: pohon mati di satu sisi
	#    saja membaca "kebun rusak"; mengelilingi, ia membaca "musim yang sama
	#    menimpa semua".
	for p in [Vector2(1640, 880), Vector2(1720, 964), Vector2(232, 848),
			Vector2(1088, 200), Vector2(1568, 424), Vector2(216, 632), Vector2(560, 216)]:
		_jejak("tree_dead_a.png" if int(p.x) % 2 == 0 else "tree_dead_b.png", p, 2.0)
	_jejak("stump.png", Vector2(1560, 1030), 1.8)
	_jejak("log_fallen.png", Vector2(1668, 1044), 1.8)
	_jejak("stump.png", Vector2(1616, 336), 1.8)          # timur laut
	_jejak("log_fallen.png", Vector2(344, 640), 1.8)      # barat

	# 4. ANTI-KOSONG (spec §2): tiap tujuan jauh harus BERUJUNG pada sesuatu.
	#    Sudut peta yang cuma rumput mengajari pemain bahwa menjauh tak berbuah, dan
	#    sesudah itu ia berhenti menjelajah — kekosongan berhenti bermakna dan mulai
	#    terasa belum-jadi. Empat sudut diberi satu benda kecil saja: cukup untuk
	#    membalas perjalanan, terlalu sedikit untuk mengisi.
	for p in [Vector2(176, 176), Vector2(1760, 200), Vector2(176, 1296), Vector2(1776, 1288)]:
		_jejak("rock.png", p, 2.2)
		_jejak("dead_bush.png", p + Vector2(38, 22), 1.6)


# ---------------------------------------------------- TAHAP 1.6 — VARIASI TANAH
## Rumput seragam terbaca sebagai KANVAS, bukan tanah. Yang memecahnya bukan
## menambah warna melainkan menambah SEBAB: tanah gundul lahir di tempat kaki lewat,
## bunga lahir di tempat kaki tak lewat, dan rumput tinggi lahir di tempat tak ada
## yang peduli. Bercak yang ditabur tanpa sebab cuma jadi derau berwarna.
##
## Semuanya dari RNG BERBIJI TETAP: tangkap-layar harus bisa diulang (#240), dan
## "Direktur menunjuk semak yang itu" mustahil kalau semaknya pindah tiap muat.
const BIJI_TANAH := 20260722

## Petak yang TIDAK boleh ditaburi: jalan, pelataran, kaki bangunan, pemakaman,
## ladang. Bukan soal rapi — rumput tinggi di tengah jalan membatalkan jalan itu.
func _zona_larangan() -> Array:
	var larang: Array = [
		Rect2(VC.x - 272, VC.y - 176, 544, 352),          # alun-alun
		Rect2(0, VC.y - 56, MAP_W * TILE, 112),           # jalan dagang
		Rect2(VC.x - 30, VC.y + 168, 60, 300),            # jalan gerbang
		Rect2(394, 1113, 460, 206),                       # pemakaman
		Rect2(322, 982, 300, 140),                        # ladang
		Rect2(0, float(MAP_H * TILE) - 96.0, MAP_W * TILE, 96.0),   # treeline
	]
	if _solids != null:
		for cs in _solids.get_children():
			if cs is CollisionShape2D and cs.shape is RectangleShape2D:
				var sz: Vector2 = cs.shape.size
				larang.append(Rect2(cs.position - sz * 0.5 - Vector2(18, 30), sz + Vector2(36, 44)))
	return larang


func _boleh_tabur(p: Vector2, larang: Array) -> bool:
	for r in larang:
		if r.has_point(p):
			return false
	return true


func _variasi_tanah() -> void:
	var larang := _zona_larangan()

	# ── 1. TANAH GUNDUL DI TEMPAT KAKI LEWAT ─────────────────────────────────
	# Bukan jalan — jalan sudah ada. Ini AMBANG: petak yang botak karena diinjak
	# tiap hari dari pintu ke jalan. Rumput yang tumbuh sampai menyentuh pintu
	# mengabarkan "tak ada yang keluar dari sini", dan itu cerita untuk rumah gelap,
	# bukan untuk rumah yang dihuni.
	#
	# ⚠ DAFTARNYA DIPANGKAS setelah tangkap-layar. Percobaan pertama menaruh ambang di
	#   depan TIAP pintu — dan sebagian besar mendarat DI ATAS BATU, bukan di rumput:
	#   rumah C2 barat membuka langsung ke jalan dagang (celahnya cuma 6 px), dan tiap
	#   bangunan bernama sudah punya setapak sendiri ke alun-alun. Tanah gundul yang
	#   digambar di atas jalan bukan jejak kaki — itu jalan yang kotor.
	#   Yang tersisa cuma tempat yang benar-benar RUMPUT: pintu yang jauh dari jalan,
	#   dan sela antar-rumah tempat orang memotong jalan.
	for amb in [
		Rect2(600, 994, 96, 42),      # pintu rumah Lyra — 200 px dari jalan terdekat
		Rect2(688, 1100, 96, 42),     # rumah selatan
		Rect2(1072, 1068, 96, 42),    # rumah tenggara
		Rect2(1328, 972, 96, 42),     # rumah timur-tenggara
		Rect2(368, 596, 44, 62),      # SELA antar-rumah C2 — jalan potong ke distrik
	]:
		_tile_mod(P_T + "ladang_tanah32.png", amb, 1, Color(0.74, 0.70, 0.64))

	# ── 2. RUMPUT MERAMBAT DI DISTRIK BEKAS ──────────────────────────────────
	# z=3: DI ATAS fondasi (z=1), karena itulah tesisnya — tanah mengambil kembali
	# batu, bukan batu yang bertahan di atas tanah. Petaknya tak beraturan; petak
	# rapi akan terbaca sebagai kebun, dan kebun berarti ada yang merawat.
	for semak in [
		Rect2(148, 232, 64, 32), Rect2(272, 176, 32, 64), Rect2(392, 240, 96, 32),
		Rect2(200, 290, 32, 64), Rect2(320, 344, 64, 32), Rect2(444, 288, 32, 64),
		Rect2(160, 448, 96, 32), Rect2(300, 400, 32, 64), Rect2(468, 440, 64, 32),
		Rect2(228, 372, 64, 32),
	]:
		_tile_mod(P_T + "ladang_semak32.png", semak, 3, Color(0.82, 0.88, 0.78))

	# ── 3. BERCAK — HALUS, DAN BERGRADIEN SEPERTI WARGA ──────────────────────
	# Dekat inti: bunga & rumput terawat (ada yang masih menyiangi). Menjauh:
	# semak liar & rumput tinggi. Di tepi: batu, ranting, jamur — tak ada lagi
	# tangan manusia, cuma waktu.
	var rng := RandomNumberGenerator.new()
	rng.seed = BIJI_TANAH
	# ⚠ WARNANYA IKUT MEREDUP KE TEPI, dan itu bukan gaya. `branch.png` berwarna
	#   oranye terang; ditaburkan penuh-warna di rumput ia terbaca sebagai SAMPAH —
	#   benda kecil menyolok yang mata cari padahal tak berarti apa-apa. Diredupkan,
	#   ia mundur jadi tekstur, dan itu memang tugasnya. Bercak tepi tak boleh menang
	#   melawan apa pun; ia cuma boleh memecah keseragaman.
	for cincin in [
		{"r0": 190.0, "r1": 420.0, "n": 26, "warna": Color(1.0, 1.0, 1.0),
			"jenis": ["flower_blue.png", "flower_pink.png", "grass.png", "bush.png"]},
		{"r0": 420.0, "r1": 700.0, "n": 34, "warna": Color(0.90, 0.93, 0.88),
			"jenis": ["grass.png", "bush.png", "pebbles.png", "flower_pink.png", "mushroom.png"]},
		{"r0": 700.0, "r1": 1080.0, "n": 30, "warna": Color(0.74, 0.79, 0.74),
			"jenis": ["bush.png", "pebbles.png", "branch.png", "rock.png", "mushroom.png"]},
	]:
		var jenis: Array = cincin["jenis"]
		for i in int(cincin["n"]):
			for percobaan in 14:
				var a := rng.randf() * TAU
				var d: float = lerpf(cincin["r0"], cincin["r1"], sqrt(rng.randf()))
				var p := VC + Vector2(cos(a) * d, sin(a) * d * 0.78)
				if p.x < 40.0 or p.x > float(MAP_W * TILE) - 40.0:
					continue
				if p.y < 40.0 or p.y > float(MAP_H * TILE) - 120.0:
					continue
				if not _boleh_tabur(p, larang):
					continue
				var sb := _jejak(jenis[rng.randi() % jenis.size()], p, rng.randf_range(1.3, 1.9))
				if sb:
					sb.modulate = cincin["warna"]
				break

	# ── 4. POHON — VARIASI BENTUK, dan ini separuh jawaban tahap 1.7 ─────────
	# Repo punya lima siluet pohon berbeda (oak, round, birch, giant, pine). Sampai
	# sekarang cuma `tree_oak` yang dipakai, empat kali, di empat sudut — jadi peta
	# punya SATU pohon yang diulang. Bentuk yang berbeda di kejauhan mengerjakan apa
	# yang tak bisa dikerjakan warna: ia memberi mata sesuatu untuk membedakan.
	for t in [
		["tree_giant.png", Vector2(232, 872), 1.7],
		["tree_round.png", Vector2(1596, 912), 1.9],
		["tree_birch.png", Vector2(1712, 548), 1.8],
		["tree_round.png", Vector2(186, 742), 1.7],
		["tree_birch.png", Vector2(1486, 1204), 1.8],
		["tree_giant.png", Vector2(1744, 1216), 1.6],
		["tree_round.png", Vector2(884, 176), 1.8],
		["tree_birch.png", Vector2(1128, 152), 1.7],
	]:
		var s := _jejak(String(t[0]), t[1], float(t[2]))
		if s:
			# batangnya saja, seperti empat pohon lama. Tajuk yang padat menghalangi
			# pemain jauh sebelum ia menyentuh pohonnya.
			_solid(Rect2(t[1].x - 9, t[1].y - 5, 18, 12))


# --------------------------------------------------- TAHAP 1.5 — LAPISAN DEKORASI
## Prop yang MENGISI ruang antar-rumah, dengan satu aturan yang membedakannya dari
## hiasan: kepadatannya ikut gradien yang sama dengan warga. C1 penuh kehidupan,
## C2 lebih jarang, C3 cuma sisa dan yang rusak.
##
## Tesisnya dikerjakan oleh BENDA YANG SAMA di tempat berbeda: lapak di alun-alun
## bercerita "pasar", lapak yang sama digelapkan di distrik bekas bercerita "pasar
## yang tak lagi ditunggui". Barang tak perlu diganti untuk berganti arti — cuma
## perlu dipindah ke tempat yang tak lagi punya orang.
func _dekorasi() -> void:
	# ── C1 — PENUH KEHIDUPAN ─────────────────────────────────────────────────
	for d in [
		["stall.png", Vector2(1140, 616), 2.0],      # lapak pasar, masih ditunggui
		["stall.png", Vector2(742, 792), 2.0],
		["signboard.png", Vector2(1016, 556), 2.2],  # papan pengumuman, di jalur balai
		["flower_pot.png", Vector2(1004, 494), 1.8], # ambang balai
		["flower_pot.png", Vector2(828, 456), 1.8],  # ambang Merrit
		["flower_pot.png", Vector2(1270, 468), 1.8], # ambang Halloran
		["crate.png", Vector2(1148, 474), 1.9],      # Halloran memanggang 200 roti
		["sack.png", Vector2(1178, 488), 1.9],
		["laundry.png", Vector2(686, 430), 1.8],     # rumah singgah: ada tamu
		["street_lamp.png", Vector2(672, 596), 1.9],
		["street_lamp.png", Vector2(1258, 812), 1.9],
	]:
		_jejak(String(d[0]), d[1], float(d[2]))
	# lapak PADAT — ia perabot, bukan hiasan; pemain tak boleh menembusnya
	for sp in [Vector2(1140, 616), Vector2(742, 792)]:
		_solid(Rect2(sp.x - 34, sp.y - 6, 68, 18))

	# ── C2 — LEBIH JARANG. Satu benda per rumah, dan rumah gelap dapat yang MATI ──
	# Rumah yang menyala dapat benda yang dipakai (jemuran, palung, pot). Rumah gelap
	# dapat peti dan karung — barang yang ditinggalkan, bukan barang yang dipakai.
	for d in [
		["flower_pot.png", Vector2(446, 664), 1.7],  # rumah C2 yang menyala
		["laundry.png", Vector2(544, 660), 1.7],
		["hay.png", Vector2(418, 676), 1.8],
		["trough.png", Vector2(596, 1006), 1.8],     # Lyra — masih dihuni
		["flower_pot.png", Vector2(710, 1002), 1.7],
		["crate.png", Vector2(302, 676), 1.7],       # rumah gelap: yang tertinggal
		["crate.png", Vector2(142, 684), 1.7],
		["sack.png", Vector2(706, 634), 1.7],
		["crate.png", Vector2(1318, 670), 1.7],      # samping toko Otha
		["sack.png", Vector2(1668, 710), 1.7],
		["crate.png", Vector2(1472, 808), 1.7],
	]:
		_jejak(String(d[0]), d[1], float(d[2]))

	# ── C3 — CUMA SISA DAN YANG RUSAK ────────────────────────────────────────
	# LAPAK KOSONG, dan ia benda terpenting di seluruh fungsi ini. Aset yang sama
	# dengan lapak alun-alun, digelapkan dan berdiri sendirian di antara fondasi:
	# pasar yang dulu ada di SINI, waktu di sinilah pusatnya. Ia mengatakan seluruh
	# tesis peta tanpa satu baris teks — dan mengatakannya dengan aset yang sudah ada.
	var lapak_mati := _jejak("stall.png", Vector2(690, 292), 1.9)
	if lapak_mati:
		lapak_mati.modulate = Color(0.60, 0.60, 0.62)
	for d in [
		["workbench.png", Vector2(516, 522), 1.7],   # bengkel yang berhenti
		["crate.png", Vector2(252, 476), 1.6],
		["sack.png", Vector2(436, 254), 1.6],
		["log_fallen.png", Vector2(178, 486), 1.7],
		["stump.png", Vector2(604, 198), 1.7],
		["trough.png", Vector2(346, 196), 1.6],      # palung ternak, nol ternak
	]:
		var s := _jejak(String(d[0]), d[1], float(d[2]))
		if s:
			s.modulate = Color(0.82, 0.82, 0.84)     # semua di sini kehilangan warnanya


## Cakram pelataran, dipusatkan (bukan `_tile` yang selalu rata-kiri-atas).
func _setapak_cakram(pusat: Vector2, z: int) -> void:
	var p := P_T + "pelataran32.png"
	if not ResourceLoader.exists(p):
		push_warning("[ash64] pelataran hilang: %s — jalankan _tools/gen_pelataran.py" % p)
		return
	var s := Sprite2D.new()
	s.texture = load(p)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = pusat
	s.z_index = z
	add_child(s)


## Setapak lurus antara dua titik BERSUMBU TEGAK/DATAR. Dipakai menyambungkan pintu
## rumah ke jalan dagang: sebelum ini rumah "terapung di rumput" — nol jejak kaki
## antara pintu dan jalan, seolah tak seorang pun pernah berjalan ke sana.
func _setapak(a: Vector2, b: Vector2, lebar := 28.0) -> void:
	var x0 := minf(a.x, b.x) - lebar * 0.5
	var y0 := minf(a.y, b.y) - lebar * 0.5
	var w := absf(b.x - a.x) + lebar
	var h := absf(b.y - a.y) + lebar
	_tile(P_T + "stone32.png", Rect2(x0, y0, w, h), 1)


func _put(path: String, pos: Vector2, z := -1) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] aset hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.position = pos
	s.z_index = int(pos.y) if z < 0 else z
	add_child(s)
	return s


# ---------------------------------------------------------------- desa
## Fasad ditambatkan pada KAKI, bukan pusat: `pos` = titik bangunan menyentuh tanah.
## Dua sebabnya. (1) y-sort: bangunan setinggi 7 petak yang diurutkan menurut
## pusatnya akan tampak di belakang orang yang berdiri di depannya. (2) Menaruh
## bangunan jadi soal "di mana ia berdiri", bukan aritmetika tinggi.
func _building(path: String, foot: Vector2) -> Sprite2D:
	if not ResourceLoader.exists(path):
		push_warning("[ash64] fasad hilang: %s" % path)
		return null
	var s := Sprite2D.new()
	s.texture = load(path)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.centered = false
	var wdt: float = s.texture.get_width()
	s.position = foot - Vector2(wdt * 0.5, s.texture.get_height())
	s.z_index = int(foot.y)
	add_child(s)
	# Tabrakan hanya di KAKI, bukan setinggi fasad. Fasad 7 petak yang padat penuh
	# akan menghalangi pemain jauh sebelum ia "menyentuh" bangunannya, dan merusak
	# y-sort yang justru membuat orang bisa berdiri di depan rumah.
	_solid(Rect2(foot.x - wdt * 0.5, foot.y - BUILDING_FOOT_H, wdt, BUILDING_FOOT_H))
	return s


## Setinggi apa kaki bangunan yang padat. 40 px = sedikit di atas tinggi pemain (30x48
## badan), jadi ia jelas "tak bisa lewat" tanpa memakan petak di depan pintu.
const BUILDING_FOOT_H := 40.0

func _village() -> void:
	# ⚠ BUKAN LAGI `fasad_inn`. Merrit dan balai memakai fasad yang SAMA selama
	#   berbulan-bulan — dua bangunan kembar bersebelahan di sisi utara alun-alun,
	#   dan koreksi 3 B' justru meminta Merrit yang TERPENDEK. `fasad_singgah`
	#   (adobe pasir, 160x192) membayar keduanya sekaligus: bahan berbeda, dan 32 px
	#   lebih pendek daripada balai yang berdiri 176 px di sebelahnya.
	_building(P_S + "fasad_singgah.png", MERRIT_HOUSE)             # rumah singgah Merrit
	_building(P_S + "fasad_gudang.png", GUDANG_KAKI)               # gudang gandum — C3
	_building(P_S + "fasad_shop.png", OTHA_KAKI)                   # toko Otha — tutup dua musim
	_building(P_S + "fasad_kosong.png", Vector2(1408, 800))        # rumah kosong
	_building(P_S + "fasad_rumah.png", Vector2(640, 992))          # rumah Lyra (masih dihuni)

	# ── C2 BARAT: GRADIEN DI RUANG (koreksi 6) ───────────────────────────────
	# Jarak antar rumah MELEBAR ke tepi — 148, 172, 194 px — dan selisihnya sendiri
	# ikut membesar. Ini koreksi yang paling tak terlihat dan paling banyak membayar:
	# kepadatan yang menipis lewat JARAK terbaca sebagai kota yang meluruh, sedangkan
	# kepadatan yang menipis lewat jumlah lampu saja terbaca sebagai kota utuh yang
	# kebetulan gelap. Ashbrook harus meluruh, bukan sekadar padam.
	#
	# Yang di 492 DIHUNI (jendelanya didaftarkan di `_jendela()`); tiga sisanya gelap.
	# Kenapa yang dihuni bukan yang terdekat ke inti: rumah hidup di tengah barisan
	# membuat kegelapan di kedua sisinya terbaca sebagai KEHILANGAN. Rumah hidup di
	# ujung dalam cuma menggambar batas antara "kota" dan "bukan kota".
	# ── BENTUK IKUT KEADAAN, bukan diundi (1.7a) ─────────────────────────────
	# Dua rumah tetap `fasad_kosong` DENGAN SENGAJA. Desa yang tiap rumahnya
	# berbeda tak terbaca beragam — ia terbaca sebagai pameran, dan tak seorang
	# pun tinggal di pameran. Yang diganti cuma yang punya alasan diganti.
	_building(P_S + "fasad_kosong.png", Vector2(640, 656))
	_building(P_S + "fasad_rumah.png", Vector2(492, 650))          # satu-satunya yang menyala
	# adobe pudar: bahan lebih tua daripada tetangganya, dan sudah mati lebih dulu
	_building(P_S + "fasad_adobe_pudar.png", Vector2(320, 660))
	# RUMAH TERLAPUK (1.7b-2) — paling barat, paling jauh dari inti, dan satu-satunya
	# yang dindingnya sudah bolong. Gradien C2 tak lagi cuma soal JARAK dan LAMPU;
	# di ujungnya bahan bangunannya sendiri mulai menyerah. Lubangnya berlatar gelap
	# ruang dalam, bukan tembus — yang tembus terbaca cacat gambar, bukan rumah yang
	# ditinggalkan.
	_building(P_S + "fasad_lapuk.png", Vector2(126, 668))
	# C2 TIMUR — gradien yang sama, dari toko Otha ke luar: 156, lalu 194.
	# MENARA TEPI (96x256): satu-satunya bangunan yang memecah garis atap desa.
	# Ditaruh paling timur supaya ia terlihat dari jauh sebelum dicapai — sisa kota
	# lama yang masih menjulang, dan tak ada lagi yang menempatinya.
	_building(P_S + "fasad_datar_tinggi.png", Vector2(1602, 700))

	# ── C1: BALAI DESA — terlalu besar untuk yang tersisa ────────────────────
	# Fasad terbesar yang dipunyai repo (inn 160x224), menghadap alun-alun dari utara.
	# Ia sengaja bangunan PALING BESAR di peta: empat puluh orang menggema di ruang
	# yang dibangun untuk lima ratus. Kekosongannya bukan kekurangan aset — itu isi
	# ceritanya, dan ia harus terbaca dari luar tanpa satu baris teks pun.
	# BERTINGKAT (1.7b-1), dan langka dengan sengaja: cuma balai + menara tepi timur.
	# Penanda cuma bekerja kalau jarang — kalau separuh desa bertingkat, tingkat
	# berhenti berarti "penting" dan mulai berarti "begitulah rumah di sini".
	# 160x288 membuatnya tertinggi di peta dengan selisih 32 px, jadi jangkar mata
	# dari gerbang (koreksi 7 B') akhirnya punya SEBAB: ia bertingkat, dan yang
	# bertingkat di Ashbrook cuma yang dibangun waktu kota masih mampu ke atas.
	_building(P_S + "fasad_balai.png", BALAI_KAKI)
	# HALLORAN — penempaan/warung, naik ke sisi utara alun-alun bersama balai & Merrit.
	# Fasadnya `fasad_rumah` (192 px) sementara balai `fasad_inn` (224 px): dua tinggi
	# berbeda dari aset yang SUDAH ADA. ⚠ Merrit masih memakai `fasad_inn` juga, jadi
	# ia setinggi balai — koreksi 3 meminta Merrit yang TERPENDEK, dan itu menuntut
	# fasad baru, bukan koordinat. Ditinggalkan sebagai utang aset, bukan disamarkan.
	_building(P_S + "fasad_rumah.png", HALLORAN_KAKI)

	# ── C2: TIGA RUMAH MENUTUP CINCIN KE SELATAN ─────────────────────────────
	# C2 sebelumnya cuma BUSUR, bukan cincin: Merrit barat, gudang barat-laut, toko
	# timur-laut, rumah kosong timur, Lyra barat-daya. Sisi selatan & tenggara NOL —
	# dan itu justru tanah yang baru lahir saat kanvas tumbuh. Ketiganya di jari-jari
	# 12-16 petak, sama dengan rumah lama, jadi cincinnya rata.
	#
	# Ketiganya GELAP (nol jendela didaftarkan di `_jendela()`). Gradien #218 yang
	# diminta — 1 dari 4 hidup — sekarang terpenuhi dengan hitungan sungguhan:
	# 8 bangunan, yang menyala cuma Lyra + lentera Merrit.
	# LEBAR-PENDEK (160x160) — kebalikan menara timur. Dua siluet ekstrem di peta
	# yang sama membuat yang di antaranya terbaca "biasa"; tanpa keduanya, semua
	# ukuran terasa sama besar.
	_building(P_S + "fasad_datar_lebar.png", Vector2(1120, 1152))  # selatan-tenggara
	_building(P_S + "fasad_rumah.png", Vector2(736, 1184))          # selatan
	_building(P_S + "fasad_kosong.png", Vector2(1376, 1056))        # timur-tenggara
	# POHON. Dulu `tree_lpc.png` — dan berkas itu ternyata BUKAN POHON: potongan
	# salah-krop berupa lengkungan cokelat-keemasan, nol batang, nol tajuk. Empat
	# "pohon" ini selama berbulan-bulan cuma noda tan di rumput, dan tak ada yang
	# menyadarinya karena dari kamera main ukurannya kecil. Komentar di bawah pun ikut
	# percaya sampai menulis "batang, bukan tajuk" untuk sprite yang tak punya keduanya.
	# `tree_oak.png` sudah ada di repo sejak lama, berbatang & bertajuk — asetnya tak
	# pernah hilang, kodenya yang menunjuk berkas salah (pola yang sama dengan ayam).
	for p in [Vector2(320, 384), Vector2(1600, 352), Vector2(1728, 1024), Vector2(224, 1088)]:
		_jejak("tree_oak.png", p, 2.0)
	# PENJURU ALUN-ALUN — bingkai, bukan hiasan. Sudut yang ditandai membuat mata
	# membaca ruang TERTUTUP ("ini tempatnya") alih-alih hamparan terbuka ("lewat saja").
	#
	# TONG, BUKAN POHON, dan itu bukan pilihan rasa: `tree_lpc.png` TERNYATA BUKAN POHON.
	# Berkasnya potongan salah-krop — lengkungan cokelat-keemasan tanpa batang maupun
	# tajuk (lihat empat "pohon" lama di 320,384 / 1600,352 / 1728,1024 / 224,1088: dari
	# kamera main mereka cuma noda tan di rumput). Komentar di kode ini pun ikut percaya,
	# sampai menulis "batang, bukan tajuk" untuk sprite yang tak punya keduanya.
	# Menambah empat salinan aset rusak bukan bingkai — itu derau yang menyamar jadi
	# bingkai. Tong terbukti terbaca sebagai tong, jadi tong yang dipakai sampai ada
	# aset pohon yang benar. Empat pohon lama DIBIARKAN: memperbaikinya kerja aset,
	# bukan tata letak.
	# Penjuru timur-laut digeser 32 px ke dalam: di (248,-152) tongnya PERSIS menindih
	# titik-periksa `ev_ashbrook_halloran_200_roti` (1216,560) — `CekJangkau.gd`
	# mengukurnya `titik_di_dalam_padat=true`. Buktinya masih terjangkau dari 20 arah,
	# jadi ia tak pernah gagal keras; ia cuma dikubur di dalam tong. Cacat diam.
	for p in [VC + Vector2(-248, -152), VC + Vector2(216, -152),
			VC + Vector2(-248, 152), VC + Vector2(248, 152)]:
		_put(P_S + "barrel_lpc.png", p)
		_solid(Rect2(p.x - 12, p.y - 4, 24, 16))
	# ── KOREKSI 5 — AIR MANCUR OFF-CENTER ────────────────────────────────────
	# Digeser 38 px ke barat & 22 px ke utara dari pusat matematis alun-alun. Tempat
	# tua tumbuh DI SEKITAR sesuatu; ia tak pernah dipusatkan padanya. Air mancurnya
	# lebih tua daripada pelatarannya, dan pelataran itulah yang mengalah — bukan
	# sebaliknya. Pergeseran kecil ini yang membedakan "alun-alun yang dirancang"
	# dari "alun-alun yang tumbuh".
	#
	# ⚠ MASIH `fountain.png` (KERING). Direktur meminta `WaterFountain.png` (berair),
	#   dan berkas itu ADA di gudang — tapi lisensinya masuk daftar ⚠CEK yang belum
	#   ditelusuri (`KATALOG_GUDANG.md`). #277 mewajibkan atribusi untuk tiap aset,
	#   dan perintah berdiri Direktur sendiri berbunyi "nol pakai aset sampai lisensi
	#   pasti". Memasangnya sekarang melanggar keduanya. Pergeserannya dijalankan;
	#   penggantian asetnya menunggu telusur — cacat 🔴-4 POTRET setengah terbayar.
	var fnt := VC + Vector2(-38, -22)
	_put(P_S + "fountain.png", fnt)                                # air mancur KERING
	_solid(Rect2(fnt.x - 26, fnt.y - 10, 52, 34))                  # cekungannya, bukan seluruh sprite
	for i in 8:                                                     # bangku terlalu banyak
		var bp: Vector2 = VC + Vector2(-224 + i * 64, 112 if i % 2 == 0 else -112)
		_put(P_S + "bench_lpc.png", bp)
		_solid(Rect2(bp.x - 14, bp.y - 4, 28, 16))                  # dudukannya saja
	for tp in [Vector2(320, 384), Vector2(1600, 352), Vector2(1728, 1024), Vector2(224, 1088)]:
		_solid(Rect2(tp.x - 10, tp.y - 6, 20, 14))                  # batang, bukan tajuk


# ------------------------------------------------- prop cerita + HUKUM BUKTI (#226)
func _props_and_evidence() -> void:
	# LAMPU MERRIT — jiwa Ashbrook. Menyala siang & malam.
	_lamp = _put(P_OLD + "lantern.png", MERRIT_HOUSE + Vector2(72, -56), Z_LAMP)
	if _lamp:
		_lamp.scale = Vector2(2, 2)                                 # 12x20 -> 24x40, seskala LPC
		var glow := PointLight2D.new()
		var gp := P_OLD + "lantern_glow.png"
		if not ResourceLoader.exists(gp):
			# FALLBACK BERTERIAK (#aset): placeholder senyap = bug berikutnya yang menunggu.
			push_warning("[aset] gagal muat: %s — cahaya lentera memakai tekstur lentera" % gp)
		glow.texture = load(gp) if ResourceLoader.exists(gp) else _lamp.texture
		glow.energy = 0.9          # siang: lentera menyala tapi tak membakar layar
		glow.texture_scale = 7.0
		glow.color = Color(1.0, 0.85, 0.55)
		_lamp.add_child(glow)
	# titik cahaya lintas-jarak (#218) — z di bawah plafon, di atas seluruh y-sort
	var beacon := Sprite2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.88, 0.6))
	beacon.texture = ImageTexture.create_from_image(img)
	beacon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	beacon.global_position = MERRIT_HOUSE + Vector2(72, -56)
	beacon.z_index = Z_BEACON
	beacon.modulate.a = 0.0                                         # siang: lentera sendiri sudah cukup
	beacon.add_to_group("lamp_beacon")
	add_child(beacon)
	_beacon = beacon

	# PAPAN OTHA — kosong + BEKAS CAT (bukti `akibat`). Diskalakan 4x supaya
	# persegi bekasnya TETAP TERBACA pada petak 32 (16x14 -> 64x56).
	var sign := _put(P_OLD + "otha_sign_fadedmark.png", OTHA_KAKI + Vector2(0, 40))
	if sign:
		sign.scale = Vector2(4, 4)
	_examine(OTHA_KAKI + Vector2(0, 92), "ev_otha_papan_bekas_cat")

	# reruntuhan: garis fondasi di rumput + batu fondasi berpahat di alun-alun
	# ⚠ URUTAN PENTING (#batas): titik ini DULU di y=1152 — di LUAR tanah 34 petak
	# (1088 px). Memasang batas tanpa memindahkannya akan MEMUTUS jalur bukti:
	# pemain tak bisa lagi menjangkaunya, dan `ev_ashbrook_fondasi_rumput` jadi
	# mustahil dikumpulkan. Reruntuhannya ikut naik supaya keduanya tetap sepasang.
	# ⚠ DULU `wall_ruin.png`, dan itu SALAH. Audit-mata membuktikan berkas itu PAGAR
	# KAYU UTUH, bukan reruntuhan (lpc32/DEPRECATED.md, "nama menyesatkan"). Dua
	# titik-periksa di bawah bercerita tentang BATU — garis fondasi dan batu berpahat —
	# dan yang tergambar selama ini kayu. Teksnya menyebut satu benda, gambarnya
	# menunjukkan benda lain, dan pemain yang memeriksa menerima keduanya sekaligus.
	#
	# Komentar lama di baris `stone` bahkan MENOLAK `ruins.png` dengan alasan
	# "16px bentrok gaya" — padahal ia 40x28 dan sudah dipakai sebagai batu sudut
	# denah C3 di seluruh peta. Alasan yang salah menutup aset yang benar, dan
	# alasannya bertahan lebih lama daripada pemeriksaannya.
	# ⚠ DIPINDAH KE DISTRIK BEKAS (koreksi 4). Titik ini dulu berdiri sendiri di
	#   tenggara — satu batu di rumput, dan teksnya bercerita tentang garis fondasi
	#   yang tak terlihat di sekelilingnya. Di dalam distrik, yang dibaca pemain dan
	#   yang dilihatnya akhirnya benda yang sama.
	_jejak("ruins.png", Vector2(322, 428), 1.8)
	_examine(Vector2(322, 462), "ev_ashbrook_fondasi_rumput")
	# batu fondasi berpahat — lebih kecil dari reruntuhan di atas: SATU batu, bukan
	# sisa dinding. Digeser sedikit ke selatan supaya tak bertindih titik-periksanya.
	_jejak("ruins.png", VC + Vector2(-176, 104), 1.2)
	_examine(VC + Vector2(-160, 152), "ev_ashbrook_batu_fondasi")

	# tiga pintu periksa Ashbrook-besar
	_examine(GUDANG_KAKI + Vector2(0, 40), "ev_ashbrook_gudang_gandum")
	# Digeser ke TIMUR fasad Halloran, bukan di depan pintunya: tepat di depan pintu
	# ia bertabrakan dengan setapak balai-Halloran dan dengan zona warga yang berdiri
	# di teras. Aturan yang sudah dibayar sekali (#zona warga vs titik-periksa).
	_examine(HALLORAN_KAKI + Vector2(78, 48), "ev_ashbrook_halloran_200_roti")
	_examine(Vector2(1856, 704), "ev_ashbrook_jembatan_terlalu_lebar")


func _examine(pos: Vector2, ev_id: String) -> void:
	var e := preload("res://scenes/world/Interactable.tscn").instantiate()
	add_child(e)
	e.evidence_id = ev_id
	e.setup("examine")
	e.global_position = pos


# ---------------------------------------------------------------- KEHIDUPAN
## Dipindahkan dari `Ashbrook.gd` 16px (keputusan Direktur: 64px jadi utama).
##
## ⚠ KOORDINAT DIHITUNG ULANG, BUKAN DISALIN. Petak 16px → 32px berarti dunia dua
## kali lebih besar dalam piksel, dan tata letak Ashbrook64 memang berbeda: alun-alun
## di `VC`, jembatan di timur, gerbang di barat. Menyalin angka 16px mentah-mentah
## akan menaruh ayam di dalam tembok. Setiap penempatan di bawah ditambatkan ke
## **penanda Ashbrook64**, bukan ke angka lama.
##
## Radius berkelana juga digandakan: makhluk yang berkelana 40 px di dunia 16px
## menempuh 2,5 petak; di petak 32 itu cuma 1,25 petak — terlihat lumpuh.
func _kehidupan() -> void:
	_ternak()
	_liar()
	_hidup_ayam_anak()
	_hidup_berpasangan()
	_jendela()
	_titik_pandang()
	_anak_serigala()


## Ayam yang benar-benar menghalangi jalan + anak-anak yang mengejarnya.
## Hidup × mati: mereka bermain di depan gudang yang isinya empat ekor ayam.
# ------------------------------------------------ LAPIS 1 — TERNAK (kehidupan tersisa)
## Ternak bukan hiasan; ia ALAT UKUR. Hewan yang dipelihara menuntut orang yang
## memeliharanya, jadi kehadirannya membuktikan rumah di sebelahnya masih dihuni —
## dan ketiadaannya di tepi membuktikan kebalikannya, tanpa satu baris teks.
##
## ⚠ GRADIENNYA TERBALIK DARI YANG DIDUGA. Bukan "banyak di pusat, sedikit di tepi"
## melainkan "ada di sebelah rumah berpenghuni, NOL di mana pun selain itu". Ternak
## yang tersebar merata cuma jadi latar; ternak yang berkelompok di dua titik
## menjadikan dua titik itu terbaca sebagai rumah yang masih ditunggui.
##
## ⚠ PAGARNYA TAK PADAT — dan itu putusan, bukan kelalaian. `Hewan` dikurung oleh
## `wander_radius`, bukan oleh tabrakan; memberi pagar `_solid()` berarti menambah
## sepuluh kotak padat di jalur yang sudah lulus `CekKoridor`, demi kurungan yang
## sudah bekerja tanpa itu. Yang berhak memakan ruang jalan cuma yang harus
## menghalangi pemain, dan kandang ayam tidak.
func _ternak() -> void:
	# KANDANG di sisi timur rumah Lyra — satu-satunya rumah C2 yang terbaca dihuni,
	# dan satu-satunya yang sudah punya palung air sejak lapisan dekorasi (1.5).
	# Palung itu sekarang punya sebab: ia milik kandang ini.
	var k := Rect2(752, 880, 176, 110)
	for i in 6:                                   # pagar utara & selatan
		var fx: float = k.position.x + 14 + i * 30
		_jejak("pagar_h32.png", Vector2(fx, k.position.y), 1.0)
		if i != 4:                                # satu ruas hilang = pintu kandang
			_jejak("pagar_h32.png", Vector2(fx, k.position.y + k.size.y), 1.0)
	for i in 3:                                   # tiang sisi timur & barat
		var fy: float = k.position.y + 22 + i * 34
		_jejak("pagar_tiang32.png", Vector2(k.position.x, fy), 1.0)
		_jejak("pagar_tiang32.png", Vector2(k.position.x + k.size.x, fy), 1.0)
	_jejak("hay.png", Vector2(k.position.x + 26, k.position.y + 30), 1.8)

	var pusat := k.position + k.size * 0.5
	for spec in [
		["domba", pusat + Vector2(-34, 6), 44.0],
		["domba", pusat + Vector2(30, -12), 44.0],
		["ayam", pusat + Vector2(-52, 32), 34.0],
		["ayam", pusat + Vector2(46, 26), 34.0],
		["ayam", pusat + Vector2(8, 38), 34.0],
	]:
		var h := Node2D.new()
		h.set_script(load("res://scenes/actors/Hewan.gd"))
		h.setup(String(spec[0]))
		add_child(h)
		h.wander_radius = float(spec[2])
		h.place(spec[1])

	# DUA AYAM LEPAS di halaman rumah C2 yang menyala. Bukan kandang — cuma ayam
	# yang dibiarkan berkeliaran, dan itu justru bacaan yang benar: rumah kecil
	# tak berkandang, ia cuma punya ayam. Satu-satunya rumah lain yang berlampu.
	for p in [Vector2(452, 700), Vector2(492, 716)]:
		var a := Node2D.new()
		a.set_script(load("res://scenes/actors/Hewan.gd"))
		a.setup("ayam")
		add_child(a)
		a.wander_radius = 40.0
		a.place(p)


# --------------------------------------------- LAPIS 2 — LIAR (rumah yang hilang)
## Kebalikan persis dari ternak, dan kebalikannya disengaja: ternak berkumpul di
## sebelah rumah berpenghuni, yang liar berkumpul di tempat yang penghuninya sudah
## pergi. Dua gradien yang berlawanan arah membuat KEDUANYA terbaca; satu gradien
## saja cuma jadi sebaran.
##
## Yang membedakan liar dari ternak bukan spritenya melainkan JARAKNYA. Ternak
## membiarkan orang mendekat karena orang yang memberinya makan. Yang liar kabur
## dari 116 px — ia sudah lupa manusia pernah ramah, dan jarak itulah kalimatnya.
func _liar() -> void:
	# BANYAK di distrik bekas, sedikit di tepi, SATU di inti. Yang satu di inti itu
	# penting: tanpa ia, "liar" jadi wilayah yang terpisah rapi dari "desa", dan
	# yang harus terbaca justru batas yang sudah kabur.
	for spec in [
		["kucing_kelabu", Vector2(258, 300), 96.0],    # distrik bekas
		["kucing_kelabu", Vector2(452, 372), 88.0],
		["kucing_jingga", Vector2(196, 452), 92.0],
		["kucing_kelabu", Vector2(1470, 892), 84.0],   # tepi timur, dekat rumah gelap
		["kucing_jingga", Vector2(1618, 1094), 84.0],
		["kucing_jingga", Vector2(1046, 830), 64.0],   # SATU di inti — batas yang kabur
	]:
		var k := Node2D.new()
		k.set_script(load("res://scenes/actors/Hewan.gd"))
		k.setup(String(spec[0]))
		add_child(k)
		k.liar = true
		k.wander_radius = float(spec[2])
		k.place(spec[1])

	# ── ANJING ───────────────────────────────────────────────────────────────
	# Anjing bukan kucing yang berbeda gambar. Kucing liar tak pernah bergantung
	# pada siapa pun, jadi ia cuma jadi lebih jauh. Anjing DULU setia pada seseorang;
	# yang tersisa sekarang kebiasaan setianya, tanpa orangnya — dan itu kalimat yang
	# tak bisa diucapkan kucing.
	for spec in [
		["anjing_cokelat", Vector2(1330, 940), 110.0],   # tepi timur, dekat rumah gelap
		["anjing_kelabu", Vector2(408, 268), 104.0],     # distrik bekas
	]:
		var d := Node2D.new()
		d.set_script(load("res://scenes/actors/Hewan.gd"))
		d.setup(String(spec[0]))
		add_child(d)
		d.liar = true
		d.wander_radius = float(spec[2])
		d.place(spec[1])

	# SATU anjing yang MENGIKUTI, dan cuma satu. Ia satu-satunya makhluk di peta yang
	# mendekat alih-alih kabur — dan seluruh maksudnya ada pada BERHENTINYA: ia ikut
	# lima detik karena itu yang selalu ia lakukan, lalu berdiri diam empat detik
	# karena kau bukan orang yang ditunggunya. Nol dialog, nol pemicu, nol imbalan.
	# Ditaruh di jalan dagang barat: jalur yang pasti dilewati, tapi bukan di alun-alun
	# — momen ini butuh sepi di sekelilingnya untuk terbaca.
	var pengikut := Node2D.new()
	pengikut.set_script(load("res://scenes/actors/Hewan.gd"))
	pengikut.setup("anjing_cokelat")
	add_child(pengikut)
	pengikut.ikut = true
	pengikut.wander_radius = 92.0
	pengikut.place(Vector2(392, 782))

	# ── BURUNG (2.5) — dua jenis yang memilih tempat BERLAWANAN ──────────────
	# Merpati hidup dekat manusia karena manusia menjatuhkan makanan. Gagak
	# berkumpul di tempat yang manusianya sudah pergi. Menaruh keduanya di peta yang
	# sama membuat penyusutan kota terbaca dari langit-langitnya: alun-alun masih
	# punya yang menunggu remah, distrik bekas sudah punya yang menunggu hal lain.
	for spec in [
		["merpati", "merpati_terbang", VC + Vector2(-96, 118), 52.0],
		["merpati", "merpati_terbang", VC + Vector2(118, 92), 52.0],
		["merpati", "merpati_terbang", VC + Vector2(24, 168), 48.0],
		["gagak", "gagak_terbang", Vector2(286, 236), 76.0],      # distrik bekas
		["gagak", "gagak_terbang", Vector2(430, 396), 76.0],
		["gagak", "gagak_terbang", Vector2(1666, 1130), 70.0],    # ladang timur, tepi
	]:
		var b := Node2D.new()
		b.set_script(load("res://scenes/actors/Hewan.gd"))
		b.setup(String(spec[0]))
		b.terbang_sheet = String(spec[1])
		add_child(b)
		b.wander_radius = float(spec[3])
		b.place(spec[2])

	# ── BURUNG LANGIT — memecah kekosongan DI ATAS ───────────────────────────
	# Ashbrook dilihat dari atas, jadi "langit" tak punya ruang sendiri; satu-satunya
	# cara menaruh sesuatu di udara adalah z tetap yang di atas seluruh y-sort, sama
	# seperti wisp (#275). Tanpa z tetap ia akan tenggelam di belakang rumah yang
	# kebetulan ber-y lebih besar, dan burung yang lewat DI BALIK atap bukan burung.
	#
	# Melintas PELAN dan JARANG. Burung yang menyeberang tiap tiga detik jadi hiasan
	# bergerak; yang lewat sekali dalam waktu lama membuat pemain mendongak.
	for lintas in [
		{"y": 168.0, "lama": 26.0, "tunda": 0.0, "jenis": "gagak_terbang_kiri.png"},
		{"y": 452.0, "lama": 34.0, "tunda": 12.0, "jenis": "merpati_terbang_kiri.png"},
	]:
		var s := _put(P_A + String(lintas["jenis"]), Vector2(-64, lintas["y"]), Z_LAMP)
		if s == null:
			continue
		s.scale = Vector2(1.3, 1.3)
		var at := AtlasTexture.new()
		at.atlas = s.texture
		at.region = Rect2(0, 0, 32, 32)
		s.texture = at
		s.modulate = Color(1, 1, 1, 0.85)
		var t := create_tween().set_loops()
		t.tween_interval(float(lintas["tunda"]))
		t.tween_property(s, "position:x", float(MAP_W * TILE) + 64.0, float(lintas["lama"]))
		t.tween_callback(func(): s.position.x = -64.0)
		t.tween_interval(float(lintas["lama"]) * 0.8)
		# kepakan: frame berganti sendiri, lepas dari gerak mendatarnya
		var k := create_tween().set_loops()
		for f in 3:
			k.tween_callback(func(): at.region = Rect2(f * 32, 0, 32, 32))
			k.tween_interval(0.14)

	# ── KUCING PENUNGGU — nol teks, nol penjelasan ───────────────────────────
	# Duduk DIAM di ambang rumah yang gelap. Ia tak berkelana, tak lari, tak
	# menunggu tombol; ia cuma ada di sana tiap kali pemain lewat. Yang memperhatikan
	# akan mengerti sendiri bahwa dulu ada yang tinggal di situ, dan pengertian yang
	# datang sendiri lebih tinggal daripada yang diberitahukan.
	#
	# ⚠ Sengaja DUA, bukan lima. Satu bisa terbaca kebetulan; dua terbaca pola; lima
	#   terbaca sistem, dan sistem menghapus rasa bahwa kita menemukan sesuatu.
	for p in [
		Vector2(156, 706),      # ambang rumah terlapuk, paling barat
		Vector2(1400, 1092),    # ambang rumah berpapan, tenggara
	]:
		var s := _put(P_A + "kucing_menunggu.png", p)
		if s:
			s.scale = Vector2(1.4, 1.4)
	# Satu lagi MERINGKUK di antara fondasi distrik bekas — tidur di rumah yang
	# tinggal denahnya. Ia tidur, jadi ia tak lari: hewan yang merasa aman di
	# reruntuhan mengabarkan sudah berapa lama tak ada orang lewat.
	var m := _put(P_A + "kucing_meringkuk.png", Vector2(322, 214))
	if m:
		m.scale = Vector2(1.4, 1.4)
	# ANJING PENUNGGU di ambang rumah kosong timur. Pose duduknya sama persis dengan
	# kucing penunggu — yang berbeda cuma hewannya, dan itu cukup: kucing yang duduk
	# di ambang berkata "aku tinggal di sini", anjing yang duduk di ambang berkata
	# "aku menunggu". Bedanya datang dari hewannya, bukan dari gambarnya.
	var aw := _put(P_A + "anjing_menunggu.png", Vector2(1436, 812))
	if aw:
		aw.scale = Vector2(1.4, 1.4)


func _hidup_ayam_anak() -> void:
	for i in 4:
		var c := Node2D.new()
		# Lewat KATALOG (#240): jenis + skala dibaca dari `_tools/katalog_hewan.json`,
		# bukan disetel di sini. `scale` sengaja TIDAK diberikan — skala yang dikarang
		# di sisi pemanggil persis cara "kambing 3x" lahir sebagai ayam raksasa.
		c.set_script(load("res://scenes/actors/Hewan.gd"))
		c.setup("ayam")
		add_child(c)
		c.wander_radius = 76.0
		c.place(GUDANG_KAKI + Vector2(randf_range(-70, 90), randf_range(20, 90)))
		_chickens.append(c)
	for i in 3:
		var k := Node2D.new()
		k.set_script(load("res://scenes/actors/AshbrookKid.gd"))
		# varian DIPASANG SEBELUM add_child: `_ready()` jalan di dalam add_child, dan
		# yang dipasang sesudahnya tak pernah terbaca. (Pertama kali salah urutan,
		# ketiga anak diam-diam jatuh ke kotak placeholder — log yang menangkapnya.)
		k.varian = i                 # tiga anak BERBEDA, bukan tiga salinan
		add_child(k)
		# CINCIN, bukan kotak. Kotak lama (VC ± 150x100) memuat air mancur di
		# tengahnya, jadi anak bisa LAHIR di dalam benda padat — dan penjaga
		# `_terhalang()` cuma menjaga GERAK, bukan kelahiran. `CekJangkau` menandainya
		# 1 dari 3 putaran; dua putaran bersih itu hasil undian, bukan bukti.
		# 108 px, naik dari 96: cekungan air mancur bergeser 38 px ke BARAT (koreksi 5),
		# jadi sisi barat cincin ini jadi lebih sempit daripada waktu angkanya dipilih.
		#
		# ⚠ TAPI JARI-JARI SAJA TAK PERNAH CUKUP, dan itu pelajaran yang dibayar dua kali.
		#   Cincin ini melintasi DUA BARIS BANGKU (VC.y ± 112), jadi berapa pun jari-jari
		#   yang dipilih, ada sudut yang menjatuhkan anak tepat di atas bangku. Anak yang
		#   LAHIR di dalam benda padat tak pernah keluar — `_terhalang()` menjaga langkah,
		#   bukan kelahiran, sehingga setiap arah tertutup dan ia terkunci diam.
		#   Sekarang titiknya DIUJI, bukan ditebak: sampai 24 lemparan, ambil yang bebas.
		#   ⚠ DAN LEMPARAN TERAKHIR TAK BOLEH DIPAKAI KALAU IA GAGAL. Versi pertama
		#     mengulang 24 kali lalu memakai `pos` apa adanya — jadi kalau kedua puluh
		#     empatnya kebetulan jatuh di bangku, anak tetap lahir di dalam bangku,
		#     cuma lebih jarang. `CekJangkau` menangkapnya 1 dari 6 putaran: cacat
		#     yang diperkecil bukan cacat yang dibereskan, dan yang jarang justru
		#     lebih mahal — ia lolos playtest lalu muncul di tangan pemain.
		#     Sekarang ada JATUH-BALIK: kalau acak menyerah, cincinnya dilebarkan
		#     selangkah demi selangkah sampai benar-benar bebas.
		var pos := VC
		var bebas := false
		for percobaan in 24:
			var a := randf() * TAU
			var r := randf_range(108.0, 172.0)
			pos = VC + Vector2(cos(a) * r, sin(a) * r * 0.7)
			if not _padat_menyentuh(pos, Vector2(16, 18), Vector2(0, -9)):
				bebas = true
				break
		if not bebas:
			for langkah in 40:
				var a2 := TAU * float(langkah) / 8.0
				var r2 := 180.0 + float(langkah / 8) * 26.0
				var q := VC + Vector2(cos(a2) * r2, sin(a2) * r2 * 0.7)
				if not _padat_menyentuh(q, Vector2(16, 18), Vector2(0, -9)):
					pos = q
					bebas = true
					break
		if not bebas:
			# Tak pernah diam-diam menyerah: anak yang lahir di dalam benda padat
			# terkunci selamanya, dan nol galat akan memberitahu siapa pun.
			push_warning("[ash64] anak %d: tak menemukan titik lahir bebas" % i)
		k.place(pos)
		k.setup(_chickens)
		# skala 1.6 dulu membesarkan kotak 7x11. Sprite LPC sudah 64px — 1.6 akan
		# membuat anak lebih besar daripada orang dewasa di alun-alun yang sama.
		_kids.append(k)


## Kambing di jembatan + sepeda di gerbang — dua ujung jalan dagang lama.
func _hidup_berpasangan() -> void:
	# DOMBA, bukan "kambing". Sampai 2026-07-20 makhluk ini adalah sprite AYAM yang
	# di-`scale` 3x lalu di-`modulate` abu — paruh dan jenggernya masih terlihat dari
	# kamera main. Sisiran nama berkas atas 111 zip gudang menemukan NOL kambing;
	# domba jantan bertanduk (Stendhal, Kimmo Rundelin) adalah ternak berkaki empat
	# bergaya LPC satu-satunya yang benar-benar ada. Nama variabel ikut dijujurkan.
	var domba := Node2D.new()
	domba.set_script(load("res://scenes/actors/Hewan.gd"))
	domba.setup("domba")
	add_child(domba)
	# ⚠ DOMBA INI SEKARANG LIAR (putusan Direktur, Lapis 2). Ia berdiri di jembatan
	#   di C4 — dan aturan gradien Lapis 1 berbunyi NOL ternak di luar inti. Bukannya
	#   memindahkannya, bacaannya yang dibetulkan: ia memang bukan ternak. Ia domba
	#   yang tak lagi dimiliki siapa pun, berdiri di ujung jalan yang tak lagi
	#   ditempuh. Itu justru kalimat yang lebih kuat daripada tempatnya semula.
	#   Posisinya TAK DIUBAH — ia masih menghalangi jembatan, dan itu masih bekerja.
	domba.liar = true
	domba.wander_radius = 60.0          # ia MENGHALANGI jembatan, bukan berkelana
	domba.place(Vector2(1790, VC.y + 8))

	var bike := ColorRect.new()        # sepeda kayu bersandar di gerbang; masih dipakai
	bike.color = Color(0.55, 0.42, 0.28)
	bike.size = Vector2(30, 16)
	bike.position = Vector2(150, VC.y - 26)
	bike.z_index = int(VC.y)
	bike.add_to_group("ashbrook_life")
	add_child(bike)


## #218 — kontras dari PERBEDAAN, bukan ketiadaan. Jendela lain menyala sore lalu
## PADAM satu per satu (19·20·21) sampai tersisa lampu Merrit.
##
## DAN yang 16px tak bisa: satu jendela gelap karena **halamannya tercoret**, bukan
## karena jam. Toko Otha punya halamannya sendiri (`person_otha_renn`), dan selama
## halaman itu tercoret jendelanya **tak pernah menyala** — siang maupun malam.
## Kota mengabarkan pelupaannya lewat jendela.
func _jendela() -> void:
	# [posisi, jam padam, id halaman (kosong = jendela biasa)]
	for w in [
		[Vector2(608, 992), 19, ""],          # rumah Lyra — masih dihuni
		[Vector2(672, 992), 21, ""],
		[Vector2(1392, 800), 20, ""],         # rumah kosong — padam paling awal terasa
		[Vector2(1424, 800), 19, ""],
		[OTHA_KAKI + Vector2(-16, 0), 21, "person_otha_renn"],  # TOKO OTHA — gelap karena TERLUPA
		[OTHA_KAKI + Vector2(16, 0), 21, "person_otha_renn"],
		# C2 barat: SATU rumah menyala di tengah barisan gelap (koreksi 6). Kegelapan
		# di kedua sisinya baru terbaca sebagai kehilangan kalau ada yang masih menyala
		# di antaranya — deretan yang seluruhnya gelap cuma terbaca sebagai latar.
		[Vector2(460, 650), 19, ""],
		[Vector2(524, 650), 21, ""],
	]:
		var win := Node2D.new()
		win.set_script(load("res://scenes/actors/AshbrookWindow.gd"))
		add_child(win)
		win.place(Vector2(w[0]) + Vector2(0, -96), int(w[1]), String(w[2]))
		win.scale = Vector2(2.0, 2.0)


## #218 PAYOFF PERJALANAN — pemain berjalan menjauh, MENOLEH, dan lampu Merrit masih
## di sana. Kamera mundur supaya lampu masuk layar dari jarak itu.
func _titik_pandang() -> void:
	var zone := Area2D.new()
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(280, 240)
	cs.shape = sh
	zone.add_child(cs)
	zone.global_position = Vector2(1480, VC.y)
	zone.add_to_group("vantage")
	add_child(zone)
	zone.body_entered.connect(func(b):
		if b == _player:
			_zoom_kamera(0.55))
	zone.body_exited.connect(func(b):
		if b == _player:
			_zoom_kamera(ZOOM))


func _zoom_kamera(z: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	for c in _player.get_children():
		if c is Camera2D:
			create_tween().tween_property(c, "zoom", Vector2(z, z), 0.6)


## #118 — monster pertama: anak serigala TERLUKA. Boleh dibantu, diabaikan, atau
## dibunuh. Semuanya sah; dunia tak menghakimi pilihannya.
func _anak_serigala() -> void:
	var m = preload("res://scenes/actors/DungeonMonster.tscn").instantiate()
	add_child(m)
	m.setup(MonsterFactory.make("grey_wolf", 2, 1))
	m.global_position = Vector2(1700, 980)
	m.add_to_group("wolf_pup")


## WHITE STAG (#D-ASH-4) — tanpa pemicu, tanpa penanda, tanpa musik, tanpa quest.
## Muncul jauh & singkat di tepi hutan, lalu hilang. Kalau pemain melihatnya: bagus.
## Kalau tidak: juga bagus. **Legenda tidak wajib ditemukan.**
func _tick_rusa(delta: float) -> void:
	if _stag != null and is_instance_valid(_stag):
		_stag_cd -= delta
		if _stag_cd <= 0.0:
			_stag.queue_free()
			_stag = null
		return
	if _player == null or not is_instance_valid(_player):
		return
	if _player.global_position.y > 460.0:      # hanya di dekat tepi hutan utara
		return
	if randf() > 0.005 * delta * 60.0:
		return
	# Dulu `Image.create(6,10)` — KOTAK PUTIH POLOS diperbesar 3x. Ia tak pernah jadi
	# sprite, dan karena kemunculannya acak & jarang (0,5%/frame, hanya y<460) ia lolos
	# dari tiap tangkap-layar termasuk seluruh audit visual. Sekarang rusa jantan
	# BERTANDUK dari katalog. Putih pucat dipertahankan lewat `modulate`: legendanya
	# adalah rusa PUTIH, dan aset sumbernya cokelat.
	_stag = Sprite2D.new()
	# skrip dimuat lewat `load`, bukan `class_name`: nama kelas global baru terdaftar
	# sesudah proyek dipindai ulang, dan scene ini harus jalan pada impor pertama.
	var H = load("res://scenes/actors/Hewan.gd")
	var kat: Dictionary = H.katalog()
	var hr: Dictionary = kat.get("hewan", {}).get("rusa", {})
	var pr: String = hr.get("sprite", "")
	if pr == "" or not ResourceLoader.exists(pr):
		push_error("[ash64] rusa: sprite katalog TAK ADA (%s) — jalankan _tools/gen_hewan.py" % pr)
		_stag = null
		return
	var atr := AtlasTexture.new()
	atr.atlas = load(pr)
	atr.region = Rect2(0, 0, int(hr.get("fw", 72)), int(hr.get("fh", 52)))
	_stag.texture = atr
	_stag.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_stag.modulate = Color(1.35, 1.35, 1.3)      # dipucatkan -> rusa PUTIH legenda
	_stag.global_position = Vector2(_player.global_position.x + randf_range(-260, 260), 190)
	_stag.z_index = 500
	_stag.modulate.a = 0.85
	add_child(_stag)
	_stag_cd = 2.2


# ------------------------------------------------- pintu & interior
const PROP := preload("res://scenes/world/Ashbrook64Prop.gd")


func _prop(pos: Vector2) -> Node2D:
	var n := Node2D.new()
	n.set_script(PROP)
	add_child(n)
	n.global_position = pos
	return n


## `z` SELALU eksplisit. Tak ada mode-otomatis di sini — justru sentinel
## "negatif berarti hitung dari y" di `_put()` yang sudah sekali menenggelamkan
## perabot kamar ini. Lantai dan dinding hidup di z rendah tetap (0-3); apa pun yang
## bisa dilalui pemain memakai y-sort biasa dan otomatis berada di atasnya.
func _kotak(pos: Vector2, size: Vector2, col: Color, z: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = col
	r.size = size
	r.position = pos
	r.z_index = z
	add_child(r)
	return r


## SATU interior yang bermakna, sisanya pintu yang bercerita.
##
## Kenapa bukan interior untuk semua: rumah kosong generik **melemahkan** dunia.
## Pemain yang membuka lima pintu dan menemukan lima ruangan kosong belajar bahwa
## pintu tak berarti apa-apa. Pintu tertutup yang mengatakan sesuatu justru menjaga
## dunia tetap padat — dan lebih jujur, karena isinya memang belum ditulis.
##
## Merrit dapat ruangan sungguhan karena payoff menuntutnya: ia yang menulis halaman
## Ashbrook (#261) dan ia yang menyalakan lentera itu. Kalau rumahnya tak bisa
## dimasuki, satu-satunya alasan pemain percaya ia "repot" adalah karena kita
## mengatakannya — bukan karena ia melihatnya.
func _pintu_dan_interior() -> void:
	_bangun_kamar_merrit()
	_gerbang_keluar()

	# pintu MASUK — di kaki fasad Merrit, tempat pintunya digambar
	var masuk := _prop(MERRIT_HOUSE + Vector2(0, -8))
	masuk.setup_pindah(INTERIOR + Vector2(150, 170), true, "Masuk rumah Merrit [E]")

	# --- PINTU YANG BERCERITA (nol interior, nol bukti) ---
	# Toko Otha. #269: Otha adalah D3 — tak pernah tercatat. Teksnya tak boleh
	# menyebut namanya; yang tersisa cuma pintu dan musim yang lewat.
	var otha := _prop(OTHA_KAKI + Vector2(0, -8))
	otha.setup_bicara([
		"Terkunci. Debu di ambangnya rata — tak ada yang membukanya sejak dua musim.",
		"Tak ada papan nama. Cuma persegi yang catnya lebih gelap, tempat sesuatu dulu tergantung.",
	], "Pintu toko [E]")

	# Rumah kosong. #269: DITINGGALKAN (D2) — pernah ada penghuninya, dan itu harus
	# terbaca. "Belum jadi" akan membuatnya D3, dan itu kematian yang berbeda.
	var kosong := _prop(Vector2(1408, 792))
	kosong.setup_bicara([
		"Pintunya tak terkunci. Engselnya masih diminyaki — seseorang merawatnya sampai hari terakhir.",
		"Di dalam gelap. Perabotnya masih ada, tertata, menunggu orang yang tak pulang.",
	], "Rumah kosong [E]")

	# Gudang gandum — pintunya, bukan titik-periksanya (yang itu tetap bukti #226)
	var gudang := _prop(GUDANG_KAKI + Vector2(0, -8))
	gudang.setup_bicara([
		"Palang pintunya dilepas sejak lama. Di dalam, empat ekor ayam dan ruang untuk empat ratus karung.",
	], "Pintu gudang [E]")

	# Rumah Lyra — masih dihuni; pintunya menolak dengan sopan
	var lyra := _prop(Vector2(640, 984))
	lyra.setup_bicara([
		"Ada suara di dalam. Seseorang sedang memasak, dan tak menyadari kau berdiri di sini.",
	], "Rumah Lyra [E]")

	# ── PINTU BANGUNAN BARU (C1 balai + 3 rumah C2) ──────────────────────────
	# Fasad tanpa pintu adalah dinding BUTA: pemain mendekat, tak ada apa-apa, dan
	# bangunan berhenti jadi tempat. Interior baru terlalu mahal untuk empat
	# bangunan. Jalan ketiga — yang sudah dipakai toko Otha & rumah kosong:
	# TERTUTUP YANG BERCERITA. Pintunya ada dan bisa ditekan; yang dikembalikannya
	# bukan ruangan, melainkan sebab kenapa ia tertutup.

	# BALAI DESA — satu-satunya bangunan yang MASIH dipakai, dan justru itu yang
	# menyakitkan: ia dipakai oleh jumlah yang salah. Angka 500 sengaja tak disebut
	# sebagai statistik; yang dipakai adalah GEMA, karena gema itu yang dirasakan.
	var balai := _prop(BALAI_KAKI + Vector2(0, -8))
	balai.setup_bicara([
		"Pintunya terbuka. Tak pernah dikunci — tak ada lagi yang perlu dikunci dari siapa.",
		"Empat puluh kursi dirapatkan ke satu sudut, menghadap mimbar. Sisa lantainya kosong,",
		"dan langkahmu kembali kepadamu sebelum kau sempat berhenti berjalan.",
	], "Balai desa [E]")

	# TIGA RUMAH C2 — semuanya gelap, tapi TIGA SEBAB BERBEDA. Kalau ketiganya
	# berkata "ditinggalkan", mereka jadi satu rumah yang disalin tiga kali, dan
	# yang hilang justru bahwa tiap keluarga pergi dengan caranya sendiri.
	var r_tenggara := _prop(Vector2(1120, 1144))
	r_tenggara.setup_bicara([
		"Terkunci dari LUAR. Siapa pun yang terakhir keluar berniat kembali.",
	], "Rumah terkunci [E]")

	var r_selatan := _prop(Vector2(736, 1176))
	r_selatan.setup_bicara([
		"Pintunya menganga. Daun jatuh masuk sampai ke tengah ruangan, bertahun-tahun tebalnya.",
		"Tak ada yang dibawa pergi, dan tak ada pula yang diambil orang. Bahkan pencuri berhenti datang.",
	], "Rumah terbuka [E]")

	var r_timur := _prop(Vector2(1376, 1048))
	r_timur.setup_bicara([
		"Jendelanya dipaku papan dari DALAM. Palunya masih tergeletak di ambang.",
	], "Rumah berpapan [E]")


## JALAN KELUAR (BAGIAN 3) — Ashbrook64 berhenti jadi penjara.
##
## Diletakkan di ujung BARAT jalan dagang lama — jalan yang sudah digambar `_ground()`
## membentang barat→timur. Keluar lewat jalan yang memang menuju ke luar, bukan lewat
## pintu ajaib di tengah rumput.
##
## ⚠ SEMENTARA ia kembali ke MENU, bukan ke Greenvale. Alasannya bukan malas:
## `TravelUI` + `regions.json` adalah alur dunia PERMANEN, dan Direktur menetapkan
## putusan "Ashbrook64 ganti vs dampingi 16px" menunggu playtest. Menyambungkannya
## sekarang berarti menjawab pertanyaan yang belum ditanyakan.
func _gerbang_keluar() -> void:
	# DIPINDAH KE SELATAN — memperbaiki "janji yang diingkari".
	#
	# Dulu ada DUA gerbang, dan yang SALAH yang berfungsi: penanda kecil di tepi
	# BARAT (96, 704) benar-benar mengeluarkan pemain, sementara gerbang selatan —
	# megah, berkarat, berdiri di ujung jalan — nol interaksi. Pemain hampir pasti
	# berjalan ke selatan, menekan E di bawah dua pilar batu, dan tak terjadi apa-apa.
	# Cacat yang sama persis yang dihindari mati-matian di treeline: yang TERLIHAT
	# seperti pintu HARUS jadi pintu.
	#
	# Penanda barat DICABUT, bukan dimatikan — dua gerbang membingungkan. Ia juga
	# memakai `wall_ruin.png` sebagai "batu penjuru aus", padahal audit-mata
	# membuktikan berkas itu PAGAR KAYU UTUH (lpc32/DEPRECATED.md).
	#
	# ⚠ TAPI ITU BUKAN SATU-SATUNYA. Dua pemakaian `wall_ruin.png` lain MASIH ADA dan
	# lebih parah, karena keduanya menopang BUKTI CERITA, bukan hiasan:
	#   :728  "reruntuhan" pendamping `ev_ashbrook_fondasi_rumput`
	#   :731  "batu fondasi berpahat" pendamping `ev_ashbrook_batu_fondasi`
	# Keduanya menggambarkan batu, dan yang tergambar adalah pagar kayu. Tak diganti
	# di sini: mengganti aset pendamping titik-periksa menyentuh jalur payoff, dan itu
	# putusan tersendiri — bukan efek samping perbaikan gerbang. Dilaporkan, dicatat.
	#
	# Ditaruh di UTARA pilar (1288 vs pilar 1298-1326): pemain berdiri DI DEPAN
	# gerbang, bukan di dalam batunya.
	var g := _prop(Vector2(VC.x, float(MAP_H * TILE) - 120.0))
	g.setup_gerbang("Jalan keluar Ashbrook [E]")


## Kamar Merrit — kecil, dan setiap benda di dalamnya menjawab satu pertanyaan:
## kenapa orang ini repot mengingat sebuah kota yang sudah selesai.
func _bangun_kamar_merrit() -> void:
	var o := INTERIOR
	# ⚠ z NEGATIF, dan sengaja. `_put()` menurunkan z dari koordinat-y, dan kamar ini
	# duduk di koordinat NEGATIF (di luar peta) — jadi perabotnya akan mendarat di z
	# sekitar −420 dan tenggelam DI BAWAH lantainya sendiri. Semua benda kamar
	# karena itu diberi z eksplisit, berlapis, dan seluruhnya di bawah 0 supaya
	# pemain (z 0) selalu tergambar di atasnya.
	_kotak(o, Vector2(320, 240), Color(0.17, 0.14, 0.11), 0)                   # lantai
	_kotak(o + Vector2(0, -14), Vector2(320, 14), Color(0.10, 0.08, 0.07), 1)   # dinding
	_kotak(o + Vector2(28, 52), Vector2(40, 34), Color(0.34, 0.19, 0.11), 2)    # perapian

	# Perapian = satu-satunya cahaya, dan ia menyala. `CanvasModulate` menggelapkan
	# seisi scene pada malam WIB; tanpa lampu ini kamarnya jadi kotak hitam.
	var api := PointLight2D.new()
	api.energy = 2.6
	api.texture_scale = 13.0
	api.color = Color(1.0, 0.74, 0.45)
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	api.texture = ImageTexture.create_from_image(img)
	api.global_position = o + Vector2(48, 70)
	add_child(api)

	# isian lembut supaya sudut jauh tak hilang total — tetap redup, tetap satu ruangan
	var isi := PointLight2D.new()
	isi.energy = 1.5
	isi.texture_scale = 26.0
	isi.color = Color(0.95, 0.80, 0.62)
	isi.texture = api.texture
	isi.global_position = o + Vector2(160, 120)
	add_child(isi)

	# Perabot memakai y-sort biasa `_put()` — di ruang positif itu sudah benar, dan
	# pemain (yang juga y-sort, `Player.gd:54`) otomatis lewat di depan/belakangnya.
	_put(P_S + "table_lpc.png", o + Vector2(160, 120))
	_put(P_S + "bench_lpc.png", o + Vector2(120, 156))
	_put(P_S + "barrel_lpc.png", o + Vector2(272, 96))

	# SURAT di meja — yang ia tunggu empat puluh tahun (A3 / companion_11)
	var surat := _prop(o + Vector2(160, 112))
	surat.setup_bicara([
		"Sepucuk surat, dibuka dan dilipat kembali sampai lipatannya menipis.",
		"Tanggalnya empat puluh tahun lalu. Isinya cuma satu kalimat: \"Tunggu aku, jangan pindah.\"",
		"Tak ada nama pengirim. Merrit tak pernah menyebutkannya kepada siapa pun.",
	], "Surat di meja [E]")

	# BOTOL MINYAK — bukti kerja, bukan penjelasan
	_kotak(o + Vector2(232, 150), Vector2(64, 18), Color(0.26, 0.30, 0.28), 3)
	var botol := _prop(o + Vector2(264, 146))
	botol.setup_bicara([
		"Botol minyak lampu, kosong semua, berjajar rapi menurut tahun.",
		"Kau berhenti menghitung di baris ketiga. Ada lebih banyak botol di sini daripada orang di Ashbrook.",
	], "Botol berjajar [E]")

	# pintu KELUAR
	var keluar := _prop(o + Vector2(150, 205))
	keluar.setup_pindah(MERRIT_HOUSE + Vector2(0, 36), false, "Keluar [E]")


# ---------------------------------------------------------------- penduduk
## Enam wajah LPC. Hook siluet berbeda per #231 (uji hitam: reports/preview/siluet231.png).
## 5 NPC berkepribadian + JADWAL (#78/#97) — sama dengan 16px. Ini yang membuat
## kota terasa punya penghuni, bukan patung. Enam wajah statis di bawah TETAP ada:
## mereka tokoh bernama di tempat tetapnya (Merrit di rumahnya, Otha di tokonya).
func _folk_berjadwal() -> void:
	# 0..4 = lima warga BERJADWAL (#97) — persona & dialog utuh, cuma sprite yang naik
	# dari `_charsys` 32px ke LPC 64px. 5..19 = lima belas penghuni latar tanpa persona.
	# Dua puluh wajah dari generator (#276), seed tetap: warga yang sama tiap muat.
	# ⚠ PUSATNYA BUKAN LAGI `VC`. `TownFolk.place()` menebar lima warga berjadwal pada
	#   CINCIN BERJARI-JARI 120 px dari titik yang diberikan — dan dengan `VC`, cincin
	#   itu jatuh persis di atas air mancur. Inilah separuh dari cacat 🔴-4 POTRET
	#   ("air mancur terkubur warga"); separuh lainnya zona latar di bawah ini.
	#   Digeser ke tenggara alun-alun: mereka tetap di C1, tetap di pelataran, tapi
	#   pusat desa tak lagi mereka duduki.
	TownFolk.place(self, "ashbrook", VC + Vector2(60, 120), 0)
	# ZONA BERALASAN. Tiap angka menjawab "kenapa orang ini berdiri di sini?", dan
	# jumlahnya sengaja TIMPANG: alun-alun bukan tempat semua orang berkumpul, ia cuma
	# salah satu tempat. Sebelumnya lima belas orang mengelilingi pusat pada radius
	# tetap — kota jadi satu gerombolan di tengah lapangan kosong.
	#
	# Ashbrook MENGECIL: rumah kosong dapat NOL warga, gudang gandum cuma dua. Yang
	# sepi harus terbaca sepi, dan itu cuma berarti kalau yang ramai terbaca ramai.
	TownFolk.place_latar(self, [
		# ⚠ DI SAMPING pintu, bukan di depannya — dan itu bukan selera.
		#   Versi pertama menaruh dua zona ini di (704,470) dan (1216,552): PERSIS di
		#   atas titik-periksa `ev_ashbrook_gudang_gandum` (704,480) dan
		#   `ev_ashbrook_halloran_200_roti` (1216,560). Warga juga `interactable`, jadi
		#   ia MEREBUT tombol E — pemain menekan E di depan bukti, yang menjawab warga.
		#   `PlayLoop64` melaporkannya sebagai "bukti tak tercatat": rantai payoff PUTUS
		#   di 2 dari 5 titik, dan jalur SENDIRI jadi mustahil. Nol galat muncul; yang
		#   pecah cerita, bukan mesin — dan tak satu pun test suite bisa melihatnya.
		#   ATURAN: zona warga latar TAK BOLEH menyentuh titik-periksa. Beri jarak, atau
		#   kehidupan latar menelan alur utama.
		# ── C1 = 8 latar (+5 berjadwal di atas = 13) ─────────────────────────
		# ⚠ ZONA ALUN-ALUN LAMA DICABUT. `VC + (0,96)` berjari-jari 96 dengan 4 orang:
		#   empat warga tersebar dalam lingkaran yang MEMUAT air mancur, dan dari kamera
		#   main pusat desa jadi kerumunan punggung. Penggantinya dua zona kecil yang
		#   MENGAPIT air mancur — orang berdiri DI SEKITAR pusat, bukan DI ATASnya.
		{"pos": VC + Vector2(-80, 58),  "r": 46.0, "n": 2},   # barat daya pelataran
		{"pos": VC + Vector2(128, 38),  "r": 52.0, "n": 3},   # timur pelataran
		{"pos": VC + Vector2(50, 154),  "r": 48.0, "n": 1},   # mulut selatan, arah gerbang
		{"pos": MERRIT_HOUSE + Vector2(0, 72),   "r": 44.0, "n": 1},   # teras rumah singgah
		{"pos": HALLORAN_KAKI + Vector2(-82, 68), "r": 40.0, "n": 1},  # teras Halloran
		# ── C2 = 6 ───────────────────────────────────────────────────────────
		{"pos": Vector2(560, 728),  "r": 52.0, "n": 2},    # jalan dagang, ujung barat
		{"pos": Vector2(1330, 724), "r": 52.0, "n": 2},    # jalan dagang, ujung timur
		{"pos": Vector2(640, 1060), "r": 44.0, "n": 1},    # rumah Lyra — satu-satunya yang dihuni
		{"pos": Vector2(492, 726),  "r": 40.0, "n": 1},    # rumah C2 yang masih menyala
		# ── C3 = 1 · C4 = 0 ──────────────────────────────────────────────────
		# Satu orang di distrik bekas, dan cuma satu. Nol di C4 disengaja: yang hidup
		# di tepi hanya cahaya yang tak bisa diraih (wisp), dan gradien itu tesisnya.
		{"pos": Vector2(420, 360),  "r": 44.0, "n": 1},
	], 5)
	for c in get_children():
		var sc = c.get_script()
		if sc != null and String(sc.resource_path).contains("Villager"):
			c.add_to_group("ashbrook_life")


func _folk() -> void:
	_folk_berjadwal()
	for spec in [
		["merrit_fane", MERRIT_HOUSE + Vector2(48, 96)],
		["halloran", HALLORAN_KAKI + Vector2(58, 68)],   # di depan penempaannya sendiri
		["old_bram", VC + Vector2(-224, 96)],
		["nyai", VC + Vector2(160, 128)],
		["otha_renn", OTHA_KAKI + Vector2(58, 52)],      # di luar tokonya yang tutup
		["sora", Vector2(672, 1024)],
	]:
		var p := P_C + str(spec[0]) + "_idle.png"
		if not ResourceLoader.exists(p):
			push_warning("[ash64] NPC belum dirakit: %s" % spec[0])
			continue
		var s := Sprite2D.new()
		var at := AtlasTexture.new()
		at.atlas = load(p)
		at.region = Rect2(0, 128, 64, 64)      # baris 2 = hadap bawah (frame_map.json)
		s.texture = at
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.global_position = spec[1]
		s.z_index = int(s.global_position.y)
		add_child(s)


## Langit & lentera mengikuti jam WIB — aturan yang SAMA dengan `Ashbrook.gd`
## (#218). Diulang, bukan diwarisi: dua scene ini sengaja tak berbagi induk sampai
## salah satunya dipensiunkan, dan menyalin 12 baris lebih jujur daripada membuat
## kelas dasar untuk sesuatu yang akan dihapus.
##
## `AETHER_PIN_DAY=1` mematok siang untuk harness tangkap-layar.
func _process(_delta: float) -> void:
	var h := GameClock.wib_hour()
	if h != _last_hour:
		_last_hour = h
		for w in get_tree().get_nodes_in_group("ashbrook_window"):
			w.apply_hour(h)      # desa TERTIDUR satu per satu — dan satu menolak
	_tick_rusa(_delta)
	if OS.get_environment("AETHER_PIN_DAY") == "1":
		return
	if _canvas_mod:
		_canvas_mod.color = GameClock.ambient_color()
	if _lamp:
		# Lentera Merrit menyala siang & malam. Malam hari ia satu-satunya yang menyala.
		_lamp.modulate = Color(1, 1, 1, 1.0 if h >= 17 or h < 6 else 0.75)
	if _beacon:
		var ba := 1.0 if h >= 17 or h < 6 else 0.55
		# Dari dekat beacon MENUTUPI lenteranya (6x6 px, z di atas segalanya, di luar
		# jangkauan Light2D → kotak gelap menempel di kaca). Pelajaran yang sudah
		# dibayar di scene 16px; jangan bayar dua kali.
		if _player and is_instance_valid(_player) 				and _player.global_position.distance_to(_beacon.global_position) < 320.0:
			ba = 0.0
		_beacon.modulate.a = ba
