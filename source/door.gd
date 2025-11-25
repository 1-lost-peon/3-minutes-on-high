@tool
@icon("uid://dv83ksu0bnc8c")
extends StaticBody2D
class_name Door

## Door in the game world which can be strengthened with a barricade.

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

## Helper area to check if player is inside.
@onready var _player_detection_area_2d: Area2D = $PlayerDetectionArea2D
## Sprite of the door.
@onready var sprite_2d: Sprite2D = $Sprite2D
## Collision shape of the static body.
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
## Player detection area helper node to detect player.
@onready var player_detection_area_2d: PlayerDetectionArea2D = $PlayerDetectionArea2D

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
	if not _player_detection_area_2d.is_player_inside():
		return
	
	if event.is_action_pressed("interact"):
		holding = true
		
	if event.is_action_released("interact"):
		holding = false
		hold_progress = 0.0
		$InteractionText/VBoxContainer/ProgressBar.value = 0
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
	
	# Update visuals here.
	if closed_texture:
		sprite_2d.texture = closed_texture 
	
	# Disable being a obstacle here.
	collision_shape_2d.set_deferred("disabled", false)

## Opens the door forcefully.
## Make sure to check if door is barricaded first,
func open() -> void:
	# Dont remove if check, it causes stack overflow.
	if not Engine.is_editor_hint():
		is_opened = true
	
	# Update visuals here.
	if open_texture:
		sprite_2d.texture = open_texture
	
	# Enable being a obstacle here.
	collision_shape_2d.set_deferred("disabled", true)
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	player_ref.hp -= 60

func _on_barricade_down() -> void:
	is_barricaded = false
	barricade = null

func _show_interaction_visual() -> void:
	if outline_material:
		sprite_2d.material = outline_material
	
	if _interaction_tween:
		_interaction_tween.kill()
	
	_interaction_tween = create_tween()
	
	_interaction_tween.tween_property(sprite_2d, "scale",
		_default_sprite_scale * interaction_scale_factor, interaction_duration_secs)

func _show_default_visual() -> void:
	sprite_2d.material = null
	
	if _interaction_tween:
		_interaction_tween.kill()
	
	_interaction_tween = create_tween()
	
	_interaction_tween.tween_property(sprite_2d, "scale",
		_default_sprite_scale, interaction_duration_secs)

func _on_player_detection_area_2d_player_entered(_player: Player) -> void:
	if not is_opened:
		_show_interaction_visual()
		$InteractionText.visible = true

func _on_player_detection_area_2d_player_exited(_player: Player) -> void:
	_show_default_visual()
	$InteractionText.visible = false
