extends Node

@export var parent : CharacterBody2D

signal just_landed

func is_touching_any_surface():
	if !parent: return false
	return (parent.is_on_floor() or parent.is_on_ceiling() or parent.is_on_wall())
 
var was_on_floor = true
func _physics_process(_delta: float) -> void:
	var is_on_floor_now = is_touching_any_surface()
	if was_on_floor != is_on_floor_now and is_on_floor_now:
		emit_signal("just_landed")
	was_on_floor = is_touching_any_surface()
