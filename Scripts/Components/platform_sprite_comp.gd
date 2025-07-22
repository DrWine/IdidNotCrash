extends Sprite2D

@onready var shaker: Shaker = $Shaker
@onready var top_area: Area2D = $"../TopArea"
@onready var bottom: Marker2D = $"../Markers/Bottom"
@onready var platform: Platform = $".."

func _ready() -> void:
	shaker.stop()

func _process(_delta: float) -> void:
	var jump_buffer = References.player.get_node("JumpBufferComp")
	if not jump_buffer.is_connected("just_landed", player_just_landed):
		jump_buffer.connect("just_landed", player_just_landed)

func player_just_landed():
	if top_area.overlaps_body(References.player):
		heavy_effect()
		shaker.start(0.17)
		
func heavy_effect():
	if !References.player:
		return

	var local_dir = to_local(References.player.global_position) - position
	var base_offset = -local_dir.normalized() * 7

	for i in range(3):
		var ghost = Sprite2D.new()
		ghost.texture = texture
		ghost.texture_filter = texture_filter
		ghost.rotation = rotation
		ghost.z_index = z_index - 1

		var alpha = 0.5 - i * 0.15  # 0.5, 0.35, 0.2
		ghost.modulate = Color(1, 1, 1, alpha)
		ghost.position = base_offset * (i + 1)

		add_child(ghost)

		var tween = get_tree().create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(ghost, "position", ghost.position + base_offset * 0.5, 0.3)

		# Queue free after animation ends
		tween.tween_callback(Callable(ghost, "queue_free"))
