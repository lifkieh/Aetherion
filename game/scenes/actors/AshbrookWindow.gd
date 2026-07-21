extends Node2D
## JENDELA ASHBROOK (#218) — **kontras dari PERBEDAAN, bukan ketiadaan.**
##
## Sebelum ini, "hanya lampu Merrit yang menyala" benar hanya karena **tak ada
## jendela lain sama sekali**. Mata pemain tak pernah melihat apa pun **padam**.
##
## Kini: rumah-rumah lain **menyala sore hari**, lalu **PADAM SATU PER SATU**
## (19.00 · 20.00 · 21.00). Pemain menyaksikan desa **tertidur** — dan satu lampu
## menolak ikut tidur.

var off_hour := 20

## #218 + payoff — JENDELA YANG MENGABARKAN PELUPAAN.
##
## Bila diisi id halaman Chronicle, jendela ini **gelap permanen** selama halaman itu
## TERCORET — bukan gelap karena jam. Kota mengabarkan apa yang sudah dilupakannya
## lewat jendela yang tak pernah menyala lagi.
##
## D-3 tetap: nol teks, nol penanda. Pemain yang tak memperhatikan tak akan tahu
## bahwa satu jendela ini gelap karena sebab yang berbeda dari tetangganya.
var page_id := ""

var _rect: ColorRect
var _light: PointLight2D

## MATI = tak berpenghuni, titik. Bukan mekanisme Chronicle.
##
## ⚠ KENAPA INI PERLU ADA, dan kenapa `terlupa()` saja tak cukup:
##   `terlupa()` menuntut halaman ADA dan TERCORET. Otha Renn adalah kematian **d3**
##   (`chronicle_losses.json`) — halamannya tak pernah lahir sama sekali, jadi ia tak
##   pernah bisa tercoret, jadi `terlupa()` selamanya false untuknya.
##   Akibatnya jendela tokonya menyala tiap malam seperti rumah berpenghuni —
##   sementara pintunya berkata "Terkunci. Debu di ambangnya rata; tak ada yang
##   membukanya sejak dua musim." Pemain MEMBACA satu hal dan MELIHAT kebalikannya.
##   Aturan #229.3 tetap utuh: d3 tak meninggalkan apa-apa untuk dilihat. Yang
##   membuat jendela ini gelap bukan Chronicle — melainkan kenyataan bahwa tak ada
##   seorang pun di dalam untuk menyalakan lampu.
var mati := false


func place(p: Vector2, hour_off: int, page := "", kosong := false) -> void:
	global_position = p
	off_hour = hour_off
	page_id = page
	mati = kosong


## Terlupa = halaman ada DAN tercoret. Halaman yang tak pernah lahir tak membuat
## jendela gelap — itu D3, dan D3 tak meninggalkan apa-apa untuk dilihat (#229.3).
func terlupa() -> bool:
	return page_id != "" and Chronicle.state_of(page_id) == Chronicle.ST_STRUCK

func _ready() -> void:
	add_to_group("ashbrook_window")
	z_index = 3000
	_rect = ColorRect.new()
	_rect.color = Color(1.0, 0.84, 0.52)
	_rect.size = Vector2(7, 6)
	_rect.position = Vector2(-3, -3)
	add_child(_rect)
	_light = PointLight2D.new()
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1))
	_light.texture = ImageTexture.create_from_image(img)
	_light.energy = 0.8
	_light.texture_scale = 4.0
	_light.color = Color(1.0, 0.82, 0.5)
	add_child(_light)
	apply_hour(GameClock.wib_hour())

## Menyala hanya SORE (17.00) sampai jam padamnya sendiri. Dipanggil test (#151b).
func apply_hour(h: int) -> void:
	if mati or terlupa():
		visible = false          # gelap permanen; jam tak berlaku lagi
		return
	var lit := h >= 17 and h < off_hour
	visible = lit

func is_lit() -> bool:
	return visible
