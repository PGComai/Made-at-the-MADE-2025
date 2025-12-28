extends Camera2D


@export var car: Car


var target_zoom: float = 2.0


func _process(delta: float) -> void:
	if car:
		global_position = car.global_position
		target_zoom = lerp(target_zoom,
						remap(-car.speed, -250.0, -car.INITIAL_SPEED, 1.0, 2.0),
						0.1)
		target_zoom = clampf(target_zoom, 1.0, 2.0)
		zoom = Vector2(target_zoom, target_zoom)
