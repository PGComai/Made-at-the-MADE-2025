extends Node2D

@onready var game_controller = get_node("/root/Racetrack/Main")
@onready var ui_node = get_node("/root/Racetrack/Main/CanvasLayer/UI")

@export var xp_amt := 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		game_controller.add_xp(xp_amt)
		queue_free()
