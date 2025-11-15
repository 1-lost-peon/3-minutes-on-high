extends Control


func _ready():
	%StartButton.pressed.connect(start)
	%QuitButton.pressed.connect(quit)

func start():
	get_tree().change_scene_to_file("res://game.tscn")

func quit():
	get_tree().quit()
