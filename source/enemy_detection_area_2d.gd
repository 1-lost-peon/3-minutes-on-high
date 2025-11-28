extends Area2D
class_name EnemyDetectionArea2D

## Helper node that signals enemy entered or exited the area.
##
## Usefull for detecting if enemy is close so it can interact with parent object.
## Example: Opening door.

signal enemy_entered(enemy : Enemy)
signal enemy_exited(enemy : Enemy)

## Check if enemy is inside this area.
func is_enemy_inside() -> bool:
	var enemy_ref := get_tree().get_first_node_in_group("enemy")
	
	if enemy_ref:
		return overlaps_body(enemy_ref)
	else:
		return false


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is Enemy:
		enemy_entered.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Enemy:
		enemy_exited.emit(body)
