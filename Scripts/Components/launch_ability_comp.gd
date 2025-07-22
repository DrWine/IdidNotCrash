extends Node2D

@export var parent: CharacterBody2D
@export var launch_speed: float = 1500

@onready var jump_buffer_comp: Node = $"../JumpBufferComp"
@onready var coll: CollisionShape2D = $"../CollisionShape2D"

@export var used : bool = true
var col_scale_fly : Vector2 = Vector2(0.1,0.1)

var aiming := false
var fly_velocity := Vector2.ZERO
var flight_landed_cooldown := false

func _process(delta: float) -> void:
	if used: return
	if Input.is_action_pressed("Space") and not parent.is_flying:
		aiming = true
		# TODO: draw aim line, slow time, etc.

	if Input.is_action_just_released("Space") and aiming and not parent.is_flying:
		coll.set_scale(col_scale_fly)
		aiming = false
		parent.is_flying = true
		var mouse_position = get_global_mouse_position()
		var player_position = parent.global_position
		var direction = (mouse_position - player_position).normalized()
		fly_velocity = direction * launch_speed

func _physics_process(delta: float) -> void:
	if used: return
	if parent.is_flying and not flight_landed_cooldown:
		var collision = parent.move_and_collide(fly_velocity * delta)
		if collision:
			flight_landed_cooldown = true
			fly_velocity = Vector2.ZERO
			set_flying_false()

func set_flying_false() -> void:
	parent.velocity = Vector2.ZERO
	coll.set_scale(Vector2(1,1))
	var timer = get_tree().create_timer(0.025)
	await timer.timeout
	parent.is_flying = false
	flight_landed_cooldown = false

func force_stop() -> void:
	# Immediately cancel flying, mid-air or not
	parent.velocity = Vector2.ZERO
	fly_velocity = Vector2.ZERO
	parent.is_flying = false
	coll.set_scale(Vector2(1,1))
	flight_landed_cooldown = false
