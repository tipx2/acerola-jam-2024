extends CharacterBody2D

signal spinbar_broken
@export var SPINBAR_DAMAGE = 2

func _physics_process(delta):
	var col = move_and_collide(Vector2.ZERO)
	if col:
		if col.get_collider().is_in_group("player"):
			col.get_collider().damage(SPINBAR_DAMAGE)
			spinbar_broken.emit()
			queue_free.call_deferred()
