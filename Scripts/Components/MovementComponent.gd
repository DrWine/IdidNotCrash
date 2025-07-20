extends Node2D

@export var speed : float = 10
@onready var parent : Node2D = get_parent()

@export_group("Rotation properties")
@export var rotation_speed: float = 0.05
@export var rotation_accel_curve: Curve
@export var rotation_deaccel_curve: Curve

var can_rotate: bool = true
var start : bool = true

var time : float = 0.0
var released_time: float = 0.0
var released_dir: int = 0
var released: bool = false

func _ready() -> void:
	start = true
	if start:
		var screen_size = get_viewport().get_visible_rect().size
		parent.global_position = screen_size / 2

func _process(delta: float) -> void:
	can_rotate = start
	if can_rotate:
		if Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Right"):
			time = 0.0
			released = false

		if Input.is_action_just_released("Left"):
			released = true
			released_time = 0.0
			released_dir = -1

		if Input.is_action_just_released("Right"):
			released = true
			released_time = 0.0
			released_dir = 1

		if Input.is_action_pressed("Left"):
			time += delta
			parent.global_rotation -= rotation_speed * rotation_accel_curve.sample(clamp(time, 0.0, get_curve_max_x(rotation_accel_curve)))

		if Input.is_action_pressed("Right"):
			time += delta
			parent.global_rotation += rotation_speed * rotation_accel_curve.sample(clamp(time, 0.0, get_curve_max_x(rotation_accel_curve)))

		# Apply deceleration (friction) when released
		if released:
			released_time += delta
			var friction = rotation_deaccel_curve.sample(clamp(released_time, 0.0, get_curve_max_x(rotation_deaccel_curve)))
			parent.global_rotation += rotation_speed * friction * released_dir

			if released_time >= get_curve_max_x(rotation_deaccel_curve):
				released = false
				released_dir = 0

func get_curve_max_x(curve: Curve) -> float:
	if curve.get_point_count() > 0:
		return curve.get_point_position(curve.get_point_count() - 1).x
	else:
		return 1.0  # default fallback

func _physics_process(delta: float) -> void:
	if start:
		return
	
	pass
