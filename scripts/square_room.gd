extends Node2D

var borders = Rect2(0, 0, 100, 100)

@onready var tile_map := $TileMap

@onready var navigation_region_2d = $NavigationRegion2D

signal map_generated(tile_list, tile_map)

func _ready():
	generate_level()

func generate_level():
	tile_map.clear()
	var walker := Walker.new(Vector2(19, 11), borders)
	var map := walker.walk(250)
	walker.queue_free()
	tile_map.set_cells_terrain_connect(0, map, 0, 0)
	navigation_region_2d.bake_navigation_polygon(true)
	map_generated.emit(map, tile_map)
