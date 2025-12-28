@tool
class_name Checkpoint
extends Area2D

signal car_entered(car: Node2D)
signal car_exited(car: Node2D)

@export var shape: Shape2D:
	set(value):
		if shape != value:
			shape = value
			if is_node_ready():
				collision_shape.shape = shape
				update_configuration_warnings()

@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	collision_shape.shape = shape
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		car_entered.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("car"):
		car_exited.emit(body)

func _get_configuration_warnings() -> PackedStringArray:
	if shape == null:
		return ["A shape must be provided for Checkpoint to function."]
	return []
