extends Node2D
@onready var parent: Player = $".."

var is_swinging = false
var grapple_point = Vector2.ZERO
var radius = 0.0
var angle = 0.0
var angular_speed = 0.0

const BASE_ANGULAR_SPEED = 3.0
const MAX_LINEAR_SPEED = 600.0
const MIN_ANGULAR_SPEED = 1.0

func _physics_process(delta: float) -> void:
	
	
	if Input.is_action_just_released("Ability2"):
		if not is_swinging:
			# START grappling
			grapple_point = get_global_mouse_position()

			var to_player = parent.global_position - grapple_point
			radius = to_player.length()
			if radius == 0:
				radius = 1

			angle = to_player.angle()

			# Compute tangent direction
			var to_player_norm = to_player.normalized()
			var t_hat = Vector2(-to_player_norm.y, to_player_norm.x)  # CCW tangent

			# Determine swing direction based on initial velocity
			var tangent_sign = sign(parent.velocity.dot(t_hat))
			if tangent_sign == 0:
				tangent_sign = 1  # default to CCW if velocity is zero

			# Base angular speed
			angular_speed = BASE_ANGULAR_SPEED * radius * tangent_sign

			# Clamp linear speed
			var linear_speed = abs(angular_speed * radius)
			if linear_speed > MAX_LINEAR_SPEED:
				linear_speed = MAX_LINEAR_SPEED
				angular_speed = (linear_speed / radius) * tangent_sign

			# Minimum angular speed
			if abs(angular_speed) < MIN_ANGULAR_SPEED:
				angular_speed = MIN_ANGULAR_SPEED * tangent_sign

			is_swinging = true
			parent.is_grappling = true

		else:
			# STOP grappling
			is_swinging = false
			parent.is_grappling = false

	# Apply swing motion
	if is_swinging:
		angle += angular_speed * delta

		var new_pos = grapple_point + Vector2(cos(angle), sin(angle)) * radius
		parent.global_position = new_pos

		var tangent_dir = Vector2(-sin(angle), cos(angle)) * sign(angular_speed)  # dynamic direction
		parent.velocity = tangent_dir * abs(angular_speed) * radius
