extends Node2D
class_name Spawner

## Spawner helper node to spawn enemies on the level.

@export var spawn_rule : SpawnRule = SpawnRule.new()

# Flag that indicates should spawner work or not.
var _should_spawn : bool = false
# Elapsed time since the last spawn.
var _elapsed_since_last_time : float = 0.0

func _ready() -> void:
	DifficultyTracker.difficulty_increased.connect(_on_difficulty_increased)
	DifficultyTracker.difficulty_reset.connect(_on_difficulty_reset)

func _process(delta: float) -> void:
	_elapsed_since_last_time += delta
	
	if _should_spawn and \
		_elapsed_since_last_time >= spawn_rule.get_cooldown_on_difficulty(DifficultyTracker.get_difficulty()):
		_spawn()

# Check if spawn logic should run.
func _on_difficulty_increased() -> void:
	_should_spawn = spawn_rule.is_working_on_difficulty(DifficultyTracker.get_difficulty())

# Check if spawn logic should run.
func _on_difficulty_reset() -> void:
	_should_spawn = spawn_rule.is_working_on_difficulty(DifficultyTracker.get_difficulty())

# Spawn
func _spawn() -> void:
	_elapsed_since_last_time = 0.0
	
	if spawn_rule.spawn_scene:
		for i in range(0, 1, spawn_rule.get_spawn_count_on_difficulty(DifficultyTracker.get_difficulty())):
			var spawned_node = spawn_rule.spawn_scene.instantiate()
			if spawned_node is Node2D:
				spawned_node.position
			add_child(spawned_node)
			
