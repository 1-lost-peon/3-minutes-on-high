extends Node2D

@onready var player_ref: Player = get_tree().get_first_node_in_group("player")
#@onready var spawners: Array[EnemySpawner] = get_tree().get_nodes_in_group("enemy_spawner")
@onready var spawners := %SpawnerNodes.get_children()

var game_started := false
var wave_number: int = 1
var wave_in_progress := false
var enemies_alive: int = 0
var game_over = false

@export var base_enemies_per_wave := 5
@export var enemies_per_wave_growth := 3
@export var wave_delay_seconds := 2.0

func _ready():
	%Intro.start_game.connect(_on_start_game)
	_reset_player()
	_reset_level()
	_connect_spawners()
	if player_ref:
		player_ref.died.connect(_on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if game_over == true:
		if event.is_action_pressed("interact"):
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_player_died() -> void:
	$HUDCanvasLayer/GameOver.visible = true
	game_over = true

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
	wave_number = 1
	wave_in_progress = false
	enemies_alive = 0

func _connect_spawners() -> void:
	for s in spawners:
		s.enemy_spawned.connect(_on_spawner_enemy_spawned)

func _on_start_game() -> void:
	game_started = true
	_start_wave(wave_number)
	# enable spawns, timers, etc. here, if needed
	
# -------------------------
# Wave logic
# -------------------------
func _start_wave(wave: int) -> void:
	if spawners.is_empty():
		push_warning("No spawners found in group 'enemy_spawner'.")
		return

	wave_in_progress = true
	var total_to_spawn := _calculate_wave_size(wave)

	var active_spawners := _get_active_spawners_for_wave(wave)
	if active_spawners.is_empty():
		active_spawners = spawners # fallback

	var per_spawner := total_to_spawn / active_spawners.size()
	var remainder := total_to_spawn % active_spawners.size()

	enemies_alive = 0

	for i in range(active_spawners.size()):
			var extra := 1 if i < remainder else 0
			var amount := per_spawner + extra
			active_spawners[i].start_wave(amount)

func _calculate_wave_size(wave: int) -> int:
	return base_enemies_per_wave + (wave - 1) * enemies_per_wave_growth
	
# For now: arbitrary “which spawners are open”
# This opens more spawners as wave_number increases.
func _get_active_spawners_for_wave(wave: int) -> Array[Node]:
	var result: Array[Node] = spawners.duplicate()
	return result

# -------------------------
# Enemy tracking
# -------------------------
func _on_spawner_enemy_spawned(enemy: Node) -> void:
	enemies_alive += 1

	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	else:
		enemy.tree_exited.connect(_on_enemy_died_tree_exited)

func _on_enemy_died() -> void:
	enemies_alive -= 1
	_check_wave_end()

func _on_enemy_died_tree_exited() -> void:
	enemies_alive -= 1
	_check_wave_end()

func _check_wave_end() -> void:
	if !wave_in_progress:
		return

	if enemies_alive <= 0:
		wave_in_progress = false
		wave_number += 1
		# reset difficulty or ramp it here if you want
		await get_tree().create_timer(wave_delay_seconds).timeout
		if game_started:
			_start_wave(wave_number)
