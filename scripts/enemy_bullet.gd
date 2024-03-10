extends CharacterBody2D
class_name EnemyBullet

@export var BULLET_DAMAGE := 1
@onready var collision_shape_2d = $CollisionShape2D

var initial_dir : Vector2
var speed : float
var shot = false

func initialise(start_dir : Vector2, start_pos : Vector2, s : float ) -> EnemyBullet:
	self.initial_dir = start_dir
	self.speed = s
	self.global_transform.origin = start_pos
	self.shot = true
	return self

func _physics_process(delta):
	if shot:
		velocity = initial_dir * speed
		
		var col = move_and_collide(velocity)
		
		if col:
			if col.get_collider().is_in_group("player"):
				col.get_collider().damage(BULLET_DAMAGE)
			elif col.get_collider().is_in_group("bullet"):
				return
			collision_shape_2d.disabled = true
			queue_free.call_deferred()
