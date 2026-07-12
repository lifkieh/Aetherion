extends Node
## Loc — lokalisasi string-key (B15, Decision Log #62). KONVENSI PERMANEN:
## semua teks UI BARU wajib lewat Loc.t("key") mulai commit setelah 2026-07-12;
## retrofit teks lama dilakukan di v0.4.4. Fallback: bahasa aktif → id → key.

var language := "id"                # "id" | "en" (persist via Settings)
var _tables := {}                   # lang -> {key: text}

func _ready() -> void:
	for lang in ["id", "en"]:
		var path := "res://translations/%s.json" % lang
		if FileAccess.file_exists(path):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
			_tables[lang] = parsed if parsed is Dictionary else {}
		else:
			_tables[lang] = {}
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		language = cfg.get_value("general", "language", "id")

func set_language(lang: String) -> void:
	if not (lang in ["id", "en"]):
		return
	language = lang
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("general", "language", lang)
	cfg.save("user://settings.cfg")

## Terjemahkan key. Fallback berjenjang: bahasa aktif → id → key mentah.
func t(key: String) -> String:
	var v: String = _tables.get(language, {}).get(key, "")
	if v == "":
		v = _tables.get("id", {}).get(key, "")
	return v if v != "" else key
