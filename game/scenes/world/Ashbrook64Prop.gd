extends Node2D
## Prop yang bisa ditekan E di Ashbrook64 — untuk hal-hal yang BUKAN bukti.
##
## `Interactable.tscn` sudah menangani titik-periksa (`kind = "examine"`), tapi ia
## mengikat teks ke `evidence_id`: tanpa bukti, ia diam. Pintu yang bercerita dan
## gerbang keluar tak boleh jadi bukti — memasukkannya ke `Evidence` akan mengubah
## jumlah jenis yang pemain bawa, dan itu langsung mengubah `loss` halaman (#226 #3).
##
## Maka: node kecil sendiri. Ia masuk grup `interactable` supaya `WorldController`
## menemukannya lewat tombol E yang sama, tapi ia **tak pernah menyentuh Evidence**.
##
## ⛔ D-3 berlaku: nol penanda "!", nol ikon, nol banner. Labelnya sama biasa dengan
## titik-periksa lain — pemain yang tak menekan E tak pernah tahu ada apa.

enum Mode { BICARA, GERBANG, MASUK, KELUAR }

const NEAR := 72.0

var mode: int = Mode.BICARA
var lines: Array = []                 # untuk BICARA
var speaker := ""
var teleport_to := Vector2.ZERO       # untuk MASUK/KELUAR
var label_text := "Periksa [E]"

var _label: Label
var _cd := 0.0


## Label disetel lewat sini, bukan hanya di _ready(). Node ini dibuat dengan
## add_child() lalu di-setup SESUDAHNYA, jadi _ready() sudah jalan duluan dengan
## teks bawaan — tanpa ini setiap pintu bercerita berlabel Periksa [E] yang sama.
func _pasang_label(t: String) -> void:
	label_text = t
	if _label:
		_label.text = t


func setup_bicara(txt, lbl := "Periksa [E]", who := "") -> void:
	mode = Mode.BICARA
	lines = txt if txt is Array else [txt]
	_pasang_label(lbl)
	speaker = who


func setup_gerbang(lbl := "Jalan keluar Ashbrook [E]") -> void:
	mode = Mode.GERBANG
	_pasang_label(lbl)


func setup_pindah(target: Vector2, masuk: bool, lbl: String) -> void:
	mode = Mode.MASUK if masuk else Mode.KELUAR
	teleport_to = target
	_pasang_label(lbl)


func _ready() -> void:
	add_to_group("interactable")
	_label = Label.new()
	_label.text = label_text
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("outline_size", 4)
	_label.position = Vector2(-40, -34)
	_label.custom_minimum_size = Vector2(80, 0)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.visible = false
	add_child(_label)


func _process(delta: float) -> void:
	_cd -= delta
	if _cd > 0.0:
		return
	_cd = 0.15
	z_index = int(global_position.y)
	var p := get_tree().get_first_node_in_group("player")
	if p and _label:
		_label.visible = global_position.distance_to(p.global_position) < NEAR


func interact() -> void:
	if Stage.is_busy():
		return
	match mode:
		Mode.BICARA:
			await Stage.say(lines, speaker)
		Mode.GERBANG:
			# ⚠ SEMENTARA — kembali ke menu, BUKAN ke Greenvale.
			# Alur dunia permanen (Ashbrook64 ganti vs dampingi 16px) belum diputus
			# Direktur, dan `TravelUI`/`regions.json` akan mengukuhkannya lebih cepat
			# daripada rencana. Yang penting hari ini cuma satu: Ashbrook64 berhenti
			# jadi penjara. Ganti ke gerbang dunia sungguhan setelah playtest.
			await Stage.say("Jalan dagang lama membentang ke barat. Kau bisa pergi kapan saja.")
			Stage.go_to_scene("res://scenes/ui/MainMenu.tscn")
		Mode.MASUK, Mode.KELUAR:
			var p := get_tree().get_first_node_in_group("player")
			if p:
				p.global_position = teleport_to
