extends CharacterBody2D
class_name BasicBullet

var initial_dir : Vector2
var speed : float

var moving = true

func initialise(start_dir : Vector2, start_pos : Vector2, s : float ) -> BasicBullet:
	self.initial_dir = start_dir
	self.speed = s
	self.global_transform.origin = start_pos
	return self

func _physics_process(_delta):
	if moving:
		velocity = initial_dir.normalized() * speed
		
		var col = move_and_collide(velocity)
		
		if col:
			print(col.get_collider())
			moving = false
			queue_free()
