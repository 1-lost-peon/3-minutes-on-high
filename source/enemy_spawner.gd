extends Node2D
class_name EnemySpawner

signal enemy_spawned(enemy: Node2D)

@export var enemy_scene: PackedScene
@export var spawn_interval := 0.6

var _remaining_to_spawn := 0
var _is_spawning := false

func start_wave(count: int) -> void:
	if count <= 0:
		return
	_remaining_to_spawn = count
	if !_is_spawning:
		_is_spawning = true
		_spawn_loop()

func stop_wave() -> void:
	_remaining_to_spawn = 0
	_is_spawning = false

func _spawn_loop() -> void:
	while _is_spawning and _remaining_to_spawn > 0:
		_remaining_to_spawn -= 1

		var enemy := enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = global_position
		enemy_spawned.emit(enemy)

		if _remaining_to_spawn > 0:
			await get_tree().create_timer(spawn_interval).timeout

	_is_spawning = false
