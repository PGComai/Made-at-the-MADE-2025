class_name VehiclePlayer
extends Node2D

@onready var collision_player: AudioStreamPlayer2D = %CollisionPlayer
@onready var engine_player: AudioStreamPlayer2D = %EnginePlayer
@onready var honk_player: AudioStreamPlayer2D = %HonkPlayer
@onready var gear_player: AudioStreamPlayer2D = %GearPlayer

#region Node

var gear: int = 0

func _ready() -> void:
	engine_player.volume_linear = 0
	engine_player.play()

func _physics_process(delta: float) -> void:
	engine_player.volume_linear = \
		clampf(engine_player.volume_linear + delta, 0, 0.8)
	engine_player.pitch_scale = \
		clampf(engine_player.volume_linear + delta, 0.5, 1 + 0.2 * gear)

#endregion

#region Audio

## Plays the collision sound effect.
func collide() -> void:
	collision_player.play()

## Plays the gear shift sound effect. This is normally played automatically by
## the [VehiclePlayer] when the velocity changes.
func gear_shift(g: int) -> void:
	gear = g
	gear_player.play(0.22)
	engine_player.pitch_scale = 0.5
	engine_player.volume_linear = 0

## Plays the honk sound effect.
func honk() -> void:
	honk_player.play(0.54)

#endregion
