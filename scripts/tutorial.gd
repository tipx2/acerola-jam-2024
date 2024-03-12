extends Control

@onready var tut_image = $PanelContainer/CenterContainer/VBoxContainer/CenterContainer/tut_image
@onready var animation_player = $AnimationPlayer
@onready var exit = $Control/exit
@onready var out_of = $"PanelContainer/CenterContainer/VBoxContainer/HBoxContainer/out of"

@export var tutorials : Array[String]
var current_tut = 0

func _ready():
	if !Globals.show_shop_tutorial:
		queue_free()
	update_tut_image()

func _on_left_pressed():
	current_tut -= 1
	if current_tut < 0:
		current_tut = 0
	update_tut_image()

func _on_right_pressed():
	current_tut += 1
	if current_tut == tutorials.size() - 1:
		exit.visible = true
	elif current_tut == tutorials.size():
		current_tut = tutorials.size() - 1
		
	update_tut_image()

func update_tut_image():
	out_of.text = str(current_tut + 1) + "/" + str(tutorials.size())
	tut_image.texture = load(tutorials[current_tut])

func on_screen():
	animation_player.play("on_screen")

func off_screen():
	animation_player.play("off_screen")


func _on_exit_pressed():
	off_screen()
	await animation_player.animation_finished
	queue_free()
