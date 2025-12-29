class_name Main
extends Node

const POINT_TIME := 0.1

const GAME_OVER = preload("uid://cdmwdc4fob4s2")

@export var car: Car
@onready var time_label: Label = %TimeLabel
@onready var score_label: Label = %ScoreLabel
@onready var power_up_label: Label = %PowerUpLabel

## The current score.
var score: int = 0

## How long to wait before updating the score again in seconds.
var point_cooldown: float = POINT_TIME

## A list of all checkpoints in the level.
var all_checkpoints: Array[Checkpoint] = []

## The checkpoints visited by the player
var seen_checkpoints: Array[Checkpoint] = []

func _ready() -> void:
	car.i_died.connect(_on_car_died)
	car.power_up_get.connect(_on_car_power_up_get)
	car.power_up_used.connect(_on_car_power_up_used)

	for node in get_tree().get_nodes_in_group("checkpoint"):
		if node is not Checkpoint:
			print(node.get_path(), " is in the checkpoint group but is not a checkpoint!")
			continue

		var checkpoint: Checkpoint = node
		var callable := record_checkpoint.bind(checkpoint)
		if not checkpoint.car_entered.is_connected(callable):
			checkpoint.car_entered.connect(callable)

		all_checkpoints.push_back(checkpoint)

	for node in get_tree().get_nodes_in_group("finish_line"):
		if node is not FinishLine:
			print(node.get_path(), " is in the finish_line group but is not a finish line!")
			continue

		var finish_line: FinishLine = node
		if not finish_line.body_entered.is_connected(_on_finish_crossed):
			finish_line.body_entered.connect(_on_finish_crossed)

## Records a checkpoint for a body.
func record_checkpoint(body: Node2D, checkpoint: Checkpoint) -> void:
	if body != car:
		return
	if seen_checkpoints.has(checkpoint):
		return

	seen_checkpoints.push_back(checkpoint)
	car.toast.toast("%d/%d!" % [
		seen_checkpoints.size(),
		all_checkpoints.size(),
	])

func has_seen_all_checkpoints() -> bool:
	var to_see := all_checkpoints.duplicate()
	for seen_checkpoint in seen_checkpoints:
		to_see.erase(seen_checkpoint)
	return to_see.size() == 0

func _process(delta: float) -> void:
	time_label.text = "%.2f" % car.life

	var num = int(score_label.text)
	while num != score and point_cooldown >= 0:
		var diff = (score - num)
		num = num + ceili(diff / 2.0)
		score_label.text = str(num)
		point_cooldown -= POINT_TIME
	point_cooldown += delta

func _on_finish_crossed(body: Node2D) -> void:
	if body != car:
		return

	if has_seen_all_checkpoints():
		if not car.is_dead:
			score += floori(car.life * car.completed_laps)
			point_cooldown = 0
		car._on_lap_finished()
		seen_checkpoints.clear()

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
