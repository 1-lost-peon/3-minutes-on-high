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
## Maximum number of living entity for the spawn.
@export var max_living_entity : int = 1
## Scene to spawn.
@export var spawn_scene : PackedScene = null
## Spawn cooldown in seconds.
@export var cooldown_seconds : float = 10.0
## Maximum number of spawns for this rule, leave it as -1 if not specified.
@export var max_spawns : int = -1
## Spawn count for the each spawn.
@export var spawn_count : int = 1


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

@export_group("Max Spawns Scales")
## Scale will multiply max_spawns in matching difficulty level.
@export var easy_max_spawn_scale : int = 1
## Scale will multiply max_spawns in matching difficulty level.
@export var normal_max_spawn_scale : int = 1
## Scale will multiply max_spawns in matching difficulty level.
@export var hard_max_spawn_scale : int = 1
## Scale will multiply max_spawns in matching difficulty level.
@export var insane_max_spawn_scale : int = 1
## Scale will multiply max_spawns in matching difficulty level.
@export var lethal_max_spawn_scale : int = 1

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

func get_max_living_entity_on_difficulty(difficulty_level : DifficultyTracker.Difficulty) -> int:
	
