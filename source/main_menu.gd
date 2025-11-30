extends Control

@onready var start_button: TextureButton = %StartButton
@onready var quit_button: TextureButton = %QuitButton

@onready var sfx_confirm: AudioStreamPlayer = %ConfirmSfx
@onready var sfx_back: AudioStreamPlayer = %BackSfx
@onready var sfx_hover: AudioStreamPlayer = %HoverSfx
@onready var music: AudioStreamPlayer = %ThemeMusic

@onready var volume_slider: HSlider = %VolumeSlider

func _ready():
	music.play()
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	start_button.mouse_entered.connect(_on_button_hovered)
	quit_button.mouse_entered.connect(_on_button_hovered)
	
	# Setup volume slider
	var master_bus := AudioServer.get_bus_index("Master")
	var current_db := AudioServer.get_bus_volume_db(master_bus)
	
	# Make sure slider matches current Master volume
	volume_slider.value = current_db
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_start_pressed():
	# Confirmation sound
	sfx_confirm.play()
	# tiny delay so you actually hear the click
	await get_tree().create_timer(0.1).timeout
	music.stop()  # optional, scene change will also kill it
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed():
	# Go-back sound
	sfx_back.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
	
func _on_button_hovered():
	sfx_hover.play()

func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, value)
