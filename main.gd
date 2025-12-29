extends Node

const POINT_TIME := 0.1

var score: int = 0
var point_cooldown: float = POINT_TIME

const GAME_OVER = preload("uid://cdmwdc4fob4s2")

@export var car: Car
@onready var time_label: Label = %LabelTimeLeft
@onready var score_label: Label = %Score
@onready var label_power_up: Label = %LabelPowerUp

func _ready() -> void:
	car.completed_lap.connect(_on_completed_lap)

func _process(delta: float) -> void:
	time_label.text = "%.2f" % car.life

	var num = int(score_label.text)
	while num != score and point_cooldown >= 0:
		var diff = (score - num)
		num = num + ceili(diff / 2.0)
		score_label.text = str(num)
		point_cooldown -= POINT_TIME
	point_cooldown += delta

func _on_completed_lap(c: Car) -> void:
	if not c.is_dead:
		score += floori(c.life * c.completed_laps)
		point_cooldown = 0

func game_over() -> void:
	var new_game_over: GameOver = GAME_OVER.instantiate()
	new_game_over.score = score
	add_child(new_game_over)

func _on_car_power_up_get(pup: Car.PowerUp) -> void:
	if not label_power_up:
		await ready
	label_power_up.text = "Power Up: %s" % Car.PowerUp.keys()[pup]

func _on_car_power_up_used() -> void:
	label_power_up.text = "Power Up: None"
