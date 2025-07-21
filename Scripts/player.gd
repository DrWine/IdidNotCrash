extends CharacterBody2D

var time_scale: float = 1
var speed_scale : float = 1

func _physics_process(_delta: float) -> void:
	move_and_slide()
