extends Control


const GAME_OVER = preload("uid://cdmwdc4fob4s2")


@export var car: Car
@onready var label_time_left: Label = $LabelTimeLeft

func _process(_delta: float) -> void:
	label_time_left.text = "%.2f" % car.life

func game_over() -> void:
	var new_game_over = GAME_OVER.instantiate()
	add_child(new_game_over)
