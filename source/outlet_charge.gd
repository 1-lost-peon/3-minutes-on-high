@tool

extends Node2D

@onready var interaction_text: Label = $InteractionText
@onready var player_detection_area_2d: PlayerDetectionArea2D = $PlayerDetectionArea2D

@export var ammo_type : Player.AmmoType = Player.AmmoType.RED:
	set(value):
		if is_node_ready():
			$Sprite2D.frame = value
		ammo_type = value
	get:
		return ammo_type
func _ready() -> void:
	ammo_type = ammo_type
	print(ammo_type)
var hold_progress := 0.0
var hold_time :=1.0
var holding := false

func _unhandled_input(event: InputEvent) -> void:
	if not player_detection_area_2d.is_player_inside():
		return
	
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	if not player_ref:
		return
	if Input.is_action_pressed("interact"):
		holding = true
	if event.is_action_released("interact"):
		holding = false
		hold_progress = 0.0
		$ProgressBar.value = 0


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	var is_player_inside = player_detection_area_2d.is_player_inside()
	interaction_text.visible = is_player_inside
	if not is_player_inside:
		return
	if holding:
		hold_progress += delta * 2.5
		$ProgressBar.value = (hold_progress / hold_time) * 100

	if hold_progress >= hold_time:
		holding = false
		var player_ref := get_tree().get_first_node_in_group("player") as Player
		player_ref.ammo.push_front(ammo_type)
		hold_progress = 0.0

		

		
		
	
