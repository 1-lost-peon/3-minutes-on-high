extends Control

var pause := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause = !pause
		get_tree().paused = pause
