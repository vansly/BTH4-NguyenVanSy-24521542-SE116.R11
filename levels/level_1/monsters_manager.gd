extends Node3D
class_name MonstersManager

## Keeps the stage's door locked until every enemy in the stage is dead. The door is placed in the
## scene as locked, with an `unlock_flag`; killing the last enemy sets that flag.

@onready var door: Door = $"../Door"

var monster_list: Array = []


func _ready() -> void:
	monster_list = get_tree().get_nodes_in_group("enemy")
	EventBus.enemy_died.connect(_on_monster_killed)


func _on_monster_killed(enemy: EnemyCharacter) -> void:
	monster_list.erase(enemy)
	if monster_list.is_empty() and door != null:
		GameManager.unlock_door(door.unlock_flag)
