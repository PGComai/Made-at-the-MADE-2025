extends Camera2D

@export var car: Car

var target_zoom: float = 2.0


var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _shake_direction = Vector2.ZERO
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)
var tween
var current_zoom
var anim_player
var base_position

func _process(delta: float) -> void:
	if car:
		if car.is_dead:
			target_zoom = lerpf(target_zoom, 8.0, delta * 0.5)
		else:
			target_zoom = lerp(target_zoom,
							remap(-car.speed, -250.0, -car.INITIAL_SPEED, 1.0, 2.0),
							delta)
			target_zoom = clampf(target_zoom, 1.0, 2.0)

		global_position = car.global_position
		zoom = Vector2(target_zoom, target_zoom)

	# Only shake when there's shake time remaining.
	if _timer == 0:
		set_offset(Vector2())
		#set_process(false)
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = randf_range(-1.0, 1.0)
		new_x += _shake_direction.x * 4.0
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		
		var new_y = randf_range(-1.0, 1.0)
		new_y += _shake_direction.y * 4.0
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)
		
# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude, direction = Vector2.ZERO):
	# Don't interrupt current shake duration
	if(_timer != 0):
		return
	print("shake direction: ", direction)
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_shake_direction = direction
	_previous_x = randf_range(-1.0, 1.0)
	_previous_y = randf_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)
	set_process(true)
