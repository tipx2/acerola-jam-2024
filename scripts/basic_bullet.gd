extends CharacterBody2D
class_name BasicBullet

var damage_number = preload("res://scenes/damage_number.tscn")

var BULLET_DAMAGE := 1
var initial_dir : Vector2
var speed : float

var moving = true
@onready var collision_shape_2d = $CollisionShape2D

func initialise(start_dir : Vector2, start_pos : Vector2, s : float, damage : int ) -> BasicBullet:
	self.initial_dir = start_dir
	self.speed = s
	self.BULLET_DAMAGE = damage
	self.global_transform.origin = start_pos
	return self

func _physics_process(_delta):
	if moving:
		velocity = initial_dir.normalized() * speed
		
		var col = move_and_collide(velocity)
		
		if col:
			if col.get_collider().is_in_group("enemy"):
				col.get_collider().damage(BULLET_DAMAGE)
				
				var d = damage_number.instantiate()
				get_parent().get_parent().add_child(d)
				d.set_number(BULLET_DAMAGE)
				d.global_position = global_position
				# d.set_as_top_level(true)
			
			moving = false
			collision_shape_2d.disabled = true
			queue_free.call_deferred()
