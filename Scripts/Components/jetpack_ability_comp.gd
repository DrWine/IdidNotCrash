extends Node2D

@export var parent: CharacterBody2D
@export var launch_speed: float = 1500

@onready var jump_buffer_comp: Node = $"../JumpBufferComp"
@onready var coll: CollisionShape2D = $"../CollisionShape2D"
@onready var launch_ability_comp: Node2D = $"../LaunchAbilityComp"

var aiming := false
var fly_velocity := Vector2.ZERO
var flight_landed_cooldown := false
@export var used : bool = true
func _process(delta: float) -> void:
	if used : return
	if Input.is_action_pressed("Space") and parent.is_flying:
		aiming = true
		# TODO: draw aim line, slow time, etc.

	if Input.is_action_just_released("Space") and aiming and parent.is_flying:
		aiming = false
		# Re-aim mid-air
		launch_ability_comp.force_stop()
		coll.set_scale(Vector2(0.7,0.7))
		var mouse_position = get_global_mouse_position()
		var player_position = parent.global_position
		var direction = (mouse_position - player_position).normalized()
		fly_velocity = direction * launch_speed

func _physics_process(delta: float) -> void:
	if used: return
	if parent.is_flying and not flight_landed_cooldown:
		parent.velocity = Vector2.ZERO
		var collision = parent.move_and_collide(fly_velocity * delta)
		if collision:
			flight_landed_cooldown = true
			fly_velocity = Vector2.ZERO
			set_flying_false()

func set_flying_false() -> void:
	parent.velocity = Vector2.ZERO
	coll.set_scale(Vector2(1,1))
	var timer = get_tree().create_timer(0.005)
	await timer.timeout
	parent.is_flying = false
	flight_landed_cooldown = false
