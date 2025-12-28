class_name VehiclePlayer
extends Node3D

## The velocity of the car.
@export var velocity: Vector2:
	set(value):
		if velocity != value:
			velocity = value

			var speed_squared := velocity.length_squared()
			if is_zero_approx(speed_squared):
				gear = 0
			elif speed_squared < 10:
				gear = 1
			elif speed_squared < 20:
				gear = 2
			elif speed_squared < 30:
				gear = 3
			else:
				gear = 4

## The gear that the car is in. Gear 0 is used when the car is not moving.
var gear: int = 0:
	set(value):
		if gear != value:
			gear = value
			gear_shift()

@onready var collision_player: AudioStreamPlayer3D = %CollisionPlayer
@onready var engine_player: AudioStreamPlayer3D = %EnginePlayer
@onready var honk_player: AudioStreamPlayer3D = %HonkPlayer
@onready var gear_player: AudioStreamPlayer3D = %GearPlayer

#region Node

func _ready() -> void:
	engine_player.volume_linear = 0
	engine_player.play()

func _physics_process(delta: float) -> void:
	if gear == 0:
		engine_player.volume_linear = \
			clampf(engine_player.volume_linear - delta * 2, 0, 1)
	else:
		engine_player.volume_linear = \
			clampf(engine_player.volume_linear + delta * 2, 0, 1)

#endregion

#region Audio

## Plays the collision sound effect.
func collide() -> void:
	collision_player.play()

## Plays the gear shift sound effect. This is normally played automatically by
## the [VehiclePlayer] when the velocity changes.
func gear_shift() -> void:
	gear_player.play()
	engine_player.volume_linear = 0

## Plays the honk sound effect.
func honk() -> void:
	honk_player.play()

#endregion
