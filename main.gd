extends Control


const GAME_OVER = preload("uid://cdmwdc4fob4s2")


@onready var label_time_left: Label = $LabelTimeLeft


func game_over() -> void:
	var new_game_over = GAME_OVER.instantiate()
	add_child(new_game_over)
