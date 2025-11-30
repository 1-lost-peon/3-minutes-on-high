@icon("uid://bk3qswx4ngrin")
class_name Player extends CharacterBody2D

signal died

enum PlayerState {
	IDLE,
	WALK,
	DEAD
}
enum AmmoType {
	RED,
	PURPLE,
	GREEN,
	BLUE
}

@export var hp_drain_interval: float = 1.25
var _hp_drain_timer: float = 0.0
@export var max_hp : int = 180
const MAX_AMMO := 30
@export var ammo: Array[AmmoType] = [
	Player.AmmoType.GREEN,
	Player.AmmoType.GREEN,
	Player.AmmoType.GREEN,
	Player.AmmoType.GREEN,
	Player.AmmoType.GREEN
	]
@export var bullet_scene : PackedScene
@export var points: int = 5
@export_range(1, 1000, 0.1)  var speed : float 
@export_range(0.0, 1.0) var shake_strength : float = 0.2

@onready var state_label: Label = $Container/StateLabel
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_cd_label: Label = $Container/AttackCDLabel
@onready var ammo_label: Label = $Container/AmmoLabel
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_sfx = $DeathSfx
@onready var injured_sfx = $InjuredSfx

@onready var hp : int = self.max_hp

func _ready() -> void:
	ammo = ammo
	max_hp = max_hp
	current_state = current_state
	points = points

var current_state: PlayerState = PlayerState.IDLE:
	set = change_state


func change_state(new_state):
	#print("Current: %s, new: %s" % [current_state, new_state])
	state_label.text = "State: %s"  % str(PlayerState.keys()[new_state])
	
	current_state = new_state

func attack(attack_direction:Vector2):
	var bullet = bullet_scene.instantiate()
	add_sibling(bullet)
	bullet.global_position = global_position
	bullet.direction = attack_direction
	ammo.pop_back()
	attack_timer.start()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&'debug_hurt'):
		take_damage(1)
		
	var string_ammo = []
	for a in ammo:
		string_ammo.append(AmmoType.keys()[a])
	ammo_label.text = str(string_ammo)
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
		len(ammo) > 0 and
		attack_timer.is_stopped()
	)
	if can_attack:
		attack(input_attack_direction)

func take_damage(value):
	injured_sfx.play()
	animated_sprite_2d.play("hurt_front")
	if current_state == PlayerState.DEAD:
		return
	
	hp -= value
	CameraAgent.add_trauma(value * shake_strength)
	
	if hp <= 0:
		current_state = PlayerState.DEAD

func _idle_update(_delta):
	animated_sprite_2d.play("idle_front")
	var input_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_direction != Vector2.ZERO:
		current_state = PlayerState.WALK
	
func _dead_update(_delta):
	animated_sprite_2d.play("death")
	$CollisionShape2D.disabled = true
	await animated_sprite_2d.animation_finished
	await death_sfx.play()
	died.emit()
	#queue_free()

func _walk_update(_delta):
	animated_sprite_2d.play("walk_front")
	var input_direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	
	if input_direction == Vector2.ZERO:
		current_state = PlayerState.IDLE
		return
	velocity = input_direction * speed
	move_and_slide()

func fill_ammo_full() -> void:
	ammo.clear()
	for i in range(MAX_AMMO):
		ammo.append(Player.AmmoType.GREEN)

func reset_hp() -> void:
	hp = max_hp

func _on_health_drain_timer_timeout():
	hp -= 1
