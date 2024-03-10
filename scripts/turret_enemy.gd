extends StaticBody2D
class_name TurretEnemy
signal enemy_died(e)

@export var reward = 2
@export var MAX_HP := 5
var additional_max_hp = 0
var current_hp : int

var intangible := false

var player : Node2D
@onready var healthbar = $healthbar
@onready var collision_shape_2d = $CollisionShape2D
@onready var new_spinbar = $new_spinbar
@onready var flash_player = $flash_player

@onready var hit_sound = $hit_sound
@onready var turret_die = $turret_die

@onready var current_bar = $spinbar
var spinbar_up = true

var spinbar_scene := preload("res://scenes/spinbar.tscn")

var dead = false

func _ready():
	healthbar.max_value = MAX_HP + additional_max_hp
	
	current_hp = MAX_HP + additional_max_hp
	healthbar.value = current_hp
	
	player = Globals.player

func set_health(additional : int):
	additional_max_hp = additional

func damage(amount : int):
	if dead:
		return
	current_hp -= amount
	healthbar.value = current_hp
	
	if current_hp <= 0:
		dead = true
		die()

func die():
	if spinbar_up:
		current_bar.queue_free()
	turret_die.pitch_scale *= randf_range(0.7, 1.059463)
	turret_die.play()
	await turret_die.finished
	enemy_died.emit(self)
	queue_free()

func set_intangible(b : bool):
	intangible = true
	collision_shape_2d.call_deferred("set_disabled", b)

func _on_spinbar_spinbar_broken():
	spinbar_up = false
	hit_sound.play()
	new_spinbar.start()

func _on_new_spinbar_timeout():
	flash_player.play("flash")
	await flash_player.animation_finished
	var new_bar = spinbar_scene.instantiate()
	add_child(new_bar)
	new_bar.spinbar_broken.connect(_on_spinbar_spinbar_broken)
	current_bar = new_bar
	spinbar_up = true
