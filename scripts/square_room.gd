extends Node2D

var tile_textures = [load("res://assets/visuals/tileset_grey.png"), load("res://assets/visuals/tileset_red.png"), load("res://assets/visuals/tileset_blue.png"), load("res://assets/visuals/tileset_green.png"), load("res://assets/visuals/tileset_pink.png"), load("res://assets/visuals/tileset_purple.png"), load("res://assets/visuals/tileset_yellow.png"), load("res://assets/visuals/tileset_black.png")]
var back_colors = [Color("#271f1b"), Color("#290501"), Color("1b2447"), Color("27412d"), Color("e27285"), Color("494182"), Color("f8f644"), Color("#000000")]
# grey, red, blue, green, pink, purple, yellow, black

var borders = Rect2(0, 0, 100, 100)

@onready var bg = $Sprite2D
@onready var tile_map := $TileMap
@onready var navigation_region_2d = $NavigationRegion2D

signal map_generated(tile_list, tile_map)

func generate_level(steps : int):
	tile_map.clear()
	var walker := Walker.new(Vector2(19, 11), borders)
	var map := walker.walk(steps)
	walker.queue_free()
	tile_map.set_cells_terrain_connect(0, map, 0, 0)
	navigation_region_2d.bake_navigation_polygon(true)
	map_generated.emit(map, tile_map)

func set_tilemap(level_num : int):
	# var r = randi_range(0, tile_textures.size()-1)
	tile_map.tile_set.get_source(1).texture = tile_textures[level_num-1]
	bg.self_modulate = back_colors[level_num-1]
