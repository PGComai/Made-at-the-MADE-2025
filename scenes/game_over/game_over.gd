class_name GameOver
extends CanvasLayer

@onready var anchor: Control = %Anchor
@onready var score_label: Label = %ScoreLabel

var score: int
var from_angle: float
var to_angle: float
var can_restart := false

func _ready() -> void:
	from_angle = randf_range(-PI/12, PI/12)
	if randf_range(-1, 1) < 0:
		to_angle = from_angle - deg_to_rad(randf_range(5, 10))
	else:
		to_angle = from_angle + deg_to_rad(randf_range(5, 10))

	anchor.rotation = from_angle
	score_label.text = "(you scored %d points though)" % score

func _input(event: InputEvent) -> void:
	if can_restart:
		if Input.is_action_just_pressed("a"):
			get_tree().change_scene_to_file("res://scenes/Levels/Track1.tscn")

func _enter_tree() -> void:
	Engine.time_scale = 0.5
	AudioServer.playback_speed_scale = 0.5

func _exit_tree() -> void:
	Engine.time_scale = 1
	AudioServer.playback_speed_scale = 1

func _process(delta: float) -> void:
	anchor.rotation = lerpf(anchor.rotation, to_angle, delta)


func _on_timer_mash_proof_timeout() -> void:
	can_restart = true


func _on_timer_main_menu_timeout() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
