extends Node2D
class_name Spawner

## Spawner helper node to spawn enemies on the level.

## Spawn rule for the spawner.
@export var spawn_rule : SpawnRule = SpawnRule.new()

## Edit this property to activate / deactivate spawner.
## This property only indicates spawner is working, whether or not it is spawning
## depends on spawn_rule and game state.
@export var active : bool = false

# Elapsed time since the last spawn.
var _elapsed_since_last_time : float = 0.0

# Internal counter for the living entities.
var _living_entites_count : int = 0

# Internal array to references for the weak references.
var _weak_refs : Array[WeakRef] = []

# Internal counter to count how many spawned till now.
var _spawned_entities : int = 0

func _process(delta: float) -> void:
	if not active:
		return
	_elapsed_since_last_time += delta
	
	if _can_spawn():
		_spawn()

# Spawn entity if scene is assigned to spawn rule.
# If spawn is succesfull elapsed_since_last_time will be reset to 0.
# Only continues to spawn if _can_spawn returns true.
func _spawn() -> void:
	if not spawn_rule.spawn_scene:
		return
	
	for i in range(0, spawn_rule.get_spawn_count_on_difficulty(DifficultyTracker.get_difficulty())):
		var spawned_node = spawn_rule.spawn_scene.instantiate()
		
		if spawned_node is Node2D:
			var offset_x : float = randf_range(-spawn_rule.position_offset_range.x / 2.0, spawn_rule.position_offset_range.x / 2.0)
			var offset_y : float = randf_range(-spawn_rule.position_offset_range.y / 2.0, spawn_rule.position_offset_range.y / 2.0)
			spawned_node.position = Vector2(position.x + offset_x, position.y + offset_y)
		add_sibling(spawned_node)
		
		# save weak ref and increment spawn counter.
		_weak_refs.push_back(weakref(spawned_node))
		_spawned_entities += 1
		
		# Check count and quit looping if living count is maximum.
		if not _can_spawn():
			break
	
	# spawn loop is over reset elapsed time.
	_elapsed_since_last_time = 0.0

# Helper node to check if can/should spawn now.
func _can_spawn() -> bool:
	var time_check : bool = _elapsed_since_last_time >= \
		spawn_rule.get_cooldown_on_difficulty(DifficultyTracker.get_difficulty())
	
	_check_living_entites()
	
	var living_entity_check : bool = _living_entites_count < \
			spawn_rule.get_max_living_entity_on_difficulty(DifficultyTracker.get_difficulty())
	
	# Override count check if its 0.
	if spawn_rule.max_living_entity == 0:
		living_entity_check = true
	
	var max_spawns_check : bool = _spawned_entities < \
		spawn_rule.get_total_max_spawn_on_difficulty(DifficultyTracker.get_difficulty())
	
	# Override count check if its 0.
	if spawn_rule.total_max_spawns == 0:
		max_spawns_check = true
	
	var difficulty_check : bool = spawn_rule.is_working_on_difficulty(DifficultyTracker.get_difficulty())
	
	var can : bool = time_check and living_entity_check and difficulty_check and max_spawns_check
	
	return can

# Helper to check for living entities from time to time.
# Updates _living_entities_count and erases _weak_refs if neccessary.
func _check_living_entites() -> void:
	var to_erase : Array[WeakRef] = []
	
	# Check for living state
	for ref : WeakRef in _weak_refs:
		if not ref.get_ref():
			to_erase.push_back(ref)
	
	# Erase dead refs.
	for ref : WeakRef in to_erase:
		_weak_refs.erase(ref)
	
	_living_entites_count = _weak_refs.size()
