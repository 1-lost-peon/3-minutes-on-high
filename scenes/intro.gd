extends Control

@onready var sfx_confirm: AudioStreamPlayer = %ConfirmSfx

signal start_game

func _unhandled_input(event: InputEvent) -> void:
	if !visible:
		return

	if event.is_action_pressed("interact"):
		sfx_confirm.play()
		hide()
		start_game.emit()
