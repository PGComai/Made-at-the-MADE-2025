extends CharacterBody2D
class_name Car


enum PowerUp{BRAKE, JUMP, SHIELD, GHOST, AUTO}

const INITIAL_SPEED: float = 50.0
const MIN_GRIP: float = 0.05
const WHEEL_SPIN_SCALE: float = 0.05
const BRAKE_EFFECT: float = 0.99


@export var show_steer := true


var current_powerup: PowerUp
var wheel_angle: float = 0.0
var car_angle: float = 0.0
var grip: float = 1.0:
	set(value):
		grip = clampf(value, MIN_GRIP, 1.0)
var turn_grip: float = 1.0:
	set(value):
		turn_grip = clampf(value, 0.0, 1.0)
var drag: float = 0.995
var spin: float = 0.0
var spin_momentum: float = 1.0:
	set(value):
		spin_momentum = clampf(value, 1.0, 2.0)
var speed: float = INITIAL_SPEED
var wheels: Array[AnimatedSprite2D]
var smoke_timer: float = 0.0
var terrain_slip: float = 1.0
var terrain_damp: float = 1.0
var current_terrain: Terrain
var braking := false
## How many laps have been completed
var completed_laps := 0


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label_grip: Label = $LabelGrip
@onready var wheel_fl: AnimatedSprite2D = $WheelFL
@onready var wheel_fr: AnimatedSprite2D = $WheelFR
@onready var wheel_bl: AnimatedSprite2D = $WheelBL
@onready var wheel_br: AnimatedSprite2D = $WheelBR
@onready var smoke_left: GPUParticles2D = $SmokeLeft
@onready var smoke_right: GPUParticles2D = $SmokeRight
@onready var vehicle_player: VehiclePlayer = %VehiclePlayer
@onready var stuff_detector: Area2D = $StuffDetector
@onready var toast: Toast = %Toast


func _ready() -> void:
	wheels = [wheel_fl, wheel_fr, wheel_bl, wheel_br]
	for wheel in wheels:
		wheel.play()
		wheel.speed_scale = 0.0

func _physics_process(delta: float) -> void:
	var turn: float = Input.get_axis("left", "right")

	wheel_angle = lerp_angle(wheel_angle, turn * PI/4.0, 0.1)

	if show_steer:
		wheel_fl.rotation = lerp_angle(wheel_fl.rotation, wheel_angle, 0.1)
		wheel_fr.rotation = lerp_angle(wheel_fr.rotation, wheel_angle, 0.1)

	grip = remap(velocity.normalized().dot(-global_transform.y),
				-1.0,
				1.0,
				MIN_GRIP,
				1.0)
	grip = pow(grip, 6.0)
	var tire_smoke: bool = grip < 0.65
	smoke_left.emitting = tire_smoke
	smoke_right.emitting = tire_smoke
	label_grip.text = "GRIP: %s" % snappedf(grip, 0.01)

	var real_vel: Vector2 = get_real_velocity()
	var small_speed: float = clampf(real_vel.length(), 0.0, 1.0)

	var thrust_dir: Vector2 = -global_transform.y
	velocity += thrust_dir * speed * delta * grip
	var ideal_vel: Vector2 = -global_transform.y * velocity.length()

	velocity = velocity.slerp(ideal_vel, 0.08 * grip * terrain_slip)
	velocity *= drag * remap(grip, MIN_GRIP, 1.0, 0.995, 1.0) * terrain_damp
	if braking:
		velocity *= BRAKE_EFFECT

	var heading = velocity.rotated(wheel_angle * small_speed)

	var ang_diff: float = angle_difference(car_angle, heading.angle() + PI/2.0)

	spin_momentum += absf(ang_diff) * 0.8 * small_speed
	spin = lerp(spin, ang_diff, 0.02 * grip * terrain_slip)
	var steer_strength: float = pow(speed, 0.95) * (3.0 / INITIAL_SPEED)

	car_angle += spin * delta * steer_strength * spin_momentum * grip * terrain_slip
	rotation = car_angle
	label_grip.rotation = -rotation

	move_and_slide()

	spin_momentum *= 0.99

	for wheel in wheels:
		wheel.speed_scale = (real_vel.length() + randfn(0.0, 0.1)) * WHEEL_SPIN_SCALE

func _on_checkpoint_entered(_body: Node2D, count: int, total: int) -> void:
	toast.toast("Checkpoint %d/%d!" % [count, total])

func _on_lap_finished(_body: Node2D) -> void:
	completed_laps += 1
	vehicle_player.gear_shift(completed_laps)
	toast.toast("Lap %d!" % [completed_laps + 1])
	speed += 50.0 - clampf(float(completed_laps * 5), 5.0, 45.0)
	print("new accel: %s" % snappedf(speed, 1.0))
	current_powerup = PowerUp[PowerUp.keys().pick_random()]
	print(current_powerup)


func _on_stuff_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("terrain"):
		var terrain_area: Terrain = area
		current_terrain = terrain_area
		if current_terrain.terrain_type == "oil":
			terrain_slip = 0.4
			terrain_damp = 1.0
		elif current_terrain.terrain_type == "rough":
			terrain_slip = 0.9
			terrain_damp = 0.99
		elif current_terrain.terrain_type == "sand":
			terrain_slip = 0.9
			terrain_damp = 0.97
		elif current_terrain.terrain_type == "dirt":
			terrain_slip = 0.8
			terrain_damp = 0.995


func _on_stuff_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("terrain"):
		var terrain_area: Terrain = area
		if current_terrain == terrain_area:
			current_terrain = null
			terrain_slip = 1.0
			terrain_damp = 1.0
