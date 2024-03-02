extends Node2D

@onready var sprite_2d := $Sprite2D as Sprite2D

const LERP_SPEED = 20

var item_ID : int
var item_grids := []
var selected = false
var grid_anchor = null

# it's like python __repr__
func _to_string() -> String:
	return str(DataHandler.item_data[str(item_ID)])

func _process(delta : float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), LERP_SPEED * delta)

func load_item(a_ItemID : int) -> void:
	item_ID = a_ItemID
	var Icon_path = "res://assets/visuals/inventory/%s.png" %  DataHandler.item_data[str(a_ItemID)]["ImageName"]
	sprite_2d.texture = load(Icon_path)
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
