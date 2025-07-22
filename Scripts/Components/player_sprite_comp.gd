extends Sprite2D

@onready var parent = get_parent().get_parent()
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var movement_comp = parent.get_node("MovementComp")

var state = "idle"

func _process(delta: float) -> void:
	var angle: float

	if parent.is_flying:
		angle = parent.velocity.angle()
	else:
		angle = movement_comp.gravity_vec.angle()

	# Apply rotation with offset (assuming sprite points up)
	rotation = angle - deg_to_rad(90)

	# Normalize global rotation into 0–360° for flipping logic
	var global_deg = fposmod(rad_to_deg(global_rotation), 360.0)
	var is_upside_down = global_deg > 90 and global_deg < 270

	# Flip H depending on direction, reverse if upside down
	if is_upside_down:
		flip_h = parent.velocity.x < 0
	else:
		flip_h = parent.velocity.x > 0

	# Flip V if flying and facing upside down (mirrored orientation)
	if parent.is_flying and is_upside_down:
		flip_v = true
	else:
		flip_v = false

	if state == "idle" and !anim.is_playing():
		anim.play("Idle", -1, 2, false)
