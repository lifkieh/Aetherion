p = 'game/scenes/ui/PauseMenu.gd'
s = open(p, encoding='utf-8').read()

old = '''	else:
		vb.add_child(_slider("Musik", Settings.music_volume, func(v): Settings.set_music_volume(v)))
		vb.add_child(_slider("Efek Suara", Settings.sfx_volume, func(v): Settings.set_sfx_volume(v)))
		vb.add_child(_check("Layar Penuh", Settings.fullscreen, func(v): Settings.set_fullscreen(v)))
		vb.add_child(_check("Mode Hemat (30fps)", Settings.eco_mode, func(v): Settings.set_eco(v)))
		vb.add_child(_check("Bisukan Audio", Settings.muted, func(v): Settings.set_muted_pref(v)))
		vb.add_child(_btn("← Kembali", func(): _mode = "main"; _build()))'''
new = '''	elif _mode == "settings":
		vb.add_child(_lbl(Loc.t("ui.settings.audio"), 15, Color(0.7, 0.85, 1.0)))
		vb.add_child(_slider(Loc.t("ui.settings.music"), Settings.music_volume, func(v): Settings.set_music_volume(v)))
		vb.add_child(_slider(Loc.t("ui.settings.sfx"), Settings.sfx_volume, func(v): Settings.set_sfx_volume(v)))
		vb.add_child(_slider(Loc.t("ui.settings.ambience"), Settings.ambience_volume, func(v): Settings.set_ambience_volume(v)))
		vb.add_child(_slider(Loc.t("ui.settings.ui_sfx"), Settings.ui_volume, func(v): Settings.set_ui_volume(v)))
		vb.add_child(_check(Loc.t("ui.settings.mute"), Settings.muted, func(v): Settings.set_muted_pref(v)))
		vb.add_child(_lbl(Loc.t("ui.settings.video"), 15, Color(0.7, 0.85, 1.0)))
		vb.add_child(_check(Loc.t("ui.settings.fullscreen"), Settings.fullscreen, func(v): Settings.set_fullscreen(v)))
		vb.add_child(_check(Loc.t("ui.settings.vsync"), Settings.vsync, func(v): Settings.set_vsync(v)))
		vb.add_child(_check(Loc.t("ui.settings.eco"), Settings.eco_mode, func(v): Settings.set_eco(v)))
		vb.add_child(_btn(Loc.t("ui.settings.controls"), func(): _mode = "controls"; _build()))
		vb.add_child(_btn(Loc.t("ui.settings.language"), func(): _mode = "language"; _build()))
		vb.add_child(_btn(Loc.t("ui.back"), func(): _mode = "main"; _build()))
	elif _mode == "language":
		vb.add_child(_lbl(Loc.t("ui.settings.language"), 15, Color(0.7, 0.85, 1.0)))
		for pair in [["id", "Bahasa Indonesia"], ["en", "English"]]:
			var mark: String = "● " if Loc.language == pair[0] else "○ "
			vb.add_child(_btn(mark + pair[1], func():
				Loc.set_language(pair[0])
				_build()))
		vb.add_child(_lbl(Loc.t("ui.settings.language_note"), 11, Color(0.7, 0.74, 0.85)))
		vb.add_child(_btn(Loc.t("ui.back"), func(): _mode = "settings"; _build()))
	else:
		# KONTROL: remap keyboard/mouse + glyph gamepad (v0.4.4 #99)
		vb.add_child(_lbl(Loc.t("ui.settings.controls_hint"), 11, Color(0.75, 0.8, 0.95)))
		if _await_action != "":
			vb.add_child(_lbl(Loc.t("ui.keybind.press") % _await_action, 14, Color(1.0, 0.86, 0.42)))
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 6)
		vb.add_child(grid)
		for pair in Keybinds.REMAPPABLE:
			grid.add_child(_lbl(Loc.t(pair[1]), 13))
			var glyph := InputGlyphs.icon(pair[0], 20)
			if glyph:
				grid.add_child(glyph)
			else:
				grid.add_child(_lbl(" ", 13))
			var act: String = pair[0]
			grid.add_child(_btn(Keybinds.label_for(act), func():
				_await_action = act
				_build()))
		vb.add_child(_btn(Loc.t("ui.keybind.reset"), func():
			Keybinds.reset_defaults()
			_build()))
		vb.add_child(_btn(Loc.t("ui.back"), func(): _mode = "settings"; _build()))'''
assert old in s
s = s.replace(old, new, 1)

# state remap + input capture
s = s.replace('var _mode := "main"   # main | settings',
              'var _mode := "main"   # main | settings | controls | language\nvar _await_action := ""   # aksi yang sedang menunggu tombol baru (remap)')

s = s.rstrip('\n') + '''

## Menangkap tombol untuk remap (v0.4.4 #99). ESC membatalkan.
func _unhandled_input(event: InputEvent) -> void:
	if _await_action == "":
		return
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ESCAPE:
			_await_action = ""
			_build()
			get_viewport().set_input_as_handled()
			return
		if Keybinds.rebind(_await_action, event):
			Audio.play_sfx("success")
		_await_action = ""
		_build()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if Keybinds.rebind(_await_action, event):
			Audio.play_sfx("success")
		_await_action = ""
		_build()
		get_viewport().set_input_as_handled()
'''
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('pause menu ok')
