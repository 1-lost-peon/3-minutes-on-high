extends Resource
class_name SpawnRule

## Rules to determine how enemy spawning will work in game.
##
## Used to edit spawner on editor via a resource.

@export_group("Base Spawn Rules")
## Minimum difficulty level required for the spawn to work.
@export var min_difficulty_level : DifficultyTracker.Difficulty = DifficultyTracker.Difficulty.EASY
## Maximum difficulty level the spawn will work.
@export var max_difficulty_level : DifficultyTracker.Difficulty = DifficultyTracker.Difficulty.LETHAL
## Maximum number of living entity for the spawn, leave it as 0 if not specified.
@export var max_living_entity : int = 0
## Scene to spawn.
@export var spawn_scene : PackedScene = null
## Spawn cooldown in seconds.
@export var cooldown_seconds : float = 10.0
## Maximum number of total spawns for this rule, leave it as 0 if not specified.
@export var total_max_spawns : int = 0
## Spawn count for the each spawn.
@export var spawn_count : int = 1
## Maximum offset for the spawns, will be picked random in given range.
@export var position_offset_range : Vector2 = Vector2(50,50)


@export_group("Cooldown Scales")
## Scale will multiply cooldown_seconds in matching difficulty level.
@export var easy_cooldown_scale : float = 1.0
## Scale will multiply cooldown_seconds in matching difficulty level.
@export var normal_cooldown_scale : float = 1.0
## Scale will multiply cooldown_seconds in matching difficulty level.
@export var hard_cooldown_scale : float = 1.0
## Scale will multiply cooldown_seconds in matching difficulty level.
@export var insane_cooldown_scale : float = 1.0
## Scale will multiply cooldown_seconds in matching difficulty level.
@export var lethal_cooldown_scale : float = 1.0

@export_group("Spawn Count Scales")
## Scale will multiply spawn_count in matching difficulty level.
@export var easy_spawn_count_scale : int = 1
## Scale will multiply spawn_count in matching difficulty level.
@export var normal_spawn_count_scale : int = 1
## Scale will multiply spawn_count in matching difficulty level.
@export var hard_spawn_count_scale : int = 1
## Scale will multiply spawn_count in matching difficulty level.
@export var insane_spawn_count_scale : int = 1
## Scale will multiply spawn_count in matching difficulty level.
@export var lethal_spawn_count_scale : int = 1

@export_group("Total Max Spawns Scales")
## Scale will multiply total_max_spawns in matching difficulty level.
@export var easy_total_max_spawn_scale : int = 1
## Scale will multiply total_max_spawns in matching difficulty level.
@export var normal_total_max_spawn_scale : int = 1
## Scale will multiply total_max_spawns in matching difficulty level.
@export var hard_total_max_spawn_scale : int = 1
## Scale will multiply total_max_spawns in matching difficulty level.
@export var insane_total_max_spawn_scale : int = 1
## Scale will multiply total_max_spawns in matching difficulty level.
@export var lethal_total_max_spawn_scale : int = 1

@export_group("Max Living Entity Scales")
## Scale will multiply max_living_entity in matching difficulty level.
@export var easy_max_living_entity : int = 1
## Scale will multiply max_living_entity in matching difficulty level.
@export var normal_max_living_entity : int = 1
## Scale will multiply max_living_entity in matching difficulty level.
@export var hard_max_living_entity : int = 1
## Scale will multiply max_living_entity in matching difficulty level.
@export var insane_max_living_entity : int = 1
## Scale will multiply max_living_entity in matching difficulty level.
@export var lethal_max_living_entity : int = 1

## Check if this spawn rule should work on given difficulty level.
func is_working_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> bool:
	if difficulty_level >= min_difficulty_level and difficulty_level <= max_difficulty_level:
		return true
	else:
		return false

## Get multiplied max living entity on given difficulty level.
## Returns -1 if not working on that difficuly level.
## Returns 0 if not specified.
func get_max_living_entity_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> int:
	
	if not is_working_on_difficulty(difficulty_level):
		return -1
	
	if max_living_entity == 0:
		return 0
	
	match difficulty_level:
		DifficultyTracker.Difficulty.EASY:
			return max_living_entity * easy_max_living_entity
		DifficultyTracker.Difficulty.NORMAL:
			return max_living_entity * normal_max_living_entity
		DifficultyTracker.Difficulty.HARD:
			return max_living_entity * hard_max_living_entity
		DifficultyTracker.Difficulty.INSANE:
			return max_living_entity * insane_max_living_entity
		DifficultyTracker.Difficulty.LETHAL:
			return max_living_entity * lethal_max_living_entity
	
	# This shouldnt really happen but anyway return -1
	return -1

## Get multiplied max spawn on given difficulty level.
## Returns -1 if not working on that difficuly level.
## Returns 0 if there is no cap.
func get_total_max_spawn_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> int:
	
	if not is_working_on_difficulty(difficulty_level):
		return -1
	
	if total_max_spawns == 0:
		return 0
	
	match difficulty_level:
		DifficultyTracker.Difficulty.EASY:
			return max_living_entity * easy_total_max_spawn_scale
		DifficultyTracker.Difficulty.NORMAL:
			return max_living_entity * normal_total_max_spawn_scale
		DifficultyTracker.Difficulty.HARD:
			return max_living_entity * hard_total_max_spawn_scale
		DifficultyTracker.Difficulty.INSANE:
			return max_living_entity * insane_total_max_spawn_scale
		DifficultyTracker.Difficulty.LETHAL:
			return max_living_entity * lethal_total_max_spawn_scale
	
	# This shouldnt really happen but anyway return -1
	return -1

## Get multiplied spawn count on given difficulty level.
## Returns -1 if not working on that difficuly level.
func get_spawn_count_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> int:
	
	if not is_working_on_difficulty(difficulty_level):
		return -1
	
	match difficulty_level:
		DifficultyTracker.Difficulty.EASY:
			return spawn_count * easy_spawn_count_scale
		DifficultyTracker.Difficulty.NORMAL:
			return spawn_count * normal_spawn_count_scale
		DifficultyTracker.Difficulty.HARD:
			return spawn_count * hard_spawn_count_scale
		DifficultyTracker.Difficulty.INSANE:
			return spawn_count * insane_spawn_count_scale
		DifficultyTracker.Difficulty.LETHAL:
			return spawn_count * lethal_spawn_count_scale
	
	# This shouldnt really happen but anyway return -1
	return -1

## Get multiplied cooldown on given difficulty level.
## Returns -1.0 if not working on that difficuly level.
func get_cooldown_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> float:
	
	if not is_working_on_difficulty(difficulty_level):
		return -1.0
	
	match difficulty_level:
		DifficultyTracker.Difficulty.EASY:
			return cooldown_seconds * easy_cooldown_scale
		DifficultyTracker.Difficulty.NORMAL:
			return cooldown_seconds * normal_cooldown_scale
		DifficultyTracker.Difficulty.HARD:
			return cooldown_seconds * hard_cooldown_scale
		DifficultyTracker.Difficulty.INSANE:
			return cooldown_seconds * insane_cooldown_scale
		DifficultyTracker.Difficulty.LETHAL:
			return cooldown_seconds * lethal_cooldown_scale
	
	# This shouldnt really happen but anyway return -1
	return -1.0
