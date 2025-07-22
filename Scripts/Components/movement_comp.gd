extends Node

@export var speed = 700
@export var jump_speed = -1800
@export var gravity = 400

@export var parent : CharacterBody2D
@onready var jump_buffer_comp: Node = $"../JumpBufferComp"

func _ready() -> void:
	jump_buffer_comp.connect("just_landed", player_just_landed)

func player_just_landed():
	#parent.velocity = Vector2.ZERO
	pass

func _physics_process(delta):
	# parent.velocity.y += gravity * delta

	var axis_x = Input.get_axis("Left", "Right")
	var axis_y = Input.get_axis("Up", "Down")

	if not parent.is_flying:
		for i in parent.get_slide_collision_count():
			var collision = parent.get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is not Platform:
				continue
			collider = collider as Platform

			var dir = collider.get_platform_direction(Vector2(axis_x, axis_y))
			var limit = collider.get_limits(parent.global_position, Vector2(axis_x, axis_y))
			var gravity_vec = collider.calc_gravity_vector()

			parent.velocity = (dir * speed * limit) + (gravity_vec * gravity * limit)
