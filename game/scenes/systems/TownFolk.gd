class_name TownFolk
extends RefCounted
## HUKUM NPC ANEH (E6, Decision Log #78): tiap kota/desa WAJIB punya minimal lima
## NPC berkepribadian — 1 Aneh, 1 Misterius, 1 Lucu, 1 Tragis, 1 Tak-masuk-akal.
## Mereka tidak memberi quest, tidak menjual apa pun, tidak menjelaskan dunia.
## Mereka hanya membuat dunia terasa DIHUNI.
##
## Oddwalker (blueprint "The Strange Ones"): 90% dari mereka memang tidak penting.
## ~10% menyimpan sesuatu — di data ditandai `oddwalker: true`. TIDAK ADA payoff
## sekarang (itu disengaja): hanya benih, agar kelak ada yang bisa tumbuh.

const REQUIRED := ["aneh", "misterius", "lucu", "tragis", "tak_masuk_akal"]

static func personas(town_id: String) -> Array:
	return Db.town_npcs.get(town_id, [])

## Apakah satu kota memenuhi Hukum NPC Aneh?
static func satisfies_law(town_id: String) -> bool:
	var seen := {}
	for p in personas(town_id):
		seen[p.get("archetype", "")] = true
	for a in REQUIRED:
		if not seen.has(a):
			return false
	return true

## Tempatkan kelima persona di sekitar `center` (rute jalan kecil per orang).
##
## `lpc_awal` OPT-IN (#276): kosong = sprite `_charsys` 32px, perilaku lama persis.
## Diisi indeks awal = kelima persona memakai sheet LPC `warga_<NN>` berurutan.
## Greenvale memanggil tanpa argumen itu dan TIDAK berubah — itu inti opt-in.
static func place(host: Node2D, town_id: String, center: Vector2, lpc_awal := -1) -> int:
	var list := personas(town_id)
	var n := 0
	for i in list.size():
		var p: Dictionary = list[i]
		var a := TAU * float(i) / maxf(1.0, float(list.size()))
		# ⚠ JANGKAR BOLEH DITENTUKAN PERSONA. Cincin berjari-jari 120 px benar untuk
		#   warga yang tak punya tempat; ia SALAH untuk warga yang tempatnya bagian
		#   dari ceritanya. Old Bram duduk di bangku alun-alun — "aku ini cuma orang
		#   tua yang punya kursi favorit" — dan menaruhnya di titik cincin yang
		#   kebetulan membatalkan kalimatnya sendiri.
		var anchor := center + Vector2.from_angle(a) * 120.0
		if p.has("anchor"):
			var av: Array = p["anchor"]
			anchor = Vector2(float(av[0]), float(av[1]))
		var wps := [anchor, anchor + Vector2.from_angle(a + 1.2) * 46.0, anchor + Vector2(0, 40)]
		var v := preload("res://scenes/actors/Villager.tscn").instantiate()
		# SEBELUM add_child: `_build()` jalan di dalam `_ready()`.
		# ⚠ WAJAH ASLI kalau persona menyebutnya. Sebelum ini SEMUA warga berpersona
		#   memakai wajah generik `warga_NN`, termasuk yang punya potret buatan tangan
		#   sendiri — jadi "Old Bram" yang bisa diajak bicara berwajah orang asing,
		#   sementara potret Bram yang sesungguhnya berdiri bisu beberapa petak darinya.
		#   Audit menyebutnya "dua Bram berdampingan". Satu berkas, satu orang.
		if p.has("lpc_sheet"):
			v.lpc_sheet = String(p["lpc_sheet"])
		elif lpc_awal >= 0:
			v.lpc_sheet = "warga_%03d" % (lpc_awal + i)
		host.add_child(v)
		v.setup(p.get("name", "Warga"), p.get("config", {}), wps)
		v.set("_home", anchor)        # jangkar jadwal (#97)
		v.set_persona(p)
		v.global_position = wps[0]
		n += 1
	return n


## Penghuni latar TANPA persona & TANPA jadwal — mereka bukan tokoh, mereka KERUMUNAN.
## Sengaja dipisah dari `place()`: warga berjadwal (#97) punya kepribadian dan dialog,
## warga latar cuma menjadikan kota berpenghuni. Mencampur keduanya akan menuntut
## persona untuk dua puluh orang yang tak pernah diajak bicara.
## `zona` = [{pos, r, n}] — TEMPAT BERALASAN, bukan lingkaran di sekitar pusat.
##
## Versi pertama menyebar warga pada radius tetap dari pusat kota. Hasilnya terbaca di
## tangkap-layar: hampir dua puluh orang menumpuk di dalam persegi alun-alun sementara
## seperempat peta kosong melompong. Mereka berdiri di tempat RUMUS menaruh mereka,
## bukan di tempat orang punya ALASAN berada — dan itu terlihat, meski tiap wajahnya
## berbeda.
##
## Zona diberikan oleh SCENE, bukan ditebak di sini: scene yang tahu di mana gudangnya,
## pintunya, jalannya. `TownFolk` tak boleh mengarang geografi kota mana pun — ia
## melayani enam wilayah yang tata letaknya tak saling tahu.
static func place_latar(host: Node2D, zona: Array, awal: int, seed_pos := 20260720) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_pos            # posisi ikut reproducible, bukan cuma wajahnya
	var n := 0
	for z in zona:
		var pos: Vector2 = z.get("pos", Vector2.ZERO)
		var r: float = z.get("r", 60.0)
		for i in int(z.get("n", 1)):
			# sebaran DI DALAM zona, bukan di cincinnya: sqrt() supaya kepadatan rata
			# dan tak menumpuk di tepi luar (cacat versi pertama, dalam bentuk kecil)
			var a := rng.randf_range(0.0, TAU)
			var d := r * sqrt(rng.randf())
			var anchor := pos + Vector2.from_angle(a) * d
			var wps := [anchor, anchor + Vector2.from_angle(rng.randf_range(0.0, TAU))
					* rng.randf_range(24.0, 64.0)]
			var v := preload("res://scenes/actors/Villager.tscn").instantiate()
			v.lpc_sheet = "warga_%03d" % (awal + n)
			v.latar = true          # kerumunan: tanpa dialog, tanpa tombol E
			host.add_child(v)
			v.setup("Warga", {}, wps)
			v.set("_home", anchor)
			v.global_position = anchor
			n += 1
	return n
