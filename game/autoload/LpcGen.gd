extends Node
## LpcGen — merakit karakter LPC 64 px SAAT MAIN, dari lapis yang ikut dikirim.
##
## KENAPA ADA
## 120 warga Ashbrook memakai lembar LPC yang dirakit di Python (`rakit_npc.py`).
## Pemain tidak bisa: kombinasinya BEBAS, jadi tak ada yang bisa dipanggang lebih
## dulu. Berkas ini melakukan pekerjaan yang sama, di dalam game, untuk satu karakter.
##
## `CharGen.gd` (penggambar prosedural 32 px) TIDAK dihapus — ia masih menyuplai
## Villager latar, Cermin Jiwa, dan save lama. Dua sistem hidup berdampingan sampai
## seluruh pemanggilnya pindah, dan itu disengaja: mengganti keduanya sekaligus
## berarti tak punya satu pun jalur yang diketahui benar saat ada yang pecah.
##
## URUTAN LAPIS = URUTAN GAMBAR, dan ia bukan selera:
##   badan → kaki → sepatu → dalaman → torso → kepala → rambut
## Kepala SESUDAH torso (kerah menimpa leher), rambut PALING AKHIR (menimpa batok).
## Urutan yang sama dipakai `assemble.py`; kalau salah satunya berubah, karakter
## pemain dan karakter NPC akan terlihat berbeda tanpa ada yang tahu kenapa.

const DIR := "res://assets/game/sprites/chargen/"
const MANIFES := "res://data/chargen.json"

var data: Dictionary = {}
var _cache: Dictionary = {}


func _ready() -> void:
	var f := FileAccess.open(MANIFES, FileAccess.READ)
	if f == null:
		push_warning("[lpcgen] %s tak ada — pembuat karakter LPC nonaktif" % MANIFES)
		return
	var j = JSON.parse_string(f.get_as_text())
	if typeof(j) == TYPE_DICTIONARY:
		data = j


func siap() -> bool:
	return not data.is_empty()


# ───────────────────────────────────────────────────────── pilihan untuk UI
func builds() -> Array:
	var b: Array = data.get("build", {}).keys()
	b.sort()
	return b


func kulit(build: String) -> Array:
	return data.get("build", {}).get(build, {}).get("kulit", [])


func rambut(build: String) -> Array:
	var uk := String(data.get("build", {}).get(build, {}).get("rambut", "dewasa"))
	return data.get("rambut", {}).get(uk, [])


## Pilihan pakaian slot ini untuk build ini. TIAP entri `[garmen, warna]`.
## Kosong bukan galat — `child` memang cuma punya tiga torso, dan UI harus
## menampilkan tiga, bukan berpura-pura punya dua puluh.
func pakaian(build: String, slot: String) -> Array:
	return data.get("build", {}).get(build, {}).get("pakaian", {}).get(slot, [])


## Config yang PASTI sah untuk build ini. Dipakai saat build diganti: pilihan lama
## bisa jadi tak ada di build baru, dan menyisakannya menghasilkan lapis yang gagal
## dimuat — cacat yang muncul sebagai "bajunya hilang", bukan sebagai galat.
func rapikan(cfg: Dictionary) -> Dictionary:
	var b := String(cfg.get("build", "male"))
	if not data.get("build", {}).has(b):
		b = "male"
	var out := {"build": b}
	var k: Array = kulit(b)
	out["kulit"] = cfg.get("kulit", "") if cfg.get("kulit", "") in k else (k[0] if k else "")
	var r: Array = rambut(b)
	out["rambut"] = cfg.get("rambut", "") if cfg.get("rambut", "") in r else (r[0] if r else "")
	for slot in ["torso", "legs", "feet"]:
		var opsi: Array = pakaian(b, slot)
		var punya = cfg.get(slot, null)
		var sah := false
		for o in opsi:
			if punya is Array and punya.size() == 2 and o[0] == punya[0] and o[1] == punya[1]:
				sah = true
				break
		out[slot] = punya if sah else (opsi[0] if not opsi.is_empty() else null)
	return out


func acak(cfg_awal := {}) -> Dictionary:
	var b: Array = builds()
	var cfg := {"build": b[randi() % b.size()]}
	var bb := String(cfg["build"])
	var k: Array = kulit(bb)
	var r: Array = rambut(bb)
	cfg["kulit"] = k[randi() % k.size()] if not k.is_empty() else ""
	cfg["rambut"] = r[randi() % r.size()] if not r.is_empty() else ""
	for slot in ["torso", "legs", "feet"]:
		var o: Array = pakaian(bb, slot)
		cfg[slot] = o[randi() % o.size()] if not o.is_empty() else null
	return cfg


# ───────────────────────────────────────────────────────────────── perakit
func _lapis(cfg: Dictionary) -> Array:
	var b := String(cfg.get("build", "male"))
	var kul := String(cfg.get("kulit", ""))
	var kepala := String(data.get("build", {}).get(b, {}).get("kepala", b))
	var out: Array = []
	out.append("body_%s_%s.png" % [b, kul])
	# DALAMAN sebelum torso. `overalls`/`suspenders` tali dan kain depan — tanpa
	# kemeja di bawahnya pemakainya berdada telanjang. Aturannya datang dari
	# `chargen.json`, bukan ditulis di sini: menambah garmen semacam ini nanti tak
	# boleh menuntut menyentuh kode.
	var d: Dictionary = data.get("dalaman", {})
	var tg = cfg.get("torso", null)
	if tg is Array and tg.size() == 2 and String(tg[0]) in (d.get("butuh", []) as Array):
		var pilih := String(d.get("pakai_garmen", "longsleeve"))
		for o in pakaian(b, "torso"):
			if String(o[0]) == pilih:
				out.append("torso_%s_%s.png" % [o[0], o[1]])
				break
	for slot in ["legs", "feet", "torso"]:
		var g = cfg.get(slot, null)
		if g is Array and g.size() == 2:
			out.append("%s_%s_%s.png" % [slot, g[0], g[1]])
	out.append("head_%s_%s.png" % [kepala, kul])
	var r := String(cfg.get("rambut", ""))
	if r != "":
		out.append("hair_%s.png" % r)
	return out


## Lembar penuh 832x2944. Di-cache per-config: pembuat karakter memanggil ini tiap
## kali tombol ditekan, dan merakit ulang sembilan lembar 832x2944 tiap penekanan
## membuat UI-nya tersendat.
func sheet(cfg: Dictionary) -> ImageTexture:
	var kunci := JSON.stringify(cfg)
	if _cache.has(kunci):
		return _cache[kunci]
	var dasar: Image = null
	for nama in _lapis(cfg):
		var p: String = DIR + nama
		if not ResourceLoader.exists(p):
			# BERTERIAK, jangan diam. Lapis yang hilang tampil sebagai "bajunya
			# tidak muncul" — gejala yang mustahil dilacak tanpa baris ini.
			push_warning("[lpcgen] lapis hilang: %s" % p)
			continue
		var tex: Texture2D = load(p)
		var img := tex.get_image()
		if img == null:
			continue
		img.convert(Image.FORMAT_RGBA8)
		if dasar == null:
			dasar = Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
		dasar.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
	if dasar == null:
		return null
	var t := ImageTexture.create_from_image(dasar)
	_cache[kunci] = t
	return t


## Satu petak 64x64 untuk pratinjau. `arah` mengikuti `frame_map.json`
## dir_order [up, left, down, right]; `walk` mulai di baris 8.
func petak(cfg: Dictionary, arah: int, frame := 1) -> ImageTexture:
	var s := sheet(cfg)
	if s == null:
		return null
	var img := s.get_image()
	var C := 64
	var baris := 8 + clampi(arah, 0, 3)
	var sel := img.get_region(Rect2i(frame * C, baris * C, C, C))
	return ImageTexture.create_from_image(sel)


## SpriteFrames siap pakai — `walk_up/left/down/right` + `idle_*`.
## Bentuk keluarannya sengaja SAMA dengan `CharGen.sprite_frames()` supaya pemanggil
## lama (pratinjau pembuat karakter, Player) bisa berpindah tanpa menyentuh apa pun
## selain satu baris. Dua sistem yang berbeda bentuk keluarannya akan menuntut tiap
## pemanggil tahu ia sedang bicara dengan yang mana.
func sprite_frames(cfg: Dictionary) -> SpriteFrames:
	var s := sheet(cfg)
	if s == null:
		return null
	var img := s.get_image()
	var C := 64
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	var arah := ["up", "left", "down", "right"]
	for i in arah.size():
		var baris: int = 8 + i
		for nama in ["walk_" + arah[i], "idle_" + arah[i]]:
			sf.add_animation(nama)
			sf.set_animation_speed(nama, 8.0)
			sf.set_animation_loop(nama, true)
		# walk = frame 1..8; idle = frame 0 (pose berdiri LPC)
		for f in range(1, 9):
			var r := Rect2i(f * C, baris * C, C, C)
			if r.position.x + C <= img.get_width():
				sf.add_frame("walk_" + arah[i],
					ImageTexture.create_from_image(img.get_region(r)))
		sf.add_frame("idle_" + arah[i],
			ImageTexture.create_from_image(img.get_region(Rect2i(0, baris * C, C, C))))
	return sf
