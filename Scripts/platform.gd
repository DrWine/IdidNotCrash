extends StaticBody2D
class_name Platform

@export var WandS: bool = false

@onready var sides: Area2D = $Sides
@onready var bottom_area: Area2D = $BottomArea
@onready var top_area: Area2D = $TopArea

@export var left_corner : float = -15.667
@export var right_corner : float = 15.833

var markers: Dictionary = {}
var dirs: Dictionary[Vector2, Vector2] = {}

func _ready() -> void:
	$Markers/Left.position.x = left_corner
	$Markers/Right.position.x = right_corner
	
	
	var marker_array: Array = []

	# Collect all Marker2D nodes under $Markers
	for child in $Markers.get_children():
		if child is Marker2D:
			marker_array.append(child)

	if marker_array.size() < 4:
		push_error("Platform node needs at least 4 Marker2D nodes under $Markers.")
		return

	# Initialize markers with the first one
	markers["top"] = marker_array[0]
	markers["bottom"] = marker_array[0]
	markers["left"] = marker_array[0]
	markers["right"] = marker_array[0]

	# Find actual top, bottom, left, right
	for marker in marker_array:
		var pos = marker.global_position

		if pos.y < markers["top"].global_position.y:
			markers["top"] = marker
		if pos.y > markers["bottom"].global_position.y:
			markers["bottom"] = marker
		if pos.x < markers["left"].global_position.x:
			markers["left"] = marker
		if pos.x > markers["right"].global_position.x:
			markers["right"] = marker


	
	# Setup movement directions
	if !WandS:
		var slope_dir = (markers["right"].global_position - markers["left"].global_position).normalized()
		dirs[Vector2(1, 0)] = slope_dir
		dirs[Vector2(-1, 0)] = -slope_dir
	else:
		dirs[Vector2(0, -1)] = (markers["top"].global_position - global_position).normalized()
		dirs[Vector2(0, 1)] = (markers["bottom"].global_position - global_position).normalized()

func get_platform_direction(vec2: Vector2) -> Vector2:
	if WandS:
		vec2.x = 0
	else:
		vec2.y = 0

	if sides.has_overlapping_bodies():
		return Vector2.ZERO

	if dirs.has(vec2):
		return dirs[vec2]

	return Vector2.ZERO

func calc_gravity_vector() -> Vector2:
	var gravity = Vector2.ZERO
	if bottom_area.has_overlapping_bodies():
		gravity = $Markers/Top.global_position - global_position
	elif top_area.has_overlapping_bodies():
		gravity = $Markers/Bottom.global_position - global_position

	return gravity.normalized()
	#return	 Vector2(0,0)/

func get_limits(player_position: Vector2, axis: Vector2) -> int:
	var safe_margin := -10.0

	# Handle slope logic if platform is not WandS (horizontal walking)
	if !WandS:
		var A = markers["left"].global_position
		var B = markers["right"].global_position
		var AB = B - A
		var AB_dir = AB.normalized()

		var AP = player_position - A
		var projection = AB_dir.dot(AP)

		if projection < -safe_margin:
			# Before slope start
			if axis.dot(-AB_dir) > 0:
				return 0
			return 1
		elif projection > AB.length() + safe_margin:
			# After slope end
			if axis.dot(AB_dir) > 0:
				return 0
			return 1

		return 1  # within slope bounds

	# Keep original vertical limits if WandS is true
	else:
		if player_position.y < markers["top"].global_position.y - safe_margin:
			if axis.y < 0:
				return 0
			return 1
		if player_position.y > markers["bottom"].global_position.y + safe_margin:
			if axis.y > 0:
				return 0
			return 1

	return 1
