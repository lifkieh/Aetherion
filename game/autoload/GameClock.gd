extends Node
## GameClock — real WIB (UTC+7) time, lunar phase, day/night, sky events.
## The heart of Aetherion (Fase0 §3). Time == device clock forced to WIB.

const WIB_OFFSET := 7 * 3600
const SYNODIC := 29.530588853
const KNOWN_NEW_MOON := 947182440  # 2000-01-06 18:14 UTC reference

# Day/night boundaries (WIB hours)
const DAWN_HOUR := 5
const DAY_HOUR := 7
const GOLDEN_START := 17          # 17:00
const NIGHT_HOUR := 19
const DAWN_END := 6

# --- MUSIM (Addendum A4 / v0.4.3 #83): 4 musim x 2 MINGGU NYATA = siklus 56 hari ---
# Diikat ke tanggal WIB asli (seperti bulan & jam) — dunia berjalan walau game ditutup.
const SEASON_DAYS := 14
const SEASON_EPOCH := 1767225600   # 2026-01-01 00:00 WIB (Semi mulai di sini)

var _last_minute := -1
var _last_hour := -1
var _last_is_night := false
var _last_moon_index := -1
var _last_season_index := -1
var _sky_calendar: Array = []

func _ready() -> void:
	# Db may not be loaded yet at autoload time; pull calendar lazily.
	set_process(true)
	_tick(true)

func _process(_delta: float) -> void:
	_tick(false)

# --- Core time queries ------------------------------------------------------

func now_wib() -> Dictionary:
	var t := Time.get_unix_time_from_system()
	return Time.get_datetime_dict_from_unix_time(int(t) + WIB_OFFSET)

func unix_now() -> int:
	return int(Time.get_unix_time_from_system())

func wib_hour() -> int:
	return now_wib().hour

func time_string() -> String:
	var d := now_wib()
	return "%02d:%02d" % [d.hour, d.minute]

func date_string() -> String:
	var d := now_wib()
	return "%04d-%02d-%02d" % [d.year, d.month, d.day]

# --- Musim ------------------------------------------------------------------

## Hari ke-berapa sejak epoch musim (WIB).
func _season_day_index() -> int:
	var wib := int(Time.get_unix_time_from_system()) + WIB_OFFSET
	return int(floor(float(wib - SEASON_EPOCH) / 86400.0))

func season_index() -> int:
	var d := _season_day_index()
	return int(floor(float(d) / float(SEASON_DAYS))) % 4 if d >= 0 else 0

func season() -> String:
	if Db.seasons.is_empty():
		return "semi"
	return Db.seasons[season_index() % Db.seasons.size()].get("id", "semi")

func season_def() -> Dictionary:
	if Db.seasons.is_empty():
		return {}
	return Db.seasons[season_index() % Db.seasons.size()]

func season_name() -> String:
	return season_def().get("name", "Semi")

## Hari ke-berapa di dalam musim ini (1..SEASON_DAYS).
func season_day() -> int:
	var d := _season_day_index()
	return (d % SEASON_DAYS) + 1 if d >= 0 else 1

func days_to_next_season() -> int:
	return SEASON_DAYS - season_day() + 1

# --- Lunar phase ------------------------------------------------------------

func moon_phase() -> float:
	# 0.0 = new moon, 0.5 = full moon
	var days := (Time.get_unix_time_from_system() - KNOWN_NEW_MOON) / 86400.0
	return fposmod(days, SYNODIC) / SYNODIC

func moon_index() -> int:
	# 0..7 sprite frame: 0 new,1 waxing crescent,2 first quarter,3 waxing gibbous,
	# 4 full,5 waning gibbous,6 last quarter,7 waning crescent
	var p := moon_phase()
	return int(round(p * 8.0)) % 8

func moon_name() -> String:
	return ["Bulan Baru","Sabit Muda","Kuartal Pertama","Cembung Muda","Purnama",
		"Cembung Tua","Kuartal Akhir","Sabit Tua"][moon_index()]

func is_full_moon() -> bool:
	var p := moon_phase()
	return abs(p - 0.5) < 0.02

func is_new_moon() -> bool:
	var p := moon_phase()
	return p < 0.02 or p > 0.98

func tide_level() -> float:
	# -1 extreme low .. +1 extreme high; full & new moon = spring tide (high)
	return cos((moon_phase() - 0.5) * TAU)

# --- Day / night ------------------------------------------------------------

func is_night() -> bool:
	var h := wib_hour()
	return h >= NIGHT_HOUR or h < DAWN_END

func is_golden_hour() -> bool:
	var d := now_wib()
	return (d.hour == GOLDEN_START) or (d.hour == 18 and d.minute <= 30)

func is_morning_dew() -> bool:
	var h := wib_hour()
	return h >= DAWN_HOUR and h < DAY_HOUR

## Day fraction 0..1 (0=midnight) — used for CanvasModulate day/night curve.
func day_fraction() -> float:
	var d := now_wib()
	return (d.hour * 3600.0 + d.minute * 60.0 + d.second) / 86400.0

## Ambient light color for the current time (warm day -> deep blue night).
## Warna ambient dunia: waktu-hari, lalu DIWARNAI MUSIM (A4) — semua scene dunia
## memanggil ini, jadi musim langsung terasa di mana pun.
func ambient_color() -> Color:
	var c := _time_color()
	var sd := season_def()
	var t: Array = sd.get("tint", [])
	if t.size() == 3:
		var st := Color(float(t[0]), float(t[1]), float(t[2]))
		c = c.lerp(c * st, float(sd.get("tint_weight", 0.15)))
	return c

func _time_color() -> Color:
	var f := day_fraction()
	# Keyframes across the day (hour -> color)
	var keys := [
		[0.0,  Color(0.20, 0.24, 0.42)],   # midnight
		[5.0,  Color(0.35, 0.32, 0.48)],   # pre-dawn
		[6.5,  Color(0.95, 0.72, 0.60)],   # sunrise (warm)
		[9.0,  Color(1.0, 1.0, 1.0)],      # full day
		[16.0, Color(1.0, 1.0, 1.0)],
		[17.5, Color(1.0, 0.72, 0.50)],    # golden hour
		[19.0, Color(0.45, 0.40, 0.58)],   # dusk
		[21.0, Color(0.22, 0.26, 0.46)],   # night
		[24.0, Color(0.20, 0.24, 0.42)],
	]
	var h := f * 24.0
	for i in range(keys.size() - 1):
		var a: Array = keys[i]
		var b: Array = keys[i + 1]
		if h >= a[0] and h <= b[0]:
			var t: float = (h - a[0]) / maxf(0.0001, (b[0] - a[0]))
			return (a[1] as Color).lerp(b[1] as Color, t)
	return Color.WHITE

# --- Sky calendar (data-driven special events) ------------------------------

func _ensure_calendar() -> void:
	if _sky_calendar.is_empty() and Engine.has_singleton("Db") == false:
		# Db is an autoload node, access directly.
		pass
	if _sky_calendar.is_empty() and typeof(Db) != TYPE_NIL and Db.sky_calendar.size() > 0:
		_sky_calendar = Db.sky_calendar

func sky_event_today() -> String:
	_ensure_calendar()
	var today := date_string()
	for e in _sky_calendar:
		if e.get("date", "") == today:
			return e.get("name", "")
	return ""

## Whole days from now (WIB) until an ISO date "YYYY-MM-DD" (negative if past).
func days_until(iso_date: String) -> int:
	var target := Time.get_unix_time_from_datetime_string(iso_date + "T00:00:00")
	var now := Time.get_unix_time_from_system() + WIB_OFFSET
	# compare against WIB midnight today
	var d := now_wib()
	var today_mid := Time.get_unix_time_from_datetime_string("%04d-%02d-%02dT00:00:00" % [d.year, d.month, d.day])
	return int(round((target - today_mid) / 86400.0))

## Next `limit` sky-calendar events, soonest first, with day countdowns.
func upcoming_events(limit: int = 5) -> Array:
	_ensure_calendar()
	var out: Array = []
	for e in _sky_calendar:
		var dleft := days_until(e.get("date", ""))
		if dleft >= 0:
			out.append({"name": e.get("name", ""), "date": e.get("date", ""), "days": dleft, "type": e.get("type", "")})
	out.sort_custom(func(a, b): return a.days < b.days)
	return out.slice(0, limit)

## WIB week index (for the weekly prophecy rotation).
func week_index() -> int:
	return int((Time.get_unix_time_from_system() + WIB_OFFSET) / 604800)

# --- Tick / signal emission -------------------------------------------------

func _tick(force: bool) -> void:
	var d := now_wib()
	if d.minute != _last_minute or force:
		_last_minute = d.minute
		EventBus.minute_passed.emit(d)
	if d.hour != _last_hour or force:
		_last_hour = d.hour
		EventBus.hour_passed.emit(d.hour)
		var ev := sky_event_today()
		if ev != "":
			EventBus.sky_event.emit(ev)
	var night := is_night()
	if night != _last_is_night or force:
		_last_is_night = night
		if night:
			EventBus.night_started.emit()
		else:
			EventBus.day_started.emit()
	if is_golden_hour():
		EventBus.golden_hour.emit()
	var si := season_index()
	if si != _last_season_index or force:
		_last_season_index = si
		EventBus.season_changed.emit(season())
	var mi := moon_index()
	if mi != _last_moon_index or force:
		_last_moon_index = mi
		EventBus.moon_phase_changed.emit(mi)
		if is_full_moon():
			EventBus.full_moon_began.emit()
		elif is_new_moon():
			EventBus.new_moon_began.emit()
