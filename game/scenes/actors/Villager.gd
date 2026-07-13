extends CharacterBody2D
## Villager (R2 Part 1) — a townsfolk NPC that strolls a simple looping route so the
## town feels alive. Reuses the player walk sheet, tinted. Interact (E) for ambient
## dialogue that references the CURRENT sky/weather (set in Part 4 via ambient_lines()).

const SPEED := 26.0

var _config: Dictionary = {}
var _name := "Warga"
var _waypoints: Array = []       # global positions to loop between
var _wp := 0
var _pause := 0.0
var _sprite: AnimatedSprite2D
var _label: Label
var _persona: Dictionary = {}    # NPC berkepribadian (Hukum NPC Aneh, E6 #78)
var _line_idx := 0               # dialog persona bergilir, bukan acak
var _home := Vector2.ZERO        # jangkar jadwal (JADWAL NPC, #97)
var _slot := ""                  # slot waktu terakhir yang diterapkan
var _sched_cd := 0.0

func setup(nm: String, config: Dictionary, waypoints: Array) -> void:
	_name = nm
	_config = config
	_waypoints = waypoints
	if is_inside_tree():
		global_position = waypoints[0]

## Jadikan warga ini NPC berkepribadian (data: town_npcs.json). Aman dipanggil
## sebelum maupun sesudah node masuk tree (penempatan memanggilnya setelah add_child).
func set_persona(p: Dictionary) -> void:
	_persona = p
	if not _persona.is_empty() and is_inside_tree():
		add_to_group("town_folk")

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("villagers")
	if not _persona.is_empty():
		add_to_group("town_folk")
	if _home == Vector2.ZERO and not _waypoints.is_empty():
		_home = _waypoints[0]
	_apply_schedule(true)
	collision_layer = 0
	collision_mask = 0
	_build()
	if not _waypoints.is_empty():
		global_position = _waypoints[0]

func _build() -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = CharGen.sprite_frames(_config if not _config.is_empty() else CharGen.default_config())
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.offset = Vector2(0, -8)     # 32px cell: feet at the node origin
	_sprite.play("idle_down")
	add_child(_sprite)
	_label = Label.new()
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_label.add_theme_font_override("font", load("res://assets/game/fonts/m5x7.ttf"))
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("outline_size", 4)
	_label.text = "%s [E]" % _name
	_label.position = Vector2(-24, -26)
	_label.visible = false
	add_child(_label)

func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)
	# JADWAL (#97): cek slot waktu tiap 2 detik — murah
	_sched_cd -= delta
	if _sched_cd <= 0.0:
		_sched_cd = 2.0
		_apply_schedule(false)
	var p := get_tree().get_first_node_in_group("player")
	if p and _label:
		_label.visible = global_position.distance_to(p.global_position) < 60.0
	if _waypoints.size() < 2:
		return
	if Stage.is_busy():           # freeze while talking / paused
		velocity = Vector2.ZERO
		return
	if _pause > 0.0:
		_pause -= delta
		_sprite.play("idle_" + SheetUtil.dir_from_vec(velocity))
		velocity = Vector2.ZERO
		return
	var target: Vector2 = _waypoints[_wp]
	var to := target - global_position
	if to.length() < 4.0:
		_wp = (_wp + 1) % _waypoints.size()
		_pause = randf_range(0.8, 2.2)
		return
	velocity = to.normalized() * SPEED
	move_and_slide()
	_sprite.play("walk_" + SheetUtil.dir_from_vec(velocity))

## Pindah ke pos jadwal slot ini. Kalau pemain MELIHAT → berjalan (waypoint baru);
## kalau tidak → teleport (murah; dunia tak perlu membuktikan diri saat tak ditonton).
func _apply_schedule(force: bool) -> void:
	if _persona.is_empty():
		return
	var slot := NpcSchedule.slot()
	if slot == _slot and not force:
		return
	_slot = slot
	var post := NpcSchedule.post_for(_persona, _home)
	if post.is_empty():
		return
	var target: Vector2 = post.pos
	var p := get_tree().get_first_node_in_group("player")
	var seen: bool = p != null and global_position.distance_to(p.global_position) < NpcSchedule.SEE_RADIUS
	if seen and is_inside_tree():
		_waypoints = [target, target + Vector2(24, 12)]   # berjalan ke pos barunya
		_wp = 0
	else:
		global_position = target                          # tak dilihat: pindah saja
		_waypoints = [target, target + Vector2(24, 12)]
		_wp = 0

func interact() -> void:
	if Stage.is_busy():
		return
	velocity = Vector2.ZERO
	if not _persona.is_empty():
		await Stage.say(persona_line(), _name)
		return
	var lines: Array = ambient_lines()
	await Stage.say(lines[randi() % lines.size()], _name)

## Dialog NPC berkepribadian: bergilir (agar terasa seperti orang yang sama, bukan
## generator), sesekali diselingi GOSIP yang boleh saja tidak akurat (E5 #77).
func persona_line() -> String:
	var lines: Array = _persona.get("lines", [])
	if lines.is_empty():
		return "..."
	# kota sedang membicarakan sebuah pencapaian? itu lebih hangat daripada gosip biasa
	var talk := Chronicle.town_talk()
	if talk != "" and randf() < 0.2:
		return "Semua orang membicarakannya: %s. Kau dengar juga, kan?" % talk
	# 1 dari 5: sapaan sesuai SLOT WAKTU + apa yang sedang ia kerjakan (#97)
	if randf() < 0.2:
		var post := NpcSchedule.post_for(_persona, _home)
		var doing: String = post.get("activity", "")
		if doing != "":
			return "%s (Ia sedang %s.)" % [NpcSchedule.greeting(), doing]
		return NpcSchedule.greeting()
	# 1 dari 4 giliran: warga ini menggosipkan sesuatu — mungkin keliru
	if randf() < 0.25:
		var r := RumorSystem.speak()
		return r.get("text", "")
	var l: String = lines[_line_idx % lines.size()]
	_line_idx += 1
	return l

func persona() -> Dictionary:
	return _persona

## Ambient dialogue — references the CURRENT sky + town so the world feels alive
## and time-aware. Returns 2-3 rotating lines; interact() picks one at random.
func ambient_lines() -> Array:
	var lines: Array = []
	var weather: String = WorldState.weather
	var moon: String = GameClock.moon_name()
	var hour: int = GameClock.wib_hour()
	# time-of-day greeting
	if GameClock.is_night():
		lines.append("Sudah larut. %s menggantung di langit malam." % moon)
	else:
		lines.append("Selamat %s! Semoga harimu menyenangkan." % ("pagi" if hour < 11 else ("siang" if hour < 16 else "sore")))
	# weather comment
	if weather == "rain" or weather == "thunderstorm":
		lines.append("Hujan begini, air di sumur pasti penuh. Enaknya di dalam rumah.")
	elif weather == "blizzard":
		lines.append("Brr, dingin menusuk... jaga kehangatanmu, ya.")
	else:
		lines.append("Cuaca cerah — pas untuk menjemur atau berkebun.")
	# moon / omen gossip
	if GameClock.is_full_moon():
		lines.append("Bulan purnama... kata Pak Astrolog, monster jadi lebih ganas malam ini.")
	# gosip kota — LEWAT RumorSystem: warga bisa saja salah/membesar-besarkan (E5 #77),
	# dan keajaiban semalam hanya diumumkan lewat mulut mereka (E7 #79)
	lines.append(RumorSystem.speak().get("text", ""))
	return lines
