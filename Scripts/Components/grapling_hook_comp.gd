extends Node2D

@onready var parent: Player = $".."
var is_swinging = false
var is_aiming = false
var is_throwing_hook = false
var grapple_point = Vector2.ZERO
var radius = 0.0
var angle = 0.0
var angular_speed = 0.0
var rope_buffer = 100.0
var current_rope_length = 0.0

const BASE_ANGULAR_SPEED = 3.0
const MAX_LINEAR_SPEED = 600.0
const MIN_ANGULAR_SPEED = 1.0
const HOOK_THROW_SPEED = 2000.0

@onready var grappling_hook: Line2D = $GraplingHook
@onready var dashed_line: DashedLine = $DashedLine
@onready var launch_ability_comp: Node2D = $"../LaunchAbilityComp"

var hook_tween: Tween
var hook_local_pos = Vector2.ZERO

func _ready() -> void:
	dashed_line.trans_color(Color(1,1,1,0), 0)
	dashed_line.clear_points()
	dashed_line.add_point(Vector2.ZERO)
	dashed_line.add_point(Vector2.ZERO)
	
	grappling_hook.clear_points()
	grappling_hook.add_point(Vector2.ZERO)
	grappling_hook.add_point(Vector2.ZERO)
	grappling_hook.width = 3
	grappling_hook.default_color = Color.GRAY

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Ability2"):
		if not is_swinging:
			is_aiming = true
			parent.set_time_scale(0.2)
			dashed_line.trans_color(Color.CYAN, 0.1)
	
	if is_aiming:
		update_grapple_trajectory()
	
	if is_swinging:
		update_hook_line()

func update_grapple_trajectory():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var distance = global_position.distance_to(mouse_pos)
	dashed_line.points[0] = Vector2.ZERO
	dashed_line.points[1] = direction * min(distance, 500)

func hide_trajectory_line():
	dashed_line.trans_color(Color(1,1,1,0), 0.1)

func animate_hook_throw(target_global_pos: Vector2):
	is_throwing_hook = true
	hook_local_pos = Vector2.ZERO
	
	if hook_tween:
		hook_tween.kill()
	
	hook_tween = create_tween()
	var throw_distance = global_position.distance_to(target_global_pos)
	var throw_time = throw_distance / HOOK_THROW_SPEED
	
	var target_local_pos = to_local(target_global_pos)
	hook_tween.tween_method(update_hook_position, Vector2.ZERO, target_local_pos, throw_time)
	hook_tween.tween_callback(start_swinging)

func update_hook_position(local_pos: Vector2):
	hook_local_pos = local_pos
	grappling_hook.points[0] = Vector2.ZERO
	grappling_hook.points[1] = hook_local_pos

func update_hook_line():
	var hook_local_pos = to_local(grapple_point)
	grappling_hook.points[0] = Vector2.ZERO
	grappling_hook.points[1] = hook_local_pos

func start_swinging():
	launch_ability_comp.force_stop()
	is_throwing_hook = false
	
	grapple_point = to_global(hook_local_pos)
	
	var to_player = parent.global_position - grapple_point
	radius = to_player.length()
	current_rope_length = radius
	if radius == 0:
		radius = 1
	angle = to_player.angle()
	var to_player_norm = to_player.normalized()
	var t_hat = Vector2(-to_player_norm.y, to_player_norm.x)
	var tangent_sign = sign(parent.velocity.dot(t_hat))
	if tangent_sign == 0:
		tangent_sign = 1
	angular_speed = BASE_ANGULAR_SPEED * radius * tangent_sign
	var linear_speed = abs(angular_speed * radius)
	if linear_speed > MAX_LINEAR_SPEED:
		linear_speed = MAX_LINEAR_SPEED
		angular_speed = (linear_speed / radius) * tangent_sign
	if abs(angular_speed) < MIN_ANGULAR_SPEED:
		angular_speed = MIN_ANGULAR_SPEED * tangent_sign

	is_swinging = true
	parent.is_grappling = true

func hide_hook():
	grappling_hook.clear_points()
	grappling_hook.add_point(Vector2.ZERO)
	grappling_hook.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("Ability2"):
		if is_aiming:
			parent.set_time_scale(1)
			hide_trajectory_line()
			is_aiming = false
		
		if not is_swinging and not is_throwing_hook:
			var mouse_pos = get_global_mouse_position()
			var direction = (mouse_pos - global_position).normalized()
			var distance = global_position.distance_to(mouse_pos)
			var clamped_distance = min(distance, 500)
			
			var target_global_pos = global_position + direction * clamped_distance
			animate_hook_throw(target_global_pos)
			
		elif is_swinging:
			is_swinging = false
			parent.is_grappling = false
			hide_hook()
	
	if is_swinging:
		var current_distance = parent.global_position.distance_to(grapple_point)
		
		if current_distance <= current_rope_length + rope_buffer:
			var new_radius = min(current_distance, current_rope_length + rope_buffer)
			if new_radius > current_rope_length:
				radius = new_radius
				var to_player = parent.global_position - grapple_point
				angle = to_player.angle()
		else:
			var to_player = parent.global_position - grapple_point
			radius = to_player.length()
			angle = to_player.angle()
		
		angle += angular_speed * delta
		var new_pos = grapple_point + Vector2(cos(angle), sin(angle)) * radius
		parent.global_position = new_pos
		var tangent_dir = Vector2(-sin(angle), cos(angle)) * sign(angular_speed)
		parent.velocity = tangent_dir * abs(angular_speed) * radius
