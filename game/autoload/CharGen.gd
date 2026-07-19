extends Node
## CharGen (Aetherion Character System v2) — GDScript port of gen_charsys_v2.py's
## compose()/make_sheet(). Builds a 96x128 (3 frames x 4 dirs, 32px) character sheet
## as an ImageTexture from a modular config (per-part race + skin + hair + outfit).
## Cached per config.
##
## KANON #254 (2026-07-19) — **LPC = SUMBER TUNGGAL, karakter DAN dunia. AKTIF.**
## #253 (tetap 16px) **DICABUT**. #250 (LPC sumber tunggal) **DIPULIHKAN**.
## #232 (dunia tak boleh SA) **DICABUT** — seluruh aset kini boleh publik/CC-BY-SA.
##
## `_charsys` berstatus **PENSIUN, BUKAN DIHAPUS** — ia masih menyuplai SELURUH karakter
## yang hidup di dunia hari ini (pemain · warga · 8 jenis NPC · pratinjau · 8 assertion test).
## Jangan hapus sebelum penggantinya benar-benar jalan. Daftar migrasi + urutan aman:
## `reports/MIGRASI_CHARSYS.md`.
##
## ⚠ CATATAN SKALA yang mengubah arti "#254 64px": **tak ada tileset LPC 64px.**
## Standar LPC = **ubin dunia 32×32** + **frame karakter 64×64**. Jadi target sesungguhnya
## bukan "semua 64", melainkan **petak 32px + karakter berframe 64px** — tampilan LPC kanonik.
## Bukti visual: `reports/preview/bukti254_lpc_dunia.png` · scene `world/Ashbrook64.tscn`.
##
## Pipeline aktif: `_tools/lpc_assembler/assemble.py` (+ `characters/*.json`, ter-commit #251).

const OUTLINE := Color8(36, 31, 54)
const WHITE := Color(1, 1, 1)
const CW := 32
const CH := 32

# race skin: [base, shadow, highlight]
var RACE_SKIN := {
	"human":     ["#f5c9a2", "#c98a5c", "#ffe4c8"],
	"human2":    ["#c98a5c", "#a5713f", "#e0b088"],
	"wolfkin":   ["#a5713f", "#6b4226", "#c98a5c"],
	"lizardkin": ["#4fa352", "#2e6b3f", "#8fd46a"],
	"candyfolk": ["#f78fc8", "#d95fa4", "#ffc2e2"],
	"frostkin":  ["#6fb4d9", "#3a6fa0", "#b8e4f2"],
	"undead":    ["#a89fc4", "#6f6690", "#e8e2f4"],
}
var RACE_FEATURES := {
	"human": [], "human2": [],
	"wolfkin": ["ears_wolf", "muzzle", "tail_wolf"],
	"lizardkin": ["crest", "tail_lizard", "scales"],
	"candyfolk": ["sprinkles", "gum_hair"],
	"frostkin": ["horns_ice"],
	"undead": ["ribs", "hollow_eyes"],
}
const RACES := ["human", "human2", "wolfkin", "lizardkin", "candyfolk", "frostkin", "undead"]
const HAIR_STYLES := ["short", "long", "spiky", "mohawk", "bun", "none"]

var _cache := {}

func races() -> Array: return RACES
func hair_styles() -> Array: return HAIR_STYLES

# --- public: build (and cache) a full directional sheet texture -----------------

func sheet_texture(config: Dictionary) -> ImageTexture:
	var key := _key(config)
	if _cache.has(key):
		return _cache[key]
	var tex := ImageTexture.create_from_image(_make_sheet(config))
	_cache[key] = tex
	return tex

func sheet_image(config: Dictionary) -> Image:
	return _make_sheet(config)

func _key(c: Dictionary) -> String:
	return "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s" % [
		c.get("head_race", "human"), c.get("torso_race", "human"), c.get("legs_race", "human"),
		c.get("hair", "short"), c.get("hair_color", "#241f36"), c.get("shirt", ""), c.get("pants", ""),
		c.get("head_skin", ""), c.get("torso_skin", ""), c.get("legs_skin", "")]

# --- pixel helpers --------------------------------------------------------------

func _p(img: Image, x: int, y: int, c) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, _col(c))

func _r(img: Image, a: int, b: int, cx: int, dy: int, c) -> void:
	var col := _col(c)
	for y in range(b, dy + 1):
		for x in range(a, cx + 1):
			if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, col)

func _col(c) -> Color:
	if c is Color:
		return c
	return Color.html(c)

func _skin(race: String, override_hex: String) -> Array:
	if override_hex != "":
		var b := Color.html(override_hex)
		return [b, b.darkened(0.32), b.lightened(0.34)]
	var s: Array = RACE_SKIN.get(race, RACE_SKIN["human"])
	return [Color.html(s[0]), Color.html(s[1]), Color.html(s[2])]

# --- PART: legs (y 18..27) ------------------------------------------------------

func _draw_legs(img: Image, race: String, frame: int, skin: Array, pants: String) -> void:
	var base: Color = skin[0]; var sh: Color = skin[1]; var hi: Color = skin[2]
	var col: Color = Color.html(pants) if pants != "" else base
	var csh: Color = sh if pants == "" else Color.html(pants)
	var l := -1 if frame == 0 else (1 if frame == 2 else 0)
	var rr := -l
	_r(img, 6, 18, 8, 18, "#241f36")
	if race == "lizardkin" or race == "wolfkin":
		_r(img, 5, 19, 7, 22 + l, col); _p(img, 5, 22 + l, csh)
		_r(img, 8, 19, 10, 22 + rr, col); _p(img, 10, 22 + rr, csh)
		_r(img, 5, 23 + l, 6, 24 + l, csh); _r(img, 9, 23 + rr, 10, 24 + rr, csh)
		_r(img, 4, 25 + l, 7, 25 + l, sh); _r(img, 8, 25 + rr, 11, 25 + rr, sh)
		if race == "lizardkin":
			_p(img, 4, 25 + l, hi); _p(img, 11, 25 + rr, hi)
	else:
		_r(img, 5, 19, 7, 24 + l, col); _r(img, 5, 19, 5, 24 + l, csh)
		_r(img, 8, 19, 10, 24 + rr, col); _r(img, 10, 19, 10, 24 + rr, csh)
		var shoe: Color = Color8(36, 31, 54) if race != "undead" else sh
		_r(img, 5, 25 + l, 7, 25 + l, shoe); _r(img, 8, 25 + rr, 10, 25 + rr, shoe)
		if race == "undead":
			_p(img, 6, 21 + l, hi); _p(img, 9, 22 + rr, hi)

# --- PART: torso + arms (y 9..18) -----------------------------------------------

func _draw_torso(img: Image, race: String, frame: int, direction: String, skin: Array, shirt: String) -> void:
	var base: Color = skin[0]; var sh: Color = skin[1]; var hi: Color = skin[2]
	var col: Color = Color.html(shirt) if shirt != "" else base
	var csh: Color = sh
	var l := -1 if frame == 0 else (1 if frame == 2 else 0)
	var rr := -l
	var feats: Array = RACE_FEATURES.get(race, [])
	_r(img, 4, 10, 11, 18, col)
	_r(img, 4, 10, 4, 18, csh); _r(img, 4, 16, 11, 18, csh)
	_r(img, 5, 10, 10, 10, hi if shirt == "" else col)
	if "ribs" in feats and shirt == "":
		for y in [12, 14, 16]: _r(img, 6, y, 9, y, hi)
	if "scales" in feats and shirt == "":
		for pt in [Vector2i(6,12), Vector2i(9,13), Vector2i(7,15), Vector2i(10,16)]: _p(img, pt.x, pt.y, hi)
	if "sprinkles" in feats:
		_p(img, 6, 12, "#f5e042"); _p(img, 9, 14, "#6fb4d9"); _p(img, 7, 16, "#fff0f8")
	if direction == "down" or direction == "up":
		_r(img, 3, 11 + max(0, l), 3, 15 + l, base); _p(img, 3, 16 + l, sh)
		_r(img, 12, 11 + max(0, rr), 12, 15 + rr, base); _p(img, 12, 16 + rr, sh)
	else:
		var ax := 3 if direction == "left" else 12
		_r(img, ax, 11, ax, 15 + l, base); _p(img, ax, 16 + l, sh)

# --- PART: head (y 0..9) --------------------------------------------------------

func _draw_head(img: Image, race: String, direction: String, skin: Array, hair: String, hair_color: String) -> void:
	var base: Color = skin[0]; var sh: Color = skin[1]; var hi: Color = skin[2]
	var hc: Color = Color.html(hair_color)
	_r(img, 4, 2, 11, 9, base)
	_r(img, 4, 8, 11, 9, sh)
	_r(img, 5, 2, 10, 2, hi)
	var f: Array = RACE_FEATURES.get(race, [])
	if direction == "down":
		if "hollow_eyes" in f:
			_r(img, 5, 5, 6, 6, OUTLINE); _r(img, 9, 5, 10, 6, OUTLINE)
		else:
			_p(img, 6, 5, OUTLINE); _p(img, 9, 5, OUTLINE)
			_p(img, 6, 4, WHITE); _p(img, 9, 4, WHITE)
		if "muzzle" in f:
			_r(img, 6, 6, 9, 8, hi); _p(img, 7, 6, OUTLINE); _p(img, 8, 6, OUTLINE)
		elif not ("crest" in f):
			_p(img, 7, 7, sh)
	elif direction == "left" or direction == "right":
		_p(img, 6, 5, OUTLINE); _p(img, 6, 4, WHITE)
		if "muzzle" in f or "crest" in f:
			_r(img, 3, 6, 4, 8, base); _p(img, 3, 6, OUTLINE)
		_r(img, 11, 2, 11, 8, sh)
	if "ears_wolf" in f:
		for x in [4, 10]:
			_p(img, x, 1, base); _p(img, x, 0, base); _p(img, x + 1, 1, sh)
	if "crest" in f:
		for x in [5, 7, 9]: _r(img, x, 0, x, 1, sh)
	if "horns_ice" in f:
		_p(img, 4, 0, "#b8e4f2"); _p(img, 4, 1, "#eefaff"); _p(img, 11, 0, "#b8e4f2"); _p(img, 11, 1, "#eefaff")
	if "gum_hair" in f:
		_r(img, 3, 0, 12, 3, hc); _r(img, 3, 3, 4, 5, hc); _r(img, 11, 3, 12, 5, hc)
		_p(img, 5, 1, "#fff0f8"); _p(img, 9, 2, "#fff0f8")
	elif hair == "short":
		_r(img, 4, 1, 11, 3, hc); _p(img, 4, 4, hc); _p(img, 11, 4, hc)
	elif hair == "long":
		_r(img, 4, 1, 11, 3, hc); _r(img, 3, 2, 3, 11, hc); _r(img, 12, 2, 12, 11, hc)
	elif hair == "spiky":
		for x in [4, 6, 8, 10]: _r(img, x, 0, x, 2, hc)
		_r(img, 4, 2, 11, 3, hc)
	elif hair == "mohawk":
		_r(img, 7, 0, 8, 3, hc); _r(img, 4, 2, 11, 3, hc)
	elif hair == "bun":
		_r(img, 4, 1, 11, 3, hc); _r(img, 6, 0, 9, 1, hc)
	if direction == "up":
		var has_hair: bool = (hair != "" and hair != "none") or ("gum_hair" in f)
		_r(img, 4, 2, 11, 8, hc if has_hair else sh)

# --- tail (back layer) ----------------------------------------------------------

func _draw_tail(img: Image, race: String, direction: String, frame: int, skin: Array) -> void:
	var base: Color = skin[0]; var hi: Color = skin[2]
	var f: Array = RACE_FEATURES.get(race, [])
	if "tail_wolf" in f:
		if direction == "up":
			_r(img, 7, 18, 8, 22, base); _p(img, 7, 23, hi)
		elif direction == "left" or direction == "right":
			var x0 := 12 if direction == "left" else 2
			var x1 := 13 if direction == "left" else 3
			_r(img, x0, 17, x1, 18, base)
			_p(img, 14 if direction == "left" else 1, 16, hi)
	if "tail_lizard" in f:
		if direction == "up":
			_r(img, 7, 18, 8, 24, base); _r(img, 8, 24, 9, 25, skin[1])
		elif direction == "left" or direction == "right":
			var xs0 := 12 if direction == "left" else 1
			var xs1 := 14 if direction == "left" else 3
			_r(img, xs0, 18, xs1, 19, base)
			_p(img, xs1 if direction == "left" else xs0, 20, skin[1])

# --- compose one 16x28 sprite ---------------------------------------------------

func _compose(config: Dictionary, direction: String, frame: int) -> Image:
	var img := Image.create(16, 28, false, Image.FORMAT_RGBA8)
	var head_r: String = config.get("head_race", "human")
	var torso_r: String = config.get("torso_race", "human")
	var legs_r: String = config.get("legs_race", "human")
	var head_s := _skin(head_r, config.get("head_skin", ""))
	var torso_s := _skin(torso_r, config.get("torso_skin", ""))
	var legs_s := _skin(legs_r, config.get("legs_skin", ""))
	_draw_tail(img, torso_r, direction, frame, torso_s)
	_draw_legs(img, legs_r, frame, legs_s, config.get("pants", ""))
	_draw_torso(img, torso_r, frame, direction, torso_s, config.get("shirt", ""))
	_draw_head(img, head_r, direction, head_s, config.get("hair", "short"), config.get("hair_color", "#241f36"))
	if direction == "right":
		img.flip_x()
	return img

func _outline(src: Image) -> Image:
	var w := src.get_width(); var h := src.get_height()
	var out := Image.create(w + 2, h + 2, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			if src.get_pixel(x, y).a > 0.4:
				for off in [Vector2i(0, 1), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 2)]:
					out.set_pixel(x + off.x, y + off.y, OUTLINE)
	for y in range(h):
		for x in range(w):
			var c := src.get_pixel(x, y)
			if c.a > 0.0:
				out.set_pixel(x + 1, y + 1, c)
	return out

func _make_sheet(config: Dictionary) -> Image:
	var sheet := Image.create(CW * 3, CH * 4, false, Image.FORMAT_RGBA8)
	var dirs := ["down", "left", "right", "up"]
	for r in range(4):
		for fr in range(3):
			var spr := _outline(_compose(config, dirs[r], fr))
			var ox := (CW - spr.get_width()) / 2
			var oy := CH - spr.get_height() - 1
			sheet.blend_rect(spr, Rect2i(0, 0, spr.get_width(), spr.get_height()), Vector2i(fr * CW + ox, r * CH + oy))
	return sheet

# ══════════════════════════════════════════════════════════════════════════════
# JALUR LPC (#254) — TITIK CEKIK TUNGGAL
# ══════════════════════════════════════════════════════════════════════════════
#
# Seluruh karakter dunia lahir dari `sprite_frames()` / `sheet_texture()`:
#   Player.gd:42 · Villager.gd:51 · Interactable.gd:153 · CharacterCreator.gd:188
# Maka satu cabang di sini memindahkan SELURUH jalur pemain ke LPC sekaligus —
# tanpa menyentuh satu pun scene.
#
# Aktif bila config punya kunci "lpc" berisi id tokoh yang sudah dirakit
# `_tools/lpc_assembler/assemble.py` (#240: script ter-commit).
# Bila lembarnya tak ada → JATUH KEMBALI ke _charsys. `_charsys` TIDAK dihapus
# sampai LPC terbukti di jalur nyata (perintah Direktur).
#
# Perbedaan bentuk yang ditangani cabang ini:
#   sel     : _charsys 32px  →  LPC 64px
#   frame   : _charsys 3/baris → LPC walk 8/baris (idle = lembar terpisah, 1 frame)
#   urutan  : _charsys [down,left,right,up] → LPC [up,left,down,right] (frame_map.json)
const LPC_CELL := 64
const LPC_DIR_ROW := {"up": 0, "left": 1, "down": 2, "right": 3}
const LPC_DIR := "res://assets/game/sprites/characters/"

func _lpc_id(config: Dictionary) -> String:
	var id: String = str(config.get("lpc", ""))
	if id == "":
		return ""
	return id if ResourceLoader.exists(LPC_DIR + id + "_walk.png") else ""


func _lpc_atlas(tex: Texture2D, col: int, dir: String) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(col * LPC_CELL, int(LPC_DIR_ROW[dir]) * LPC_CELL, LPC_CELL, LPC_CELL)
	return at


func _lpc_frames(id: String, fps: float) -> SpriteFrames:
	var walk: Texture2D = load(LPC_DIR + id + "_walk.png")
	var idle_path := LPC_DIR + id + "_idle.png"
	var idle: Texture2D = load(idle_path) if ResourceLoader.exists(idle_path) else walk
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for dir in ["down", "left", "right", "up"]:
		sf.add_animation("walk_" + dir)
		sf.set_animation_speed("walk_" + dir, fps)
		sf.set_animation_loop("walk_" + dir, true)
		for fr in range(8):                      # LPC walk = 8 frame per arah
			sf.add_frame("walk_" + dir, _lpc_atlas(walk, fr, dir))
		# idle: lembar 64x256 (1 kolom x 4 arah)
		sf.add_animation("idle_" + dir)
		sf.set_animation_speed("idle_" + dir, 2.0)
		sf.add_frame("idle_" + dir, _lpc_atlas(idle, 0, dir))
		# serang: pinjam dua frame walk (slash LPC = ronde berikutnya)
		sf.add_animation("attack_" + dir)
		sf.set_animation_speed("attack_" + dir, 14.0)
		sf.set_animation_loop("attack_" + dir, false)
		sf.add_frame("attack_" + dir, _lpc_atlas(walk, 2, dir))
		sf.add_frame("attack_" + dir, _lpc_atlas(walk, 6, dir))
	return sf


## Build a SpriteFrames from a config: walk_<dir> (0-1-2-1) + idle_<dir> (frame 1).
func sprite_frames(config: Dictionary, fps: float = 8.0) -> SpriteFrames:
	var lpc := _lpc_id(config)
	if lpc != "":
		return _lpc_frames(lpc, fps)
	var tex := sheet_texture(config)
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	var dirs := ["down", "left", "right", "up"]
	for r in range(4):
		var dir: String = dirs[r]
		sf.add_animation("walk_" + dir); sf.set_animation_speed("walk_" + dir, fps); sf.set_animation_loop("walk_" + dir, true)
		for fr in [0, 1, 2, 1]:
			sf.add_frame("walk_" + dir, _atlas(tex, fr, r))
		sf.add_animation("idle_" + dir); sf.set_animation_speed("idle_" + dir, 2.0)
		sf.add_frame("idle_" + dir, _atlas(tex, 1, r))
		# 2-frame attack swing (windup pose -> strike pose), non-looping
		sf.add_animation("attack_" + dir); sf.set_animation_speed("attack_" + dir, 14.0); sf.set_animation_loop("attack_" + dir, false)
		sf.add_frame("attack_" + dir, _atlas(tex, 0, r))
		sf.add_frame("attack_" + dir, _atlas(tex, 2, r))
	return sf

func _atlas(tex: Texture2D, col: int, row: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(col * CW, row * CH, CW, CH)
	return at

## The default starter look (human).
## Kunci `lpc` mengaktifkan jalur LPC (#254). Kunci _charsys DIPERTAHANKAN sebagai
## cadangan: bila lembar LPC hilang, `_lpc_id()` mengembalikan "" dan sistem lama
## dipakai tanpa error. `_charsys` tidak dihapus sampai LPC terbukti di jalur nyata.
func default_config() -> Dictionary:
	return {"head_race": "human", "torso_race": "human", "legs_race": "human",
		"hair": "short", "hair_color": "#6b4226", "shirt": "#2e6b3f", "pants": "#453d5c",
		"lpc": "player_default"}
