extends CharacterBody2D

var time_scale: float = 1
var speed_scale : float = 1
var is_flying = false
func _physics_process(_delta: float) -> void:
	if !is_flying:
		move_and_slide()
