extends Node3D

## A platform that rides its Path3D only while the fox stands on it AND holds `interact`. Let go,
## or step off, and it eases to a stop. Next time it heads the other way, so one ride goes from the
## start of the path to the end, and the next ride comes back. Shape the route by editing the curve
## of the Path3D child in the editor.

## Top speed along the path, in meters per second.
@export var speed := 3.0
## Meters per second squared: how quickly it speeds up and slows down.
@export var acceleration := 6.0
@export var interact_input_action := "interact"

@onready var _path: Path3D = $Path3D
@onready var _follow: PathFollow3D = $Path3D/PathFollow3D
## The zone just above the platform's top that detects the fox. It is a child of the platform, so it
## rides along.
@onready var _rider_area: Area3D = $Platform/RiderArea

var _direction := 1.0
var _speed := 0.0


## Moves in _physics_process, not _process: the platform is an AnimatableBody3D, which only carries
## the fox correctly when it moves with the physics step.
func _physics_process(delta: float) -> void:
	var wanted := speed if _rider_wants_to_move() else 0.0
	_speed = move_toward(_speed, wanted, acceleration * delta)
	if _speed == 0.0:
		return
	var length := _path.curve.get_baked_length()
	_follow.progress = clampf(_follow.progress + _direction * _speed * delta, 0.0, length)
	if (_direction > 0.0 and _follow.progress >= length) or (_direction < 0.0 and _follow.progress <= 0.0):
		_direction = -_direction    # reached an end: the next ride goes back
		_speed = 0.0


## Same rule as InteractiveArea3D: the key counts for a body that can interact right now (Player.can_interact(): alive, not talking).
func _rider_wants_to_move() -> bool:
	if not Input.is_action_pressed(interact_input_action):
		return false
	for body: Node3D in _rider_area.get_overlapping_bodies():
		if not body.has_method("can_interact") or body.can_interact():
			return true
	return false
