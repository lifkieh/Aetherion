class_name NpcSchedule
extends RefCounted
## JADWAL NPC (v0.4.3 #4, Decision Log #97) — tiga slot waktu WIB:
##   pagi   05:00–11:59   ·   sore 12:00–18:59   ·   malam 19:00–04:59
## Tiap NPC bernama punya posisi & aktivitas berbeda per slot. Pergerakan MURAH:
## kalau pemain melihat, ia BERJALAN ke pos barunya; kalau tidak (jauh/di layar
## lain), ia dipindah begitu saja — dunia tak perlu membuktikan dirinya saat
## tak ditonton (sejalan dengan hukum simulasi saat-login, #89).

const SLOTS := ["pagi", "sore", "malam"]
const SEE_RADIUS := 420.0        # di dalam radius ini pemain "melihat" → jalan kaki

static func slot() -> String:
	var h := GameClock.wib_hour()
	if h >= 19 or h < 5:
		return "malam"
	return "pagi" if h < 12 else "sore"

static func slot_label() -> String:
	return {"pagi": "pagi", "sore": "siang/sore", "malam": "malam"}.get(slot(), "")

## Sapaan kontekstual per slot (dipakai NPC persona & warga).
static func greeting() -> String:
	match slot():
		"pagi": return "Pagi. Embun masih di rumput."
		"sore": return "Siang begini paling enak kerja — atau pura-pura kerja."
		_: return "Sudah malam. Jangan jauh-jauh dari lampu."

## Offset posisi untuk slot ini (dari data persona `schedule`), {} bila tak ada.
static func post_for(persona: Dictionary, home: Vector2) -> Dictionary:
	var sch: Dictionary = persona.get("schedule", {})
	var s: Dictionary = sch.get(slot(), {})
	if s.is_empty():
		return {}
	var off: Array = s.get("at", [0, 0])
	return {
		"pos": home + Vector2(float(off[0]), float(off[1])),
		"activity": s.get("do", ""),
	}

## Rumah warga terkunci larut malam (22:00–05:00) — pintu yang tertutup adalah
## cara termurah membuat kota terasa punya penghuni sungguhan.
static func doors_locked() -> bool:
	var h := GameClock.wib_hour()
	return h >= 22 or h < 5
