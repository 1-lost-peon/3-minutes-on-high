extends Node2D

@onready var player_ref: Player = get_tree().get_first_node_in_group("player")

var game_started := false

func _ready():
	%Intro.start_game.connect(_on_start_game)
	_reset_player()
	_reset_level()

func _process(delta: float) -> void:
	if !game_started:
		return
	# actual gameplay update here

func _reset_player() -> void:
	if player_ref:
		player_ref.fill_ammo_full()
		player_ref.reset_hp()

func _reset_level():
	DifficultyTracker.reset_difficulty()

func _on_start_game() -> void:
	game_started = true
	# enable spawns, timers, etc. here, if needed
