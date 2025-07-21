extends Node2D

@export var parent: CharacterBody2D
@export var launch_speed: float = 200

@onready var jump_buffer_comp: Node = $"../JumpBufferComp"

var aiming := false
var is_flying := false
var fly_velocity := Vector2.ZERO

func _process(delta: float) -> void:
	printt(aiming, jump_buffer_comp.is_touching_any_surface())
	if Input.is_action_pressed("Space") and jump_buffer_comp.is_touching_any_surface():
		aiming = true
		# TODO: draw aim line, slow time, etc.

	if Input.is_action_just_released("Space") and aiming:
		aiming = false
		is_flying = true
		var mouse_position = get_global_mouse_position()
		var player_position = parent.global_position
		var direction = (mouse_position - player_position).normalized()
		fly_velocity = direction * launch_speed

func _physics_process(delta: float) -> void:
	if is_flying:
		var collision = parent.move_and_collide(fly_velocity * delta)
		if collision:
			is_flying = false
			fly_velocity = Vector2.ZERO
