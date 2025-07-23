extends Node2D

@onready var parent: CharacterBody2D = $".."
@export var launch_speed: float = 1500
@onready var coll: CollisionShape2D = $"../CollisionShape2D"
@onready var dashed_line: DashedLine = $DashedLine

var fly_velocity := Vector2.ZERO
var flight_landed_cooldown := false
var mid_air_jump_used := false
var is_aiming := false

@export var reset_on_landing: bool = false 

func _ready() -> void:
	# Start with invisible line
	dashed_line.trans_color(Color(1,1,1,0), 0)
	dashed_line.clear_points()
	dashed_line.add_point(Vector2.ZERO)
	dashed_line.add_point(Vector2.ZERO)

func _process(delta: float) -> void:
	# Start aiming only if allowed
	if (Input.is_action_just_pressed("Space") or Input.is_action_just_pressed("Ability1")):
		if (parent.is_flying and !mid_air_jump_used) or !parent.is_flying:
			is_aiming = true
			parent.set_time_scale(0.2)
			dashed_line.trans_color(Color.WHITE, 0.1)
	
	if is_aiming:
		update_trajectory_line()
	
	# Mid-air jump on Ability1 release
	if Input.is_action_just_released("Ability1"):
		parent.set_time_scale(1)
		hide_trajectory_line()
		is_aiming = false
		if parent.is_flying and not mid_air_jump_used:
			var dir = (get_global_mouse_position() - parent.global_position).normalized()
			fly_velocity = dir * launch_speed
			mid_air_jump_used = true
	
	# Ground launch on Space release
	if Input.is_action_just_released("Space"):
		parent.set_time_scale(1)
		hide_trajectory_line()
		is_aiming = false
		if not parent.is_flying:
			parent.is_flying = true
			coll.set_scale(Vector2(0.1, 0.1))
			var dir = (get_global_mouse_position() - parent.global_position).normalized()
			fly_velocity = dir * launch_speed
			# Do NOT reset mid_air_jump_used here

func update_trajectory_line():
	var mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(mouse_pos)
	var direction = (mouse_pos - global_position).normalized()
	
	# Set trajectory line points
	dashed_line.points[0] = Vector2.ZERO
	dashed_line.points[1] = clamp(distance, 1, 500) * direction

func hide_trajectory_line():
	dashed_line.trans_color(Color(1,1,1,0), 0.1)

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

	if reset_on_landing:
		mid_air_jump_used = false

func force_stop() -> void:
	fly_velocity = Vector2.ZERO
	parent.velocity = Vector2.ZERO
	parent.is_flying = false
	flight_landed_cooldown = false
	is_aiming = false
	mid_air_jump_used = false if reset_on_landing else mid_air_jump_used
	parent.set_time_scale(1)
	hide_trajectory_line()
	coll.set_scale(Vector2(1, 1))
