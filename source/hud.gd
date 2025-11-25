extends CanvasLayer
class_name HUD

## Heads up display for the game.

@onready var hp_label: Label = %HPLabel
@onready var points_label: Label = %PointsLabel
@onready var ammo_label: Label = %AmmoLabel
@onready var wave_label: Label = %WaveLabel
@onready var digit_1 = %Digit1
@onready var digit_2 = %Digit2
@onready var digit_3 = %Digit3
@onready var digit_4 = %Digit4

func _process(_delta: float) -> void:
	_update_player_stats()

func _update_player_stats() -> void:
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	
	if not player_ref:
		hp_label.text = ""
		points_label.text = ""
		ammo_label.text = ""
		return
		
	update_clock(player_ref.hp)
	hp_label.text = "HP: " + str(player_ref.hp)
	points_label.text = "Points: " + str(player_ref.points)
	ammo_label.text = "Ammo: " + str(player_ref.ammo)

func update_clock(total_seconds):
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60

	if total_seconds > 0:
		digit_1.frame = minutes / 10
		digit_2.frame = minutes % 10

		digit_3.frame = seconds / 10
		digit_4.frame = seconds % 10
	else:
		digit_1.frame = 0
		digit_2.frame = 0

		digit_3.frame = 0
		digit_4.frame = 0
