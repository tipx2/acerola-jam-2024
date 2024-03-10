extends BasicEnemy

@onready var shotpoints = $sprite/shotpoints

func _on_shottimer_timeout():
	if dead:
		return
	
	shoot_sound.pitch_scale = randf_range(1.0, 1.3)
	shoot_sound.play()
	#var bullet_dir := global_transform.origin.direction_to(player.global_transform.origin) + Vector2(randf_range(-BULLET_SPREAD, BULLET_SPREAD), randf_range(-BULLET_SPREAD, BULLET_SPREAD))
	
	for point in shotpoints.get_children():
		var new_bullet = bullet_scene.instantiate()
		var bullet_dir = Vector2.RIGHT.rotated(point.global_rotation)
		get_parent().add_child(new_bullet.initialise(bullet_dir, global_transform.origin, BULLET_SPEED))
		new_bullet.set_as_top_level(true)
