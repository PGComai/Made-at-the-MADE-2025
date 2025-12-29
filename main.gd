extends Node

const POINT_TIME := 0.1

var score: int = 0
var point_cooldown: float = POINT_TIME

const GAME_OVER = preload("uid://cdmwdc4fob4s2")

@export var car: Car
@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var power_up_label: Label = %PowerUpLabel

func _ready() -> void:
	car.completed_lap.connect(_on_completed_lap)
	car.died.connect(_on_car_died)
	car.power_up_get.connect(_on_car_power_up_get)
	car.power_up_used.connect(_on_car_power_up_used)

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

func _on_car_died() -> void:
	var new_game_over: GameOver = GAME_OVER.instantiate()
	new_game_over.score = score
	add_child(new_game_over)

func _on_car_power_up_get(pup: Car.PowerUp) -> void:
	if not power_up_label:
		await ready
	power_up_label.text = "Power Up: %s" % Car.PowerUp.keys()[pup]

func _on_car_power_up_used() -> void:
	power_up_label.text = "Power Up: None"
