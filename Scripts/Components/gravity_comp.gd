extends Node2D

@onready var top: Area2D = $Top
@onready var bottom: Area2D = $Bottom
@onready var left: Area2D = $Left
@onready var right: Area2D = $Right

@onready var areas = [top,bottom,left,right]
@onready var vectors_dict = {
	top:Vector2(0,1),
	bottom:Vector2(0,-1),
	left:Vector2(1,0),
	right:Vector2(-1,0)
}

@onready var player: CharacterBody2D = $".."

func _physics_process(_delta: float) -> void:
	var last_detect : Area2D
	for area: Area2D in areas:
		if area.has_overlapping_bodies():
			last_detect = area
		pass
	
	
	
