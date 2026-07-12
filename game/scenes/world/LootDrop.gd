class_name LootDrop
extends Node2D
## Physical loot burst (FF-2f): dead monsters SPRAY their drops as little item
## sprites that scatter, then magnet to the player, then land in the bag.
## Works in both perspectives (pure Node2D + tweens, no physics).

var item_id := ""
var qty := 1
var _player: Node2D = null
var _magnet := false
var _t := 0.0

static func spawn(parent: Node, pos: Vector2, id: String, amount: int) -> void:
	if parent == null:
		return
	var d: LootDrop = LootDrop.new()
	d.item_id = id
	d.qty = amount
	parent.add_child(d)
	d.global_position = pos

func _ready() -> void:
	z_index = 40
	# item icon (fallback: tier-colored square)
	var icon_path := Db.item_icon(item_id)
	if icon_path != "" and ResourceLoader.exists(icon_path):
		var s := Sprite2D.new()
		s.texture = load(icon_path)
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(0.55, 0.55)
		add_child(s)
	else:
		var sq := ColorRect.new()
		sq.color = Color(0.9, 0.85, 0.5)
		sq.size = Vector2(6, 6)
		sq.position = Vector2(-3, -3)
		add_child(sq)
	# scatter hop: out in a random direction with a little arc
	var dir := Vector2.from_angle(randf() * TAU)
	var target := global_position + dir * randf_range(10.0, 26.0)
	scale = Vector2(0.2, 0.2)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "global_position", target, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(func(): _magnet = true)

func _process(delta: float) -> void:
	_t += delta
	if _t > 20.0:            # safety despawn
		_collect()
		return
	if not _magnet:
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if _player == null:
			return
	var d := _player.global_position - global_position
	# short grace hop, then accelerate toward the player
	var speed := clampf(240.0 - d.length(), 90.0, 240.0) + _t * 60.0
	global_position += d.normalized() * speed * delta
	if d.length() < 12.0:
		_collect()

func _collect() -> void:
	if item_id != "":
		PlayerData.add_item(item_id, qty)
		Audio.play_sfx("coin", randf_range(0.95, 1.15))
	queue_free()
