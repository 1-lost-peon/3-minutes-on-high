extends CanvasLayer
class_name DifficultyVisualizer

## CanvasLayer that visualizes games current difficulty level / crime progress / elapsed time.
##
## Listens DifficultyTracker singletons signals.


@export_category("Difficulty Textures")
## Easy diff texture.
@export var easy_difficulty_texture : Texture2D = null
## Normal diff texture.
@export var normal_difficulty_texture : Texture2D = null
## Hard diff texture.
@export var hard_difficulty_texture : Texture2D = null
## Insane diff texture.
@export var insane_difficulty_texture : Texture2D = null
## Lethal diff texture.
@export var lethal_difficulty_texture : Texture2D = null

@export_category("Difficulty_Texts")
## Easy diff text.
@export var easy_difficulty_text : String = ""
## Normal diff text.
@export var normal_difficulty_text : String = ""
## Hard diff text.
@export var hard_difficulty_text : String = ""
## Insane diff text.
@export var insane_difficulty_text : String = ""
## Lethal diff text.
@export var lethal_difficulty_text : String = ""

@export_category("Animations")
## Seconds of animation of the progress bar changes.
@export var progress_bar_anim_secs : float = 0.2
## Seconds of animation of difficulty level texture changes.
@export var difficulty_texture_anim_secs : float = 0.2
## Scale factor for the difficulty level texture change animations.
@export var difficulty_texture_scale_factor : float = 1.1

@onready var difficulty_texture_rect: TextureRect = %DifficultyTextureRect
@onready var crime_progress_bar: ProgressBar = %CrimeProgressBar
@onready var difficulty_label: Label = %DifficultyLabel
@onready var time_label: Label = %TimeLabel

# To calculate elapsed time.
var _start_time : int = 0
# To animate progress bar.
var _progress_bar_tween : Tween = null
# To animate difficulty texture.
var _difficulty_texture_tween : Tween = null
# To store textures initial minimum size.
@onready var _difficulty_texture_min_size_y = self.difficulty_texture_rect.custom_minimum_size.y

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		DifficultyTracker.report_crime(DifficultyTracker.Crime.LITTLE)

func _ready() -> void:
	_start_time = Time.get_ticks_msec()
	DifficultyTracker.crime_committed.connect(_on_crime_committed)
	#DifficultyTracker.difficulty_increased.connect(_on_difficulty_increased)
	#DifficultyTracker.difficulty_reset.connect(_on_difficulty_reset)

func _process(_delta: float) -> void:
	_handle_elapsed_time()

# Update the progressbar.
func _on_crime_committed() -> void:
	_animate_progress_bar_to_value(DifficultyTracker.get_progress())

# Update the texture.
func _on_difficulty_increased() -> void:
	_animate_progress_bar_to_value(DifficultyTracker.get_progress())
	_animate_difficulty_texture()
	
	match DifficultyTracker.get_difficulty():
		DifficultyTracker.Difficulty.EASY:
			if easy_difficulty_texture:
				difficulty_texture_rect.texture = easy_difficulty_texture
			
			difficulty_label.text = easy_difficulty_text
			
		DifficultyTracker.Difficulty.NORMAL:
			if normal_difficulty_texture:
				difficulty_texture_rect.texture = normal_difficulty_texture
			
			difficulty_label.text = normal_difficulty_text
			
		DifficultyTracker.Difficulty.HARD:
			if hard_difficulty_texture:
				difficulty_texture_rect.texture = hard_difficulty_texture
			
			difficulty_label.text = hard_difficulty_text
			
		DifficultyTracker.Difficulty.INSANE:
			if insane_difficulty_texture:
				difficulty_texture_rect.texture = insane_difficulty_texture
			
			difficulty_label.text = insane_difficulty_text
			
		DifficultyTracker.Difficulty.LETHAL:
			if lethal_difficulty_texture:
				difficulty_texture_rect.texture = lethal_difficulty_texture
			
			difficulty_label.text = lethal_difficulty_text
			crime_progress_bar.hide() # Since we dont need progression anymore.

# Reset state.
func _on_difficulty_reset() -> void:
	# Also reset time.
	_start_time = Time.get_ticks_msec()
	crime_progress_bar.value = 0.0
	
	if not crime_progress_bar.visible:
		crime_progress_bar.show()
	
	if easy_difficulty_texture:
		difficulty_texture_rect.texture = easy_difficulty_texture
	
	difficulty_label.text = easy_difficulty_text

# Handles elapsed time calculations and updates time_label.text field.
func _handle_elapsed_time() -> void:
	var curr_msec := Time.get_ticks_msec()
	var elapsed_msec := curr_msec - _start_time
	
	# Convert milliseconds to proper time units
	var milliseconds := elapsed_msec % 1000
	var total_seconds := elapsed_msec / 1000.0 as int
	var seconds := total_seconds % 60
	var total_minutes := total_seconds / 60.0 as int
	var minutes := total_minutes % 60
	var hours := total_minutes / 60.0 as int
	
	var text : String
	
	if hours > 0:
		text = "%d:%02d:%02d.%03d" % [hours, minutes, seconds, milliseconds]
	elif minutes > 0:
		text = "%d:%02d.%03d" % [minutes, seconds, milliseconds]
	else:
		text = "%d.%03d" % [seconds, milliseconds]
	
	time_label.text = text

func _animate_progress_bar_to_value(percentage : float) -> void:
	if _progress_bar_tween:
		_progress_bar_tween.kill()
	
	_progress_bar_tween = create_tween()
	_progress_bar_tween.tween_property(crime_progress_bar, "value", percentage, progress_bar_anim_secs)

func _animate_difficulty_texture() -> void:
	if _difficulty_texture_tween:
		_difficulty_texture_tween.kill()
	
	_difficulty_texture_tween = create_tween()
	
	_difficulty_texture_tween.tween_property(difficulty_texture_rect, "custom_minimum_size:y",
		_difficulty_texture_min_size_y * difficulty_texture_scale_factor, difficulty_texture_anim_secs)
		
	_difficulty_texture_tween.tween_property(difficulty_texture_rect, "custom_minimum_size:y",
		_difficulty_texture_min_size_y, difficulty_texture_anim_secs)
	
