extends Node
class_name _DifficultyTracker

## Singleton that adjusts game difficulty.
##
## Report every crime committed via report_crime method.
## If difficulty threshold is reached, games difficulty will increase.
## To learn about games current difficulty level use get_difficulty method.
## Enemies and other nodes can increase their strength by checking difficulty level of the game.

## Emitted whenever difficulty is increased.
signal difficulty_increased()

## Emitted whenever crime is committed.
#signal crime_committed()

## Emitted whenever singleton is reset. Used to replay the game.
signal difficulty_reset()

## Types of crime. Every committed crime will contribute to the difficulty level of the game.
enum Crime {
	LITTLE,
	MEDIUM,
	BIG,
}

## Difficulty. Game start on easy and scales up to lethal over time by the committed crimes.
enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	INSANE,
	LETHAL,
}

# Threshold required to fullfilled to scale up difficulty.
const _difficulty_threshold : int = 500

# Punishment value for the little crime.
const _little_crime_punishment : int = 50
# Punishment value for the medium crime.
const _medium_crime_punishment : int = 150
# Punishment value for the big crime.
const _big_crime_punishment : int = 300

# Current level of punishment
var _current_punishment : int = 0
# Current level of difficulty
var _current_difficulty : Difficulty = Difficulty.EASY

func increase_difficulty() -> void:
	match _current_difficulty:
		Difficulty.EASY:
			_current_difficulty = Difficulty.NORMAL
			difficulty_increased.emit()
		Difficulty.NORMAL:
			_current_difficulty = Difficulty.HARD
			difficulty_increased.emit()
		Difficulty.HARD:
			_current_difficulty = Difficulty.INSANE
			difficulty_increased.emit()
		Difficulty.INSANE:
			_current_difficulty = Difficulty.LETHAL
			difficulty_increased.emit()
		Difficulty.LETHAL:
			pass

## Get the games current difficulty level.
func get_difficulty() -> Difficulty:
	return _current_difficulty

## Get the current crime progress as %.
func get_progress() -> float:
	return _current_punishment as float / _difficulty_threshold as float * 100.0

## Reset the singleton to replay the game.
func reset_difficulty() -> void:
	_current_punishment = 0
	_current_difficulty = Difficulty.EASY
	difficulty_reset.emit()
