extends CanvasLayer
## MenuUI (M5) — inventory / crafting / shop overlay. Pauses gameplay while open.
## Built in code; rebuilt each open to reflect current state.

var _font: Font
var mode := "inventory"      # inventory | crafting | shop
var _ctx = null              # bench/npc context
var root: Control
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

	var panel := PanelContainer.new()
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
	for m in [["status", "Status"], ["inventory", "Tas"], ["crafting", "Craft"], ["shop", "Toko"], ["quest", "Quest"], ["skill", "Skill"], ["prof", "Profesi"], ["pedia", "Pedia"], ["panduan", "Panduan"]]:
		var b := Button.new()
		b.text = m[1]
		if _font: b.add_theme_font_override("font", _font)
		b.pressed.connect(func(): Audio.play_sfx("menu"); mode = m[0]; _rebuild())
		tabs.add_child(b)
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
	_rebuild()

func close_menu() -> void:
	root.visible = false
	get_tree().paused = false

func _refresh_gold() -> void:
	gold_lbl.text = "Gold: %d" % PlayerData.gold

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
	return b

func _rebuild() -> void:
	_refresh_gold()
	_clear()
	match mode:
		"inventory": _build_inventory()
		"crafting": _build_crafting()
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

func _build_skill() -> void:
	title.text = "Skill Book"
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
			var b := _btn("Latih %d G" % int(u.get("cost", 0)), func(): if PlayerData.train_skill(sid): _rebuild())
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
	content.add_child(_mk_label("☾ Fase: %s   ·   %s %s WIB" % [GameClock.moon_name(), GameClock.date_string(), GameClock.time_string()], 16))
	var tide := GameClock.tide_level()
	var tide_txt := "Pasang tinggi" if tide > 0.3 else ("Surut ekstrem" if tide < -0.3 else "Normal")
	content.add_child(_mk_label("Pasang-surut: %s   ·   Cuaca: %s" % [tide_txt, WorldState.weather.capitalize()], 14))
	var rasi: String = PlayerData.birth_sign if PlayerData.birth_sign != "" else "-"
	content.add_child(_mk_label("Rasi Kelahiranmu: %s" % rasi, 14))
	content.add_child(_mk_label("— Ramalan Mingguan —", 16))
	var prophecy := _weekly_prophecy()
	var pl := _mk_label(prophecy, 14)
	pl.autowrap_mode = TextServer.AUTOWRAP_WORD
	pl.custom_minimum_size = Vector2(500, 0)
	pl.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	content.add_child(pl)
	content.add_child(_mk_label("— Langit Mendatang (kalender nyata) —", 16))
	var events: Array = GameClock.upcoming_events(6)
	if events.is_empty():
		content.add_child(_mk_label("(tak ada event terjadwal)", 13))
	for e in events:
		var when := "hari ini" if e.days == 0 else ("besok" if e.days == 1 else "%d hari lagi" % e.days)
		content.add_child(_mk_label("✦ %s — %s (%s)" % [e.name, e.date, when], 14))

func _weekly_prophecy() -> String:
	# Rotating riddle that hints at an active/eligible Hidden Scenario (v0.3 §3.2).
	var scs: Array = Db.scenarios.filter(func(s): return s.has("hint"))
	if scs.is_empty():
		return "Langit sunyi minggu ini."
	var pick: Dictionary = scs[GameClock.week_index() % scs.size()]
	return "\"%s\"" % pick.get("hint", "")

func _build_quests() -> void:
	title.text = "Papan Quest Harian"
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
		l.custom_minimum_size = Vector2(400, 0)
		if q.claimed: l.modulate = Color(0.5, 0.5, 0.5)
		h.add_child(l)
		if q.done and not q.claimed:
			h.add_child(_btn("Klaim", func(): QuestSystem.claim(q.id); _rebuild()))
		elif q.claimed:
			h.add_child(_mk_label("diklaim", 12))

func _build_pedia() -> void:
	title.text = "Aetherpedia"
	# --- Dunia / lore (Celestia canon) ---
	var lore := _mk_label("🌍 Dunia Aetherion", 18)
	lore.add_theme_color_override("font_color", UiTheme.ACCENT)
	content.add_child(lore)
	for line in [
		"Celestia Kingdom — ibukota agung tempat SEMUA ras hidup berdampingan. Multi-ras adalah jati dirinya; kota terbesar di Aetherion.",
		"Ras: Manusia, Serigala (Wolfkin), Kadal (Lizardkin), Permen (Candyfolk), Es (Frostkin), dan Mayat Hidup (Undead).",
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
		content.add_child(_mk_label("(kosong)", 14))
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
		"junk": "Rongsokan", "skillbook": "Kitab Skill"}.get(type_id, type_id)
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
		var l := _mk_label("%s [%s]  (%d%%)  ← %s" % [result_name, tier, rate, ", ".join(ing_txt)], 14)
		l.custom_minimum_size = Vector2(400, 0)
		if not can: l.modulate = Color(0.6, 0.6, 0.6)
		if not access.ok: l.tooltip_text = access.reason
		h.add_child(l)
		if not access.ok:
			h.add_child(_mk_label("🔒", 14))
		var b := _btn("Craft", func(): CraftingSystem.craft(r.get("id", "")); _rebuild())
		b.disabled = not can
		h.add_child(b)

func _build_shop() -> void:
	title.text = "Toko Greenvale"
	content.add_child(_mk_label("— Beli —", 16))
	for id in ["minor_potion", "mana_draught", "basic_orb", "seed_mintleaf", "seed_sunbud", "fishing_rod", "star_bait", "saddle", "copper_sword"]:
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

func _build_status() -> void:
	title.text = "Status Karakter"
	var cd := Db.cls(PlayerData.char_class)
	content.add_child(_mk_label("%s  ·  %s (%s)  ·  Level %d" % [PlayerData.char_name, cd.get("name", "-"), cd.get("title", ""), PlayerData.level], 18))
	content.add_child(_mk_label("Afinitas senjata: %s  ·  %s" % [", ".join(cd.get("affinity", [])), cd.get("advanced", "")], 11, Color(0.75, 0.8, 0.95)))
	var pts := _mk_label("Poin bebas: %d  (+5 tiap naik level)" % PlayerData.stat_points, 15)
	pts.add_theme_color_override("font_color", UiTheme.ACCENT)
	content.add_child(pts)
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
