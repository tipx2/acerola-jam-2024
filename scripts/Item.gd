extends Node2D

signal buy_button_pressed
signal item_mouse_entered
signal item_mouse_exited

@onready var sprite_2d := $Sprite2D as Sprite2D
@onready var aberration_particles = $GPUParticles2D

@onready var color_rect = $ColorRect
@onready var grid_container = $Grids/GridContainer
@onready var effect_holder = $effect_holder
@onready var stars_animation = $stars_holder/AnimationPlayer
@onready var stars_holder = $stars_holder

const TILT_AMOUNT = 12
const TILT_LERP_SPEED = 10
const LERP_SPEED = 20

var adj_visual := preload("res://scenes/adj_visual_square.tscn")

var item_ID : int
var item_type : String
var stars_config : String

var item_grids := []
var item_adj_grids := []
var selected = false
var grid_anchor = null
var sprite_size : Vector2

var moused_on = false
var showing_stars = false
var in_shop = true
var aberrated = false

var adjacent_items := []

# it's like python __repr__
func _to_string() -> String:
	return str(DataHandler.item_data[str(item_ID)])

func _process(delta : float) -> void:
	
	var curr_y_rot = sprite_2d.material.get_shader_parameter("y_rot")
	var curr_x_rot = sprite_2d.material.get_shader_parameter("x_rot")
	
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), LERP_SPEED * delta)
		if !showing_stars:
			stars_animation.play("fade_in")
			showing_stars = true
	
	if !selected and moused_on:
		var vector_to_mouse = get_corrected_tilt_target(global_position.direction_to(get_global_mouse_position()).normalized() * TILT_AMOUNT)
		sprite_2d.material.set_shader_parameter("y_rot", lerp(curr_y_rot, vector_to_mouse.x, TILT_LERP_SPEED * delta))
		sprite_2d.material.set_shader_parameter("x_rot", lerp(curr_x_rot, -vector_to_mouse.y, TILT_LERP_SPEED * delta))
		if !showing_stars:
			stars_animation.play("fade_in")
			showing_stars = true
	else:
		sprite_2d.material.set_shader_parameter("y_rot", lerp(curr_y_rot, 0.0, TILT_LERP_SPEED * delta))
		sprite_2d.material.set_shader_parameter("x_rot", lerp(curr_x_rot, 0.0, TILT_LERP_SPEED * delta))
		if showing_stars:
			stars_animation.play("fade_out")
			showing_stars = false

func load_item(a_ItemID : int) -> void:
	item_ID = a_ItemID
	item_type = DataHandler.item_data[str(a_ItemID)]["Type"]
	var Icon_path = "res://assets/visuals/backpack_inventory/%s" %  DataHandler.item_data[str(a_ItemID)]["ImageName"]
	if FileAccess.file_exists(Icon_path):
		sprite_2d.texture = load(Icon_path)
	else:
		push_error("Image not found for item " + DataHandler.item_data[str(a_ItemID)]["DisplayName"])
	
	# scale mouse_over color rect to fit
	sprite_size = sprite_2d.texture.get_size() * sprite_2d.scale.x
	color_rect.size = sprite_size
	color_rect.position = -sprite_size/2
	
	aberration_particles.process_material.emission_shape_scale = Vector3(sprite_size.x, sprite_size.y, 0)/4
	
	for grid in DataHandler.item_grid_data[str(a_ItemID)]:
		var inted_x = int(grid[0])
		var inted_y = int(grid[1])
		item_grids.push_back([inted_x, inted_y])
	
	for grid in DataHandler.item_adj_grid_data[str(a_ItemID)]:
		var inted_x = int(grid[0])
		var inted_y = int(grid[1])
		item_adj_grids.push_back([inted_x, inted_y])
	
	
	# hide all first
	for config in stars_holder.get_children():
		if config is AnimationPlayer:
			continue
		config.visible = false
	
	stars_config = DataHandler.item_data[str(a_ItemID)]["Stars_config"]
	stars_holder.get_node(stars_config).visible = true
	
	var script_path = "res://scripts/backpack_scripts/%s" % DataHandler.item_data[str(a_ItemID)]["Script_path"]
	if FileAccess.file_exists(script_path):
		effect_holder.set_script(load(script_path))
	else:
		push_error("Script not found for item " + DataHandler.item_data[str(a_ItemID)]["DisplayName"])

func rotate_item():
	for grid in item_grids:
		var temp_y = grid[0]
		grid[0] = -grid[1]
		grid[1] = temp_y
		
	for grid in item_adj_grids:
		var temp_y = grid[0]
		grid[0] = -grid[1]
		grid[1] = temp_y
		
	rotation_degrees += 90
	if rotation_degrees == 360:
		rotation_degrees = 0

# probably an easy elegent maths way of doing this...
func get_corrected_tilt_target(vector_to_mouse : Vector2) -> Vector2:
	if rotation_degrees == 90 or rotation_degrees == 270:
		var tempx = vector_to_mouse.x
		vector_to_mouse.x = vector_to_mouse.y
		vector_to_mouse.y = tempx
		if rotation_degrees == 90:
			vector_to_mouse.y = -vector_to_mouse.y
		elif rotation_degrees == 270:
			vector_to_mouse.x = -vector_to_mouse.x
	elif rotation_degrees == 180:
		vector_to_mouse.x = -vector_to_mouse.x
		vector_to_mouse.y = -vector_to_mouse.y
	
	return vector_to_mouse

func _snap_to(dest : Vector2):
	var tween = get_tree().create_tween()
	if int(rotation_degrees) % 180 == 0:
		dest += sprite_2d.get_rect().size
	else:
		var temp_xy_switch = Vector2(sprite_2d.get_rect().size.y, sprite_2d.get_rect().size.x)
		dest += temp_xy_switch
	
	tween.tween_property(self, "global_position", dest, 0.2).set_trans(Tween.TRANS_EXPO)
	selected = false

func update_adjacent_items(items : Array):
	adjacent_items = []
	# eliminating dupes
	for item in items:
		if not adjacent_items.has(item):
			adjacent_items.push_back(item)
	# print(adjacent_items)

func set_aberrated(shown : bool):
	aberrated = shown
	aberration_particles.emitting = true

func _on_buy_button_pressed():
	buy_button_pressed.emit()


func _on_mouse_entered():
	item_mouse_entered.emit()
	moused_on = true


func _on_mouse_exited():
	item_mouse_exited.emit()
	moused_on = false
