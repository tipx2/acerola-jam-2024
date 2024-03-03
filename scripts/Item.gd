extends Node2D

signal buy_button_pressed
signal item_mouse_entered
signal item_mouse_exited

@onready var sprite_2d := $Sprite2D as Sprite2D
@onready var color_rect = $ColorRect

const TILT_AMOUNT = 12
const TILT_LERP_SPEED = 10
const LERP_SPEED = 20

var item_ID : int
var item_grids := []
var selected = false
var grid_anchor = null

var moused_on = false

# it's like python __repr__
func _to_string() -> String:
	return str(DataHandler.item_data[str(item_ID)])

func _process(delta : float) -> void:
	var curr_y_rot = sprite_2d.material.get_shader_parameter("y_rot")
	var curr_x_rot = sprite_2d.material.get_shader_parameter("x_rot")
	
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), LERP_SPEED * delta)
	
	if !selected and moused_on:
		var vector_to_mouse = global_position.direction_to(get_global_mouse_position()).normalized() * TILT_AMOUNT
		sprite_2d.material.set_shader_parameter("y_rot", lerp(curr_y_rot, vector_to_mouse.x, TILT_LERP_SPEED * delta))
		sprite_2d.material.set_shader_parameter("x_rot", lerp(curr_x_rot, -vector_to_mouse.y, TILT_LERP_SPEED * delta))
	else:
		sprite_2d.material.set_shader_parameter("y_rot", lerp(curr_y_rot, 0.0, TILT_LERP_SPEED * delta))
		sprite_2d.material.set_shader_parameter("x_rot", lerp(curr_x_rot, 0.0, TILT_LERP_SPEED * delta))

func load_item(a_ItemID : int) -> void:
	item_ID = a_ItemID
	var Icon_path = "res://assets/visuals/inventory/%s.png" %  DataHandler.item_data[str(a_ItemID)]["ImageName"]
	sprite_2d.texture = load(Icon_path)
	
	# scale mouse_over color rect to fit
	var sprite_size = sprite_2d.texture.get_size() * sprite_2d.scale.x
	color_rect.size = sprite_size
	color_rect.position = -sprite_size/2
	
	for grid in DataHandler.item_grid_data[str(a_ItemID)]:
		item_grids.push_back([int(grid[0]), int(grid[1])])

func rotate_item():
	for grid in item_grids:
		var temp_y = grid[0]
		grid[0] = -grid[1]
		grid[1] = temp_y
	rotation_degrees += 90
	if rotation_degrees == 360:
		rotation_degrees = 0

func _snap_to(dest : Vector2):
	var tween = get_tree().create_tween()
	if int(rotation_degrees) % 180 == 0:
		dest += sprite_2d.get_rect().size
	else:
		var temp_xy_switch = Vector2(sprite_2d.get_rect().size.y, sprite_2d.get_rect().size.x)
		dest += temp_xy_switch
	
	tween.tween_property(self, "global_position", dest, 0.2).set_trans(Tween.TRANS_EXPO)
	selected = false


func _on_buy_button_pressed():
	buy_button_pressed.emit()


func _on_mouse_entered():
	item_mouse_entered.emit()
	moused_on = true


func _on_mouse_exited():
	item_mouse_exited.emit()
	moused_on = false

