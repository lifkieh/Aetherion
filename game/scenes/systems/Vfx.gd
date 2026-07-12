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

## Melee swing flourish (FF-2b): every weapon type draws a DIFFERENT, visible
## slash — a filled arc slice that sweeps with a bright leading edge and a
## 3-step ghost trail. All procedural (Polygon2D/Line2D), no textures = cheap.
static func swing(parent: Node, pos: Vector2, dir: Vector2, elem: String, wtype: String = "", reach: float = 46.0, arc_deg: float = 110.0) -> void:
	if parent == null:
		return
	var col := elem_color(elem)
	if col == Color(1, 1, 1):
		col = Color(0.92, 0.95, 1.0)   # neutral steel-white
	match wtype:
		"spear":
			_thrust_fx(parent, pos, dir, col, reach)
			return
		"dagger":
			_slash_arc(parent, pos, dir, col, reach, arc_deg, 0.07, 2, 0.55)
			return
		"hammer":
			_slash_arc(parent, pos, dir, col, reach, arc_deg, 0.16, 3, 1.0)
			_ground_dust(parent, pos + dir * reach * 0.7, col)
			return
		"scythe":
			_slash_arc(parent, pos, dir, col, reach, maxf(arc_deg, 160.0), 0.14, 3, 0.8)
			return
		"bow", "wand", "staff":
			_muzzle_flash(parent, pos + dir * 10.0, col)
			return
		_:
			_slash_arc(parent, pos, dir, col, reach, arc_deg, 0.11, 3, 0.8)

## Filled arc slice that sweeps across the swing with ghost-trail fade.
static func _slash_arc(parent: Node, pos: Vector2, dir: Vector2, col: Color, reach: float, arc_deg: float, dur: float, ghosts: int, edge_w: float) -> void:
	var half := deg_to_rad(arc_deg) * 0.5
	var base := dir.angle()
	# ghost trail: N slices fading in sequence = "2-3 frame trail" feel
	for g in range(ghosts):
		var poly := Polygon2D.new()
		var pts := PackedVector2Array()
		var inner := reach * 0.30
		var steps := 10
		var g_half := half * (1.0 - 0.18 * g)
		for i in range(steps + 1):
			var a := base - g_half + (g_half * 2.0) * float(i) / steps
			pts.append(pos + Vector2.from_angle(a) * reach)
		for i in range(steps, -1, -1):
			var a := base - g_half + (g_half * 2.0) * float(i) / steps
			pts.append(pos + Vector2.from_angle(a) * inner)
		poly.polygon = pts
		poly.color = Color(col.r, col.g, col.b, 0.34 - 0.09 * g)
		poly.z_index = 30
		parent.add_child(poly)
		var tw := poly.create_tween()
		tw.tween_interval(dur * 0.25 * g)
		tw.tween_property(poly, "color:a", 0.0, dur)
		tw.tween_callback(poly.queue_free)
	# bright leading edge sweeping across the arc
	var edge := Line2D.new()
	edge.width = 3.0 * edge_w + 1.0
	edge.default_color = Color(minf(col.r * 1.4, 1), minf(col.g * 1.4, 1), minf(col.b * 1.4, 1), 0.95)
	edge.z_index = 31
	edge.points = PackedVector2Array([pos + Vector2.from_angle(base - half) * (reach * 0.30), pos + Vector2.from_angle(base - half) * reach])
	parent.add_child(edge)
	var sweep := func(t: float) -> void:
		if not is_instance_valid(edge):
			return
		var a: float = base - half + half * 2.0 * t
		edge.points = PackedVector2Array([pos + Vector2.from_angle(a) * (reach * 0.30), pos + Vector2.from_angle(a) * reach])
		edge.modulate.a = 1.0 - t * 0.5
	var et := edge.create_tween()
	et.tween_method(sweep, 0.0, 1.0, dur)
	et.tween_callback(edge.queue_free)

## Spear: a long bright thrust quad stabbing forward then retracting.
static func _thrust_fx(parent: Node, pos: Vector2, dir: Vector2, col: Color, reach: float) -> void:
	var line := Line2D.new()
	line.width = 5.0
	line.default_color = Color(col.r, col.g, col.b, 0.9)
	line.z_index = 31
	line.points = PackedVector2Array([pos + dir * 8.0, pos + dir * 14.0])
	parent.add_child(line)
	var thrust := func(t: float) -> void:
		if not is_instance_valid(line):
			return
		var tip: float = lerpf(14.0, reach + 6.0, minf(t * 1.6, 1.0))
		line.points = PackedVector2Array([pos + dir * maxf(8.0, tip - 26.0), pos + dir * tip])
		line.modulate.a = 1.0 - maxf(0.0, t - 0.55) * 2.2
	var tw := line.create_tween()
	tw.tween_method(thrust, 0.0, 1.0, 0.16)
	tw.tween_callback(line.queue_free)

## Ranged muzzle flash: quick expanding ring at the fire point.
static func _muzzle_flash(parent: Node, pos: Vector2, col: Color) -> void:
	var ring := Line2D.new()
	ring.width = 2.0
	ring.default_color = Color(col.r, col.g, col.b, 0.9)
	ring.z_index = 31
	ring.closed = true
	parent.add_child(ring)
	var grow := func(t: float) -> void:
		if not is_instance_valid(ring):
			return
		var pts := PackedVector2Array()
		var r: float = lerpf(2.0, 12.0, t)
		for i in range(9):
			pts.append(pos + Vector2.from_angle(TAU * i / 8.0) * r)
		ring.points = pts
		ring.modulate.a = 1.0 - t
	var tw := ring.create_tween()
	tw.tween_method(grow, 0.0, 1.0, 0.14)
	tw.tween_callback(ring.queue_free)

## Hammer impact dust at the strike zone.
static func _ground_dust(parent: Node, pos: Vector2, col: Color) -> void:
	var p := GPUParticles2D.new()
	p.z_index = 29
	p.one_shot = true
	p.emitting = true
	p.amount = 14
	p.lifetime = 0.45
	p.explosiveness = 1.0
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 70.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 80.0
	mat.gravity = Vector3(0, 220, 0)
	mat.scale_min = 0.8
	mat.scale_max = 2.0
	mat.color = Color(col.r, col.g, col.b, 0.7)
	p.process_material = mat
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.8, 0.7))
	p.texture = ImageTexture.create_from_image(img)
	parent.add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)

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

## Hit impact burst (FF-2f): visible elemental particles + flash ring at the
## point of damage. Crits burst bigger and brighter.
static func impact(parent: Node, pos: Vector2, elem: String, crit: bool = false) -> void:
	if parent == null:
		return
	var col := elem_color(elem)
	if col == Color(1, 1, 1):
		col = Color(1.0, 0.9, 0.6)
	var p := GPUParticles2D.new()
	p.z_index = 33
	p.one_shot = true
	p.emitting = true
	p.amount = 18 if crit else 10
	p.lifetime = 0.35
	p.explosiveness = 1.0
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 60.0 if crit else 40.0
	mat.initial_velocity_max = 140.0 if crit else 90.0
	mat.gravity = Vector3(0, 60, 0)
	mat.scale_min = 1.0
	mat.scale_max = 2.6 if crit else 1.8
	mat.color = col
	p.process_material = mat
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(minf(col.r * 1.3, 1), minf(col.g * 1.3, 1), minf(col.b * 1.3, 1)))
	p.texture = ImageTexture.create_from_image(img)
	parent.add_child(p)
	p.global_position = pos
	p.finished.connect(p.queue_free)

## Death burst (FF-2f): white flash pop + particle explosion where a monster dies.
static func death_burst(parent: Node, pos: Vector2, elem: String) -> void:
	if parent == null:
		return
	impact(parent, pos, elem, true)
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.85)
	flash.size = Vector2(18, 18)
	flash.position = Vector2(-9, -9)
	flash.z_index = 34
	var holder := Node2D.new()
	holder.z_index = 34
	holder.add_child(flash)
	parent.add_child(holder)
	holder.global_position = pos
	var tw := holder.create_tween()
	tw.set_parallel(true)
	tw.tween_property(holder, "scale", Vector2(2.2, 2.2), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(holder, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(holder.queue_free)

## Dodge afterimages (FF-2f): 3 fading ghost snapshots trail the dash.
static func dodge_ghosts(actor: Node2D, spr: AnimatedSprite2D, duration: float = 0.22) -> void:
	if actor == null or spr == null or spr.sprite_frames == null:
		return
	var parent := actor.get_parent()
	if parent == null:
		return
	for i in range(3):
		var t := Timer.new()
		t.wait_time = maxf(0.01, duration * float(i) / 3.0)
		t.one_shot = true
		actor.add_child(t)
		t.timeout.connect(func():
			t.queue_free()
			if not is_instance_valid(actor) or not is_instance_valid(spr):
				return
			var tex := spr.sprite_frames.get_frame_texture(spr.animation, spr.frame)
			if tex == null:
				return
			var g := Sprite2D.new()
			g.texture = tex
			g.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			g.offset = spr.offset
			g.flip_h = spr.flip_h
			g.z_index = 18
			g.modulate = Color(0.7, 0.85, 1.0, 0.5)
			parent.add_child(g)
			g.global_position = actor.global_position
			var tw := g.create_tween()
			tw.tween_property(g, "modulate:a", 0.0, 0.28)
			tw.tween_callback(g.queue_free))
		t.start()

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
