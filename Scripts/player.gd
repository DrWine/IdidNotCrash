extends CharacterBody2D
class_name Player

var time_scale: float = 1
var speed_scale : float = 1
var is_flying = false

func _init() -> void:
	References.player = self
func _ready() -> void:
	References.player = self

func _physics_process(_delta: float) -> void:
	if !is_flying:
		move_and_slide()
