extends CharacterBody2D
class_name Player

var time_scale: float = 1.0
var speed_scale: float = 1.0
var is_flying = false

var movement_history = []

func _init() -> void:
	References.player = self

func _ready() -> void:
	References.player = self

func _physics_process(delta: float) -> void:
	if not is_flying:
		move_and_slide()

func set_time_scale(new_scale: float) -> void:
	time_scale = new_scale
