extends Node2D

func _on_tutorial_timer_timeout() -> void:
	var label := $TutorialText
	var tween := create_tween()
	
	# make sure it starts fully visible
	label.modulate.a = 1.0
	
	# fade to invisible over 1 second
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
