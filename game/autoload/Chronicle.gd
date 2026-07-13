extends Node
## CHRONICLE — "PENCAPAIAN TERCATAT" (v0.4.3 #4, Decision Log #96).
## Benih dari Kitab Sejarah Dunia (Piagam LEGACY, v0.5–v0.6). Setiap first-clear
## (scenario, boss, ruang rahasia, penebusan Roh Hutan) dicatat PERMANEN dengan
## **tanggal WIB nyata** — bukan "hari ke-12 dalam game", melainkan hari sungguhan
## saat kau melakukannya. Dunia mengingat kapan.
##
## Perayaan: cutscene template "first_clear" + jingle kemenangan dari bank musik +
## NPC terdekat membicarakannya beberapa hari (lewat RumorSystem — dan seperti
## gosip lain, mereka boleh saja salah menceritakannya).

const TALK_DAYS := 3        # berapa hari NPC masih membicarakannya

func entries() -> Array:
	return WorldState.chronicle

## Sudah pernah tercatat?
func has(id: String) -> bool:
	for e in WorldState.chronicle:
		if e.get("id", "") == id:
			return true
	return false

## Catat first-clear. Returns false bila sudah pernah (tak ada perayaan dobel).
func record(id: String, title: String, celebrate: bool = true) -> bool:
	if has(id):
		return false
	var entry := {
		"id": id, "title": title,
		"date": GameClock.date_string(), "time": GameClock.time_string(),
		"season": GameClock.season_name(), "by": PlayerData.char_name,
		"level": PlayerData.level,
	}
	WorldState.chronicle.append(entry)
	EventBus.chronicle_recorded.emit(id, title)
	if celebrate:
		_celebrate(entry)
	return true

func _celebrate(entry: Dictionary) -> void:
	Stage.banner(Loc.t("chronicle.recorded"), "%s — %s WIB" % [entry.title, entry.date])
	Audio.play_stinger("boss_kill")
	if Cutscene.def("first_clear").size() > 0 and not Cutscene.playing:
		Cutscene.play("first_clear")
	# warga akan membicarakannya beberapa hari (boleh keliru — E5 #77)
	WorldState.town_talk = {"text": entry.title, "until": GameClock.date_string(), "days": TALK_DAYS}

## Bahan gosip warga: apa yang sedang dibicarakan kota hari-hari ini ("" bila tak ada).
func town_talk() -> String:
	var t: Dictionary = WorldState.town_talk
	if t.is_empty():
		return ""
	return t.get("text", "")
