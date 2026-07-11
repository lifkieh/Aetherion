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

func _mk_label(t: String, s: int = 16) -> Label:
	var l := Label.new()
	l.text = t
	if _font: l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", s)
	return l

func _build_frame() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
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
	for m in [["inventory", "Tas"], ["crafting", "Craft"], ["shop", "Toko"], ["quest", "Quest"], ["pedia", "Pedia"]]:
		var b := Button.new()
		b.text = m[1]
		if _font: b.add_theme_font_override("font", _font)
		b.pressed.connect(func(): mode = m[0]; _rebuild())
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
		"quest": _build_quests()

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
	content.add_child(_btn("Kembali ke Menu Utama", func(): close_menu(); get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")))

func _load_slot(slot: int) -> void:
	if SaveManager.load_game(slot):
		close_menu()
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _build_inventory() -> void:
	title.text = "Tas"
	if PlayerData.inventory.is_empty():
		content.add_child(_mk_label("(kosong)", 14))
	for id in PlayerData.inventory.keys():
		var def := Db.item(id)
		var h := _row()
		var name_l := _mk_label("%s  [%s]  x%d" % [def.get("name", id), def.get("tier", "F"), PlayerData.inventory[id]], 15)
		name_l.custom_minimum_size = Vector2(320, 0)
		h.add_child(name_l)
		match def.get("type", ""):
			"weapon":
				h.add_child(_btn("Pakai", func(): PlayerData.equipped_weapon = id; PlayerData.recalculate_stats(); EventBus.toast.emit("Memakai " + def.get("name", id)); _rebuild()))
			"consumable":
				h.add_child(_btn("Gunakan", func(): _use_consumable(id, def)))
	var eq := _mk_label("Senjata: %s" % (Db.item_name(PlayerData.equipped_weapon) if PlayerData.equipped_weapon != "" else "-"), 14)
	content.add_child(eq)

func _use_consumable(id: String, def: Dictionary) -> void:
	if PlayerData.item_count(id) <= 0: return
	PlayerData.remove_item(id, 1)
	if def.has("heal"): PlayerData.heal(int(def.heal))
	if def.has("restore_mp"): PlayerData.restore_mp(int(def.restore_mp))
	Audio.play_sfx("success")
	EventBus.toast.emit("Menggunakan " + def.get("name", id))
	_rebuild()

func _build_crafting() -> void:
	title.text = "Bengkel Kerja"
	for r in Db.recipes:
		var h := _row()
		var result_name := Db.item_name(r.get("result", ""))
		var ing_txt := []
		for ing in r.get("ingredients", []):
			ing_txt.append("%s x%d" % [Db.item_name(ing.get("item", "")), ing.get("qty", 1)])
		var can := CraftingSystem.can_craft(r)
		var rate := int(round(CraftingSystem.success_rate(r) * 100))
		var l := _mk_label("%s  (%d%%)  ← %s" % [result_name, rate, ", ".join(ing_txt)], 14)
		l.custom_minimum_size = Vector2(400, 0)
		if not can: l.modulate = Color(0.6, 0.6, 0.6)
		h.add_child(l)
		var b := _btn("Craft", func(): CraftingSystem.craft(r.get("id", "")); _rebuild())
		b.disabled = not can
		h.add_child(b)

func _build_shop() -> void:
	title.text = "Toko Greenvale"
	content.add_child(_mk_label("— Beli —", 16))
	for id in ["minor_potion", "mana_draught", "basic_orb", "seed_mintleaf", "seed_sunbud", "fishing_rod", "star_bait", "saddle", "copper_sword"]:
		if not Db.items.has(id): continue
		var h := _row()
		var price := Economy.buy_price(id)
		var l := _mk_label("%s — %dG" % [Db.item_name(id), price], 14)
		l.custom_minimum_size = Vector2(320, 0)
		h.add_child(l)
		h.add_child(_btn("Beli", func(): if Economy.buy(id, 1): _rebuild() else: EventBus.toast.emit("Gagal beli (gold/stok).")))
	content.add_child(_mk_label("— Jual —", 16))
	for id in PlayerData.inventory.keys():
		var h := _row()
		var sp := Economy.sell_price(id)
		var l := _mk_label("%s x%d — jual %dG" % [Db.item_name(id), PlayerData.inventory[id], sp], 14)
		l.custom_minimum_size = Vector2(320, 0)
		h.add_child(l)
		h.add_child(_btn("Jual 1", func(): if Economy.sell(id, 1): _rebuild()))
