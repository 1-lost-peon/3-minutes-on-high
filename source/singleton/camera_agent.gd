extends Node
class_name _CameraAgent

## Singleton to shake the camera.
##
## Usage: [br]
## CameraAgent.add_trauma(amount : float). [br]
## amount must be within range 0.0 - 1.0.

# How quickly shaking will stop [0,1].
var _decay := 0.8

# Maximum displacement in pixels.
var _max_offset := Vector2(25,25)

# Maximum rotation in radians (use with caution lol).
var _max_roll = 0.0

# Current shake strength
var _trauma := 0.0

# Trauma exponent. Use [2,3]
var _trauma_power := 3

func _process(delta):
	
	var target := _get_active_camera() as Camera2D
	
	if(target == null):
		return
	
	if (_trauma > 0.0):
		_trauma = max(_trauma - _decay * delta, 0)
		_shake_camera(target)


## Add trauma to the camera. Amount beyond 1.0 doesnt have any effect, use [1-0 range]
func add_trauma(amount : float) -> void:
	_trauma = min(_trauma + amount, 1.0)

# Returns null if no camera is active.
func _get_active_camera() -> Camera2D:

	return get_viewport().get_camera_2d()

# Helper function that shakes the camera on process.
func _shake_camera(camera : Camera2D) -> void:
	var amount = pow(_trauma, _trauma_power)

	camera.rotation = _max_roll * amount * randf_range(-1.0, 1.0)
	camera.offset.x = _max_offset.x * amount * randf_range(-1.0, 1.0)
	camera.offset.y = _max_offset.y * amount * randf_range(-1.0, 1.0)
