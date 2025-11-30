@icon("uid://buurifc5jfvyc")
extends CharacterBody2D
class_name Enemy

signal died

enum EnemyState {
	WALK,
	DEAD,
	ATTACK
}
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@onready var state_label: Label = $Container/StateLabel
@onready var health_label: Label = $Container/HealthLabel
#@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var explosion_area: Area2D = $ExplosionArea
@onready var noise_sfx = $NoiseSfx
@onready var explode_sfx = $ExplodeSfx
@onready var noise_timer = $NoiseTimer

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

@export var noise_min_wait := 2.0
@export var noise_max_wait := 5.0

var is_dead = false

var current_state: EnemyState = EnemyState.WALK:
	set = change_state

var _player_ref : Player = null

func _ready() -> void:
	_player_ref = get_tree().get_first_node_in_group("player")
	_reset_noise_timer()
	noise_timer.timeout.connect(_on_noise_timer_timeout)

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
	_player_ref.hp += 2
	if current_state == EnemyState.DEAD:
		return
	health -= value
	if health <= 0:
		current_state = EnemyState.ATTACK
	
func _dead_update(_delta):
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_damage_player()
	$CollisionShape2D.disabled = true

	died.emit()
	queue_free()


func _walk_update(_delta):
	if health == 2:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("injured")
		
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
	animated_sprite_2d.play("explode")
	await animated_sprite_2d.animation_finished
	explode_sfx.play()
	current_state = EnemyState.DEAD

func _damage_player() -> void:
	if _player_ref:
		_player_ref.take_damage(attack_damage)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	if current_state != EnemyState.DEAD:
		move_and_slide()
		
func _on_noise_timer_timeout() -> void:
	#if !noise_sfx.playing:
		#noise_sfx.play()
	_reset_noise_timer()

func _reset_noise_timer() -> void:
	noise_timer.wait_time = randf_range(noise_min_wait, noise_max_wait)
	noise_timer.start()
