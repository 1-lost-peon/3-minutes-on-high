extends CanvasLayer
class_name HUD

## Heads up display for the game.

@onready var hp_label: Label = %HPLabel
@onready var points_label: Label = %PointsLabel
@onready var ammo_label: Label = %AmmoLabel
@onready var wave_label: Label = %WaveLabel

func _process(_delta: float) -> void:
	_update_player_stats()

func _update_player_stats() -> void:
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	
	if not player_ref:
		hp_label.text = ""
		points_label.text = ""
		ammo_label.text = ""
		return
	
	hp_label.text = "HP: " + str(player_ref.hp)
	points_label.text = "Points: " + str(player_ref.points)
	ammo_label.text = "Ammo: " + str(player_ref.ammo)
