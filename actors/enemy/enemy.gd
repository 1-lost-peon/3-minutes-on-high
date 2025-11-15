extends CharacterBody2D

enum EnemyState {
	WALK,
	DEAD
}
@export var player:Player
@onready var state_label: Label = $Container/StateLabel
@onready var health_label: Label = $Container/HealthLabel

@export var health : int = 10 :
	set(value):
		health = value
		if health_label == null: return
		health_label.text = "Health: %s"  % str(value)


@export_range(1, 1000, 0.1) var speed:float 

func _ready() -> void:
	health = health
	current_state = current_state

var current_state: EnemyState = EnemyState.WALK:
	set = change_state


func change_state(new_state):
	print("Current: %s, new: %s" % [current_state, new_state])
	state_label.text = "State: %s"  % str(EnemyState.keys()[new_state])

	current_state = new_state
	
var is_attacking := false

func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.WALK: _walk_update(delta)
		EnemyState.DEAD: _dead_update(delta)

func take_damage(value):
	
	if current_state == EnemyState.DEAD:
		return
	health -= value
	if health == 0:
		current_state = EnemyState.DEAD
	
func _dead_update(_delta):
	return

func _walk_update(_delta):
	if not player:
		return
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()
