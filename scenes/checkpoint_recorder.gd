## Keeps track of the checkpoints that have been entered by each body.
class_name CheckpointRecorder
extends Node

signal checkpoint_entered(body: Node2D, count: int, total: int)

## Emitted when a body has visited all checkpoints
signal seen_all_checkpoints(body: Node2D)

## A list of all checkpoints in the level.
var all_checkpoints: Array[Checkpoint] = []

## Each body and the checkpoints that it has seen.
var seen: Dictionary = {}

func _ready() -> void:
	all_checkpoints.clear()
	seen.clear()

	for node in get_tree().get_nodes_in_group("checkpoint"):
		if node is not Checkpoint:
			print(node.get_path(), " is in the checkpoint group but is not a checkpoint!")
			continue

		var checkpoint: Checkpoint = node
		var callable := record_checkpoint.bind(checkpoint)
		if not checkpoint.car_entered.is_connected(callable):
			checkpoint.car_entered.connect(callable)

		all_checkpoints.push_back(checkpoint)

## Resets the seen checkpoints for a specific body.
func reset_for(body: Node2D) -> bool:
	return seen.erase(body)

## Records a checkpoint for a body.
func record_checkpoint(body: Node2D, checkpoint: Checkpoint) -> void:
	if not seen.has(body):
		seen[body] = []
	if seen[body].has(checkpoint):
		return

	seen[body].push_back(checkpoint)
	checkpoint_entered.emit(body, seen[body].size(), all_checkpoints.size())
	if has_seen_all(body):
		seen_all_checkpoints.emit(body)

func has_seen_all(body: Node2D) -> bool:
	if not seen.has(body):
		return false

	var to_see := all_checkpoints.duplicate()
	for seen_checkpoint in seen[body]:
		to_see.erase(seen_checkpoint)
	return to_see.size() == 0
