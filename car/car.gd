extends CharacterBody2D
class_name Car


const INITIAL_SPEED: float = 50.0


var wheel_angle: float = 0.0
var car_angle: float = 0.0
var grip: float = 1.0:
	set(value):
		grip = clampf(value, 0.0, 1.0)
var turn_grip: float = 1.0:
	set(value):
		turn_grip = clampf(value, 0.0, 1.0)
var drag: float = 0.995
var spin: float = 0.0
var spin_momentum: float = 1.0:
	set(value):
		spin_momentum = clampf(value, 1.0, 2.0)


@onready var sprite_2d: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	var turn: float = Input.get_axis("left", "right")
	
	wheel_angle = lerp_angle(wheel_angle, turn * PI/4.0, 0.1)
	
	grip = remap(velocity.normalized().dot(-global_transform.y), -1.0, 1.0, 0.1, 1.0)
	
	var real_vel: Vector2 = get_real_velocity()
	var small_speed: float = clampf(real_vel.length(), 0.0, 1.0)
	
	var thrust_dir: Vector2 = -global_transform.y
	
	velocity += thrust_dir * INITIAL_SPEED * delta * grip
	
	var ideal_vel: Vector2 = -global_transform.y * velocity.length()
	velocity = velocity.slerp(ideal_vel, 0.02 * grip)
	
	velocity *= drag
	
	var heading = velocity.rotated(wheel_angle * small_speed * turn_grip)
	
	var ang_diff: float = angle_difference(car_angle, heading.angle() + PI/2.0)
	spin_momentum += absf(ang_diff) * 0.2 * small_speed
	
	spin = lerp(spin, ang_diff, 0.02 * grip)
	
	car_angle += spin * delta * 10.0 * spin_momentum
	
	rotation = car_angle
	
	move_and_slide()
	
	spin_momentum *= 0.95
	
	#queue_redraw()


#func _draw() -> void:
	#var thrust_dir: Vector2 = -global_transform.y
	#draw_line(Vector2.ZERO, (thrust_dir * 100.0), Color.RED)


func _on_checkpoint_recorder_seen_all_checkpoints(body: Node2D) -> void:
	print("lap!")
