extends Area2D
class_name PlayerDetectionArea2D

## Helper node that signals player entered or exited the area.
##
## Usefull for detecting if player is close so it can interact with parent object.
## Example: Opening door.

signal player_entered(player : Player)
signal player_exited(player : Player)

## Check if player is inside this area.
func is_player_inside() -> bool:
	var player_ref := get_tree().get_first_node_in_group("player")
	
	if player_ref:
		return overlaps_body(player_ref)
	else:
		return false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_exited.emit(body)
