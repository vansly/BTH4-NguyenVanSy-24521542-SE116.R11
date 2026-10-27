extends AnimatableBody3D

@export var offset := Vector3(0, 4, 0)
## Meters per second.
@export var max_speed := 2.0
@export var acceleration: float = 2.0

var _speed: float = 0.0
## Seconds to wait at each end.
@export var wait_time := 1.0

var _start: Vector3
var _going_out := true
var _wait := 0.0

func _ready() -> void:
	_start = position

func _physics_process(delta: float) -> void:
	if _wait > 0.0:
		_wait -= delta
		return
	if not is_moving():
		return
	
	var target := _start + offset if _going_out else _start
	var distance := position.distance_to(target)
	var wanted := minf(max_speed, sqrt(2.0 * acceleration * distance))

	_speed = move_toward(_speed, wanted, acceleration * delta)
	print(_speed)
	position = position.move_toward(target, _speed * delta)


	if distance < 0.01:
		position = target
		_going_out = not _going_out
		_wait = wait_time
		_speed = 0.0
		
func is_moving () ->bool:
	return false