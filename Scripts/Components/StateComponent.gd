extends Node2D

var start = true


@onready var movement_component: Node2D = $"../MovementComponent"
@onready var parent: CharacterBody2D = $".."

func _process(delta: float) -> void:
	if Input.is_action_just_released("Space"):
		start = false
		movement_component.start = start
