@tool
extends Line2D
class_name DashedLine

@export var dash_length: float = 10.0:
	set(value):
		dash_length = max(value, 1.0)
		queue_redraw()

@export var gap_length: float = 5.0:
	set(value):
		gap_length = max(value, 0.0)
		queue_redraw()

@export var dash_color: Color = Color.WHITE:
	set(value):
		dash_color = value
		queue_redraw()

var _tween: Tween

func _ready():
	queue_redraw()

func _draw():
	if points.size() < 2:
		return
	
	for i in range(points.size() - 1):
		draw_dashed_segment(points[i], points[i + 1])

func draw_dashed_segment(start: Vector2, end: Vector2):
	var dir = (end - start).normalized()
	var length = start.distance_to(end)
	var t := 0.0
	
	while t < length:
		var from = start + dir * t
		t += dash_length
		var to = start + dir * min(t, length)
		draw_line(from, to, dash_color, width)
		t += gap_length

# Tween dash_color to target color over given time in seconds
func trans_color(target_color: Color, time: float) -> void:
	# Kill existing tween if running
	if _tween != null:
		_tween.kill()    
	
	# Create new tween
	_tween = create_tween()
	
	# Tween the dash_color property
	_tween.tween_property(self, "dash_color", target_color, time)
	_tween.set_trans(Tween.TRANS_LINEAR)
	_tween.set_ease(Tween.EASE_IN_OUT)
