extends Control

const TILT_AMOUNT = 12
const TILT_LERP_SPEED = 10

var logo_moused_on = false

@onready var logo = $logo
@onready var options = $options

func _on_play_pressed():
	%transition_animation.play("cover")
	await %transition_animation.animation_finished
	Globals.start_again()

func _on_options_pressed():
	options.visible = true

func _process(delta):
	var curr_y_rot = logo.material.get_shader_parameter("y_rot")
	var curr_x_rot = logo.material.get_shader_parameter("x_rot")
	if logo_moused_on:
		logo.material.set_shader_parameter("y_rot", lerp(curr_y_rot, 13.923, TILT_LERP_SPEED * delta))
		logo.material.set_shader_parameter("x_rot", lerp(curr_x_rot, -6.105, TILT_LERP_SPEED * delta))
	else:
		logo.material.set_shader_parameter("y_rot", lerp(curr_y_rot, 0.0, TILT_LERP_SPEED * delta))
		logo.material.set_shader_parameter("x_rot", lerp(curr_x_rot, 0.0, TILT_LERP_SPEED * delta))

func _on_texture_rect_mouse_entered():
	logo_moused_on = true


func _on_texture_rect_mouse_exited():
	logo_moused_on = false


func _on_option_back_pressed():
	options.visible = false


func _on_music_2_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value))

func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear_to_db(value))
