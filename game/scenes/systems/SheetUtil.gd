class_name SheetUtil
extends RefCounted
## Builds SpriteFrames from directional sheets at runtime, so we never
## hand-author fragile SpriteFrames .tres resources.

const DIRS := ["down", "up", "left", "right"]

## Build a SpriteFrames for a standard Ninja-Adventure walk sheet:
## cols x rows grid of `fs`x`fs` frames, rows = down/up/left/right.
## Produces walk_<dir> (all cols) and idle_<dir> (col 0).
static func build_directional(tex: Texture2D, fs: int, cols: int, rows: int, fps: float = 8.0) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for row in range(min(rows, DIRS.size())):
		var dir: String = DIRS[row]
		var walk := "walk_" + dir
		var idle := "idle_" + dir
		sf.add_animation(walk)
		sf.set_animation_speed(walk, fps)
		sf.set_animation_loop(walk, true)
		sf.add_animation(idle)
		sf.set_animation_speed(idle, 1.0)
		sf.set_animation_loop(idle, true)
		for col in range(cols):
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(col * fs, row * fs, fs, fs)
			sf.add_frame(walk, at)
			if col == 0:
				sf.add_frame(idle, at)
	return sf

## Slice a horizontal strip of N frames (fs x fs) into a single looping anim.
static func build_strip(tex: Texture2D, fs: int, frames: int, anim: String = "play", fps: float = 12.0, loop: bool = true) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for i in range(frames):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fs, 0, fs, fs)
		sf.add_frame(anim, at)
	return sf

## Direction name from a movement vector (4-way facing from 8-way movement).
static func dir_from_vec(v: Vector2) -> String:
	if v == Vector2.ZERO:
		return "down"
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0 else "left"
	return "down" if v.y > 0 else "up"

static func load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null
