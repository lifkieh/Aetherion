extends CanvasLayer
## MenuUI (M5) — inventory / crafting / shop overlay. Pauses gameplay while open.
## Built in code; rebuilt each open to reflect current state.

var _font: Font
var mode := "inventory"      # inventory | crafting | shop
var _ctx = null              # bench/npc context
var root: Control
var _panel_main: PanelContainer
var title: Label
var content: VBoxContainer
var gold_lbl: Label

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists("res://assets/game/fonts/m5x7.ttf"):
		_font = load("res://assets/game/fonts/m5x7.ttf")
	add_to_group("inventory_ui")
	_build_frame()
	root.visible = false
	EventBus.item_gained.connect(func(_i, _q): if root.visible: _rebuild())
	EventBus.gold_changed.connect(func(_g): if root.visible: _refresh_gold())
	EventBus.item_crafted.connect(func(_i, _s): if root.visible: _rebuild())

func _mk_label(t: String, s: int = 16, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	if col != Color.WHITE:
		l.add_theme_color_override("font_color", col)
	return l

## Category icon for an item, as a 24x24 TextureRect (UI/UX §7). Adds it to `row`.
func _add_item_icon(row: HBoxContainer, id: String) -> void:
	var path := Db.item_icon(id)
	var tr := TextureRect.new()
	tr.custom_minimum_size = Vector2(24, 24)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if path != "":
		tr.texture = load(path)
	row.add_child(tr)

func _build_frame() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.theme = UiTheme.theme    # unified JRPG UI kit
	add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	_panel_main = PanelContainer.new()
	var panel := _panel_main
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 460)
	panel.position = Vector2(-280, -230)
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	var header := HBoxContainer.new()
	vb.add_child(header)
	title = _mk_label("Tas", 22)
	title.custom_minimum_size = Vector2(300, 0)
	header.add_child(title)
	gold_lbl = _mk_label("Gold: 0", 16)
	header.add_child(gold_lbl)

	var tabs := HBoxContainer.new()
	vb.add_child(tabs)
	for m in [["status", "Status"], ["inventory", "Tas"], ["crafting", "Craft"], ["shop", "Toko"], ["kitab", "Kitab"], ["jurnal", "Jurnal"], ["quest", "Quest"], ["skill", "Skill"], ["trees", "Pohon"], ["grimoire", "Grimoire"], ["pet", "Pet"], ["prof", "Profesi"], ["pedia", "Pedia"], ["panduan", "Panduan"]]:
		var b := Button.new()
		b.text = m[1]
		if _font: b.add_theme_font_override("font", _font)
		b.pressed.connect(func():
			Audio.play_sfx("menu")
			mode = m[0]
			if m[0] == "trees":
				_ctx = null   # tab = tampilan upgrade-di-mana-pun (tanpa lokasi keeper)
			if m[0] == "kitab":
				_kitab_view = ""   # buka tab = kembali ke daftar halaman, bukan prompt lama
			_rebuild())
		UiFx.button(b)
		tabs.add_child(b)
	var mapb := Button.new()
	mapb.text = "🗺 Peta (M)"
	if _font: mapb.add_theme_font_override("font", _font)
	mapb.pressed.connect(func():
		Audio.play_sfx("menu")
		close_menu()
		load("res://scenes/ui/WorldMapUI.gd").open_over(get_tree()))
	UiFx.button(mapb)
	tabs.add_child(mapb)
	var close := Button.new()
	close.text = "Tutup (Esc)"
	if _font: close.add_theme_font_override("font", _font)
	close.pressed.connect(close_menu)
	tabs.add_child(close)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 380)
	vb.add_child(scroll)
	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(520, 0)
	content.add_theme_constant_override("separation", 3)
	scroll.add_child(content)

func _input(event: InputEvent) -> void:
	if not root.visible:
		return
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("toggle_inventory"):
		close_menu()
		get_viewport().set_input_as_handled()

# --- Open / close -----------------------------------------------------------

func toggle() -> void:
	if root.visible: close_menu()
	else: open("inventory")

func open(m: String, ctx = null) -> void:
	mode = m
	_ctx = ctx
	root.visible = true
	get_tree().paused = true
	UiFx.panel_in(_panel_main)   # panel muncul hidup (#44)
	_rebuild()

func close_menu() -> void:
	root.visible = false
	get_tree().paused = false
	_kitab_view = ""   # menutup menu = menutup kitab; jangan kembali ke prompt lama

func _refresh_gold() -> void:
	gold_lbl.text = "Gold: %d" % PlayerData.gold
	gold_lbl.visible = true    # tab Kitab menyembunyikannya lagi saat dibangun

# --- Content ----------------------------------------------------------------

func _clear() -> void:
	for c in content.get_children():
		c.queue_free()

func _row() -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	content.add_child(h)
	return h

func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	if _font: b.add_theme_font_override("font", _font)
	b.pressed.connect(func(): Audio.play_sfx("menu"))
	b.pressed.connect(cb)
	UiFx.button(b)   # hover/press feel (#44)
	return b

func _rebuild() -> void:
	_refresh_gold()
	_clear()
	match mode:
		"inventory": _build_inventory()
		"crafting": _build_crafting()
		"enchant": _build_enchant()
		"auction": _build_auction()
		"kitab": _build_kitab()
		"jurnal": _build_journal()
		"shop": _build_shop()
		"system": _build_system()
		"pedia": _build_pedia()
		"prof": _build_prof()
		"skill": _build_skill()
		"quest": _build_quests()
		"sky": _build_sky()
		"echo": _build_echo()
		"panduan": _build_panduan()
		"status": _build_status()
		"grimoire": _build_grimoire()
		"pet": _build_pet()
		"trees": _build_trees()

func _build_skill() -> void:
	title.text = "Skill Book"
	_build_advanced_block()
	content.add_child(_mk_label("Slot hotbar saat ini:", 15))
	var row := _row()
	for i in range(5):
		var hsid: String = PlayerData.hotbar[i] if i < PlayerData.hotbar.size() else ""
		var usable: bool = hsid != "" and PlayerData.can_use_skill(hsid)
		var l := _mk_label("[%d] %s" % [i + 1, Db.skill(hsid).get("name", "-")], 13, Color(0.9, 0.9, 0.9) if usable else Color(0.7, 0.4, 0.4))
		l.custom_minimum_size = Vector2(100, 0)
		row.add_child(l)
	content.add_child(_mk_label("Prime = tekan angka → tahan klik-kiri untuk channel. Dua+ angka <1.5s = Fusion.", 11))

	# --- Dikuasai (assign to hotbar) ---
	content.add_child(_mk_label("— Dikuasai (klik →slot untuk pasang) —", 15, Color(0.6, 0.9, 0.6)))
	for sk in Db.skills.values():
		var sid: String = sk.get("id", "")
		if not sk.has("unlock") or not PlayerData.can_use_skill(sid):
			continue
		var h := _row()
		var mana: int = int(sk.get("mana_cost", 0))
		var cost_txt: String = ("%d MP/cast" % mana) if mana > 0 else ("drain" if sk.get("kind", "") == "flow" else "gratis")
		var star: String = "★ " if sk.get("ultimate", false) else ""
		var l := _mk_label("%s%s [%s] · %s" % [star, sk.get("name", sid), sk.get("element", "-"), cost_txt], 13)
		l.custom_minimum_size = Vector2(230, 0)
		# COUNTERPLAY (#130): setiap skill punya cara dihindari/dihukum — pemain berhak tahu
		var cp: String = sk.get("counterplay", "")
		if cp != "":
			l.tooltip_text = "Counterplay: " + cp
		h.add_child(l)
		for slot in range(5):
			var s2 := sid
			h.add_child(_btn("→%d" % (slot + 1), func(): PlayerData.hotbar[slot] = s2; EventBus.toast.emit("Slot %d: %s" % [slot + 1, sk.get("name", s2)]); _rebuild()))

	# --- Belum dikuasai (source hints + trainer purchase) ---
	content.add_child(_mk_label("— Belum dikuasai —", 15, Color(0.8, 0.7, 0.5)))
	for sk in Db.skills.values():
		var sid: String = sk.get("id", "")
		if not sk.has("unlock") or PlayerData.can_use_skill(sid):
			continue
		var u: Dictionary = sk.get("unlock", {})
		var h := _row()
		var star: String = "★ " if sk.get("ultimate", false) else ""
		var l := _mk_label("%s%s [%s] — %s" % [star, sk.get("name", sid), sk.get("element", "-"), _unlock_hint(u)], 13, Color(0.7, 0.7, 0.72))
		l.custom_minimum_size = Vector2(330, 0)
		h.add_child(l)
		if u.get("source", "") == "trainer":
			var can_train: bool = PlayerData.level >= int(u.get("level", 1)) and PlayerData.gold >= int(u.get("cost", 0))
			var b := _btn("Latih %d G" % int(u.get("cost", 0)), func():
				if PlayerData.train_skill(sid):
					UiFx.celebrate(content, "✦")   # micro-celebration (#44)
					Audio.play_sfx("levelup", 1.3)
					_rebuild())
			b.disabled = not can_train
			h.add_child(b)

func _unlock_hint(u: Dictionary) -> String:
	match u.get("source", ""):
		"level": return "buka di Level %d" % int(u.get("level", 1))
		"book": return "pelajari dari %s" % Db.item(u.get("book", "")).get("name", "Kitab")
		"trainer": return "Pelatih: %d G (min Lv %d)" % [int(u.get("cost", 0)), int(u.get("level", 1))]
		"boss": return "kalahkan %s pertama kali" % Db.monster(u.get("boss", "")).get("name", "bos")
		"element": return "kuasai elemen %s" % u.get("element", "")
		_: return "?"

func _build_prof() -> void:
	title.text = "Profesi (1 Utama + 2 Sub)"
	var _ccd := Db.cls(PlayerData.char_class)
	if _ccd.get("path", "combat") == "life":
		content.add_child(_mk_label("Class: %s (Jalur Kehidupan) — +50%% EXP domain: %s · Combat Sub: %s" % [_ccd.get("name", "-"), ", ".join(_ccd.get("domains", ["—"])), Db.cls(PlayerData.combat_sub).get("name", "-")], 13, Color(0.9, 0.75, 0.5)))
	else:
		content.add_child(_mk_label("Profesi Combat (class): %s — %s. Maks 1 combat per karakter (GDD §3.2)." % [_ccd.get("name", "-"), _ccd.get("title", "")], 13, Color(0.9, 0.75, 0.5)))
	var main: String = ProfessionSystem.main()
	var subs: Array = ProfessionSystem.subs()
	content.add_child(_mk_label("Utama: %s (+50%% EXP, cap Lv%d) · Sub: %s (75%% efisiensi, cap Lv%d)" % [
		Db.professions.get(main, {}).get("name", "-"), ProfessionSystem.MAIN_CAP,
		("/".join(subs.map(func(s): return Db.professions.get(s, {}).get("name", s))) if not subs.is_empty() else "-"),
		ProfessionSystem.SUB_CAP], 13))
	content.add_child(_mk_label("Ganti utama: %dG + cooldown %d hari. Hanya utama+sub yang dapat XP." % [ProfessionSystem.CHANGE_MAIN_COST, ProfessionSystem.CHANGE_COOLDOWN / 86400], 11))
	for id in Db.professions.keys():
		var def: Dictionary = Db.professions[id]
		var role := ProfessionSystem.role(id)
		var lvl := ProfessionSystem.effective_level(id)
		var xp: int = PlayerData.prof_xp.get(id, 0)
		var h := _row()
		var mark := "★" if role == "main" else ("+" if role == "sub" else "")
		var l := _mk_label("%s %s — Lv %d (%d XP)%s" % [mark, def.get("name", id), lvl, xp, (" [%s]" % role.to_upper() if role != "none" else "")], 14)
		l.custom_minimum_size = Vector2(280, 0)
		if role == "none": l.modulate = Color(0.6, 0.6, 0.6)
		h.add_child(l)
		if role != "main":
			h.add_child(_btn("Utama", func(): var r = ProfessionSystem.set_main(id); if not r.ok: EventBus.toast.emit(r.reason); _rebuild()))
		if role != "main":
			h.add_child(_btn(("−Sub" if role == "sub" else "+Sub"), func(): var r = ProfessionSystem.toggle_sub(id); if not r.ok: EventBus.toast.emit(r.reason); _rebuild()))

func _build_echo() -> void:
	var d: Dictionary = _ctx if _ctx is Dictionary else {}
	title.text = d.get("name", "Gema Pedagang")
	var greet := _mk_label(d.get("greeting", ""), 14)
	greet.autowrap_mode = TextServer.AUTOWRAP_WORD
	greet.custom_minimum_size = Vector2(500, 0)
	greet.add_theme_color_override("font_color", Color(0.75, 0.7, 0.95))
	content.add_child(greet)
	content.add_child(_mk_label("— Kios —", 16))
	for w in d.get("wares", []):
		var h := _row()
		var id: String = w.get("item", "")
		var price: int = int(w.get("price", 0))
		var l := _mk_label("%s — %dG" % [Db.item_name(id), price], 14)
		l.custom_minimum_size = Vector2(320, 0)
		h.add_child(l)
		h.add_child(_btn("Beli", func():
			if PlayerData.spend_gold(price):
				PlayerData.add_item(id, 1)
				EventBus.toast.emit("Membeli %s dari gema." % Db.item_name(id))
				Audio.play_sfx("coin")
				_rebuild()
			else:
				EventBus.toast.emit("Gold tidak cukup.")))

func _build_sky() -> void:
	title.text = "Menara Astrologer"
	# pohon CELESTIAL hanya TERLIHAT di menara ini (Decision Log #30)
	content.add_child(_btn("🌳 Pohon Celestial (Sun/Moon/Star) — lihat", func():
		mode = "trees"; _ctx = {"location": "astrologer_tower"}; _rebuild()))
	content.add_child(_mk_label("☾ Fase: %s   ·   %s %s WIB" % [GameClock.moon_name(), GameClock.date_string(), GameClock.time_string()], 16))
	var tide := GameClock.tide_level()
	var tide_txt := "Pasang tinggi" if tide > 0.3 else ("Surut ekstrem" if tide < -0.3 else "Normal")
	content.add_child(_mk_label("Pasang-surut: %s   ·   Cuaca: %s" % [tide_txt, WorldState.weather.capitalize()], 14))
	# --- RASI (A5 #91): aset 12 rasi dipakai; rasi naik berganti tiap minggu nyata ---
	var asc: Dictionary = RasiSystem.ascendant()
	var brt: Dictionary = RasiSystem.birth()
	var rrow := _row()
	_add_rasi_art(rrow, asc)
	var atxt := _mk_label("RASI NAIK MINGGU INI: %s\n%s" % [asc.get("name", "-"), asc.get("philosophy", "")], 14, Color(0.85, 0.88, 1.0))
	atxt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	atxt.custom_minimum_size = Vector2(380, 0)
	rrow.add_child(atxt)
	var brow := _row()
	_add_rasi_art(brow, brt)
	var bonus_txt := "-"
	var bd: Dictionary = brt.get("bonus", {})
	if bd.get("value", 0.0) > 0.0:
		bonus_txt = "%s +%d%%" % [RASI_BONUS_LABEL.get(bd.get("field", ""), bd.get("field", "")), int(round(float(bd.value) * 100))]
	var btxt := _mk_label("Rasi Kelahiranmu: %s   (%s)\n%s" % [
		PlayerData.birth_sign if PlayerData.birth_sign != "" else "-", bonus_txt, brt.get("philosophy", "")], 13, Color(1.0, 0.9, 0.6))
	btxt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btxt.custom_minimum_size = Vector2(380, 0)
	brow.add_child(btxt)
	# TRIAL OF THE RASI (#101): hanya saat rasi KELAHIRANMU naik
	var trow := _row()
	var tb := _btn(Loc.t("trial.button"), func():
		AdvancedClass.run_trial()
		_rebuild())
	tb.disabled = not AdvancedClass.trial_available()
	trow.add_child(tb)
	trow.add_child(_mk_label(AdvancedClass.trial_reason() if not AdvancedClass.trial_available() else "✧ Langit membuka jalanmu — sekarang.", 11,
		Color(0.75, 0.8, 0.95) if not AdvancedClass.trial_available() else Color(1.0, 0.9, 0.5)))
	content.add_child(_mk_label("— Ramalan Mingguan —", 16))
	var prophecy := RasiSystem.weekly_prophecy()
	var pl := _mk_label(prophecy, 14)
	pl.autowrap_mode = TextServer.AUTOWRAP_WORD
	pl.custom_minimum_size = Vector2(500, 0)
	pl.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	content.add_child(pl)
	# --- PRAKIRAAN 24 JAM (Audit B): benar ~80%; sisanya langit berubah pikiran ---
	content.add_child(_mk_label("— Prakiraan Langit 24 Jam (akurasi ~80%) —", 16))
	var fc: Array = WorldState.forecast(24)
	var frow := _row()
	var i := 0
	for f in fc:
		if i % 8 == 0 and i > 0:
			frow = _row()
		var icon: String = {"sunny": "☀", "rain": "☔", "thunderstorm": "⚡", "blizzard": "❄", "blood_moon": "🌕"}.get(f.weather, "·")
		var fl := _mk_label("%02d:00 %s" % [f.hour, icon], 12, Color(0.78, 0.82, 0.95))
		fl.tooltip_text = f.label
		fl.custom_minimum_size = Vector2(60, 0)
		frow.add_child(fl)
		i += 1
	content.add_child(_mk_label("— Langit Mendatang (kalender nyata) —", 16))
	var events: Array = GameClock.upcoming_events(6)
	if events.is_empty():
		content.add_child(_mk_label("(tak ada event terjadwal)", 13))
	for e in events:
		var when := "hari ini" if e.days == 0 else ("besok" if e.days == 1 else "%d hari lagi" % e.days)
		content.add_child(_mk_label("✦ %s — %s (%s)" % [e.name, e.date, when], 14))

const RASI_BONUS_LABEL := {
	"hp_pct": "HP", "mp_pct": "MP", "atk_pct": "ATK", "matk_pct": "MATK", "def_pct": "DEF",
	"crit_pct": "Krit", "evasion_add": "Evasion", "drop_add": "Drop", "harvest_pct": "Panen",
	"exp_pct": "EXP", "gold_pct": "Emas",
}

## Gambar rasi 96px (aset yang sudah ada, akhirnya dipakai — A5 #91).
func _add_rasi_art(row: HBoxContainer, r: Dictionary) -> void:
	var tr := TextureRect.new()
	tr.custom_minimum_size = Vector2(72, 72)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var path: String = r.get("asset", "")
	if path != "" and ResourceLoader.exists(path):
		tr.texture = load(path)
	row.add_child(tr)

func _weekly_prophecy() -> String:
	# Rotating riddle that hints at an active/eligible Hidden Scenario (v0.3 §3.2).
	var scs: Array = Db.scenarios.filter(func(s): return s.has("hint"))
	if scs.is_empty():
		return "Langit sunyi minggu ini."
	var pick: Dictionary = scs[GameClock.week_index() % scs.size()]
	return "\"%s\"" % pick.get("hint", "")

## Taksonomi quest (E8 #80, blueprint "Quest Taxonomy"). Hukum: setiap quest harus
## MENGUBAH sesuatu; kill/collect tanpa konteks manusia dilarang jadi inti quest.
const QUEST_TYPE_LABEL := {
	"Need": "· Kebutuhan", "Dream": "· Impian", "Fear": "· Ketakutan",
	"Ambition": "· Ambisi", "Memory": "· Kenangan", "Legacy": "· Warisan",
	"Hidden": "· Tersembunyi", "Chronicle": "· Kronik", "Myth": "· Mitos",
	"World": "· Dunia", "Era": "· Era",
}
const QUEST_TYPE_COLOR := {
	"Need": Color(0.75, 0.8, 0.7), "Dream": Color(0.75, 0.85, 1.0), "Fear": Color(0.9, 0.65, 0.65),
	"Ambition": Color(0.95, 0.85, 0.55), "Memory": Color(0.8, 0.75, 0.95), "Legacy": Color(1.0, 0.85, 0.4),
	"Hidden": Color(0.6, 0.6, 0.7), "Chronicle": Color(0.85, 0.8, 0.6), "Myth": Color(0.8, 0.6, 0.95),
	"World": Color(0.6, 0.85, 0.8), "Era": Color(1.0, 0.7, 0.5),
}

## JURNAL QUEST TERPUSAT (v0.4.3 #1 / #84): tujuan aktif + taksonomi + pelacakan.
## Papan Quest = tempat MENGAMBIL & MENGKLAIM; Jurnal = tempat MENGINGAT.
func _build_journal() -> void:
	title.text = "Jurnal"
	QuestSystem.ensure_today()
	var tracked: Dictionary = QuestSystem.tracked()
	content.add_child(_mk_label("Klik 'Lacak' untuk menampilkan tujuan + arah sasaran di layar. Klik lagi untuk berhenti.", 11, Color(0.75, 0.8, 0.95)))
	var active: Array = []
	var done: Array = []
	for q in QuestSystem.quests():
		if q.get("claimed", false):
			done.append(q)
		else:
			active.append(q)
	content.add_child(_mk_label("— Sedang berjalan (%d) —" % active.size(), 15, Color(0.6, 0.9, 0.6)))
	if active.is_empty():
		content.add_child(_mk_label("(tidak ada tujuan aktif — ambil dari Papan Quest)", 12, Color(0.6, 0.6, 0.65)))
	for q in active:
		var h := _row()
		var is_tracked: bool = not tracked.is_empty() and tracked.get("id", "") == q.get("id", "")
		var mark := "🎯 " if is_tracked else ""
		var status := "SELESAI — klaim di Papan" if q.get("done", false) else "%d/%d" % [q.progress, q.count]
		var l := _mk_label("%s%s  [%s]" % [mark, q.name, status], 14, Color(1.0, 0.9, 0.5) if is_tracked else Color.WHITE)
		l.custom_minimum_size = Vector2(300, 0)
		h.add_child(l)
		var qt: String = q.get("quest_type", "")
		if qt != "":
			h.add_child(_mk_label(QUEST_TYPE_LABEL.get(qt, qt), 11, QUEST_TYPE_COLOR.get(qt, Color(0.7, 0.75, 0.85))))
		h.add_child(_btn("Berhenti" if is_tracked else "Lacak", _do_track.bind(q.get("id", ""))))
		# alasan manusia di balik quest (Hukum Quest E8): ditampilkan, bukan disembunyikan
		var d := _mk_label("   %s" % q.get("desc", ""), 11, Color(0.72, 0.76, 0.86))
		d.custom_minimum_size = Vector2(480, 0)
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(d)
	if not done.is_empty():
		content.add_child(_mk_label("— Selesai hari ini (%d) —" % done.size(), 15, Color(0.7, 0.7, 0.75)))
		for q in done:
			var dl := _mk_label("✔ %s" % q.name, 13, Color(0.55, 0.55, 0.6))
			content.add_child(dl)

## BENCANA (#145): desa sedang menderita — pemain BOLEH menolong (Stewardship).
## Kalau tidak ditolong, ia tetap mereda sendiri. Dunia tidak menyandera pemain.
func _build_dark_aid() -> void:
	if not MiracleSystem.dark_active():
		return
	var d := MiracleSystem.dark_def()
	var head := _mk_label("⚠ %s — %s" % [d.get("name", ""), d.get("effect_note", "")], 14, Color(0.95, 0.6, 0.5))
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.custom_minimum_size = Vector2(500, 0)
	content.add_child(head)
	content.add_child(_mk_label(Loc.t("dark.days_left", [MiracleSystem.days_left()]), 11, Color(0.8, 0.75, 0.7)))
	var c := MiracleSystem.aid_cost()
	var h := _row()
	var cost_txt := ""
	if c.get("item", "") != "":
		cost_txt = "%d %s" % [int(c.qty), Db.item_name(c.item)]
	elif int(c.get("gold", 0)) > 0:
		cost_txt = "%d G" % int(c.gold)
	h.add_child(_mk_label(Loc.t("dark.aid_offer", [cost_txt]), 12, Color(0.85, 0.88, 0.95)))
	h.add_child(_btn(Loc.t("dark.aid_button"), func():
		MiracleSystem.aid()
		_rebuild()))

func _do_track(quest_id: String) -> void:
	QuestSystem.track(quest_id)
	_rebuild()

func _build_quests() -> void:
	title.text = "Papan Quest Harian"
	_build_dark_aid()
	QuestSystem.ensure_today()
	content.add_child(_mk_label("Tanggal: %s (reset tiap hari WIB)" % PlayerData.daily_quests.get("date", "?"), 13))
	var qs: Array = QuestSystem.quests()
	if qs.is_empty():
		content.add_child(_mk_label("(tidak ada quest)", 14))
	for q in qs:
		var h := _row()
		var cond := ""
		if q.get("condition", "") == "rain": cond = " ☔"
		elif q.get("condition", "") == "full_moon": cond = " 🌕"
		var status := "✔" if q.done else "%d/%d" % [q.progress, q.count]
		var reward := "%dG" % q.reward_gold
		if q.reward_item != "": reward += " + %s x%d" % [Db.item_name(q.reward_item), q.reward_qty]
		var l := _mk_label("%s%s  [%s]  → %s" % [q.name, cond, status, reward], 14)
		l.custom_minimum_size = Vector2(360, 0)
		l.tooltip_text = q.get("desc", "")
		if q.claimed: l.modulate = Color(0.5, 0.5, 0.5)
		h.add_child(l)
		# TAKSONOMI QUEST (E8 #80): label kecil — quest ini menyentuh apa dari manusia?
		var qt: String = q.get("quest_type", "")
		if qt != "":
			var tag := _mk_label(QUEST_TYPE_LABEL.get(qt, qt), 11, QUEST_TYPE_COLOR.get(qt, Color(0.7, 0.75, 0.85)))
			tag.tooltip_text = "Taksonomi quest: %s" % qt
			h.add_child(tag)
		if q.done and not q.claimed:
			h.add_child(_btn("Klaim", func(): QuestSystem.claim(q.id); _rebuild()))
		elif q.claimed:
			h.add_child(_mk_label("diklaim", 12))
		else:
			h.add_child(_btn("Lacak", _do_track.bind(q.get("id", ""))))

## JALUR LANJUTAN (#101; gerbang mengikuti band konten — #153) — janji teaser ClassSelect akhirnya dibayar.
func _build_advanced_block() -> void:
	var head := _mk_label(Loc.t("adv.title"), 16, Color(1.0, 0.86, 0.42))
	content.add_child(head)
	if PlayerData.advanced_class != "":
		content.add_child(_mk_label("✦ %s" % PlayerData.advanced_class, 14, Color(0.8, 1.0, 0.8)))
	elif PlayerData.level < AdvancedClass.gate_level():
		content.add_child(_mk_label(Loc.t("adv.locked_lv", [AdvancedClass.gate_level()]), 12, Color(0.7, 0.72, 0.8)))
	else:
		content.add_child(_mk_label(Loc.t("adv.progress",
			[AdvancedClass.adv_progress(), AdvancedClass.ADV_KILLS]), 12, Color(0.9, 0.85, 0.6)))
		if AdvancedClass.adv_ready():
			for path in AdvancedClass.paths(PlayerData.char_class):
				var h := _row()
				var l := _mk_label("%s — %s" % [path.name, path.desc], 13)
				l.custom_minimum_size = Vector2(360, 0)
				l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				h.add_child(l)
				var pn: String = path.name
				h.add_child(_btn("Pilih", func():
					AdvancedClass.choose(pn)
					_rebuild()))

func _build_pedia() -> void:
	title.text = "Aetherpedia"
	# --- PENCAPAIAN TERCATAT (benih Chronicle, #96): tanggal WIB NYATA ---
	var ch := _mk_label("✦ Pencapaian Tercatat (Kitab Sejarah — benih)", 18)
	ch.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	content.add_child(ch)
	var entries: Array = Chronicle.entries()
	if entries.is_empty():
		content.add_child(_mk_label("Belum ada yang tercatat. Dunia masih menunggu kau melakukan sesuatu yang layak diingat.", 12, Color(0.7, 0.72, 0.8)))
	for e in entries:
		var l := _mk_label("• %s — %s %s WIB (%s, Lv %d, oleh %s)" % [
			e.get("title", "?"), e.get("date", ""), e.get("time", ""),
			e.get("season", ""), int(e.get("level", 1)), e.get("by", "")], 12, Color(0.88, 0.9, 1.0))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(500, 0)
		content.add_child(l)
	# Hukum pertumbuhan NPC (#137) — dunia yang jujur tentang dirinya sendiri
	content.add_child(_mk_label("— Tentang orang-orang di dunia ini —", 15, Color(0.8, 0.85, 1.0)))
	for line in [
		"Kebanyakan orang di Aetherion bekerja, berkeluarga, menua, dan meninggal tanpa menjadi legenda. Itu BUKAN kegagalan — dunia ini dibangun oleh jutaan orang biasa.",
		"Bakat besar itu langka, dan bakat saja tidak cukup. Yang mengubah sejarah adalah bakat + usaha + KESEMPATAN + sedikit keberuntungan.",
		"Banyak kehidupan gagal berkembang bukan karena kurang bakat — melainkan karena tak pernah mendapat kesempatan. Dan kau, petualang, adalah sumber kesempatan terbesar di dunia ini.",
		"Orang bisa patah. Duka, trauma, dan kelelahan menurunkan mereka. Kekuatan mental adalah bagian dari kekuatan.",
	]:
		var l2 := _mk_label("• %s" % line, 11, Color(0.75, 0.78, 0.88))
		l2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l2.custom_minimum_size = Vector2(500, 0)
		content.add_child(l2)
	# Roh Hutan: keadaan hutan (Stewardship terlihat)
	if WorldState.spirit_state != "none":
		var st := "MURKA — hutan memucat; tanam %d bibit lagi (tombol G di luar kota)" % ForestSpiritSystem.debt() if ForestSpiritSystem.is_angry() else "BERKAH — hasil kayu & herbal lebih murah hati"
		content.add_child(_mk_label("🌳 Roh Hutan: %s" % st, 12, Color(0.95, 0.6, 0.4) if ForestSpiritSystem.is_angry() else Color(0.6, 0.95, 0.6)))
	content.add_child(_mk_label("Tiap ekor monster dirol RANK BINTANG ★1–★5 (±6% stat, tampil di atas HP bar), 0–2 TRAIT individu (Kekar/Liat/Gesit/Beruntung/Berbisa), dan 1/500 lahir ✦MUTASI (emas, +10% stat, drop lebih royal).", 11, Color(0.75, 0.8, 0.95)))
	# --- Dunia / lore (Celestia canon) ---
	var lore := _mk_label("🌍 Dunia Aetherion", 18)
	lore.add_theme_color_override("font_color", UiTheme.ACCENT)
	content.add_child(lore)
	for line in [
		"Celestia Kingdom — ibukota agung tempat SEMUA ras hidup berdampingan. Multi-ras adalah jati dirinya; kota terbesar di Aetherion.",
		"Ras: Manusia, Serigala (Wolfkin), Kadal (Lizardkin), Permen (Candyfolk), Es (Frostkin), dan Mayat Hidup (Undead).",
		"Naga: yang kau temui di Storm Island adalah DRAKE muda — bukan Naga Kuno. Naga Kuno memilih siapa yang berjalan bersamanya, dan tidak muncul hanya karena badai.",
		"Tiap pemukiman punya warna rasnya: Greenvale kaum manusia; Frostpeak dihuni Frostkin & Wolfkin berbulu tebal.",
	]:
		var b := _mk_label(line, 13)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(500, 0)
		content.add_child(b)
	content.add_child(_mk_label(" ", 8))
	var mon_seen := Achievements.discovered_count("monsters")
	var mon_total := Achievements.total_monsters()
	content.add_child(_mk_label("Monster ditemukan: %d / %d" % [mon_seen, mon_total], 16))
	for id in Db.monsters.keys():
		var seen: bool = PlayerData.discovered.get("monsters", {}).has(id)
		var def := Db.monster(id)
		var txt := "%s — %s/%s" % [def.get("name", id), def.get("rarity", "?"), def.get("element", "-")] if seen else "??? (belum ditemui)"
		var l := _mk_label(txt, 14)
		if not seen: l.modulate = Color(0.5, 0.5, 0.5)
		content.add_child(l)
	content.add_child(_mk_label("— Gelar (klik untuk pasang) —", 16))
	if PlayerData.titles.is_empty():
		content.add_child(_mk_label("(belum ada gelar — raih pencapaian!)", 13))
	for t in PlayerData.titles:
		var h := _row()
		var marker := "★ " if t == PlayerData.active_title else ""
		var l := _mk_label(marker + t, 14)
		l.custom_minimum_size = Vector2(300, 0)
		h.add_child(l)
		h.add_child(_btn("Pasang", func(): PlayerData.active_title = t; PlayerData.recalculate_stats(); _rebuild()))

func _build_system() -> void:
	title.text = "Menu Sistem"
	content.add_child(_mk_label("— Simpan —", 16))
	for slot in [1, 2, 3]:
		var h := _row()
		var meta := SaveManager.save_meta(slot)
		var info := "kosong" if meta.is_empty() else "%s Lv%d (%s)" % [meta.get("name", "?"), meta.get("level", 1), meta.get("saved_at_str", "?")]
		var l := _mk_label("Slot %d: %s" % [slot, info], 14)
		l.custom_minimum_size = Vector2(340, 0)
		h.add_child(l)
		h.add_child(_btn("Simpan", func(): SaveManager.save_game(slot); _rebuild()))
		if SaveManager.has_save(slot):
			h.add_child(_btn("Muat", _load_slot.bind(slot)))
	content.add_child(_mk_label("— Opsi —", 16))
	var eco := CheckButton.new()
	eco.text = "Mode Hemat (30fps, tanpa VFX cuaca)"
	if _font: eco.add_theme_font_override("font", _font)
	eco.button_pressed = Settings.eco_mode
	eco.toggled.connect(func(v): Settings.set_eco(v))
	content.add_child(eco)
	var mute := CheckButton.new()
	mute.text = "Bisukan Audio"
	if _font: mute.add_theme_font_override("font", _font)
	mute.button_pressed = Settings.muted
	mute.toggled.connect(func(v): Settings.set_muted_pref(v))
	content.add_child(mute)
	content.add_child(_mk_label(" ", 8))
	content.add_child(_btn("Kembali ke Menu Utama", func(): close_menu(); Stage.go_to_scene("res://scenes/ui/MainMenu.tscn")))

func _load_slot(slot: int) -> void:
	if SaveManager.load_game(slot):
		close_menu()
		Stage.go_to_scene("res://scenes/Main.tscn")

func _build_inventory() -> void:
	title.text = "Tas"
	if PlayerData.inventory.is_empty():
		content.add_child(_mk_label("(tas-mu masih seringan bulu — ayo berpetualang!)", 14))
	# slotted icon grid with hover tooltips (R2 Part 3)
	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	content.add_child(grid)
	for id in PlayerData.inventory.keys():
		grid.add_child(_item_slot(id))
	content.add_child(_mk_label(" ", 6))
	content.add_child(_mk_label("— Perlengkapan terpasang —", 15, Color(0.7, 0.85, 1.0)))
	for pair in [["equipped_weapon", "Senjata"], ["equipped_armor", "Zirah"], ["equipped_accessory", "Aksesori"]]:
		var eid: String = PlayerData.get(pair[0])
		var h := _row()
		h.add_child(_mk_label("%s: %s" % [pair[1], (Db.item_name(eid) if eid != "" else "-")], 14))
		if eid != "":
			h.add_child(_btn("Lepas", func(): PlayerData.equip_item(eid); _rebuild()))
	content.add_child(_mk_label("Klik item untuk pakai/pasang · arahkan kursor untuk banding stat (hijau=lebih baik).", 11))

func _item_slot(id: String) -> Control:
	var def := Db.item(id)
	var slot = preload("res://scenes/ui/ItemSlot.gd").new()
	slot.custom_minimum_size = Vector2(52, 52)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.12, 0.26, 0.95)
	sb.border_color = _tier_color(def.get("tier", "F"))
	sb.set_border_width_all(2); sb.set_corner_radius_all(4)
	slot.add_theme_stylebox_override("panel", sb)
	slot.set_tip(_item_tooltip_bb(id, def), _font)
	var path := Db.item_icon(id)
	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 4; icon.offset_top = 3; icon.offset_right = -4; icon.offset_bottom = -9
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if path != "":
		icon.texture = load(path)
	slot.add_child(icon)
	var qty := _mk_label("x%d" % PlayerData.inventory[id], 11)
	qty.anchor_top = 1.0; qty.anchor_bottom = 1.0; qty.anchor_left = 1.0; qty.anchor_right = 1.0
	qty.position = Vector2(-22, -15)
	slot.add_child(qty)
	slot.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_use_item(id, def))
	return slot

func _tier_color(tier: String) -> Color:
	return {
		"F": Color(0.55, 0.58, 0.66), "E": Color(0.5, 0.7, 0.55), "D": Color(0.45, 0.65, 0.9),
		"C": Color(0.65, 0.5, 0.9), "B": Color(0.9, 0.6, 0.35), "A": Color(1.0, 0.82, 0.35),
		"S": Color(1.0, 0.5, 0.5),
	}.get(tier, Color(0.55, 0.58, 0.66))

const _GEAR_STAT_LABELS := [["atk", "ATK"], ["def", "DEF"], ["matk", "MATK"], ["mdef", "MDEF"], ["hp_bonus", "HP"], ["mp_bonus", "MP"]]

## Rich (BBCode) tooltip. For equippable gear, appends a green/red comparison
## against whatever is currently equipped in that slot (PC5).
func _item_tooltip_bb(id: String, def: Dictionary) -> String:
	var tier: String = def.get("tier", "F")
	var t := "[b]%s[/b]  [color=#%s]『%s』[/color]\n" % [def.get("name", id), _tier_color(tier).to_html(false), tier]
	var type_id: String = def.get("type", "")
	t += "[i]%s[/i]" % {"weapon": "Senjata", "armor": "Zirah", "accessory": "Aksesori", "material": "Bahan",
		"consumable": "Ramuan", "orb": "Orb", "seed": "Benih", "gear": "Perlengkapan", "bait": "Umpan",
		"junk": "Rongsokan", "skillbook": "Kitab Skill", "coating": "Salut Senjata"}.get(type_id, type_id)
	# meta gear v0.4.2: kualitas, enchant, maker's mark
	if type_id in ["weapon", "armor", "accessory"] and PlayerData.gear_meta.has(id):
		var gm: Dictionary = PlayerData.gear_meta[id]
		var ench := int(gm.get("enchant", 0))
		var qk: String = gm.get("quality", "normal")
		var bits := []
		if ench > 0: bits.append("[color=#ffd76b]+%d[/color]" % ench)
		if qk != "normal": bits.append("[color=#8fd0ff]%s[/color]" % PlayerData.QUALITY_NAME.get(qk, qk))
		if not bits.is_empty(): t += "  " + " ".join(bits)
		if gm.get("maker", "") != "":
			t += "
[color=#b9b2c9][i]Tempaan %s[/i][/color]" % gm.get("maker", "")
	var stats := []
	for pair in _GEAR_STAT_LABELS:
		if def.has(pair[0]): stats.append("%s %d" % [pair[1], int(def[pair[0]])])
	if def.has("heal"): stats.append("Pulih %d HP" % int(def.heal))
	if def.has("restore_mp"): stats.append("Pulih %d MP" % int(def.restore_mp))
	if def.has("value"): stats.append("~%dG" % int(def.value))
	if not stats.is_empty():
		t += "\n" + " · ".join(stats)
	# comparison vs equipped item in the same slot
	var slot := PlayerData.slot_for_item(id)
	if slot != "":
		var eq_id: String = PlayerData.get(slot)
		if eq_id == id:
			t += "\n[color=#8fd0ff](terpasang)[/color]"
		else:
			var eq := Db.item(eq_id)
			t += "\n[color=#9aa0b0]vs %s:[/color] " % (Db.item_name(eq_id) if eq_id != "" else "kosong")
			var deltas := []
			for pair in _GEAR_STAT_LABELS:
				var d: int = int(def.get(pair[0], 0)) - int(eq.get(pair[0], 0))
				if d != 0:
					var col := "#6fe06f" if d > 0 else "#e56b6b"
					deltas.append("[color=%s]%s %+d[/color]" % [col, pair[1], d])
			t += " ".join(deltas) if not deltas.is_empty() else "[color=#9aa0b0]setara[/color]"
	var flavor: String = def.get("flavor", "")
	if flavor != "":
		t += "\n[color=#b9b2c9][i]\"%s\"[/i][/color]" % flavor
	return t

func _use_item(id: String, def: Dictionary) -> void:
	match def.get("type", ""):
		"weapon", "armor", "accessory":
			PlayerData.equip_item(id)
			Audio.play_sfx("menu")
			_rebuild()
		"consumable":
			_use_consumable(id, def)
		"gear":
			# Rumah Kaca: dipasang sekali, musim tak lagi membatasi tanam (A4 #83)
			if id == "greenhouse_kit":
				if WorldState.greenhouse:
					EventBus.toast.emit(Loc.t("greenhouse.exists"))
				elif PlayerData.item_count(id) > 0:
					PlayerData.remove_item(id, 1)
					WorldState.greenhouse = true
					Audio.play_sfx("success")
					EventBus.toast.emit(Loc.t("greenhouse.built"))
					_rebuild()
		"coating":
			# lapisi senjata: elemen dominan tetap, +25% sekunder (v0.4.2)
			if PlayerData.item_count(id) > 0:
				PlayerData.remove_item(id, 1)
				PlayerData.apply_coating(def.get("coat_element", "none"), float(def.get("coat_dur", 180)))
				Audio.play_sfx("success")
				_rebuild()
		"skillbook":
			if PlayerData.use_skillbook(id):
				_rebuild()

func _use_consumable(id: String, def: Dictionary) -> void:
	if PlayerData.item_count(id) <= 0: return
	PlayerData.remove_item(id, 1)
	if def.has("heal"): PlayerData.heal(int(def.heal))
	if def.has("restore_mp"): PlayerData.restore_mp(int(def.restore_mp))
	Audio.play_sfx("success")
	EventBus.toast.emit("Menggunakan " + def.get("name", id))
	# Eating candy feeds the Sugar Queen's Tea Party hidden scenario (v0.2 §8.2).
	if def.get("candy", false):
		WorldState.add_counter("candies_eaten")
		close_menu()
		if ScenarioManager.try_trigger("eat_candy"):
			return
	_rebuild()

func _build_crafting() -> void:
	title.text = "Bengkel Kerja"
	for r in Db.recipes:
		var h := _row()
		var result_name := Db.item_name(r.get("result", ""))
		var ing_txt := []
		for ing in r.get("ingredients", []):
			ing_txt.append("%s x%d" % [Db.item_name(ing.get("item", "")), ing.get("qty", 1)])
		var access: Dictionary = ProfessionSystem.can_use_recipe(r)
		var can: bool = CraftingSystem.can_craft(r) and bool(access.ok)
		var rate := int(round(CraftingSystem.success_rate(r) * 100))
		var tier: String = Db.item(r.get("result", "")).get("tier", "F")
		var mark := "✦ " if CraftingSystem.is_transcendent(r) else ""
		var l := _mk_label("%s%s [%s]  (%d%%)  ← %s" % [mark, result_name, tier, rate, ", ".join(ing_txt)], 14)
		l.custom_minimum_size = Vector2(400, 0)
		if not can: l.modulate = Color(0.6, 0.6, 0.6)
		if not access.ok: l.tooltip_text = access.reason
		h.add_child(l)
		if not access.ok:
			h.add_child(_mk_label("🔒", 14))
		var b := _btn("✦ Tempa" if CraftingSystem.is_transcendent(r) else "Craft", _do_craft.bind(r))
		b.disabled = not can
		h.add_child(b)

func _do_craft(r: Dictionary) -> void:
	# Tier A+ = crafting Transenden: MOMEN ritual dulu, roll dieksekusi di dalamnya (#25)
	if CraftingSystem.is_transcendent(r):
		var rit := TranscendentRitual.play(self, r.get("id", ""), CraftingSystem.recipe_tier(r))
		rit.finished.connect(_after_ritual)
	else:
		CraftingSystem.craft(r.get("id", ""))
		_rebuild()

func _after_ritual(_res: Dictionary) -> void:
	if is_instance_valid(self) and is_inside_tree():
		_rebuild()

func _build_enchant() -> void:
	title.text = "Enchanter — Bisikan Mantra"
	content.add_child(_mk_label("Enchant +1..+10: +3% stat per level. Gagal menuju +7 ke atas = turun 1 level (tak pernah hancur). Gulungan Perlindungan menahan penurunan (auto-terpakai).", 11, Color(0.75, 0.8, 0.95)))
	if ProfessionSystem.is_active("enchanter"):
		content.add_child(_mk_label("Profesi Enchanter aktif: diskon 30% + bonus peluang.", 11, Color(0.6, 0.9, 0.6)))
	content.add_child(_mk_label("Gulungan Perlindungan dimiliki: %d" % PlayerData.item_count("protection_scroll"), 12, Color(0.9, 0.85, 0.6)))
	var shown := 0
	var listed: Array = []
	for slot in ["equipped_weapon", "equipped_armor", "equipped_accessory"]:
		var eq: String = PlayerData.get(slot)
		if eq != "": listed.append(eq)
	for id in PlayerData.inventory.keys():
		if Db.item(id).get("type", "") in ["weapon", "armor", "accessory"] and not id in listed:
			listed.append(id)
	for id in listed:
		var def := Db.item(id)
		var ench := PlayerData.gear_enchant(id)
		var h := _row()
		_add_item_icon(h, id)
		var rate := int(round(EnchantSystem.success_rate(id) * 100))
		var cost := EnchantSystem.cost(id)
		var suffix := " +%d" % ench if ench > 0 else ""
		var l := _mk_label("%s%s [%s] → +%d  (%d%%, %dG)" % [def.get("name", id), suffix, def.get("tier", "F"), ench + 1, rate, cost], 13)
		l.custom_minimum_size = Vector2(380, 0)
		h.add_child(l)
		var can := EnchantSystem.can_enchant(id)
		var b := _btn("Enchant", _do_enchant.bind(id))
		b.disabled = not bool(can.ok) or PlayerData.gold < cost
		if not can.ok: l.tooltip_text = can.reason
		h.add_child(b)
		shown += 1
	if shown == 0:
		content.add_child(_mk_label("Tidak ada gear untuk di-enchant.", 12, Color(0.6, 0.6, 0.65)))

func _do_enchant(id: String) -> void:
	EnchantSystem.enchant(id)
	_rebuild()

func _build_auction() -> void:
	var a := AuctionHouse.state()
	title.text = "Rumah Lelang — %s" % a.get("date", "")
	if a.get("full_moon", false):
		content.add_child(_mk_label("🌕 MALAM PURNAMA — lot istimewa turun ke lantai lelang!", 13, Color(1.0, 0.85, 0.4)))
	content.add_child(_mk_label("Tawar → saudagar rival bisa membalas. Saat rival menyerah, palu jatuh & barang milikmu. Beli Langsung = tanpa perang tawar.", 11, Color(0.75, 0.8, 0.95)))
	if not WorldState.freed_captives.is_empty():
		content.add_child(_mk_label("Tawanan yang kau bebaskan: %d — mereka mengingat kebaikanmu." % WorldState.freed_captives.size(), 11, Color(0.6, 0.9, 0.6)))
	var idx := -1
	for lot in a.get("lots", []):
		idx += 1
		var h := _row()
		var sold: bool = lot.get("sold", false)
		var lead: String = lot.get("bidder", "")
		var lead_txt := ""
		if lead == "you": lead_txt = " — penawar: KAMU"
		elif lead != "": lead_txt = " — penawar: %s" % lead
		var l: Label = null
		if lot.get("kind", "item") == "captive":
			l = _mk_label("🔗 TAWANAN: %s (%s) — tawaran %dG%s" % [lot.get("name", "?"), lot.get("tag", ""), int(lot.bid), lead_txt], 13, Color(0.95, 0.7, 0.7))
		else:
			_add_item_icon(h, lot.get("item", ""))
			var def := Db.item(lot.get("item", ""))
			var star := "🌕 " if lot.get("special", false) else ""
			l = _mk_label("%s%s [%s] — tawaran %dG%s" % [star, def.get("name", "?"), def.get("tier", "F"), int(lot.bid), lead_txt], 13)
		l.custom_minimum_size = Vector2(370, 0)
		if sold:
			l.modulate = Color(0.55, 0.55, 0.6)
			l.text += "  (TERJUAL%s)" % (" — milikmu" if lot.get("winner", "") == "you" else "")
		h.add_child(l)
		if not sold:
			var need: int = int(lot.bid) + (0 if lead == "" else AuctionHouse.raise_step(lot))
			var bb := _btn("Tawar %dG" % need, _do_bid.bind(idx))
			bb.disabled = PlayerData.gold < need or lead == "you"
			h.add_child(bb)
			var bo := _btn("Beli %dG" % int(lot.buyout), _do_buyout.bind(idx))
			bo.disabled = PlayerData.gold < int(lot.buyout)
			h.add_child(bo)

func _do_bid(idx: int) -> void:
	var r := AuctionHouse.player_bid(idx)
	if r.get("status", "") == "outbid":
		Audio.play_sfx("blip")
		EventBus.toast.emit(Loc.t("auction.outbid", [r.get("by", "?"), int(r.get("bid", 0)), r.get("style", "")]))
	_rebuild()

func _do_buyout(idx: int) -> void:
	AuctionHouse.player_buyout(idx)
	_rebuild()

func _build_shop() -> void:
	title.text = "Toko Greenvale"
	content.add_child(_mk_label("— Beli —", 16))
	for id in ["minor_potion", "mana_draught", "basic_orb", "seed_mintleaf", "seed_sunbud", "fishing_rod", "star_bait", "saddle", "copper_sword", "greenhouse_kit", "tree_sapling"]:
		if not Db.items.has(id): continue
		var h := _row()
		_add_item_icon(h, id)
		var price := Economy.buy_price(id)
		var l := _mk_label("%s — %dG" % [Db.item_name(id), price], 14)
		l.custom_minimum_size = Vector2(296, 0)
		h.add_child(l)
		h.add_child(_btn("Beli", func(): if Economy.buy(id, 1): _rebuild() else: EventBus.toast.emit("Gagal beli (gold/stok).")))
	content.add_child(_mk_label("— Jual —", 16))
	for id in PlayerData.inventory.keys():
		var h := _row()
		_add_item_icon(h, id)
		var sp := Economy.sell_price(id)
		var l := _mk_label("%s x%d — jual %dG" % [Db.item_name(id), PlayerData.inventory[id], sp], 14)
		l.custom_minimum_size = Vector2(296, 0)
		h.add_child(l)
		h.add_child(_btn("Jual 1", func(): if Economy.sell(id, 1): _rebuild()))

func _build_panduan() -> void:
	title.text = "Panduan — Cara Bermain"
	var sections := [
		["🎮 Gerak & Interaksi", "WASD untuk bergerak. E untuk berinteraksi (NPC, pohon, papan, pintu gua). I membuka Tas. Space untuk menghindar (dodge)."],
		["⚔️ Bertarung", "Klik kiri menyerang ke arah kursor. Tekan angka 1–5 untuk 'prime' skill di hotbar, lalu klik kiri untuk melepasnya ke kursor. Serangan biasa tetap jalan tanpa prime."],
		["✨ Fusion Elemen", "Tekan DUA angka dalam 1,5 detik untuk memadukan dua skill. Jika paduannya cocok (mis. Api+Angin), keluar serangan fusion yang lebih kuat (mana 2x). Jika tidak cocok, hanya asap — cobalah paduan lain untuk menemukannya!"],
		["🌳 Mengumpulkan & Meramu", "Tebang pohon / tambang batu dengan E untuk bahan. Ke Bengkel (E) untuk meramu senjata, alat, dan barang."],
		["🐾 Menjinakkan Pet", "Lemahkan monster hingga HP sangat rendah, dekati, tekan T. Pet ikut bertarung; sebagian bisa ditunggangi (R)."],
		["🏰 Kota & Gua", "Kota adalah zona aman — monster tak bisa masuk, penjaga gerbang menghalau mereka. Pintu gua (E) membawamu ke dungeon sisi-samping: lompat, gali, kalahkan bos."],
		["🌙 Waktu & Cuaca", "Waktu & fase bulan berjalan nyata (WIB). Cuaca memengaruhi pertarungan — mis. Petir lebih kuat saat musuh basah karena hujan."],
		["💾 Menyimpan", "Game tersimpan otomatis; kamu juga bisa menyimpan lewat menu Sistem (Esc)."],
	]
	for s in sections:
		var head := _mk_label(s[0], 18)
		head.add_theme_color_override("font_color", UiTheme.ACCENT)
		content.add_child(head)
		var body := _mk_label(s[1], 15)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(480, 0)
		content.add_child(body)
		content.add_child(_mk_label(" ", 6))

## Grimoire (FF-2d): fusion recipes the player has DISCOVERED (full detail) plus
## mystery rows for recipes touched by a fizzled element ("Fire + ? = ???").
## Untouched recipes stay hidden — discovery lives, but the player has a map.
func _build_grimoire() -> void:
	title.text = "Grimoire — Paduan Elemen"
	var combos: Array = Db.elements.get("combos", [])
	var found := 0
	for c in combos:
		if c.get("result", "") in PlayerData.discovered_fusions:
			found += 1
	content.add_child(_mk_label("Ditemukan: %d / %d resep" % [found, combos.size()], 15, Color(1.0, 0.86, 0.42)))
	content.add_child(_mk_label("Prime 2 elemen (tekan 2 angka <1.5 dtk) lalu klik kiri. 3-4 elemen = paduan recast. Fizzle pun meninggalkan petunjuk di sini.", 11, Color(0.75, 0.8, 0.95)))
	content.add_child(_mk_label("— Sudah ditemukan —", 15, Color(0.6, 0.9, 0.6)))
	var none_found := true
	for c in combos:
		var nm: String = c.get("result", "")
		if not (nm in PlayerData.discovered_fusions):
			continue
		none_found = false
		var elems := _combo_elems(c)
		var tier_txt := " · recast" if elems.size() >= 3 else ""
		var l := _mk_label("%s  =  %s  『×%.1f%s』" % [" + ".join(elems.map(func(e): return e.capitalize())), nm, float(c.get("mult", 1.0)), tier_txt], 14)
		content.add_child(l)
		var d := _mk_label("   %s" % c.get("desc", ""), 11, Color(0.72, 0.76, 0.9))
		content.add_child(d)
	if none_found:
		content.add_child(_mk_label("(belum ada — dunia menunggu percikan pertamamu!)", 12, Color(0.7, 0.7, 0.72)))
	content.add_child(_mk_label("— Misteri (petunjuk dari fizzle) —", 15, Color(0.8, 0.7, 0.5)))
	var hidden := 0
	var mystery := 0
	for c in combos:
		var nm: String = c.get("result", "")
		if nm in PlayerData.discovered_fusions:
			continue
		var elems := _combo_elems(c)
		var known := elems.filter(func(e): return e in PlayerData.fusion_fizzled_elements)
		if known.is_empty():
			hidden += 1
			continue
		mystery += 1
		var parts := []
		for e in elems:
			parts.append(e.capitalize() if (e in PlayerData.fusion_fizzled_elements) else "?")
		content.add_child(_mk_label("%s  =  ???" % " + ".join(parts), 14, Color(0.75, 0.75, 0.8)))
	if mystery == 0:
		content.add_child(_mk_label("(belum ada petunjuk)", 12, Color(0.7, 0.7, 0.72)))
	if hidden > 0:
		content.add_child(_mk_label("...dan %d resep lain yang belum tersentuh sama sekali." % hidden, 11, Color(0.6, 0.6, 0.65)))

func _combo_elems(c: Dictionary) -> Array:
	var elems: Array = c.get("elems", [])
	if elems.is_empty():
		elems = [c.get("a", ""), c.get("b", "")]
	return elems

## Skill Tree TERIKAT LOKASI (Decision Log #30). Dari Penjaga Pohon (_ctx.location):
## pohon lokal bisa DIBUKA; pohon luar-lokasi tampil sebagai RUMOR berarah; Celestial
## tampil-terkunci butuh buku skenario. Dari tab Pohon (tanpa lokasi): hanya upgrade
## pohon yang sudah dimiliki — di mana pun, tanpa bolak-balik.
const LOC_LABEL := {
	"greenvale": "Greenvale", "frostpeak_village": "Pos Pendaki Frostpeak",
	"candyveil_palace": "Istana Sugar Queen", "desert_ruins": "Reruntuhan Gurun",
	"storm_island": "Menara Zephyr", "homestead": "Homestead",
	"astrologer_tower": "Menara Astrologer", "celestia": "Celestia Kingdom",
	"emberfall": "Emberfall", "ocean_kingdom": "Kerajaan Thalassar",
	"ancient_jungle": "Ancient Jungle", "skyveil": "Skyveil", "abyss": "Abyss",
	"wildhearth": "Wildhearth (kota beast)",
}

func _build_trees() -> void:
	var loc := ""
	if _ctx is Dictionary:
		loc = _ctx.get("location", "")
	if loc != "":
		title.text = "Penjaga Pohon — %s" % LOC_LABEL.get(loc, loc)
		content.add_child(_mk_label("Pohon hanya bisa DIBUKA di tanah asalnya. Setelah dimiliki, upgrade bisa di mana pun (tab Pohon).", 11, Color(0.75, 0.8, 0.95)))
		content.add_child(_mk_label("— Pohon di sini —", 15, Color(0.6, 0.9, 0.6)))
		var locals := SkillTreeSystem.at_location(loc)
		if locals.is_empty():
			content.add_child(_mk_label("(tidak ada pohon di lokasi ini)", 12, Color(0.7, 0.7, 0.72)))
		for t in locals:
			_tree_row(t, loc)
		content.add_child(_mk_label("— Rumor dari penjuru dunia —", 15, Color(0.8, 0.7, 0.5)))
		for t in SkillTreeSystem.all():
			var tid: String = t.get("id", "")
			if t.get("unlock_location", "") == loc or SkillTreeSystem.owned(tid):
				continue
			var lock := "🔒 " if t.get("content_locked", false) else ""
			var r := _mk_label("🗺 %s%s — \"%s\"" % [lock, t.get("name", tid), t.get("rumor", "")], 11, Color(0.72, 0.72, 0.78))
			r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			r.custom_minimum_size = Vector2(500, 0)
			content.add_child(r)
	else:
		title.text = "Pohon Skill"
		content.add_child(_mk_label("Upgrade pohon yang KAU MILIKI — di mana pun. Membuka pohon baru: kunjungi Penjaga Pohon di lokasinya.", 11, Color(0.75, 0.8, 0.95)))
		var any := false
		for tid in PlayerData.skill_trees:
			any = true
			_tree_row(SkillTreeSystem.tree(tid), "")
		if not any:
			content.add_child(_mk_label("(belum ada pohon — temui Penjaga Pohon di alun-alun Greenvale)", 12, Color(0.7, 0.7, 0.72)))

func _tree_row(t: Dictionary, loc: String) -> void:
	var tid: String = t.get("id", "")
	var lv := SkillTreeSystem.level(tid)
	var h := _row()
	var head := "%s  [%d/%d]" % [t.get("name", tid), lv, int(t.get("max_level", 3))]
	var l := _mk_label(head, 14, Color(0.6, 0.9, 0.6) if lv > 0 else Color.WHITE)
	l.custom_minimum_size = Vector2(230, 0)
	h.add_child(l)
	if lv == 0 and loc != "":
		var chk := SkillTreeSystem.can_unlock(tid, loc)
		var domain_tag := " 🌿domain" if SkillTreeSystem.is_domain_tree(tid) else ""
		var b := _btn("Buka %d G%s" % [SkillTreeSystem.unlock_cost(tid), domain_tag], func():
			var res := SkillTreeSystem.unlock(tid, loc)
			if not res.ok:
				EventBus.toast.emit(res.reason)
			else:
				UiFx.celebrate(content, "🌿")   # micro-celebration (#44)
			_rebuild())
		if t.get("requires_scenario", "") != "" and not chk.ok:
			b.disabled = true
			h.add_child(b)
			h.add_child(_mk_label("📖 terkunci — butuh buku Skenario Tersembunyi", 11, Color(0.85, 0.7, 0.5)))
		else:
			h.add_child(b)
	elif lv > 0 and lv < int(t.get("max_level", 3)):
		h.add_child(_btn("Upgrade %d G" % SkillTreeSystem.upgrade_cost(tid), func():
			var res := SkillTreeSystem.upgrade(tid, loc)
			if not res.ok: EventBus.toast.emit(res.reason)
			_rebuild()))
	elif lv >= int(t.get("max_level", 3)):
		h.add_child(_mk_label("MAX", 12, Color(1.0, 0.86, 0.42)))
	var d := _mk_label("   " + t.get("desc", ""), 11, Color(0.72, 0.76, 0.9))
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(500, 0)
	content.add_child(d)

## Ranch/Pet UI (v0.4.1): roster pet dengan bintang, trait, MUTASI, AFFINITY hidup
## (naik saat ikut bertempur / diberi makan) + aktifkan + beri makan.
func _build_pet() -> void:
	title.text = "Pet & Ranch"
	if PlayerData.monsters.is_empty():
		content.add_child(_mk_label("Belum ada pet. Lemahkan monster (HP<5%) lalu tekan T dengan Orb.", 14))
		return
	content.add_child(_mk_label("Affinity naik saat pet ikut bertempur & diberi makan — gerbang konten masa depan (Fusion/Pact).", 11, Color(0.75, 0.8, 0.95)))
	var food := ""
	for fid in ["grilled_fish", "meat_jerky", "fish_sushi", "minor_potion"]:
		if PlayerData.item_count(fid) > 0:
			food = fid
			break
	for i in range(PlayerData.monsters.size()):
		var pet: Dictionary = PlayerData.monsters[i]
		var h := _row()
		var active := i == PlayerData.active_pet_index
		var stars := "★".repeat(int(pet.get("star", 3)))
		var traits: Array = pet.get("ind_traits", [])
		var line := "%s%s Lv%d %s" % [("▶ " if active else ""), pet.get("name", "?"), int(pet.get("level", 1)), stars]
		if not traits.is_empty():
			line += " · " + ", ".join(traits)
		if pet.get("mutation", false):
			line += " ✦MUTASI"
		var l := _mk_label(line, 13, Color(1.0, 0.9, 0.6) if active else Color.WHITE)
		l.custom_minimum_size = Vector2(250, 0)
		h.add_child(l)
		var aff := int(pet.get("affinity", 0))
		var ab := ProgressBar.new()
		ab.custom_minimum_size = Vector2(80, 12)
		ab.max_value = 100
		ab.value = aff
		ab.show_percentage = false
		ab.tooltip_text = "Affinity %d/100" % aff
		h.add_child(ab)
		h.add_child(_mk_label("%d" % aff, 11))
		if not active:
			var idx := i
			h.add_child(_btn("Aktifkan", func():
				PlayerData.active_pet_index = idx
				EventBus.pet_added.emit(PlayerData.monsters[idx])
				_rebuild()))
		if food != "":
			var idx2 := i
			var f2 := food
			h.add_child(_btn("🍖 %s" % Db.item_name(f2), func():
				if PlayerData.feed_pet(idx2, f2): _rebuild()))
	if food == "":
		content.add_child(_mk_label("(tidak ada makanan di tas — masak/beli untuk memberi makan)", 11, Color(0.7, 0.7, 0.72)))

func _build_status() -> void:
	title.text = "Status Karakter"
	var cd := Db.cls(PlayerData.char_class)
	var jalur := "🌾 Jalur Kehidupan" if cd.get("path", "combat") == "life" else "⚔ Jalur Tempur"
	content.add_child(_mk_label("%s  ·  %s (%s)  ·  %s  ·  Level %d" % [PlayerData.char_name, cd.get("name", "-"), cd.get("title", ""), jalur, PlayerData.level], 18))
	if PlayerData.combat_sub != "":
		content.add_child(_mk_label("Combat Sub: %s (1 senjata + 2 skill) · %s" % [Db.cls(PlayerData.combat_sub).get("name", "-"), cd.get("perk", "")], 11, Color(0.75, 0.8, 0.95)))
	else:
		content.add_child(_mk_label("Afinitas senjata: %s  ·  %s" % [", ".join(cd.get("affinity", [])), cd.get("advanced", "")], 11, Color(0.75, 0.8, 0.95)))
	var pts := _mk_label("Poin bebas: %d  (+5 tiap naik level)" % PlayerData.stat_points, 15)
	pts.add_theme_color_override("font_color", UiTheme.ACCENT)
	content.add_child(pts)
	# publikasi cap & formula (GDD §6.3 "semua cap dipublikasikan", v0.4.1)
	content.add_child(_mk_label("— Formula & Cap (transparan untuk semua pemain) —", 14, Color(0.7, 0.85, 1.0)))
	for line in [
		"Crit: %d%%–%d%% · Crit Dmg 150%% (cap 250%%)" % [int(CombatResolver.CRIT_MIN * 100), int(CombatResolver.CRIT_MAX * 100)],
		"Evasion: cap 40%% dari AGI (+buff maks 75%%) · Accuracy: 60%%–99%% dari DEX",
		"Peluang kena = Accuracy − Evasion (minimal 20%%)",
		"DEF & MDEF memitigasi %d%% nilainya dari damage" % int(CombatResolver.DEF_FACTOR * 100),
		"Elemen: kuat ×1.3 · lemah ×0.7 · Combo 2 skill beda <2 dtk = +30%%",
		"Mana: regen surge ×3 setelah 3 dtk tidak bertarung · channel dibatasi kolam mana",
	]:
		content.add_child(_mk_label("• " + line, 11, Color(0.72, 0.76, 0.9)))
	content.add_child(_mk_label(" ", 4))
	for attr in PlayerData.ATTR_ORDER:
		var h := _row()
		var l := _mk_label("%s  %d" % [attr, int(PlayerData.attributes.get(attr, 5))], 16)
		l.custom_minimum_size = Vector2(90, 0)
		h.add_child(l)
		var plus := _btn("+", func():
			if PlayerData.allocate_point(attr):
				Audio.play_sfx("menu"); _rebuild())
		plus.disabled = PlayerData.stat_points <= 0
		h.add_child(plus)
		var desc := _mk_label(PlayerData.ATTR_DESC.get(attr, ""), 12)
		desc.custom_minimum_size = Vector2(360, 0)
		h.add_child(desc)
	content.add_child(_mk_label(" ", 4))
	# derived stats readout
	for line in [
		"HP %d/%d · MP %d/%d" % [PlayerData.hp, PlayerData.max_hp, PlayerData.mp, PlayerData.max_mp],
		"ATK %d · DEF %d · MATK %d · MDEF %d" % [PlayerData.atk, PlayerData.def, PlayerData.matk, PlayerData.mdef],
		"Kecepatan serang %.2fx · Evasion %d%% · Akurasi %d%%" % [PlayerData.attack_speed, int(PlayerData.evasion * 100), int(PlayerData.accuracy * 100)],
		"Crit %d%% · Regen mana %.1f/dtk · Bonus panen %d%% · Bonus drop %d%%" % [int(PlayerData.crit_rate * 100), PlayerData.mana_regen, int(PlayerData.gather_bonus * 100), int(PlayerData.drop_bonus * 100)],
	]:
		content.add_child(_mk_label(line, 13))
	content.add_child(_mk_label(" ", 6))
	# respec (paid)
	var respec_cost := 100 + PlayerData.level * 20
	var rrow := _row()
	rrow.add_child(_mk_label("Reset atribut (respec):", 14))
	rrow.add_child(_btn("Respec (%dG)" % respec_cost, func():
		if PlayerData.spend_gold(respec_cost):
			PlayerData.respec(); Audio.play_sfx("success"); EventBus.toast.emit("Atribut di-reset. Alokasikan ulang poinmu."); _rebuild()
		else:
			EventBus.toast.emit("Gold tidak cukup untuk respec.")))

# ══════════════════════════════════════════════════════════════════════════════
# KITAB — R1 · SPEC_PAYOFF_SLICE §4.F/§4.G
# ══════════════════════════════════════════════════════════════════════════════
#
# Tab TERPISAH dari `pedia`/#96. `_build_pedia()` TIDAK disentuh: Aetherpedia
# adalah daftar pencapaian, Kitab adalah buku yang dicoret dan ditulis ulang.
# Dua benda berbeda yang kebetulan membaca larik yang sama.
#
# ⛔ HUKUM D-4 — dikodekan di sini juga:
#   Layar ini TIDAK BOLEH menampilkan hitungan bukti, "3/5", bilah kemajuan,
#   atau persen. Ia hanya boleh menjawab ya/tidak untuk satu aksi konkret:
#   bisakah halaman ini ditulis ulang sekarang. Kapasitas ingatan pemain
#   terasa HANYA lewat penolakan saat penuh (#257) — tak pernah lewat meteran.
#   Dijaga `_test_no_chronicle_score()` + `_test_no_evidence_score()`.
#
# #229.4 — `struck_cause` TIDAK PERNAH ditampilkan. Pemain tak akan pernah bisa
#   membedakan penghapusan dari kelupaan biasa, dan kita tak menjawabnya.
#
# #259 — keterbukaan Elyn tampil SEBELUM konfirmasi. Nol jebakan.

const KITAB_PAPER := Color(0.115, 0.105, 0.095)   # kertas tua, bukan panel biru
const KITAB_EDGE := Color(0.34, 0.31, 0.26)
const KITAB_INK := Color(0.91, 0.88, 0.79)
const KITAB_INK_DIM := Color(0.58, 0.56, 0.50)
const KITAB_LOSS := Color(0.97, 0.74, 0.44)       # baris tak-terpulihkan
const KITAB_SCRATCH := Color(0.82, 0.79, 0.71, 0.70)   # tembus: nama tercoret harus TETAP terbaca

## "" = daftar. Selain itu "<layar>:<id_halaman>".
## path = pilih jalur · elyn = keterbukaan (#259) · full = penolakan (#257) · done = hasil
var _kitab_view := ""

## Teks kanon §4.G. Dwibahasa sejak awal (#166) — slot EN disiapkan, bukan ditambal nanti.
const KITAB_TXT := {
	"elyn_disclosure": {
		"id": "Elyn akan menulis ini untukmu. Ingatan itu akan menempati ruangnya, bukan ruangmu.\nUmurnya berkurang tiap kali ia menolak lupa. Dan ruang yang penuh diwariskan —\nketurunannya memikul apa yang tak sanggup kaubawa sendiri.",
		"en": "Elyn will write this for you. The memory will take her room, not yours.\nHer years shorten each time she refuses to forget. And a full room is inherited —\nher descendants carry what you could not carry yourself.",
	},
	"elyn_first": {
		"id": "\"Aku sudah melihat empat generasi manusia pergi. Satu ingatan lagi bukan beban baru — hanya ruang yang lebih sempit untuk lupa. Berikan. Aku akan mengingatnya selama aku bisa.\"",
		"en": "\"I have watched four generations of humans go. One more memory is no new burden — only less room to forget in. Give it to me. I will remember it while I can.\"",
	},
	"memory_full": {
		"id": "Kamu tak sanggup memikul lebih banyak masa lalu. Lepaskan sesuatu yang kausimpan,\natau biarkan Elyn yang menanggung ini.",
		"en": "You cannot carry any more of the past. Let go of something you hold,\nor let Elyn bear this one.",
	},
	"take_elyn": {"id": "Biarkan Elyn menanggung", "en": "Let Elyn bear it"},
	"take_self": {"id": "Simpan sendiri", "en": "Keep it yourself"},
	"rewrite": {"id": "Tulis ulang", "en": "Rewrite"},
	"back": {"id": "Kembali ke kitab", "en": "Back to the book"},
	"no_trace": {
		"id": "Belum ada cukup bekas untuk menuliskannya kembali.",
		"en": "Not enough traces yet to write it back.",
	},
	"from_testimony": {
		"id": "dipulihkan dari kesaksian",
		"en": "restored from testimony",
	},
	"loss_header": {"id": "Yang tidak kembali:", "en": "What did not come back:"},
	"empty": {
		"id": "Belum ada apa pun di kitab ini. Dunia masih menunggu seseorang repot menuliskannya.",
		"en": "Nothing in this book yet. The world is still waiting for someone to bother writing it.",
	},
	"who_bothered": {
		"id": "Buku ini tidak menghakimi. Ia hanya mencatat siapa yang repot.",
		"en": "This book does not judge. It only records who bothered.",
	},
	"struck_head": {"id": "— Halaman yang tercoret —", "en": "— Struck pages —"},
	"read_head": {"id": "— Yang masih terbaca —", "en": "— Still legible —"},
	"choose": {
		"id": "Siapa yang akan memegang pena?",
		"en": "Who will hold the pen?",
	},
	"self_note": {
		"id": "Tulisanmu sendiri. Berantakan, dan lebih banyak yang hilang — karena kau tak tahu caranya. Tetap sah: dunia mengingat versimu.",
		"en": "Your own hand. Messy, and more is lost — because you do not know how. Still valid: the world remembers your version.",
	},
	"self_locked": {
		"id": "Bekas yang kaubawa belum cukup untuk tanganmu sendiri.",
		"en": "The traces you carry are not enough for your own hand.",
	},
	"elyn_locked": {
		"id": "Bekas yang kaubawa belum cukup, bahkan untuk Elyn.",
		"en": "The traces you carry are not enough, even for Elyn.",
	},
}


func _kt(key: String) -> String:
	return Loc.c(KITAB_TXT[key])


## Panel kertas — Kitab sengaja tidak memakai biru JRPG. Ia benda lain di tas.
func _kitab_paper(pad: int = 10) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = KITAB_PAPER
	sb.border_color = KITAB_EDGE
	sb.set_border_width_all(1)
	sb.border_width_left = 3          # rusuk jilid di tepi kiri
	sb.corner_radius_top_left = 2
	sb.corner_radius_bottom_left = 2
	sb.content_margin_left = pad + 4
	sb.content_margin_right = pad
	sb.content_margin_top = pad
	sb.content_margin_bottom = pad
	p.add_theme_stylebox_override("panel", sb)
	content.add_child(p)
	return p


func _kitab_line(box: VBoxContainer, t: String, s: int, col: Color, wrap := true) -> Label:
	var l := _mk_label(t, s, col)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(470, 0)
	box.add_child(l)
	return l


## JUDUL TERCORET — jantung emosi layar ini.
##
## Bukan `[s]` RichTextLabel: garis rapi di tengah huruf terbaca sebagai
## "item dinonaktifkan", bukan sebagai orang yang dicoret dari sebuah buku.
## Yang digambar di sini dua sapuan pena: satu tebal menyeberang, satu tipis
## mengulang — persis yang dilakukan tangan saat menghapus sesuatu.
##
## Getarannya DITENTUKAN oleh hash id halaman, bukan acak: halaman yang sama
## harus tercoret dengan bentuk coretan yang sama tiap kali kitab dibuka.
const KITAB_TITLE_SIZE := 20

func _kitab_struck_title(box: VBoxContainer, text: String, seed_src: String) -> void:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(470, 30)
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(holder)

	var l := _mk_label(text, KITAB_TITLE_SIZE, KITAB_INK.darkened(0.18))
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	holder.add_child(l)

	# LEBAR CORETAN = lebar teksnya, bukan lebar kartu. Garis yang membentang
	# sepenuh kartu terbaca sebagai garis pemisah; yang berhenti di ujung nama
	# terbaca sebagai nama yang dicoret.
	var tw := float(text.length()) * 9.0
	if _font:
		tw = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, KITAB_TITLE_SIZE).x
	var seed_v := float(int(abs(float(hash(seed_src)))) % 211)

	holder.draw.connect(func() -> void:
		var w: float = min(holder.size.x, tw + 8.0)
		var h: float = holder.size.y
		var mid: float = h * 0.58
		# dua sapuan: satu tebal menyeberang, satu tipis mengulang sedikit meleset
		for stroke in 2:
			var pts := PackedVector2Array()
			var steps := 9
			for i in steps + 1:
				var f := float(i) / float(steps)
				var jitter := sin(f * 11.0 + seed_v + float(stroke) * 2.7) * 1.5
				var tilt := (f - 0.5) * 2.0            # tangan miring sedikit ke bawah
				var off := -2.2 if stroke == 0 else 2.0
				pts.append(Vector2(-3.0 + (w + 6.0) * f, mid + jitter + tilt + off))
			holder.draw_polyline(pts, KITAB_SCRATCH, 2.1 if stroke == 0 else 1.2, true)
	)


func _build_kitab() -> void:
	title.text = "Kitab"
	# Gold disembunyikan: Kitab bukan panel inventaris, dan angka apa pun di
	# kepalanya menarik mata ke arah yang salah.
	gold_lbl.visible = false
	if _kitab_view != "":
		var parts := _kitab_view.split(":", true, 1)
		var pid: String = parts[1] if parts.size() > 1 else ""
		match parts[0]:
			"path": _kitab_prompt_path(pid); return
			"elyn": _kitab_prompt_elyn(pid); return
			"full": _kitab_prompt_full(pid); return
			"done": _kitab_done(pid); return
	_kitab_list()


func _kitab_list() -> void:
	var struck: Array = Chronicle.struck_entries()
	var readable: Array = Chronicle.readable_entries()
	if struck.is_empty() and readable.is_empty():
		content.add_child(_mk_label(_kt("empty"), 13, KITAB_INK_DIM))
		return

	var note := _mk_label(_kt("who_bothered"), 12, KITAB_INK_DIM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(500, 0)
	content.add_child(note)

	if not struck.is_empty():
		content.add_child(_mk_label(_kt("struck_head"), 14, KITAB_INK_DIM))
	for e in struck:
		_kitab_card_struck(e)

	if not readable.is_empty():
		content.add_child(_mk_label(_kt("read_head"), 14, KITAB_INK_DIM))
	for e in readable:
		_kitab_card_readable(e)


func _kitab_card_struck(e: Dictionary) -> void:
	var pid: String = e.get("id", "")
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_kitab_paper().add_child(box)

	_kitab_struck_title(box, str(e.get("title", "?")), pid)
	# #229.4 — `struck_cause` TIDAK IKUT. Tak pernah.
	_kitab_line(box, "ditulis %s WIB · oleh %s" % [e.get("date", ""), e.get("by", "")],
		11, KITAB_INK_DIM)

	# Ya/tidak untuk satu aksi konkret — bukan skor (D-4).
	var can_self: bool = Evidence.enough_for(pid, Chronicle.SCRIBE_SELF)
	var can_elyn: bool = Evidence.enough_for(pid, Chronicle.SCRIBE_ELYN)
	if can_self or can_elyn:
		var b := _btn(_kt("rewrite"), func():
			_kitab_view = "path:" + pid
			_rebuild())
		b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(b)
	else:
		_kitab_line(box, _kt("no_trace"), 12, KITAB_INK_DIM)


func _kitab_card_readable(e: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_kitab_paper().add_child(box)

	_kitab_line(box, str(e.get("title", "?")), 17, KITAB_INK)
	_kitab_line(box, "ditulis %s WIB · oleh %s" % [e.get("date", ""), e.get("by", "")],
		11, KITAB_INK_DIM)

	if e.get("state", "") != Chronicle.ST_RESTORED:
		return
	# ATURAN KERAS #3 — "dipulihkan dari kesaksian", tak pernah "dipulihkan".
	# Halaman pulih tidak pernah identik; menyebutnya "pulih" saja adalah kebohongan.
	var scribe: String = str(e.get("scribe", ""))
	var hand := "tanganmu sendiri" if scribe == Chronicle.SCRIBE_SELF else "tangan Elyn"
	if scribe == Chronicle.SCRIBE_SORA:
		hand = "tangan Sora"
	_kitab_line(box, "%s · %s · %s" % [_kt("from_testimony"), hand, e.get("restored_at", "")],
		12, KITAB_INK_DIM)
	_kitab_loss_block(box, str(e.get("loss", "")))


## BARIS TAK-TERPULIHKAN — fokus visual halaman pulih, bukan catatan kaki (§4.F).
## Ia diberi kotaknya sendiri, warnanya sendiri, dan ukuran lebih besar daripada
## judul halaman di sekitarnya. Yang hilang harus lebih keras daripada yang kembali.
func _kitab_loss_block(box: VBoxContainer, loss: String) -> void:
	if loss == "":
		return
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.14, 0.07)
	sb.border_color = KITAB_LOSS
	sb.border_width_left = 4
	sb.content_margin_left = 12
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	p.add_theme_stylebox_override("panel", sb)
	box.add_child(p)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	vb.add_child(_mk_label(_kt("loss_header"), 12, KITAB_LOSS.darkened(0.25)))
	# lebih besar daripada judul halaman di sekitarnya — itu maksudnya
	var l := _mk_label(loss, 19, KITAB_LOSS)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(440, 0)
	vb.add_child(l)


func _kitab_back_btn(label_key := "back") -> void:
	var b := _btn(_kt(label_key), func():
		_kitab_view = ""
		_rebuild())
	b.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	content.add_child(b)


func _kitab_entry(pid: String) -> Dictionary:
	for x in Chronicle.entries():
		if x.get("id", "") == pid:
			return x
	return {}


func _kitab_head(pid: String) -> VBoxContainer:
	var e := _kitab_entry(pid)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_kitab_paper(12).add_child(box)
	_kitab_line(box, str(e.get("title", "?")), 18, KITAB_INK)
	return box


## PILIH JALUR (#228) — SENDIRI selalu ditawarkan bila buktinya cukup.
## Elyn bukan satu-satunya jalan, dan layar ini tak boleh membuatnya terasa begitu.
func _kitab_prompt_path(pid: String) -> void:
	var box := _kitab_head(pid)
	_kitab_line(box, _kt("choose"), 15, KITAB_INK_DIM)

	if Evidence.enough_for(pid, Chronicle.SCRIBE_SELF):
		var bs := _btn(_kt("take_self"), func(): _kitab_do_self(pid))
		bs.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(bs)
		_kitab_line(box, _kt("self_note"), 11, KITAB_INK_DIM)
	else:
		_kitab_line(box, _kt("self_locked"), 12, KITAB_INK_DIM)

	if Evidence.enough_for(pid, Chronicle.SCRIBE_ELYN):
		# #259 — TIDAK langsung menulis. Tekan ini → layar keterbukaan dulu.
		var be := _btn(_kt("take_elyn"), func():
			_kitab_view = "elyn:" + pid
			_rebuild())
		be.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(be)
	else:
		_kitab_line(box, _kt("elyn_locked"), 12, KITAB_INK_DIM)

	_kitab_back_btn()


## #259 HUKUM KETERBUKAAN — ongkos Elyn tampil SEBELUM konfirmasi. Nol jebakan.
func _kitab_prompt_elyn(pid: String) -> void:
	var box := _kitab_head(pid)
	var l := _mk_label(_kt("elyn_disclosure"), 15, KITAB_LOSS)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(450, 0)
	box.add_child(l)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	row.add_child(_btn("[ %s ]" % _kt("take_elyn"), func():
		var r: Dictionary = Chronicle.restore_elyn(pid, Evidence.for_page(pid))
		if r.get("ok", false):
			_kitab_view = "done:" + pid
		_rebuild()))
	row.add_child(_btn("[ %s ]" % _kt("take_self"), func(): _kitab_do_self(pid)))
	_kitab_back_btn()


## SENDIRI. Ruang penuh → penolakan (#257), BUKAN tombol mati tanpa keterangan.
func _kitab_do_self(pid: String) -> void:
	var r: Dictionary = Chronicle.restore_self(pid, Evidence.for_page(pid))
	if r.get("ok", false):
		_kitab_view = "done:" + pid
	elif r.get("reason", "") == "memory_full":
		_kitab_view = "full:" + pid
	_rebuild()


## #257 — batas ingatan ditemui sebagai PENOLAKAN, tak pernah dibaca sebagai angka.
## Elyn TETAP tersedia di layar ini: kapasitas memindahkan ongkos, tak mengunci payoff.
func _kitab_prompt_full(pid: String) -> void:
	var box := _kitab_head(pid)
	var l := _mk_label(_kt("memory_full"), 15, KITAB_LOSS)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(450, 0)
	box.add_child(l)
	if Evidence.enough_for(pid, Chronicle.SCRIBE_ELYN):
		var be := _btn("[ %s ]" % _kt("take_elyn"), func():
			_kitab_view = "elyn:" + pid
			_rebuild())
		be.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		box.add_child(be)
	_kitab_back_btn()


func _kitab_done(pid: String) -> void:
	var e := _kitab_entry(pid)
	# Elyn bicara HANYA saat pertama kali dilimpahi — sesudahnya ia sudah menjawab.
	if str(e.get("scribe", "")) == Chronicle.SCRIBE_ELYN and PlayerData.elyn_burden.size() <= 1:
		var qbox := VBoxContainer.new()
		_kitab_paper(12).add_child(qbox)
		_kitab_line(qbox, _kt("elyn_first"), 14, KITAB_INK)
	_kitab_card_readable(e)
	_kitab_back_btn()
