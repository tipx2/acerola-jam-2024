extends CharacterBody2D

var bullet_scene : PackedScene = preload("res://scenes/basic_bullet.tscn")

const BASE_BULLET_SPREAD := 0.05
var extra_bullet_spread := 0.0

const BASE_BULLET_SPEED := 10.0
var extra_bullet_speed := 0.0

const BASE_SPEED := 200.0
var extra_move_speed := 0.0

const SHOT_TIME := 0.3
var extra_attack_speed := 0.0

const BASE_BULLET_DAMAGE := 1
var extra_attack_damage := 0

const MAX_HP := 10
var extra_max_hp := 0

var current_hp := MAX_HP
var speed : float
var bullet_speed : float
var bullet_spread : float
var intangible = false


var extra_crit_chance := 0.0

@onready var shotpoint = $shotpoint
@onready var collision_shape_2d = $CollisionShape2D
@onready var hp_debug := $CanvasLayer/hp_debug as Label
@onready var shottimer = $shottimer

@onready var canvas_player = $CanvasLayer/AnimationPlayer
@onready var money_value = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/money_value
@onready var hp_bar = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/hp_bar
@onready var health_number = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/health_number

func _ready():
	shottimer.wait_time = SHOT_TIME / (1.0 + extra_attack_speed)
	
	hp_debug.text = str(current_hp)
	hp_bar.max_value = MAX_HP + extra_max_hp
	hp_bar.value = current_hp
	update_money()
	
	speed = BASE_SPEED
	bullet_speed = BASE_BULLET_SPEED
	bullet_spread = BASE_BULLET_SPREAD


func _physics_process(_delta):
	if intangible:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * speed * (1.0 + extra_move_speed)
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	move_and_slide()

func shoot():
	if shottimer.time_left > 0:
		return
	
	var adjusted_b_spread := bullet_spread * (1.0 * extra_bullet_spread)
	var spread_offset := Vector2(randf_range(-adjusted_b_spread, adjusted_b_spread), randf_range(-adjusted_b_spread, adjusted_b_spread))
	var bullet_dir := global_transform.origin.direction_to(get_global_mouse_position()) + spread_offset
	var new_bullet = bullet_scene.instantiate()
	add_child(new_bullet.initialise(bullet_dir, shotpoint.global_transform.origin, bullet_speed * (1.0 + extra_bullet_speed), BASE_BULLET_DAMAGE + extra_attack_damage))
	new_bullet.set_as_top_level(true)
	
	shottimer.start()

func damage(amount : int):
	# TODO play hurt animation etc. here
	
	# TODO update health bar etc. here
	current_hp -= amount
	
	get_tree().call_group("effect", "_on_player_damage", amount)
	
	hp_bar.value = current_hp
	update_text_hp()
	
	hp_debug.text = str(current_hp)
	
	if current_hp <= 0:
		die()

func die():
	# TODO do something here
	print("you died 💀💀💀💀💀")

func set_intangible(b : bool):
	intangible = b
	collision_shape_2d.call_deferred("set_disabled", b)

func initialise_static_buffs():
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
