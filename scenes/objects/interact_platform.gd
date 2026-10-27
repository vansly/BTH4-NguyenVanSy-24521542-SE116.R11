extends Node3D

## A platform that rides its Path3D only while the fox stands on it AND holds `interact`. Let go,
## or step off, and it eases to a stop. It also eases into each end of the path, and waits there
## until the key is let go; the next ride goes the other way. Shape the route by editing the curve
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
## Set on arriving at an end: the fox has to let go of the key before the platform sets off again,
## otherwise a held key would send it straight back.
var _must_release := false


## Moves in _physics_process, not _process: the platform is an AnimatableBody3D, which only carries
## the fox correctly when it moves with the physics step.
func _physics_process(delta: float) -> void:
	var riding := _rider_wants_to_move()
	if _must_release:
		_must_release = riding
		riding = false
	var length := _path.curve.get_baked_length()
	var remaining := length - _follow.progress if _direction > 0.0 else _follow.progress
	# sqrt(2 * a * d) is the fastest speed from which it can still stop within d meters, so the
	# platform eases into the end of the path instead of hitting it at full speed.
	var wanted := minf(speed, sqrt(2.0 * acceleration * remaining)) if riding else 0.0
	_speed = move_toward(_speed, wanted, acceleration * delta)
	if _speed == 0.0:
		return
	var step := minf(_speed * delta, remaining)
	_follow.progress += _direction * step
	if remaining - step < 0.01:
		_follow.progress = length if _direction > 0.0 else 0.0
		_direction = -_direction    # reached an end: the next ride goes back
		_speed = 0.0
		_must_release = true


## Same rule as InteractiveArea3D: the key counts for a body that can interact right now (Player.can_interact(): alive, not talking).
func _rider_wants_to_move() -> bool:
	if not Input.is_action_pressed(interact_input_action):
		return false
	for body: Node3D in _rider_area.get_overlapping_bodies():
		if not body.has_method("can_interact") or body.can_interact():
			return true
	return false
