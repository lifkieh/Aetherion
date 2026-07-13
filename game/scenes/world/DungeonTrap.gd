class_name DungeonTrap
extends Area2D
## Jebakan dungeon (v0.4.3 #6, Decision Log #85). Dua jenis:
##   - `spike`: paku di lantai — TERLIHAT (jujur: bisa dihindari kalau kau melihat).
##   - `dart`: lubang panah di dinding — telegraf 0.5 dtk (bunyi + kilatan) sebelum
##     menembak; jebakan yang membunuh tanpa peringatan adalah desain malas.
## Jebakan tidak pernah membunuh dari full HP: damage di-cap 25% max HP.

const SPIKE_DMG := 0.12       # fraksi max HP
const DART_DMG := 0.10
const CAP := 0.25             # cap keras per pukulan
const COOLDOWN := 1.2

var kind := "spike"
var _cd := 0.0
var _armed := true
var _telegraph := 0.0

static func spawn(host: Node2D, pos: Vector2, k: String = "spike") -> DungeonTrap:
	var t: DungeonTrap = DungeonTrap.new()
	t.kind = k
	host.add_child(t)
	t.global_position = pos
	return t

func _ready() -> void:
	z_index = 25
	collision_layer = 0
	collision_mask = 1 | 2      # pemain
	monitoring = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 10) if kind == "spike" else Vector2(96, 20)
	shape.shape = rect
	add_child(shape)
	queue_redraw()

func _draw() -> void:
	if kind == "spike":
		var col := Color(0.75, 0.78, 0.85)
		for i in 3:
			var x := -6.0 + i * 6.0
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - 2.5, 5), Vector2(x + 2.5, 5), Vector2(x, -5)]), col)
	else:
		# lubang panah: kotak gelap di dinding, memerah saat mengokang
		var c := Color(0.2, 0.18, 0.22) if _telegraph <= 0.0 else Color(0.9, 0.35, 0.3)
		draw_rect(Rect2(Vector2(-44, -4), Vector2(8, 8)), c)

func _physics_process(delta: float) -> void:
	_cd = maxf(0.0, _cd - delta)
	if kind == "dart":
		_dart_logic(delta)
		return
	if _cd > 0.0:
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("player"):
			_hit(b, SPIKE_DMG)
			return

func _dart_logic(delta: float) -> void:
	if _telegraph > 0.0:
		_telegraph -= delta
		queue_redraw()
		if _telegraph <= 0.0:
			_fire()
		return
	if _cd > 0.0 or not _armed:
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("player"):
			_telegraph = 0.5          # peringatan: bunyi + warna sebelum menembak
			Audio.play_sfx("trap_dart", 1.0)   # kokang: peringatan sebelum tembak
			queue_redraw()
			return

func _fire() -> void:
	_cd = COOLDOWN * 2.0
	queue_redraw()
	for b in get_overlapping_bodies():
		if b.is_in_group("player"):
			_hit(b, DART_DMG)

func _hit(body: Node, frac: float) -> void:
	_cd = COOLDOWN
	if not body.has_method("take_hit"):
		return
	var dmg := int(clampf(frac, 0.0, CAP) * float(PlayerData.max_hp))
	body.take_hit({"damage": maxi(1, dmg), "element": "none", "is_crit": false}, self)
	Audio.play_sfx("trap_spike" if kind == "spike" else "trap_dart")
