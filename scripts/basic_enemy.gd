extends CharacterBody2D
class_name BasicEnemy

@export var BASE_SPEED := 150.0
var speed : float

var player : Node2D
@onready var navigation_agent_2d := $NavigationAgent2D

func _ready():
	speed = BASE_SPEED
	player = Globals.player

func _physics_process(_delta) -> void:
	var dir = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	navigation_agent_2d.set_velocity(dir * speed)

func _on_nav_timer_timeout():
	navigation_agent_2d.target_position = player.global_transform.origin


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
