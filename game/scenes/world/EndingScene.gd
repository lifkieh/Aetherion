extends Node2D
## LIMA ENDING (#304 · kanon #134/D2 · STORY_SPINE §6) — layar penutup era.
## Hukum yang dipegang: TIDAK ADA ending sempurna · Nirnama TIDAK mati ·
## Final Silence = dunia LUPA, bukan dunia berakhir (#176, LAW OF ERAS #75b
## utuh) · D-4: epilog bicara KUALITATIF — bukan satu pun angka metrik.
##
## Hakim (`tentukan`) = fungsi MURNI atas metrik warisan yang sudah menyala
## sejak #291: save file-mu adalah argumennya.

const DATA := {
	"world_remembers": {
		"judul": "THE WORLD REMEMBERS",
		"baris": [
			"Kabut berhenti bertanya. Bukan karena kalah — karena jawabannya datang dari terlalu banyak arah.",
			"Halaman-halaman yang ditulis ulang. Tangan-tangan yang ikut menghitung. Kartu pos yang tiba dari pesisir. Lampu-lampu yang dinyalakan orang yang berbeda-beda, untuk alasan yang sama.",
			"Sang Nirnama tidak pergi. Ia menunggu — sebagaimana ia selalu menunggu. Tapi malam ini, untuk pertama kalinya dalam waktu yang sangat lama, dunia menjawab lebih cepat daripada ia melupakan.",
			"Tidak semuanya kembali. Itu hukumnya, dan tak ada yang bisa menawarnya. Tapi yang tersisa DIINGAT — dan diingat oleh lebih dari satu orang.",
		],
	},
	"dawn": {
		"judul": "DAWN",
		"baris": [
			"Fajar tidak menghapus kabut. Fajar hanya membuatnya terlihat.",
			"Sedikit yang dipulihkan. Cukup untuk membuktikan bahwa memulihkan itu mungkin — dan itu lebih dari yang dunia ini miliki kemarin.",
			"Sang Nirnama menatap halaman-halaman yang ditulis ulang, lama. Lalu mundur satu langkah. Hanya satu.",
			"Ini bukan kemenangan. Ini pagi. Pagi harus diperjuangkan lagi besok.",
		],
	},
	"last_sky": {
		"judul": "LAST SKY",
		"baris": [
			"Lebih banyak yang tercoret daripada yang sempat ditulis ulang. Jauh lebih banyak.",
			"Tapi seseorang menyimpan sesuatu. Satu halaman. Satu nama. Satu kebiasaan kecil yang tubuh seseorang menolak lupakan.",
			"Di bawah langit yang mulai memutih, dua orang berdiri memandang ke atas — dan salah satunya masih ingat kenapa.",
			"Era ini menutup dengan langit terakhirnya disaksikan. Tidak semua era mendapat itu.",
		],
	},
	"broken_answer": {
		"judul": "BROKEN ANSWER",
		"baris": [
			"Dunia menjawab. Jawabannya utuh, keras, tak terbantah.",
			"Tapi jawabannya ditulis dengan tangan orang lain — dan tangan-tangan itu gemetar sekarang. Ada yang umurnya berkurang. Ada yang bebannya bertambah dan tidak pernah mengeluh. Ada yang tak akan pernah tahu bahwa ia membayar.",
			"Sang Nirnama menerima jawabannya. Ia juga melihat retaknya.",
			"\"Kau menjawab,\" katanya — atau tidak berkata apa-apa; tak ada yang yakin. \"Siapa yang membayar jawabanmu?\"",
		],
	},
	"final_silence": {
		"judul": "THE FINAL SILENCE",
		"baris": [
			"Dunia tidak berakhir. Dunia bangun keesokan paginya, menyalakan tungku, memanggang roti.",
			"Hanya saja tak seorang pun ingat siapa yang mengajari mereka resepnya.",
			"Papan-papan nama kosong. Lampu-lampu padam tanpa penonton. Buku besar itu masih ada di perpustakaan — halaman-halamannya bersih, rapi, dan tak berisi apa-apa.",
			"Sang Nirnama tidak menang. Ia hanya tidak dijawab. Dan keheningan, pada akhirnya, adalah jawaban juga.",
		],
	},
}


## HAKIM — murni, deterministik, diuji. `w` = snapshot WorldState.counters.
static func tentukan(w: Dictionary) -> String:
	var pulih := int(w.get("warisan:pulih", 0))
	var sendiri := int(w.get("warisan:pulih_sendiri", 0))
	var coret := int(w.get("warisan:tercoret", 0))
	var beban_sora := int(w.get("sora_beban", 0))
	var beban_elyn := int(w.get("elyn_beban", 0))
	var ditunda := int(w.get("warisan:penggusuran_ditunda", 0))
	var kartu := int(w.get("arlen_kartu", 0))
	var pulang := int(w.get("sora_pulang", 0))
	if pulih <= 0:
		return "final_silence"
	if pulih >= 3 and sendiri >= 1 and ditunda == 1 and (kartu == 1 or pulang == 1):
		return "world_remembers"
	if beban_sora + beban_elyn >= 3 and sendiri == 0:
		return "broken_answer"
	if coret > pulih * 2:
		return "last_sky"
	return "dawn"


func _ready() -> void:
	var id := WorldState.pending_ending
	if id == "" or not DATA.has(id):
		id = tentukan(WorldState.counters)
	WorldState.pending_ending = ""
	WorldState.counters["badai_selesai"] = 1
	WorldState.counters["warisan:ending_" + id] = 1   # tercatat untuk era berikutnya

	var latar := ColorRect.new()
	latar.color = Color(0.94, 0.94, 0.96) if id == "final_silence" else Color(0.055, 0.07, 0.13)
	latar.set_anchors_preset(Control.PRESET_FULL_RECT)
	var ui := CanvasLayer.new()
	add_child(ui)
	ui.add_child(latar)
	var tinta := Color(0.16, 0.16, 0.2) if id == "final_silence" else Color(0.87, 0.89, 0.96)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(640, 0)
	box.add_theme_constant_override("separation", 18)
	ui.add_child(box)
	var f := load("res://assets/game/fonts/m5x7.ttf")
	var judul := Label.new()
	judul.text = DATA[id]["judul"]
	judul.add_theme_font_override("font", f)
	judul.add_theme_font_size_override("font_size", 42)
	judul.add_theme_color_override("font_color", tinta)
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(judul)
	for b in DATA[id]["baris"]:
		var l := Label.new()
		l.text = b
		l.add_theme_font_override("font", f)
		l.add_theme_font_size_override("font_size", 17)
		l.add_theme_color_override("font_color", tinta)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(640, 0)
		box.add_child(l)
	var tutup := Label.new()
	tutup.text = "— era ini selesai. dunia melanjutkan. —\n[tekan apa saja]"
	tutup.add_theme_font_override("font", f)
	tutup.add_theme_font_size_override("font_size", 14)
	tutup.add_theme_color_override("font_color", tinta.lerp(Color(0.5, 0.5, 0.55), 0.4))
	tutup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(tutup)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
