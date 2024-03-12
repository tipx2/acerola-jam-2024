extends CharacterBody2D
class_name BasicEnemy

signal enemy_died(e)

@export var reward = 4

@export var MAX_HP := 5
var additional_max_hp = 0

@export var BULLET_SPREAD := 0.3
@export var BULLET_SPEED := 2.0
@export var DESIRED_DISTANCE := 200.0
@export var BASE_SPEED := 150.0
@export var ATTACK_SPEED := 0.3
var speed : float

var intangible := false
var can_see_player := false
var saw_player := false

var player : Node2D
@onready var navigation_agent_2d := $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D

@onready var raycast_view = $RaycastView
@onready var shottimer = $shottimer
@onready var healthbar = $healthbar
@onready var sprite_2d = $sprite

@onready var tank_break = $tank_break
@onready var shoot_sound = $shoot


var dead = false
var bullet_scene = preload("res://scenes/enemy_bullet.tscn")
var current_hp : int

func _ready():
	healthbar.max_value = MAX_HP + additional_max_hp
	
	current_hp = MAX_HP + additional_max_hp
	healthbar.value = current_hp
	
	shottimer.wait_time = ATTACK_SPEED
	speed = BASE_SPEED
	player = Globals.player

func _physics_process(_delta) -> void:
	raycast_view.target_position = raycast_view.to_local(player.global_position)
	
	if raycast_view.is_colliding() and raycast_view.get_collider():
		can_see_player = raycast_view.get_collider().is_in_group("player")
		if can_see_player:
			saw_player = true
	
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	navigation_agent_2d.set_velocity(dir * speed)
	
	if !dead and saw_player:
		sprite_2d.look_at(player.global_position)

func shoot():
	if shottimer.time_left > 0:
		return
	
	shottimer.start()

func _on_shottimer_timeout():
	if dead:
		return
	
	shoot_sound.pitch_scale = randf_range(1.0, 1.3)
	shoot_sound.play()
	var bullet_dir := global_transform.origin.direction_to(player.global_transform.origin) + Vector2(randf_range(-BULLET_SPREAD, BULLET_SPREAD), randf_range(-BULLET_SPREAD, BULLET_SPREAD))
	var new_bullet = bullet_scene.instantiate()
	get_parent().add_child(new_bullet.initialise(bullet_dir, global_transform.origin, BULLET_SPEED))
	new_bullet.set_as_top_level(true)

func _on_nav_timer_timeout():
	navigation_agent_2d.target_position = player.global_transform.origin

func set_health(additional : int):
	additional_max_hp = additional

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	# this is like an extension of _physics_process
	velocity = safe_velocity
	# move if we aren't close enough or can't see the guy
	if !intangible and saw_player:
		if (!can_see_player or global_position.distance_to(player.global_position) > DESIRED_DISTANCE):
			move_and_slide()
		else: # otherwise shoot the guy
			shoot()

func damage(amount : int):
	if dead:
		return
	current_hp -= amount
	healthbar.value = current_hp
	
	if current_hp <= 0:
		die()

func die():
	dead = true
	raycast_view.enabled = false
	enemy_died.emit(self)
	tank_break.play()
	await tank_break.finished
	queue_free()

func set_intangible(b : bool):
	intangible = true
	collision_shape_2d.call_deferred("set_disabled", b)
