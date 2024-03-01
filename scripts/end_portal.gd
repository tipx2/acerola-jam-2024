extends Area2D

signal level_ended

func _on_body_entered(body):
	if body.is_in_group("player"):
		level_ended.emit()
