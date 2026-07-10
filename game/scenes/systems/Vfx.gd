class_name Vfx
extends RefCounted
## Lightweight one-shot visual effects (M3 element flow + chains).
## All effects self-free; cheap enough for the "game ringan" target.

static func elem_color(elem: String) -> Color:
	match elem:
		"fire": return Color(1.0, 0.55, 0.15)
		"lightning": return Color(1.0, 0.95, 0.35)
		"ice": return Color(0.6, 0.9, 1.0)
		"water": return Color(0.4, 0.6, 1.0)
		"wood": return Color(0.5, 0.85, 0.4)
		"poison": return Color(0.7, 0.4, 0.9)
		"earth": return Color(0.8, 0.65, 0.4)
		"wind": return Color(0.7, 1.0, 0.85)
		"moon": return Color(0.8, 0.85, 1.0)
		_: return Color(1, 1, 1)

## Melee swing flourish in front of the attacker, tinted by element.
static func swing(parent: Node, pos: Vector2, dir: Vector2, elem: String) -> void:
	if parent == null:
		return
	var col := elem_color(elem)
	if elem == "fire" and ResourceLoader.exists("res://assets/game/vfx/fire_flow_strip.png"):
		var s := AnimatedSprite2D.new()
		s.sprite_frames = SheetUtil.build_strip(load("res://assets/game/vfx/fire_flow_strip.png"), 32, 8, "play", 24.0, false)
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.z_index = 30
		parent.add_child(s)
		s.global_position = pos + dir * 16.0
		s.rotation = dir.angle()
		s.play("play")
		s.animation_finished.connect(s.queue_free)
		return
	# generic elemental slash arc
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = col
	line.z_index = 30
	var perp := dir.orthogonal()
	line.points = PackedVector2Array([
		pos + dir * 10 - perp * 14,
		pos + dir * 22,
		pos + dir * 10 + perp * 14,
	])
	parent.add_child(line)
	line.global_position = Vector2.ZERO
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.22)
	tw.tween_callback(line.queue_free)

## Arc of light between two points (lightning chain).
static func chain_arc(parent: Node, from: Vector2, to: Vector2, elem: String = "lightning") -> void:
	if parent == null:
		return
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = elem_color(elem)
	line.z_index = 35
	var pts := PackedVector2Array()
	var steps := 6
	for i in range(steps + 1):
		var t := float(i) / steps
		var p := from.lerp(to, t)
		if i != 0 and i != steps:
			p += (to - from).orthogonal().normalized() * randf_range(-6, 6)
		pts.append(p)
	line.points = pts
	parent.add_child(line)
	var tw := line.create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.25)
	tw.tween_callback(line.queue_free)

## Small radial spark burst.
static func spark(parent: Node, pos: Vector2, elem: String) -> void:
	if parent == null:
		return
	var p := GPUParticles2D.new()
	p.z_index = 32
	p.one_shot = true
	p.emitting = true
	p.amount = 10
	p.lifetime = 0.4
	p.explosiveness = 0.9
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 90.0
	mat.gravity = Vector3(0, 120, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	mat.color = elem_color(elem)
	p.process_material = mat
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(elem_color(elem))
	p.texture = ImageTexture.create_from_image(img)
	parent.add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)
