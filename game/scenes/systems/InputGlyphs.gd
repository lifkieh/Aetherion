class_name InputGlyphs
extends RefCounted
## GLYPH TOMBOL (v0.4.4, Decision Log #99) — aset Kenney input-prompts.
## Glyph mengikuti perangkat yang BENAR-BENAR dipakai pemain terakhir kali
## (Keybinds.last_device): pegang gamepad → semua petunjuk berubah jadi tombol
## gamepad, tanpa pemain perlu mengatur apa pun.

const DIR := "res://assets/game/ui/prompts/"

const KB := {
	"move_up": "kb_w.png", "move_down": "kb_s.png", "move_left": "kb_a.png", "move_right": "kb_d.png",
	"interact": "kb_e.png", "toggle_inventory": "kb_i.png", "world_map": "kb_m.png",
	"plant_sapling": "kb_g.png", "pause_menu": "kb_esc.png", "dodge": "kb_space.png",
	"attack": "mouse_left.png", "cast": "mouse_right.png",
	"slot_1": "kb_1.png", "slot_2": "kb_2.png", "slot_3": "kb_3.png",
	"slot_4": "kb_4.png", "slot_5": "kb_5.png", "tame": "kb_t.png",
}
const PAD := {
	"interact": "pad_a.png", "attack": "pad_x.png", "dodge": "pad_b.png",
	"toggle_inventory": "pad_y.png", "world_map": "pad_start.png", "pause_menu": "pad_start.png",
	"plant_sapling": "pad_lb.png", "cast": "pad_rt.png",
	"slot_5": "pad_rb.png",
}

static func using_pad() -> bool:
	return Keybinds.last_device == "gamepad"

## Path glyph untuk sebuah aksi ("" bila tak ada).
static func path_for(action: String) -> String:
	var f: String = ""
	if using_pad():
		f = PAD.get(action, "")
	if f == "":
		f = KB.get(action, "")
	if f == "":
		return ""
	var p := DIR + f
	return p if ResourceLoader.exists(p) else ""

## TextureRect siap pakai (24x24). null bila glyph tak ada.
static func icon(action: String, size: int = 22) -> TextureRect:
	var p := path_for(action)
	if p == "":
		return null
	var tr := TextureRect.new()
	tr.texture = load(p)
	tr.custom_minimum_size = Vector2(size, size)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return tr
