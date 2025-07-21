extends Node


@export var speed = 700
@export var jump_speed = -1800
@export var gravity = 4000

@export var parent : CharacterBody2D
@onready var jump_buffer_comp: Node = $"../JumpBufferComp"

func _ready() -> void:
	jump_buffer_comp.connect("just_landed", player_just_landed)

func player_just_landed():
	parent.velocity = Vector2.ZERO

#func _physics_process(delta):
	# Add gravity every frame
	#parent.velocity.y += gravity * delta

	# Input affects x axis only
	#parent.velocity.x = Input.get_axis("Left", "Right") * speed
	
