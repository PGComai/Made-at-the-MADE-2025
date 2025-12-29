extends Control


const GAME_OVER = preload("uid://cdmwdc4fob4s2")


@export var car: Car
@onready var label_time_left: Label = $LabelTimeLeft
@onready var label_power_up: Label = $LabelPowerUp

func _process(_delta: float) -> void:
	label_time_left.text = "%.2f" % car.life

func game_over() -> void:
	var new_game_over = GAME_OVER.instantiate()
	add_child(new_game_over)


func _on_car_power_up_get(pup: Car.PowerUp) -> void:
	if not label_power_up:
		await ready
	label_power_up.text = "Power Up: %s" % Car.PowerUp.keys()[pup]


func _on_car_power_up_used() -> void:
	label_power_up.text = "Power Up: None"
