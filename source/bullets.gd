extends Area2D

var direction = Vector2.ZERO
@export var speed :float = 300.0
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var damage :int = 1 

func _on_ready():
	animated_sprite_2d.play("default")

func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed


func _on_body_entered(body: Node2D) -> void:
	animated_sprite_2d.play("hit")
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
