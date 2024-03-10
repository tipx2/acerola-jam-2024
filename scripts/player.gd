extends CharacterBody2D

signal player_died

var bullet_scene : PackedScene = preload("res://scenes/basic_bullet.tscn")

const BASE_BULLET_SPREAD := 0.05
var extra_bullet_spread := 0.0

const BASE_BULLET_SPEED := 10.0
var extra_bullet_speed := 0.0

const BASE_SPEED := 200.0
var extra_move_speed := 0.0

const SHOT_TIME := 0.3
var extra_attack_speed := 0.0 : set = config_attack_speed

const BASE_BULLET_DAMAGE := 1
var extra_attack_damage := 0

const MAX_HP := 10
var extra_max_hp := 0

var current_hp := MAX_HP
var speed : float
var bullet_speed : float
var bullet_spread : float

var intangible = false
var invunderable = false

var extra_crit_chance := 0.0

@onready var shotpoint = $shotpoint
@onready var collision_shape_2d = $CollisionShape2D
@onready var hp_debug := $CanvasLayer/hp_debug as Label
@onready var shottimer = $shottimer

@onready var canvas_player = $CanvasLayer/AnimationPlayer
@onready var money_value = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/money_value
@onready var hp_bar = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/hp_bar
@onready var health_number = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/health_number

@onready var legsplayer = $legs/legsplayer
@onready var legs = $legs
@onready var inv_flash_player = $inv_flash_player

@onready var damage_sound = $damage_sound
@onready var shot_sound = $shot_sound

func _ready():
	
	shottimer.wait_time = SHOT_TIME / (1.0 + extra_attack_speed)
	
	hp_debug.text = str(current_hp)
	hp_bar.max_value = MAX_HP + extra_max_hp
	hp_bar.value = current_hp
	update_money()
	update_text_hp()
	
	speed = BASE_SPEED
	bullet_speed = BASE_BULLET_SPEED
	bullet_spread = BASE_BULLET_SPREAD


func _physics_process(_delta):
	if intangible:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * speed * (1.0 + extra_move_speed)
	
	if velocity == Vector2.ZERO:
		legsplayer.play("stopped")
	else:
		legsplayer.play("walk")
	
	look_at(get_global_mouse_position())
	#legs.global_rotation_degrees = -rad_to_deg(velocity.angle()) - 90
	
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	move_and_slide()

func shoot():
	if shottimer.time_left > 0:
		return
	
	shot_sound.pitch_scale = randf_range(0.8, 1.3)
	shot_sound.play()
	#print(shottimer.wait_time)
	
	var adjusted_b_spread := bullet_spread * (1.0 + extra_bullet_spread)
	var spread_offset := Vector2(randf_range(-adjusted_b_spread, adjusted_b_spread), randf_range(-adjusted_b_spread, adjusted_b_spread))
	var bullet_dir := global_transform.origin.direction_to(get_global_mouse_position()) + spread_offset
	var new_bullet = bullet_scene.instantiate()
	# print(extra_bullet_speed)
	print(BASE_BULLET_DAMAGE + extra_attack_damage)
	add_child(new_bullet.initialise(bullet_dir, shotpoint.global_transform.origin, bullet_speed * (1.0 + extra_bullet_speed), BASE_BULLET_DAMAGE + extra_attack_damage))
	new_bullet.set_as_top_level(true)
	
	get_tree().call_group("effect", "_on_player_attack", new_bullet)
	
	shottimer.start()

func damage(amount : int):
	
	if invunderable:
		return
	
	# TODO play hurt animation etc. here
	damage_sound.pitch_scale = randf_range(1.0, 1.3)
	damage_sound.play()
	current_hp -= amount
	
	get_tree().call_group("effect", "_on_player_damage", amount)
	
	hp_bar.value = current_hp
	update_text_hp()
	
	hp_debug.text = str(current_hp)
	
	if current_hp <= 0:
		die()
	
	inv_flash_player.play("flash")

func set_invunderable(inv : bool):
	invunderable = inv

func heal(amount : int):
	# TODO play heal animation here
	current_hp += amount
	
	if current_hp + amount > MAX_HP + extra_max_hp:
		get_tree().call_group("effect", "_on_player_heal", MAX_HP + extra_max_hp - current_hp)
		current_hp = MAX_HP + extra_max_hp
	else:
		get_tree().call_group("effect", "_on_player_heal", amount)
	
	hp_bar.value = current_hp
	update_text_hp()


func die():
	player_died.emit()

func set_intangible(b : bool):
	if b:
		legsplayer.play("stopped")
	intangible = b
	collision_shape_2d.call_deferred("set_disabled", b)

func config_attack_speed(e : float):
	# print(e, " ", "config'd at speed")
	extra_attack_speed = e
	shottimer.wait_time = SHOT_TIME / (1.0 + extra_attack_speed)
	

func update_max_hp():
	hp_bar.max_value = MAX_HP + extra_max_hp
	if current_hp > MAX_HP + extra_max_hp:
		current_hp = MAX_HP + extra_max_hp
	update_text_hp()

func update_text_hp():
	health_number.text = str(current_hp) + "/" + str(MAX_HP + extra_max_hp)

func update_money():
	money_value.text = "£%d" % Globals.money

func hud_visible(shown : bool):
	if shown:
		canvas_player.play("fade_in")
	else:
		canvas_player.play("fade_out")
