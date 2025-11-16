extends Node2D
class_name Door

## Door in the game world which can be strengthened with a barricade.

@export var is_barricaded : bool = false
@export var is_opened : bool = false
@export var barricade_scene : PackedScene = null

## Helper area to check if player is inside.
@onready var _player_detection_area_2d: Area2D = $PlayerDetectionArea2D

## Reference to the barricade if any exist at the moment.
var barricade : Node2D = null

func _physics_process(_delta: float) -> void:
	_handle_interaction_visual()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_player_close():
		return
	
	if event.is_action_pressed("interact"):
		if is_opened:
			close()
		else:
			open()
	
	if event.is_action_pressed("barricade"):
		if not is_barricaded:
			set_barricade()

## Sets up barricade forcefully, make sure to check status first.
func set_barricade() -> void:
	# Set up barricade here.
	is_barricaded = true
	barricade = barricade_scene.instantiate() as Barricade
	add_child(barricade)

## Closes the door.
func close() -> void:
	is_opened = false
	# Update visuals here.
	# Disable being a obstacle here.

## Opens the door forcefully.
## Make sure to check if door is barricaded first,
func open() -> void:
	# Update visuals here.
	# Enable being a obstacle here.
	pass

# Draws a outline via shader if player is close to this door,
# to indicate player can interact with it.
func _handle_interaction_visual() -> void:
	if _is_player_close():
		# draw outline here via shader.
		pass
	else:
		# dont draw outline.
		pass

# Helper function that checks if player is close.
# Used for listening interactions.
func _is_player_close() -> bool:
	for bodies in _player_detection_area_2d.get_overlapping_bodies():
		if bodies is Player:
			return true
		else:
			return false
	
	# Overlaps nothing
	return false
