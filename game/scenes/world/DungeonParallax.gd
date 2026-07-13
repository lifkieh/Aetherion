class_name DungeonParallax
extends ParallaxBackground
## PARALLAX DUNGEON (v0.4.3 #6, Decision Log #98).
##
## **Cainos "Pixel Art Top Down Basic" dinilai ulang dan DITOLAK untuk keperluan ini**
## (jujur, bukan dipaksakan): pack itu top-down, sedangkan dungeon kita side-view —
## dindingnya tak punya sisi yang bisa dilihat dari samping. Memakainya akan terlihat
## seperti lantai yang ditempel di langit. Maka: **siluet gradient PROSEDURAL** —
## 3 lapis, digambar sekali ke ImageTexture (bukan _draw tiap frame), tanpa aset,
## ~30 KB memori, dan bisa diwarnai per tema dungeon.
##
## Mode Hemat (Settings.eco_mode) MEMATIKAN parallax sepenuhnya.

const LAYER_CFG := [
	{"scale": 0.25, "y": 0.0, "rows": 3, "alpha": 0.35, "shade": 0.55},   # jauh: kabut & massa batu
	{"scale": 0.5, "y": 12.0, "rows": 5, "alpha": 0.5, "shade": 0.75},    # tengah: pilar
	{"scale": 0.75, "y": 26.0, "rows": 7, "alpha": 0.65, "shade": 1.0},   # dekat: stalaktit
]

static func attach(host: Node2D, tint: Color, seed_id: String) -> DungeonParallax:
	if Settings.eco_mode:
		return null                      # Mode Hemat: parallax dimatikan (perintah owner)
	var px: DungeonParallax = DungeonParallax.new()
	px.name = "DungeonParallax"
	host.add_child(px)
	px._build(tint, seed_id)
	return px

func _build(tint: Color, seed_id: String) -> void:
	layer = -25
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_id)
	var i := 0
	for cfg in LAYER_CFG:
		var pl := ParallaxLayer.new()
		pl.motion_scale = Vector2(float(cfg.scale), float(cfg.scale) * 0.6)
		pl.motion_mirroring = Vector2(640, 0)
		add_child(pl)
		var spr := Sprite2D.new()
		spr.centered = false
		spr.texture = _layer_texture(tint * float(cfg.shade), int(cfg.rows), float(cfg.alpha), rng)
		spr.position = Vector2(0, float(cfg.y))
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		pl.add_child(spr)
		i += 1

## Satu lapis = siluet stalaktit/pilar acak di atas gradient. Digambar SEKALI.
func _layer_texture(col: Color, cols: int, alpha: float, rng: RandomNumberGenerator) -> Texture2D:
	var w := 640
	var h := 360
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	# gradient vertikal lembut
	for y in h:
		var t := float(y) / float(h)
		var c := Color(col.r * (0.35 + t * 0.5), col.g * (0.35 + t * 0.5), col.b * (0.4 + t * 0.5), alpha * 0.55)
		for x in w:
			img.set_pixel(x, y, c)
	# stalaktit dari atas + pilar dari bawah
	var step := int(float(w) / float(maxi(1, cols)))
	for i in cols:
		var cx := i * step + rng.randi_range(6, maxi(7, step - 6))
		var half := rng.randi_range(10, 26)
		var depth := rng.randi_range(50, 150)
		var body := Color(col.r * 0.5, col.g * 0.5, col.b * 0.55, alpha)
		for y in depth:
			var span := int(half * (1.0 - float(y) / float(depth)))
			for x in range(cx - span, cx + span):
				if x >= 0 and x < w:
					img.set_pixel(x, y, body)
		# pilar bawah
		var ph := rng.randi_range(40, 120)
		var pw := rng.randi_range(8, 20)
		for y in range(h - ph, h):
			for x in range(cx - pw, cx + pw):
				if x >= 0 and x < w:
					img.set_pixel(x, y, body)
	return ImageTexture.create_from_image(img)
