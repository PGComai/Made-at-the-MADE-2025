@tool
class_name Checkpoint
extends Area2D

signal car_entered(car: Node2D)
signal car_exited(car: Node2D)

@export var width: float = 0:
	set(value):
		if width != maxf(0, value):
			width = maxf(0, value)
			if is_node_ready():
				var shape := RectangleShape2D.new()
				shape.size = Vector2(width, 20)
				collision_shape.shape = shape

@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 20)
	collision_shape.shape = shape

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		car_entered.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("car"):
		car_exited.emit(body)
