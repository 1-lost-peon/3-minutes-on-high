class_name Player extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALK,
	DEAD
}

@export var health : int = 10 :
	set(value):
		health = value
		if health_label == null: return
		health_label.text = "Health: %s"  % str(value)

@export var ammo: int = 5 :
	set(value):
		ammo = value
		if ammo_label == null: return
		ammo_label.text = "Ammo: %s"  % str(value)

@export var points: int = 5 :
	set(value):
		points = value
		if points_label == null: return
		points_label.text = "Points: %s"  % str(value)
		
@export_range(1, 1000, 0.1)  var speed : float 

@export_range(0.0, 1.0) var shake_strength : float = 0.2


@onready var state_label: Label = $Container/StateLabel
@onready var health_label: Label = $Container/HealthLabel
@onready var ammo_label: Label = $Container/AmmoLabel
@onready var points_label: Label = $Container/PointsLabel
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_cd_label: Label = $Container/AttackCDLabel


func _ready() -> void:
	ammo = ammo
	health = health
	current_state = current_state
	points = points

var current_state: PlayerState = PlayerState.IDLE:
	set = change_state


func change_state(new_state):
	print("Current: %s, new: %s" % [current_state, new_state])
	state_label.text = "State: %s"  % str(PlayerState.keys()[new_state])

	current_state = new_state
	
var is_attacking := false
@export var bullet_scene : PackedScene
func attack(attack_direction:Vector2):
	var bullet = bullet_scene.instantiate()
	add_sibling(bullet)
	bullet.global_position = global_position
	bullet.direction = attack_direction
	ammo -= 1
	$AttackTimer.start()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&'debug_hurt'):
		take_damage(1)
	if attack_timer.time_left > 0:
		attack_cd_label.text = "Cooldown: %.2f" % attack_timer.time_left
	else:
		attack_cd_label.text = ""
	match current_state:
		PlayerState.IDLE: _idle_update(delta)
		PlayerState.WALK: _walk_update(delta)
		PlayerState.DEAD: _dead_update(delta)

	var input_attack_direction = Input.get_vector(
		&"attack_left", &"attack_right", &"attack_up", &"attack_down"
	)
	var can_attack :bool = (
		current_state != PlayerState.DEAD and
		input_attack_direction != Vector2.ZERO and
		ammo > 0 and
		$AttackTimer.is_stopped()
	)
	if can_attack:
		attack(input_attack_direction)

func take_damage(value):
	
	if current_state == PlayerState.DEAD:
		return
	
	health -= value
	CameraAgent.add_trauma(value * shake_strength)
	
	if health <= 0:
		current_state = PlayerState.DEAD

func _idle_update(_delta):
	var input_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_direction != Vector2.ZERO:
		current_state = PlayerState.WALK
	
func _dead_update(_delta):
	return

func _walk_update(_delta):
	var input_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	
	if input_direction == Vector2.ZERO:
		current_state = PlayerState.IDLE
		return
	velocity = input_direction * speed
	move_and_slide()
