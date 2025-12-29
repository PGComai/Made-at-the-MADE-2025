extends Camera2D

@export var car: Car

var target_zoom: float = 2.0

func _process(delta: float) -> void:
	if car:
		if car.is_dead:
			target_zoom = lerpf(target_zoom, 8.0, delta)
		else:
			target_zoom = lerp(target_zoom,
							remap(-car.speed, -250.0, -car.INITIAL_SPEED, 1.0, 2.0),
							delta)
			target_zoom = clampf(target_zoom, 1.0, 2.0)

		global_position = car.global_position
		zoom = Vector2(target_zoom, target_zoom)
