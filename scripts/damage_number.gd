extends Node2D

@onready var label = $holder/Label
@onready var animation_player = $AnimationPlayer

func set_number(n : int):
	label.text = str(n)

func _ready():
	animation_player.play("float")
	await animation_player.animation_finished
	queue_free.call_deferred()
