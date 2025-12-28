extends Camera2D


@export var car: Car


func _process(delta: float) -> void:
	if car:
		global_position = car.global_position
