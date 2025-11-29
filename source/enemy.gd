@icon("uid://buurifc5jfvyc")
extends CharacterBody2D
class_name Enemy

enum EnemyState {
	WALK,
	DEAD,
	ATTACK
}
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@onready var state_label: Label = $Container/StateLabel
@onready var health_label: Label = $Container/HealthLabel
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var health : int = 2 :
	set(value):
		health = value
		if health_label == null: return
		health_label.text = "Health: %s"  % str(value)

@export_range(1, 1000, 0.1) var speed: float 

## Attack range of the enemy. Enemy attack if its this close to the Player.
@export var attack_range : float = 50.0

## Attack duration in seconds.
@export var attack_duration_secs : float = 0.2

## Damage of the single attack.
@export var attack_damage : float = 2.0

var current_state: EnemyState = EnemyState.WALK:
	set = change_state

var _player_ref : Player = null

func _ready() -> void:
	_player_ref = get_tree().get_first_node_in_group("player")

func change_state(new_state):
	#print("Current: %s, new: %s" % [current_state, new_state])
	state_label.text = "State: %s"  % str(EnemyState.keys()[new_state])
	current_state = new_state


func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.WALK: _walk_update(delta)
		EnemyState.DEAD: _dead_update(delta)
		EnemyState.ATTACK: _attack_update(delta)

func take_damage(value):
	if current_state == EnemyState.DEAD:
		return
	health -= value
	if health == 0:
		current_state = EnemyState.DEAD
		_player_ref.hp += 3
	
func _dead_update(_delta):
	return

func _walk_update(_delta):
	if not _player_ref:
		return
	navigation_agent_2d.target_position = _player_ref.global_position
	var next_path_position := navigation_agent_2d.get_next_path_position()
	var direction = global_position.direction_to(next_path_position)
	var new_velocity = direction * speed
	
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	# If we are close to player change state to attack.
	if (global_position - _player_ref.global_position).length() <= attack_range:
		current_state = EnemyState.ATTACK

func _attack_update(_delta):
	if not _player_ref:
		return
	
	# For debug purposes change this enemies color to red to indicate we are attacking.
	var tween := create_tween()
	
	# Disable physics process to hold state processing, this will result in running attack update for once.
	set_physics_process(false)
	
	tween.tween_property(sprite_2d, "self_modulate", Color.RED, attack_duration_secs * 0.66)
	tween.tween_callback(_damage_player)
	tween.tween_property(sprite_2d, "self_modulate", Color.WHITE, attack_duration_secs * 0.33)
	
	# Change state back to walk and enable physics process to reprocess states.
	tween.tween_callback(func(): current_state = EnemyState.WALK)
	tween.tween_callback(set_physics_process.bind(true))

func _damage_player() -> void:
	if _player_ref:
		_player_ref.take_damage(attack_damage)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
