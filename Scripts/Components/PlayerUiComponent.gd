extends CanvasLayer

@onready var wheel: TextureRect = $Control/Wheel

var dragging := false
var drag_offset := Vector2.ZERO

func _on_wheel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				# Calculate offset so the mouse stays on the same relative position inside the wheel
				drag_offset = event.position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		printt(event.position - drag_offset)
		# Set the global position based on mouse position and offset
		#wheel.global_position = event.position - drag_offset
