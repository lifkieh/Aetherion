extends Node
## Loc — INFRA LOKALISASI PENUH (B15 #62 → v0.4.4, Decision Log #100).
##
## Backend: **Godot TranslationServer** (sesuai blueprint). Tabel dibangun saat boot
## dari `translations/id.json` & `en.json` menjadi Translation resource lalu
## didaftarkan ke TranslationServer — jadi `tr()` bawaan Godot ikut bekerja
## (auto-translate pada Control). `Loc.t()` tetap pintu resmi karena ia mendukung
## **parameter**:
##
##     Loc.t("ui.enchant.success", [Db.item_name(id), lv])   → "✦ Pedang kini +7!"
##
## Fallback berjenjang: bahasa aktif → id → key mentah. Key mentah TAK PERNAH
## membuat crash; ia hanya kelihatan jelek — dan itu memang sinyal untuk kita.

const LANGS := ["id", "en"]

var language := "id"
var _tables := {}                   # lang -> {key: text}

func _ready() -> void:
	for lang in LANGS:
		var path := "res://translations/%s.json" % lang
		var table := {}
		if FileAccess.file_exists(path):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
			if parsed is Dictionary:
				table = parsed
		_tables[lang] = table
		_register(lang, table)
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		language = cfg.get_value("general", "language", "id")
	_apply_locale()

## Daftarkan tabel ke TranslationServer (backend resmi Godot).
func _register(lang: String, table: Dictionary) -> void:
	var tr_res := Translation.new()
	tr_res.locale = lang
	for k in table.keys():
		tr_res.add_message(k, str(table[k]))
	TranslationServer.add_translation(tr_res)

func _apply_locale() -> void:
	TranslationServer.set_locale(language)

func set_language(lang: String) -> void:
	if not (lang in LANGS):
		return
	language = lang
	_apply_locale()
	var cfg := ConfigFile.new()
	cfg.load("user://settings.cfg")
	cfg.set_value("general", "language", lang)
	cfg.save("user://settings.cfg")
	EventBus.language_changed.emit(lang)
	EventBus.toast.emit(t("ui.settings.language_changed"))

## Terjemahkan key, dengan parameter opsional (format printf GDScript).
func t(key: String, args: Array = []) -> String:
	var v: String = _tables.get(language, {}).get(key, "")
	if v == "":
		v = _tables.get("id", {}).get(key, "")
	if v == "":
		return key
	if args.is_empty():
		return v
	return v % args

# --- LOKALISASI DUA JALUR (Decision Log #166) -------------------------------
## **UI/SISTEM** → `Loc.t("key")` (translations/*.json).
## **KONTEN** (dialog NPC, rumor, gosip, flavor, teks quest) → **inline dwibahasa
## di `data/*.json`** — penulis & reviewer melihat kedua bahasa BERSEBELAHAN, dan
## diff-nya terbaca. Itu satu-satunya cara ~4.000 baris pipeline (#162) bisa
## benar-benar direview manusia.
##
## Bentuk yang diterima `c()` — ketiganya sah, supaya migrasi bertahap:
##     "Kalimat lama"                            → string polos (konten lama, ID)
##     {"id": "Halo.", "en": "Hello."}           → dwibahasa penuh (WAJIB untuk teks BARU)
##     {"id": "Halo.", "en": null}               → EN belum ditulis → fallback ke ID
##
## Fallback SELALU ke ID. Sebuah baris konten tak pernah boleh hilang hanya karena
## terjemahannya belum ada — pemain EN melihat kalimat Indonesia, bukan layar kosong.
func c(entry, args: Array = []) -> String:
	var v := ""
	if entry is Dictionary:
		var raw = entry.get(language, null)
		if raw == null or str(raw) == "":
			raw = entry.get("id", "")
		v = str(raw)
	elif entry != null:
		v = str(entry)
	if v == "" or args.is_empty():
		return v
	return v % args

## Daftar konten dwibahasa → daftar string bahasa aktif (mis. `lines` sebuah NPC).
func c_all(entries: Array) -> Array:
	var out: Array = []
	for e in entries:
		out.append(c(e))
	return out

## Apakah entri konten sudah lengkap dua bahasa? (dipakai test pipeline #162:
## teks BARU wajib lahir lengkap keduanya; konten lama boleh menyusul.)
func c_bilingual(entry) -> bool:
	if not (entry is Dictionary):
		return false
	for l in LANGS:
		var v = entry.get(l, null)
		if v == null or str(v).strip_edges() == "":
			return false
	return true

## Apakah key ada (dipakai test kelengkapan terjemahan).
func has(key: String, lang: String = "") -> bool:
	var l := lang if lang != "" else language
	return _tables.get(l, {}).has(key)

func keys(lang: String = "id") -> Array:
	return _tables.get(lang, {}).keys()
