extends Node
## Harness tangkap-layar KITAB (design-time, BUKAN test — tak menambah hitungan suite).
##
## Kenapa harness sendiri, bukan ShotScene: Kitab adalah layar berkeadaan. Empat
## keadaannya (tercoret · pilih jalur · keterbukaan Elyn · penolakan ruang penuh ·
## pulih) tak bisa dicapai dengan menunggu — masing-masing harus DISIAPKAN.
## Berkas ini menyiapkan dunia, lalu menjepret satu per satu.
##
## Harness boleh membaca state internal; UI tidak (D-4). Yang dibuktikan di sini
## justru sebaliknya: bahwa layarnya TIDAK memperlihatkan apa yang harness lihat.
##
## Scene, BUKAN `--script`. Skrip MainLoop dikompilasi SEBELUM autoload terdaftar,
## jadi `PlayerData`/`Chronicle`/`Evidence` tak dikenal di sana — dan MenuUI yang
## ikut di-preload gagal kompilasi bersamanya. Sebagai scene, autoload sudah hidup.
## (ShotScene.gd bisa tetap `--script` karena ia menyentuh autoload lewat
##  `root.get_node_or_null()`, bukan lewat nama global.)
##
## Pakai:
##   set AETHER_SHOT_DIR=D:\2DGAME\reports\preview
##   run_godot.bat res://tests/ShotKitab.tscn

const PAGE := "place_ashbrook_besar"
## Tiga jenis berbeda — cukup untuk SENDIRI (3) maupun ELYN (2).
const EV := [
	"ev_ashbrook_gudang_gandum",       # akibat
	"ev_ashbrook_halloran_200_roti",   # kebiasaan
	"ev_ashbrook_batu_fondasi",        # benda
]

var _dir := ""
var _menu: CanvasLayer
var _step := -1
var _t := 0.0
var _shots: Array = []


func _ready() -> void:
	_dir = OS.get_environment("AETHER_SHOT_DIR")
	if _dir == "":
		_dir = "user://"


func _setup_world() -> void:
	PlayerData.new_game()
	WorldState.chronicle = []
	Evidence.found = {}
	Evidence.decayed = {}
	PlayerData.memory_held = []
	PlayerData.elyn_burden = []
	PlayerData.elyn_age_spent = 0
	# Halaman lahir dari yang repot (#261), lalu dicoret diam-diam (D-3).
	Chronicle.record_person(PAGE, "Ashbrook — kota yang dulu besar", "merrit_fane")
	Chronicle.strike(PAGE, "waktu")
	# Halaman kedua yang TIDAK tercoret — supaya seksi "yang masih terbaca" terisi.
	Chronicle.record_person("person_merrit_fane", "Merrit Fane, penjaga lentera", "merrit_fane")
	for e in EV:
		Evidence.find(e)


func _bg() -> void:
	var cr := ColorRect.new()
	cr.color = Color(0.05, 0.06, 0.10)
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(cr)


func _shot(name_part: String) -> void:
	var img := get_tree().root.get_texture().get_image()
	if img == null:
		push_error("[kitab] viewport kosong — jangan jalankan --headless")
		get_tree().quit(1)
		return
	var p := _dir.path_join("6_kitab_%s.png" % name_part)
	if img.save_png(p) != OK:
		push_error("[kitab] gagal simpan %s" % p)
		get_tree().quit(1)
		return
	_shots.append(p)
	print("[kitab] ", p)


## Tiap langkah: siapkan keadaan, gambar ulang, tunggu satu frame, jepret.
func _apply(step: int) -> String:
	match step:
		0:
			_menu.mode = "kitab"
			_menu._kitab_view = ""
			_menu._rebuild()
			return "tercoret"
		1:
			_menu._kitab_view = "path:" + PAGE
			_menu._rebuild()
			return "pilih_jalur"
		2:
			_menu._kitab_view = "elyn:" + PAGE
			_menu._rebuild()
			return "keterbukaan_elyn"
		3:
			# #257 — ruang pemain dipenuhi, lalu SENDIRI ditekan lewat jalur asli.
			while not PlayerData.memory_full():
				PlayerData.memory_held.append("isi_%d" % PlayerData.memory_held.size())
			_menu._kitab_do_self(PAGE)
			return "penolakan_ruang_penuh"
		4:
			PlayerData.memory_held = []
			var r: Dictionary = Chronicle.restore_elyn(PAGE, Evidence.for_page(PAGE))
			print("[kitab] restore_elyn ok=", r.get("ok"), " loss=", r.get("loss"))
			_menu._kitab_view = "done:" + PAGE
			_menu._rebuild()
			return "pulih_loss"
	return ""


## Keadaan DIPASANG dulu, baru dijepret satu putaran kemudian. Menjepret di frame
## yang sama dengan _rebuild() menghasilkan tekstur frame SEBELUMNYA — tiap gambar
## akan menampilkan layar yang salah, dan bugnya tak kelihatan sampai dilihat.
var _pending := ""

func _process(delta: float) -> void:
	_t += delta
	if _step < 0:
		if _t < 0.6:
			return
		_setup_world()
		_bg()
		_menu = preload("res://scenes/ui/MenuUI.tscn").instantiate()
		get_tree().root.add_child(_menu)
		_menu.open("kitab")
		get_tree().paused = false            # harness menggerakkan waktunya sendiri
		_step = 0
		_t = 0.0
		return
	if _pending == "":
		_pending = _apply(_step)
		_t = 0.0
		return
	if _t < 0.4:
		return
	_t = 0.0
	_shot(_pending)
	_pending = ""
	_step += 1
	if _step > 4:
		print("[kitab] selesai, %d gambar" % _shots.size())
		get_tree().quit(0)
