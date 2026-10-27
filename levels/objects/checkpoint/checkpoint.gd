extends Area3D

## This checkpoint's name — unique within its stage. The save file stores
## this, not coordinates.
@export var id := ""

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	add_to_group("spawn_points")
	body_entered.connect(_on_body_entered)
	_sprite.play("turn" if _is_current() else "idle")

func _on_body_entered(body: Node3D) -> void:
	if not (body is Player) or _is_current():
		return
	if not (owner is Stage):
		push_warning("Checkpoint '%s' is not placed directly in a Stage — ignored" % id)
		return
	GameManager.set_checkpoint(owner.scene_file_path, id)
	_sprite.play("turn")

## `owner` is the root of the scene this checkpoint was saved in — the
## stage.
func _is_current() -> bool:
	return owner is Stage and GameManager.checkpoint_id == id \
			and GameManager.checkpoint_stage == owner.scene_file_path