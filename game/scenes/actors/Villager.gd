extends CharacterBody2D
## Villager (R2 Part 1) — a townsfolk NPC that strolls a simple looping route so the
## town feels alive. Reuses the player walk sheet, tinted. Interact (E) for ambient
## dialogue that references the CURRENT sky/weather (set in Part 4 via ambient_lines()).

const SPEED := 26.0

var _tint := Color(1, 1, 1)
var _name := "Warga"
var _waypoints: Array = []       # global positions to loop between
var _wp := 0
var _pause := 0.0
var _sprite: AnimatedSprite2D
var _label: Label

func setup(nm: String, tint: Color, waypoints: Array) -> void:
	_name = nm
	_tint = tint
	_waypoints = waypoints
	if is_inside_tree():
		global_position = waypoints[0]

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("villagers")
	collision_layer = 0
	collision_mask = 0
	_build()
	if not _waypoints.is_empty():
		global_position = _waypoints[0]

func _build() -> void:
	_sprite = AnimatedSprite2D.new()
	var tex := load("res://assets/game/sprites/player/walk.png")
	_sprite.sprite_frames = SheetUtil.build_directional(tex, 16, 4, 4, 8.0)
	_sprite.modulate = _tint
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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

func interact() -> void:
	if Stage.is_busy():
		return
	velocity = Vector2.ZERO
	var lines: Array = ambient_lines()
	await Stage.say(lines[randi() % lines.size()], _name)

## Ambient dialogue — references the CURRENT sky so the world feels time-aware.
func ambient_lines() -> Array:
	var lines := ["Hari yang biasa saja di Greenvale."]
	var weather: String = WorldState.weather
	var moon: String = GameClock.moon_name()
	var hour: int = GameClock.wib_hour()
	if weather == "rain" or weather == "thunderstorm":
		lines.append("Hujan begini enaknya di dalam rumah, bukan?")
	elif weather == "blizzard":
		lines.append("Dingin sekali... jaga kehangatanmu, ya.")
	else:
		lines.append("Cuaca cerah — cocok untuk berkebun.")
	if GameClock.is_night():
		lines.append("Sudah malam. %s menerangi langit." % moon)
	else:
		lines.append("Selamat %s, petualang!" % ("pagi" if hour < 11 else ("siang" if hour < 16 else "sore")))
	if GameClock.is_full_moon():
		lines.append("Bulan purnama... katanya monster jadi lebih ganas.")
	lines.append("Dengar-dengar ada gua tua di dekat sini. Hati-hati.")
	return lines
