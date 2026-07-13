extends Node
## CUTSCENE MINI ENGINE (v0.4.3 #3, Decision Log #94) — pemutar skrip data-driven.
## Skrip = daftar perintah di `cutscenes.json`; tak ada satu pun adegan yang
## di-hardcode. Selama cutscene berjalan: input pemain TERKUNCI, dan pemain bisa
## MELEWATI dengan MENAHAN ESC (hold, bukan tap — agar tak terlewat tak sengaja).
##
## Perintah yang didukung:
##   move_actor {actor, to:[x,y] | rel:[dx,dy], speed}   face {actor, dir}
##   camera_pan {to:[x,y] | actor, time}                 camera_zoom {zoom, time}
##   dialog {speaker, lines[], portrait}                 wait {time}
##   fade {to: "black"|"clear", time}                    shake {amount, time}
##   play_music {track}   play_stinger {kind}   sfx {name}
##   spawn {scene|script, at:[x,y], id}                  despawn {id}
##   banner {title, sub}
##
## `actor` = "player" | id hasil spawn | nama grup node pertama.

signal started(id: String)
signal finished(id: String)

const SKIP_HOLD := 0.6          # detik menahan ESC untuk melewati

var playing := false
var _skipping := false
var _skip_held := 0.0
var _spawned: Dictionary = {}   # id -> Node
var _cam_home = null            # posisi kamera sebelum cutscene

func def(id: String) -> Dictionary:
	for c in Db.cutscenes:
		if c.get("id", "") == id:
			return c
	return {}

func _process(delta: float) -> void:
	if not playing:
		return
	if Input.is_action_pressed("pause_menu"):
		_skip_held += delta
		if _skip_held >= SKIP_HOLD and not _skipping:
			_skipping = true
			EventBus.toast.emit("Cutscene dilewati.")
	else:
		_skip_held = 0.0

## Putar satu cutscene sampai selesai. Aman dipanggil headless (perintah visual
## dilewati dengan anggun bila node tak ada).
func play(id: String) -> void:
	var c := def(id)
	if c.is_empty() or playing:
		return
	playing = true
	_skipping = false
	_skip_held = 0.0
	started.emit(id)
	_lock_player(true)
	for step in c.get("steps", []):
		if _skipping:
			break
		await _run(step)
	_cleanup()
	_lock_player(false)
	playing = false
	finished.emit(id)
	WorldState.add_counter("cutscene:" + id)

func _headless() -> bool:
	return DisplayServer.get_name() == "headless"

func _run(step: Dictionary) -> void:
	# Headless (test/harness/screenshot): langkah berbasis tween/kamera dilewati —
	# tween tidak berjalan saat tree di-pause, dan cutscene TIDAK BOLEH menggantung.
	if _headless() and step.get("cmd", "") in ["camera_pan", "camera_zoom", "shake", "move_actor", "fade"]:
		await get_tree().create_timer(0.02, true).timeout
		return
	match step.get("cmd", ""):
		"wait":
			await get_tree().create_timer(float(step.get("time", 1.0)), true).timeout
		"dialog":
			var lines: Array = step.get("lines", [])
			if DisplayServer.get_name() == "headless":
				# headless (test/harness): dialog tak bisa di-klik — jangan menggantung
				await get_tree().create_timer(0.05, true).timeout
			else:
				await Stage.say(lines, step.get("speaker", ""))
		"banner":
			Stage.banner(step.get("title", ""), step.get("sub", ""))
			await get_tree().create_timer(1.2, true).timeout
		"fade":
			if step.get("to", "black") == "black":
				await Stage.fade_out(float(step.get("time", 0.4)))
			else:
				await Stage.fade_in(float(step.get("time", 0.5)))
		"play_music":
			Audio.play_music(step.get("track", ""))
		"play_stinger":
			Audio.play_stinger(step.get("kind", "quest"))
		"sfx":
			Audio.play_sfx(step.get("name", "click"))
		"shake":
			var cam := _camera()
			if cam:
				await _shake(cam, float(step.get("amount", 6.0)), float(step.get("time", 0.4)))
		"move_actor":
			await _move(step)
		"face":
			var a := _actor(step.get("actor", "player"))
			if a and "facing" in a:
				a.set("facing", step.get("dir", "down"))
		"camera_pan":
			await _pan(step)
		"camera_zoom":
			var cam2 := _camera()
			if cam2:
				var tw := cam2.create_tween()
				tw.tween_property(cam2, "zoom", Vector2.ONE * float(step.get("zoom", 1.0)), float(step.get("time", 0.8)))
				await tw.finished
		"spawn":
			_spawn(step)
		"despawn":
			var sid: String = step.get("id", "")
			if _spawned.has(sid) and is_instance_valid(_spawned[sid]):
				_spawned[sid].queue_free()
			_spawned.erase(sid)
		_:
			pass

# --- helpers ----------------------------------------------------------------

func _actor(name: String) -> Node2D:
	if name == "player":
		return get_tree().get_first_node_in_group("player") as Node2D
	if _spawned.has(name) and is_instance_valid(_spawned[name]):
		return _spawned[name]
	var g := get_tree().get_nodes_in_group(name)
	return g[0] as Node2D if not g.is_empty() else null

func _camera() -> Camera2D:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		for c in p.get_children():
			if c is Camera2D:
				return c
	var vp := get_viewport()
	return vp.get_camera_2d() if vp else null

func _move(step: Dictionary) -> void:
	var a := _actor(step.get("actor", "player"))
	if a == null:
		return
	var target: Vector2 = a.global_position
	if step.has("to"):
		var t: Array = step.get("to", [0, 0])
		target = Vector2(float(t[0]), float(t[1]))
	elif step.has("rel"):
		var r: Array = step.get("rel", [0, 0])
		target += Vector2(float(r[0]), float(r[1]))
	var speed: float = float(step.get("speed", 90.0))
	var dur: float = maxf(0.05, a.global_position.distance_to(target) / maxf(1.0, speed))
	var tw := a.create_tween()
	tw.tween_property(a, "global_position", target, dur)
	await tw.finished

func _pan(step: Dictionary) -> void:
	var cam := _camera()
	if cam == null:
		return
	if _cam_home == null:
		_cam_home = cam.offset
	var off: Vector2 = cam.offset
	if step.has("to"):
		var t: Array = step.get("to", [0, 0])
		off = Vector2(float(t[0]), float(t[1]))
	elif step.has("actor"):
		var a := _actor(step.get("actor", "player"))
		var p := _actor("player")
		if a and p:
			off = a.global_position - p.global_position
	var tw := cam.create_tween()
	tw.tween_property(cam, "offset", off, float(step.get("time", 1.0)))
	await tw.finished

func _shake(cam: Camera2D, amount: float, time: float) -> void:
	var t := 0.0
	var base: Vector2 = cam.offset
	while t < time:
		cam.offset = base + Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		await get_tree().process_frame
		t += get_process_delta_time()
	cam.offset = base

func _spawn(step: Dictionary) -> void:
	var host := get_tree().current_scene
	if host == null:
		return
	var node: Node2D = null
	if step.has("scene") and ResourceLoader.exists(step.get("scene", "")):
		node = load(step.get("scene")).instantiate()
	elif step.has("script") and ResourceLoader.exists(step.get("script", "")):
		node = Node2D.new()
		node.set_script(load(step.get("script")))
	if node == null:
		return
	host.add_child(node)
	var at: Array = step.get("at", [0, 0])
	var p := _actor("player")
	var base: Vector2 = p.global_position if p and step.get("relative_to_player", false) else Vector2.ZERO
	node.global_position = base + Vector2(float(at[0]), float(at[1]))
	_spawned[step.get("id", "actor")] = node

func _lock_player(locked: bool) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p and "cutscene_lock" in p:
		p.set("cutscene_lock", locked)

func _cleanup() -> void:
	var cam := _camera()
	if cam and _cam_home != null:
		cam.offset = _cam_home
		cam.zoom = Vector2.ONE
	_cam_home = null
	for id in _spawned.keys():
		if is_instance_valid(_spawned[id]) and _spawned[id].get_meta("keep", false) == false:
			_spawned[id].queue_free()
	_spawned.clear()
	Stage.fade_in(0.3)
