extends CharacterBody2D
class_name Car


signal i_died
signal power_up_get(pup: PowerUp)
signal power_up_used


enum PowerUp{BRAKE, JUMP, PROJECTILE}

const INITIAL_SPEED: float = 50.0
const MIN_GRIP: float = 0.4
const WHEEL_SPIN_SCALE: float = 0.05
const BRAKE_EFFECT: float = 0.99
const LIFE_TIME: float = 10.0
const JUMP_GRIP: float = 3.0
const SMOKE_THRESH_DEFAULT: float = 0.65
const SMOKE_THRESH_DIRT: float = 0.85
const SMOKE_THRESH_OIL: float = 0.0
const SMOKE_THRESH_SAND: float = 1.0


@export var show_steer := true
@export var jump_sprite_curve: Curve
@export var projectile_scene: PackedScene

var smoke_threshold: float = SMOKE_THRESH_DEFAULT
var current_powerup: PowerUp
var powerup_resources = {
	PowerUp.BRAKE : "brake",
	PowerUp.JUMP : "jump",
	PowerUp.PROJECTILE : "projectile"
}
var current_powerup_resource: PowerupData
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
var acceleration: float
var wheels: Array[AnimatedSprite2D]
var smoke_timer: float = 0.0
var terrain_slip: float = 1.0
var terrain_damp: float = 1.0
var current_terrain: Terrain
var braking := false
var jumping := false
var on_track := true
var used_powerup := false
var can_use_powerup := false
var life: float = LIFE_TIME
var is_dead: bool:
	get:
		return life <= 0
var has_started_race := false
var jump_grip_boost: float = 1.0:
	set(value):
		jump_grip_boost = clampf(value, 1.0, JUMP_GRIP)
var smoke_target_color := Color.WHITE
var skid_frame: int = 5:
	set(value):
		skid_frame = wrapi(value, 0, 6)
var smoking := false:
	set(value):
		if smoking != value:
			smoking = value
			if smoking:
				print("smoking")
				var new_skid_left := TireMark.new()
				var new_skid_right := TireMark.new()

				add_child(new_skid_left)
				add_child(new_skid_right)

				current_skid_left = new_skid_left
				current_skid_right = new_skid_right

				current_skid_left.points = []
				current_skid_right.points = []

				add_skid_points()
			else:
				add_skid_points()

#drift variables
var drifting := false
var drifting_left := false
var drifting_right := false
var double_tap_frames_left := 0
var double_tap_frames_right := 0

#stats
var turn_handling: float = 1.0
var turn_lerp_amount: float = 0.1
var grip_stat: float = 0.0
var grip_turn_adjustment: float = 0.0
var drift_power: float = 1.5

var current_skid_left: TireMark
var current_skid_right: TireMark
var queue_track_check := false

@onready var camera = %ChaseCam
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label_grip: Label = $LabelGrip
@onready var wheel_fl: AnimatedSprite2D = $Sprite2D/WheelFL
@onready var wheel_fr: AnimatedSprite2D = $Sprite2D/WheelFR
@onready var wheel_bl: AnimatedSprite2D = $Sprite2D/WheelBL
@onready var wheel_br: AnimatedSprite2D = $Sprite2D/WheelBR
@onready var smoke_left: GPUParticles2D = $SmokeLeft
@onready var smoke_right: GPUParticles2D = $SmokeRight
@onready var vehicle_player: VehiclePlayer = %VehiclePlayer
@onready var stuff_detector: Area2D = $StuffDetector
@onready var toast: Toast = %Toast
@onready var timer_power_up: Timer = $TimerPowerUp
@onready var sprite_2d_shadow: Sprite2D = $Sprite2DShadow
@onready var ui_node = get_node("/root/Racetrack/Main/CanvasLayer/UI")

func _ready() -> void:
	power_up_get.connect(_on_power_up_get)
	
	wheels = [wheel_fl, wheel_fr, wheel_bl, wheel_br]
	for wheel in wheels:
		wheel.play()
		wheel.speed_scale = 0.0
	smoke_left.emitting = false
	smoke_right.emitting = false

func get_random_powerup():
	current_powerup = PowerUp[PowerUp.keys().pick_random()]
	power_up_get.emit(current_powerup)
	
func _process(delta: float) -> void:
	#check for drift inputs if we aren't drifting
	if(!drifting):
		#check double-tap left
		if(double_tap_frames_left > 0):
			double_tap_frames_left -= 1
		if(Input.is_action_just_pressed("left")):
			if(double_tap_frames_left == 0):
				double_tap_frames_left = 16
			else:
				drifting = true
				drifting_left = true
				jump(.3,"drift!")
				double_tap_frames_left = 0
		#check double-tap right
		if(double_tap_frames_right > 0):
			double_tap_frames_right -= 1
		if(Input.is_action_just_pressed("right")):
			if(double_tap_frames_right == 0):
				double_tap_frames_right = 16
			else:
				drifting = true
				drifting_right = true
				jump(.3,"drift!")
				double_tap_frames_right = 0
	else:
		#drifting
		if(drifting_left and Input.is_action_just_released("left")):
			drifting = false
			drifting_left = false
		elif(drifting_right and Input.is_action_just_released("right")):
			drifting = false
			drifting_right = false
			
func _physics_process(delta: float) -> void:
	# Don't process any input if we are dead or haven't started yet
	if is_dead or !has_started_race:
		velocity = velocity.slerp(Vector2.ZERO, 0.1 * delta)
		move_and_slide()
		return
		
	if not used_powerup and can_use_powerup:
		if current_powerup_resource.ammo_type == "press":
			if Input.is_action_just_pressed("a"):
				timer_power_up.start()
				power_up_used.emit()
				if current_powerup == PowerUp.JUMP:
					jumping = true
					set_collision_mask_value(9,false)
					jump_grip_boost = JUMP_GRIP
					stuff_detector.monitoring = false
				elif current_powerup == PowerUp.PROJECTILE:
					shoot_projectile()
				current_powerup_resource.current_ammo -= 1
				if current_powerup_resource.current_ammo == 0:
					used_powerup = true
				ui_node.update_power_up(current_powerup_resource)
		elif current_powerup_resource.ammo_type == "hold":
			if Input.is_action_pressed("a"):
				current_powerup_resource.current_ammo -= 1
				ui_node.update_power_up(current_powerup_resource)
			if Input.is_action_just_pressed("a"):
				toast.toast(current_powerup_resource.name)
				if current_powerup == PowerUp.BRAKE:
					braking = true
			if Input.is_action_just_released("a") or current_powerup_resource.current_ammo == 0:
				if current_powerup == PowerUp.BRAKE:
					braking = false
					
	if not (on_track or jumping):
		life -= delta
		if is_dead:
			i_died.emit()

	if jumping:
		var jump_height: float = jump_sprite_curve.sample_baked(
												remap(
												-timer_power_up.time_left,
												-timer_power_up.wait_time,
												0.0,
												0.0,
												1.0)
												) * 20.0
		sprite_2d.global_position.y = global_position.y - jump_height
		sprite_2d.global_position.x = global_position.x
		var shadow_scale: float = remap(-jump_height,
										-20.0,
										0.0,
										0.5,
										1.0)
		sprite_2d_shadow.scale = Vector2(shadow_scale, shadow_scale)

	var turn: float = Input.get_axis("left", "right")
	
	wheel_angle = lerp_angle(wheel_angle, turn * PI/4.0, turn_lerp_amount)

	if show_steer:
		wheel_fl.rotation = lerp_angle(wheel_fl.rotation, wheel_angle, 0.1)
		wheel_fr.rotation = lerp_angle(wheel_fr.rotation, wheel_angle, 0.1)

	
	grip = remap(velocity.normalized().dot(-global_transform.y),
				grip_turn_adjustment,
				1.0,
				0.0,
				1.0)
	#print("grip - ", grip)
	grip = pow(grip, grip_stat)#pow(grip, 6.0)
	#print("grip adjusted - ", grip)
	var real_vel: Vector2 = get_real_velocity()
	var eh_smoke: bool = (grip <= smoke_threshold or braking) and not jumping and real_vel.length_squared() > 1.0
	smoke_left.emitting = eh_smoke
	smoke_right.emitting = eh_smoke
	label_grip.text = "GRIP: %s" % snappedf(grip, 0.01)

	var small_speed: float = clampf(real_vel.length(), 0.0, 1.0)

	var thrust_dir: Vector2 = -global_transform.y
	velocity += thrust_dir * speed * delta * grip * acceleration
	var ideal_vel: Vector2 = -global_transform.y * velocity.length()

	if not jumping:
		velocity = velocity.slerp(ideal_vel, minf(0.3, 0.08 * grip * terrain_slip * jump_grip_boost))
		velocity *= drag * remap(grip, MIN_GRIP, 1.0, 0.995, 1.0) * terrain_damp
	if braking:
		velocity *= BRAKE_EFFECT

	smoking = eh_smoke and not current_terrain

	if smoking:
		skid_frame -= 1
		if skid_frame == 0:
			#print("add skid point")
			add_skid_points()

	var heading = velocity.rotated(wheel_angle * small_speed)

	var ang_diff: float = angle_difference(car_angle, heading.angle() + PI/2.0)

	spin_momentum += absf(ang_diff) * 0.8 * small_speed
	if not jumping:
		jump_grip_boost -= delta * 10.0
		spin = lerp(spin, ang_diff, 0.02 * grip * terrain_slip)
	else:
		spin = lerp(spin, turn * 0.4, 0.2)
	var steer_strength: float = pow(speed, 0.95) * (3.0 / INITIAL_SPEED) * turn_handling
	if(drifting):
		steer_strength *= (drift_power / turn_handling)
	car_angle += spin * delta * steer_strength * spin_momentum * grip * terrain_slip
	rotation = car_angle
	label_grip.rotation = -rotation

	move_and_slide()

	spin_momentum *= 0.99

	for wheel in wheels:
		wheel.speed_scale = (real_vel.length() + randfn(0.0, 0.1)) * WHEEL_SPIN_SCALE

	var current_smoke_color: Color = smoke_left.modulate
	set_smoke_color(current_smoke_color.lerp(smoke_target_color, 0.03))

func add_skid_points() -> void:
	var temp_skid_left := current_skid_left.points
	var temp_skid_right := current_skid_right.points

	temp_skid_left.append(wheel_bl.global_position)
	temp_skid_right.append(wheel_br.global_position)

	current_skid_left.points = temp_skid_left
	current_skid_right.points = temp_skid_right

func set_smoke_color(clr: Color) -> void:
	smoke_left.modulate = clr
	smoke_right.modulate = clr

func _on_checkpoint_entered(_body: Node2D, count: int, total: int) -> void:
	toast.toast("Checkpoint %d/%d!" % [count, total])

func _on_lap_finished(completed_laps: int) -> void:
	completed_laps += 1
	vehicle_player.gear_shift(completed_laps)
	speed += 50.0 - clampf(float(completed_laps * 5), 5.0, 45.0)
	print("new accel: %s" % snappedf(speed, 1.0))
	current_powerup = PowerUp[PowerUp.keys().pick_random()]
	power_up_get.emit(current_powerup)
	used_powerup = false
	timer_power_up.wait_time = clampf(remap(-speed, -300.0, -50.0, 0.2, 1.0), 0.2, 1.0)
	print(current_powerup)
	toast.toast("PowerUp! %s" % PowerUp.keys()[current_powerup])

func _on_stuff_detector_area_entered(area: Area2D) -> void:
	_on_node_2d_entered(area)

func _on_stuff_detector_area_exited(area: Area2D) -> void:
	_on_node_2d_exited(area)

func _on_stuff_detector_body_entered(body: Node2D) -> void:
	_on_node_2d_entered(body)

func _on_stuff_detector_body_exited(body: Node2D) -> void:
	_on_node_2d_exited(body)

func _on_node_2d_entered(node_2d: Node2D) -> void:
	if node_2d.is_in_group("terrain"):
		var terrain_area: Terrain = node_2d
		current_terrain = terrain_area
		if current_terrain.terrain_type == "oil":
			terrain_slip = 0.4
			terrain_damp = 1.0
			smoke_threshold = SMOKE_THRESH_OIL
			smoke_target_color = Color.WHITE
		elif current_terrain.terrain_type == "rough":
			terrain_slip = 0.9
			terrain_damp = 0.99
			smoke_threshold = SMOKE_THRESH_DEFAULT
			smoke_target_color = Color.WHITE
		elif current_terrain.terrain_type == "sand":
			terrain_slip = 0.9
			terrain_damp = 0.97
			smoke_threshold = SMOKE_THRESH_SAND
			smoke_target_color = Color.TAN
		elif current_terrain.terrain_type == "dirt":
			terrain_slip = 0.8
			terrain_damp = 0.995
			smoke_threshold = SMOKE_THRESH_DIRT
			smoke_target_color = Color.SADDLE_BROWN
	elif node_2d.is_in_group("track"):
		on_track = true

func _on_node_2d_exited(node_2d: Node2D) -> void:
	if node_2d.is_in_group("terrain"):
		var terrain_area: Terrain = node_2d
		if current_terrain == terrain_area:
			current_terrain = null
			terrain_slip = 1.0
			terrain_damp = 1.0
			smoke_threshold = SMOKE_THRESH_DEFAULT
			smoke_target_color = Color.WHITE
	elif node_2d.is_in_group("track"):
		if not jumping:
			on_track = false
			toast.toast("Off track!")
		else:
			queue_track_check = true

func _on_power_up_get(pup: Car.PowerUp) -> void:
	can_use_powerup = true
	current_powerup_resource = load("res://CustomResources/Powerups/%s.tres" % powerup_resources[pup])
	current_powerup_resource.current_ammo = current_powerup_resource.max_ammo
	ui_node.update_power_up(current_powerup_resource)
	
func _on_timer_power_up_timeout() -> void:
	stuff_detector.monitoring = true
	braking = false
	if jumping and queue_track_check:
		var stuff_overlapping := stuff_detector.get_overlapping_bodies()
		var landed_on_track := false
		for so: Node2D in stuff_overlapping:
			if so.is_in_group("track"):
				landed_on_track = true
		if not landed_on_track:
			print("bug fixed")
			on_track = false
			toast.toast("Off track!")
	jumping = false
	set_collision_mask_value(9,true)
	sprite_2d.position.y = 0.0
	sprite_2d.position.x = 0.0
	sprite_2d_shadow.scale = Vector2.ONE

func jump(jump_time, toast_msg = "jump!"):
	timer_power_up.start(jump_time)
	jumping = true
	jump_grip_boost = JUMP_GRIP
	toast.toast(toast_msg)
	stuff_detector.monitoring = false

func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	projectile.direction = Vector2.from_angle(car_angle - PI/2)
	camera.shake(.3,80,2, projectile.direction)
	projectile.speed = 400.0
	get_parent().add_child(projectile)
	projectile.global_position = $ProjectileSpawn.global_position
