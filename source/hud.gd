extends CanvasLayer
class_name HUD

## Heads up display for the game.

@onready var hp_label: Label = %HPLabel
@onready var points_label: Label = %PointsLabel
@onready var ammo_label: Label = %AmmoLabel
@onready var wave_label: Label = %WaveLabel
@onready var digit_1 = %Digit1
@onready var digit_2 = %Digit2
@onready var digit_3 = %Digit3
@onready var digit_4 = %Digit4
@onready var bars := %BatteryBackground.get_children()
@onready var stars := %StarsPanel.get_children()

func _ready() -> void:
	DifficultyTracker.difficulty_increased.connect(_on_difficulty_increased)
	DifficultyTracker.difficulty_reset.connect(_on_difficulty_reset)

func _process(_delta: float) -> void:
	_update_player_stats()

func _update_player_stats() -> void:
	var player_ref := get_tree().get_first_node_in_group("player") as Player
	
	if not player_ref:
		hp_label.text = ""
		points_label.text = ""
		ammo_label.text = ""
		return
		
	update_clock(player_ref.hp)
	update_ammo(player_ref.ammo)
	hp_label.text = "HP: " + str(player_ref.hp)
	points_label.text = "Points: " + str(player_ref.points)
	ammo_label.text = "Ammo: " + str(len(player_ref.ammo))

func update_ammo(ammo):
	ammo = clamp(len(ammo), 0, 30)  # max bars

	for i in range(30):
		var bar := bars[i] as Sprite2D
		bar.frame = 0 if i < ammo else 4

func update_clock(total_seconds):
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60

	if total_seconds > 0:
		digit_1.frame = minutes / 10
		digit_2.frame = minutes % 10

		digit_3.frame = seconds / 10
		digit_4.frame = seconds % 10
	else:
		digit_1.frame = 0
		digit_2.frame = 0

		digit_3.frame = 0
		digit_4.frame = 0

# Update the stars
func _on_difficulty_increased() -> void:
	match DifficultyTracker.get_difficulty():
		DifficultyTracker.Difficulty.EASY:
			%StarsSprite1.frame = 0
		DifficultyTracker.Difficulty.NORMAL:
			%StarsSprite2.frame = 0
		DifficultyTracker.Difficulty.HARD:
			%StarsSprite3.frame = 0
		DifficultyTracker.Difficulty.INSANE:
			%StarsSprite4.frame = 0
		DifficultyTracker.Difficulty.LETHAL:
			%StarsSprite5.frame = 0

func _on_difficulty_reset() -> void:
	for i in range(len(stars)):
		var star = stars[i]
		star.frame = 2
	fill_star(stars[0])

func fill_star(star):
	star.frame = 0
