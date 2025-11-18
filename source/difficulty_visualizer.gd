extends CanvasLayer
class_name DifficultyVisualizer

## CanvasLayer that visualizes games current difficulty level and crime progress.
##
## Listens DifficultyTracker singletons signals.


## Easy diff texture.
@export var easy_difficulty_texture : Texture2D = null
## Normal diff texture.
@export var normal_difficulty_texture : Texture2D = null
## Hard diff texture.
@export var hard_difficulty_texture : Texture2D = null
## Insane diff texture.
@export var insane_difficulty_texture : Texture2D = null
## Lethal diff texture.
@export var lethal_difficulty_texture : Texture2D = null

func _ready() -> void:
	DifficultyTracker.crime_committed.connect(_on_crime_committed)
	DifficultyTracker.difficulty_increased.connect(_on_difficulty_increased)
	DifficultyTracker.difficulty_reset.connect(_on_difficulty_reset)

func _on_crime_committed() -> void:
	pass

func _on_difficulty_increased() -> void:
	pass

func _on_difficulty_reset() -> void:
	pass
