@tool
class_name FinishLine
extends Area2D

signal lap_finished(body: Node2D)

@export var checkpoint_recorder: CheckpointRecorder

@onready var collision_shape: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if checkpoint_recorder.has_seen_all(body):
		lap_finished.emit(body)
		checkpoint_recorder.reset_for(body)
