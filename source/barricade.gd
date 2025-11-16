@icon("uid://c6q33js31kocx")
extends StaticBody2D
class_name Barricade

## Barricade in the world which is damage-able.
## Enemies, Player and Projectiles can not pass through this obstacle.

## Emitted when barricade is taken down.
signal barricade_down()

## Maximum hp of the barricade.
@export var max_hp : float = 25.0
## Duration of the damage animation in seconds.
@export var damage_anim_duration_secs : float = 0.2
## Scale factor for the damage animation.
@export var damage_anim_scale : Vector2 = Vector2(1.2, 1.2)

## Current hp of the barricade, defaults to the max_hp on ready.
@onready var hp : float = self.max_hp
## Sprite of the barricade.
@onready var sprite_2d: Sprite2D = $Sprite2D
# Default sprite scale to animate back to normal sprite when took damage.
@onready var _default_sprite_scale := self.sprite_2d.scale


# Tween used to show damage animation.
var _damage_tween : Tween = null

func take_damage(amount : float) -> void:
	hp -= amount
	
	if hp <= 0.0:
		_show_breaking_visual_and_queue_free()
	else:
		_show_take_damage_visual()

# Show visual indicating barricade took damage.
func _show_take_damage_visual() -> void:
	if _damage_tween:
		_damage_tween.kill()
	
	_damage_tween = create_tween()
	
	# Scale a bit and make sprite red.
	_damage_tween.tween_property(sprite_2d, "self_modulate", Color.RED, damage_anim_duration_secs * 0.66)
	_damage_tween.parallel().tween_property(sprite_2d, "scale",
		_default_sprite_scale * damage_anim_scale, damage_anim_duration_secs * 0.66)
	
	# Scale down and make sprite normal color.
	_damage_tween.tween_property(sprite_2d, "self_modulate", Color.WHITE, damage_anim_duration_secs * 0.33)
	_damage_tween.parallel().tween_property(sprite_2d, "scale", _default_sprite_scale, damage_anim_duration_secs * 0.33)
	

# Show the breaking barricade visual and then queue free this barricade.
# Dont forget to disable being a obstacle feature while showing breaking visual.
func _show_breaking_visual_and_queue_free() -> void:
	# Show breaking visual here.
	
	barricade_down.emit()
	
	queue_free()
