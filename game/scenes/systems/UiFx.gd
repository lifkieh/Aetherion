class_name UiFx
extends RefCounted
## UI feel pass (Decision Log #44) — modern & playful, tetap pixel + palet resmi.
## SEMUA nilai dituning dari data/ui_feel.json. Menghormati Mode Hemat:
## saat eco, tween mahal dilewati (elemen langsung tampil, tidak ada breathing).

static func _cfg(key: String) -> Dictionary:
	return Db.ui_feel.get(key, {})

static func _on() -> bool:
	return bool(Db.ui_feel.get("enabled", true)) and not Settings.eco_mode

## Panel/menu muncul: scale 0.95→1 + fade (0.12–0.18s).
static func panel_in(ctrl: Control) -> void:
	if ctrl == null or not _on():
		return
	var c := _cfg("panel_in")
	ctrl.pivot_offset = ctrl.custom_minimum_size * 0.5
	ctrl.scale = Vector2.ONE * float(c.get("scale_from", 0.95))
	ctrl.modulate.a = 0.0
	var tw := ctrl.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ctrl, "scale", Vector2.ONE, float(c.get("dur", 0.15))).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "modulate:a", 1.0, float(c.get("dur", 0.15)))

## Tombol hidup: hover (naik + glow tipis), press (squash), SFX konsisten.
## Aman dipanggil dobel (meta guard); SFX click hanya ditambah jika belum ada.
static func button(b: BaseButton, click_sfx: bool = false) -> void:
	if b == null or b.has_meta("uifx"):
		return
	b.set_meta("uifx", true)
	b.mouse_entered.connect(func():
		if not _on(): return
		var h := _cfg("hover")
		b.pivot_offset = b.size * 0.5
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position:y", b.position.y - float(h.get("rise", 2.0)), float(h.get("dur", 0.08)))
		tw.tween_property(b, "modulate", Color.WHITE * float(h.get("glow", 1.12)), float(h.get("dur", 0.08)))
		Audio.play_sfx("blip", 1.3))
	b.mouse_exited.connect(func():
		if not _on(): return
		var h := _cfg("hover")
		var tw := b.create_tween()
		tw.set_parallel(true)
		tw.tween_property(b, "position:y", b.position.y + float(h.get("rise", 2.0)), float(h.get("dur", 0.08)))
		tw.tween_property(b, "modulate", Color.WHITE, float(h.get("dur", 0.08))))
	b.button_down.connect(func():
		if not _on(): return
		var p := _cfg("press")
		b.pivot_offset = b.size * 0.5
		b.scale = Vector2.ONE * float(p.get("squash", 0.94)))
	b.button_up.connect(func():
		if not _on(): return
		var p := _cfg("press")
		var tw := b.create_tween()
		tw.tween_property(b, "scale", Vector2.ONE, float(p.get("dur", 0.06)) * 2.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	if click_sfx:
		b.pressed.connect(func(): Audio.play_sfx("click", 1.1))

## Idle "breathing" sangat halus untuk tombol/kartu penting. Skip di Mode Hemat.
static func breathe(ctrl: Control) -> void:
	if ctrl == null or not _on():
		return
	var c := _cfg("breathe")
	ctrl.pivot_offset = ctrl.size * 0.5 if ctrl.size != Vector2.ZERO else ctrl.custom_minimum_size * 0.5
	var amt := float(c.get("amount", 0.015))
	var per := float(c.get("period", 2.4))
	var tw := ctrl.create_tween().set_loops()
	tw.tween_property(ctrl, "scale", Vector2.ONE * (1.0 + amt), per * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, per * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Bounce kecil saat ikon/kartu dipilih.
static func select_bounce(ctrl: Control) -> void:
	if ctrl == null or not _on():
		return
	var c := _cfg("select_bounce")
	ctrl.pivot_offset = ctrl.size * 0.5
	var tw := ctrl.create_tween()
	tw.tween_property(ctrl, "scale", Vector2.ONE * float(c.get("scale", 1.12)), float(c.get("dur", 0.14)) * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, float(c.get("dur", 0.14)) * 0.5)

## Micro-celebration untuk konfirmasi penting (belajar skill, beli pohon, travel):
## kilau kecil menyebar + jingle pendek dari pemanggil.
static func celebrate(parent: Control, glyph: String = "✦") -> void:
	if parent == null or not _on():
		return
	var c := _cfg("celebrate")
	var n := int(c.get("sparks", 7))
	var center := parent.size * 0.5
	for i in range(n):
		var s := Label.new()
		s.text = glyph
		s.add_theme_font_size_override("font_size", 14)
		s.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		s.position = center
		s.z_index = 100
		parent.add_child(s)
		var dir := Vector2.from_angle(TAU * i / n + randf_range(-0.2, 0.2))
		var tw := s.create_tween()
		tw.set_parallel(true)
		tw.tween_property(s, "position", center + dir * randf_range(28.0, 52.0), float(c.get("dur", 0.6))).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "modulate:a", 0.0, float(c.get("dur", 0.6)))
		tw.chain().tween_callback(s.queue_free)

## Toast masuk dengan spring (dipakai HUD).
static func toast_spring(ctrl: Control) -> void:
	if ctrl == null or not _on():
		return
	var c := _cfg("toast_spring")
	ctrl.pivot_offset = Vector2(ctrl.size.x * 0.5, ctrl.size.y)
	ctrl.scale = Vector2(0.7, 0.7)
	var tw := ctrl.create_tween()
	tw.tween_property(ctrl, "scale", Vector2.ONE * float(c.get("overshoot", 1.08)), float(c.get("dur", 0.22)) * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, float(c.get("dur", 0.22)) * 0.4)
