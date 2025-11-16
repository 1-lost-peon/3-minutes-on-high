extends Area2D

var direction = Vector2.ZERO
@export var speed :float = 300.0

@export var damage :int = 2 
func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
