class_name Toast
extends Control

const TOAST_TIME: float = 2.0
const MESSAGE = preload("uid://if4w5k74d5nj")

@onready var right_anchor: Control = %RightAnchor
@onready var notif_player: AudioStreamPlayer2D = %NotifPlayer

var messages: Array[Control] = []
var elapsed: Array[float] = []

func _process(delta: float) -> void:
	var parent := get_parent()
	if parent is Node2D:
		rotation = -parent.rotation

	for i in range(elapsed.size() - 1, -1, -1):
		elapsed[i] += delta
		messages[i].modulate.a = 1 - clampf(elapsed[i] / TOAST_TIME, 0, 1)
		if elapsed[i] > TOAST_TIME:
			for message in messages.slice(0, i + 1):
				message.queue_free()
			messages = messages.slice(i + 1)
			elapsed = elapsed.slice(i + 1)
			break

func toast(text: String) -> void:
	var msg := MESSAGE.instantiate()
	msg.rotation = randf_range(-PI/10, PI/10)
	msg.text = text
	right_anchor.add_child(msg)

	messages.push_back(msg)
	elapsed.push_back(0)
	notif_player.play(0.62)
