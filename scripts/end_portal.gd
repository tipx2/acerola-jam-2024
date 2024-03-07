extends Area2D

signal level_ended

var enabled = false

func _on_body_entered(body):
	if enabled and body.is_in_group("player"):
		level_ended.emit()
