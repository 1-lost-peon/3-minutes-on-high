extends Node2D
class_name Barricade

## Barricade in the world which is damageable.
## Enemies, Player and Projectiles can not pass through this obstacle.

## Maximum hp of the barricade.
@export var max_hp : float = 25.0

## Current hp of the barricade, defaults to the max_hp on ready.
@onready var hp : float = self.max_hp

func take_damage(amount : float) -> void:
	hp -= amount
	
	if hp <= 0.0:
		_show_breaking_visual_and_queue_free()
	else:
		_show_take_damage_visual()

# Show visual indicating barricade took damage.
func _show_take_damage_visual() -> void:
	pass

# Show the breaking barricade visual and then queue free this barricade.
# Dont forget to disable being a obstacle feature while showing breaking visual.
func _show_breaking_visual_and_queue_free() -> void:
	pass
