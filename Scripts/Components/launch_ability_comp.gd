extends Node2D

@export var parent: CharacterBody2D
@export var launch_speed: float = 1500

@onready var coll: CollisionShape2D = $"../CollisionShape2D"

var fly_velocity := Vector2.ZERO
var flight_landed_cooldown := false
var mid_air_jump_used := false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Space") or Input.is_action_just_pressed("Ability1")):
		if (parent.is_flying and !mid_air_jump_used) or !parent.is_flying:
			parent.set_time_scale(0.2)
	

	if Input.is_action_just_released("Ability1"):
		parent.set_time_scale(1)
		if parent.is_flying and not mid_air_jump_used:
			var dir = (get_global_mouse_position() - parent.global_position).normalized()
			fly_velocity = dir * launch_speed
			mid_air_jump_used = true

	if Input.is_action_just_released("Space"):
		parent.set_time_scale(1)
		if not parent.is_flying:
			parent.is_flying = true
			coll.set_scale(Vector2(0.1, 0.1))
			var dir = (get_global_mouse_position() - parent.global_position).normalized()
			fly_velocity = dir * launch_speed
			mid_air_jump_used = false



func _physics_process(delta: float) -> void:
	if parent.is_flying and not flight_landed_cooldown:
		var collision = parent.move_and_collide(fly_velocity * delta * parent.time_scale)
		if collision:
			flight_landed_cooldown = true
			fly_velocity = Vector2.ZERO
			set_flying_false()

func set_flying_false() -> void:
	parent.velocity = Vector2.ZERO
	coll.set_scale(Vector2(1, 1))
	var timer = get_tree().create_timer(0.025)
	await timer.timeout
	parent.is_flying = false
	flight_landed_cooldown = false
	mid_air_jump_used = false
