extends Node2D

var player_ref: Player

func _ready():
	DifficultyTracker.reset_difficulty()
	player_ref = get_tree().get_first_node_in_group("player")
	player_ref.fill_ammo_full()
	player_ref.reset_hp()

func _process(delta):
	pass
