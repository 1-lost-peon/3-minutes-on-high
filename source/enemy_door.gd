@tool
@icon("uid://dv83ksu0bnc8c")
extends StaticBody2D
class_name EnemyDoor

## Door in the game world which can be strengthened with a barricade.

## Emitted when door is opened.
signal opened()
## Emitted when door is closed.
signal closed()
## Emitted when door is barricaded.
signal barricaded()
## Emitted when barricade is down.
signal barricade_down()

## Do not set this property in game. Use set_barricade(). Only use this to check.
@export var is_barricaded : bool = false:
	set(value):
		if Engine.is_editor_hint() and is_node_ready():
			if value:
				set_barricade()
			else:
				remove_barricade()
		
		is_barricaded = value
	get:
		return is_barricaded

## Do not set this property in game. Use open() and close(). Only use this to check.
@export var is_opened : bool = false:
	set(value):
		if Engine.is_editor_hint() and is_node_ready():
			if value:
				open()
			else:
				close()
		
		is_opened = value
	get:
		return is_opened

@export var barricade_scene : PackedScene = null
## Point cost to set up barricade on this door.
@export var barricade_cost : int = 5.0
@export var closed_texture : Texture2D = null
@export var open_texture : Texture2D = null
## Used for drawing outline to indicate player can interact with this.
@export var outline_material : ShaderMaterial = null
## Used for scaling sprite a bit when player comes close, indicating it can interact.
@export var interaction_scale_factor : float = 1.1
## Interaction animation duration in seconds.
@export var interaction_duration_secs : float = 0.1

@onready var _enemy_detection_area_2d: Area2D = $EnemyDetectionArea2D

## Sprite of the door.
@onready var sprite_2d: Sprite2D = $Sprite2D
## Collision shape of the static body.
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

## Sprites default scale value, used for scaling down when player goes far away.
@onready var _default_sprite_scale := self.sprite_2d.scale

## Reference to the barricade if any exist at the moment.
var barricade : Node2D = null

# Reference to the tween we use to animate interactions. (player coming close)
var _interaction_tween : Tween = null

# Interaction GUI
var hold_time := 1.5
var hold_progress := 0.0
var holding := false

func _process(delta):
	if holding:
		hold_progress += delta * 2.5
		$InteractionText/VBoxContainer/ProgressBar.value = (hold_progress / hold_time) * 100

	if hold_progress >= hold_time:
		if not is_barricaded:
			open()
		holding = false
		hold_progress = 0.0
		$InteractionText/VBoxContainer/ProgressBar.value

func _unhandled_input(event: InputEvent) -> void:
	if not _enemy_detection_area_2d.is_enemy_inside():
		return
	
	#if event.is_action_pressed("interact"):
		#if not is_barricaded:
			#if is_opened:
				#close()
			#else:
				#open()
	
	if event.is_action_pressed("barricade"):
		# Can only set barricade on closed doors.
		if not is_barricaded and not is_opened:
			
			# Check players points
			var player_ref := get_tree().get_first_node_in_group("player") as Player
			if not player_ref:
				return
				
			if player_ref.points < barricade_cost:
				return
			
		# Set up barricade and decrease player points.
			player_ref.points -= barricade_cost
			set_barricade()

## Sets up barricade forcefully, make sure to check status first.
func set_barricade() -> void:
	# Dont remove if check, it causes stack overflow.
	if not Engine.is_editor_hint():
		is_barricaded = true
		barricaded.emit()
	
	barricade = barricade_scene.instantiate() as Barricade
	barricade.barricade_down.connect(_on_barricade_down)
	add_child(barricade)

## Removes the barricade, will not be used in game.
## Used for editor purposes only.
func remove_barricade() -> void:
	# Dont remove if check, it causes stack overflow.
	if not Engine.is_editor_hint():
		is_barricaded = false
	
	if barricade:
		barricade.queue_free()
	
	barricade = null

## Closes the door.
func close() -> void:
	# Dont remove if check, it causes stack overflow.
	if not Engine.is_editor_hint():
		is_opened = false
		closed.emit()
	
	# Update visuals here.
	$Sprite2D.visible = true
	
	# Disable being a obstacle here.
	collision_shape_2d.set_deferred("disabled", false)

## Opens the door forcefully.
## Make sure to check if door is barricaded first,
func open() -> void:
	# Dont remove if check, it causes stack overflow.
	if not Engine.is_editor_hint():
		is_opened = true
		opened.emit()

	$Sprite2D.visible = false
	
	# Enable being a obstacle here.
	collision_shape_2d.set_deferred("disabled", true)

func _on_barricade_down() -> void:
	is_barricaded = false
	barricade = null
	barricade_down.emit()

func _on_enemy_detection_area_2d_enemy_entered(_enemy: Enemy) -> void:
	if not is_opened:
		open()
		$InteractionText.visible = true

func _on_enemy_detection_area_2d_enemy_exited(_enemy: Enemy) -> void:
	close()
	$InteractionText.visible = false
