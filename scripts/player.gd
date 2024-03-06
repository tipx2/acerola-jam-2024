extends CharacterBody2D

var bullet_scene : PackedScene = preload("res://scenes/basic_bullet.tscn")

@export var SHOT_TIME := 0.3
@export var BASE_SPEED := 200.0
@export var BASE_BULLET_SPEED := 10.0
@export var BASE_BULLET_SPREAD := 0.05
@export var MAX_HP := 10

var current_hp := MAX_HP
var speed : float
var bullet_speed : float
var bullet_spread : float
var intangible = false

@onready var shotpoint = $shotpoint
@onready var collision_shape_2d = $CollisionShape2D
@onready var hp_debug := $CanvasLayer/hp_debug as Label
@onready var shottimer = $shottimer

func _ready():
	shottimer.wait_time = SHOT_TIME
	hp_debug.text = str(current_hp)
	speed = BASE_SPEED
	bullet_speed = BASE_BULLET_SPEED
	bullet_spread = BASE_BULLET_SPREAD

func _physics_process(_delta):
	if intangible:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * speed
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	move_and_slide()

func shoot():
	if shottimer.time_left > 0:
		return
	
	var bullet_dir := global_transform.origin.direction_to(get_global_mouse_position()) + Vector2(randf_range(-bullet_spread, bullet_spread), randf_range(-bullet_spread, bullet_spread))
	var new_bullet = bullet_scene.instantiate()
	add_child(new_bullet.initialise(bullet_dir, shotpoint.global_transform.origin, bullet_speed))
	new_bullet.set_as_top_level(true)
	
	shottimer.start()

func damage(amount : int):
	# TODO play hurt animation etc. here
	
	# TODO update health bar etc. here
	current_hp -= amount
	
	hp_debug.text = str(current_hp)
	
	if current_hp <= 0:
		die()

func die():
	# TODO do something here
	print("you died 💀💀💀💀💀")

func set_intangible(b : bool):
	intangible = b
	collision_shape_2d.call_deferred("set_disabled", b)
