extends CanvasLayer

@onready var anchor: Control = %Anchor

var from_angle: float
var to_angle: float

func _ready() -> void:
	from_angle = randf_range(-PI/12, PI/12)
	if randf_range(-1, 1) < 0:
		to_angle = from_angle - deg_to_rad(randf_range(5, 10))
	else:
		to_angle = from_angle + deg_to_rad(randf_range(5, 10))

	anchor.rotation = from_angle

func _enter_tree() -> void:
	Engine.time_scale = 0.5
	AudioServer.playback_speed_scale = 0.5

func _exit_tree() -> void:
	Engine.time_scale = 1
	AudioServer.playback_speed_scale = 1

func _process(delta: float) -> void:
	anchor.rotation = lerpf(anchor.rotation, to_angle, delta)
