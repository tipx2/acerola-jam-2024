extends Node2D

var borders = Rect2(0, 0, 100, 100)

@onready var tile_map := $TileMap
var tile_list : Array

signal map_generated(tile_list, tile_map)

func _ready():
	tile_list = generate_level()
	map_generated.emit(tile_list, tile_map)
	# $Camera2D.position = tile_map.to_global(tile_map.map_to_local(r_tile))

func generate_level():
	var walker := Walker.new(Vector2(19, 11), borders)
	var map := walker.walk(500)
	walker.queue_free()
	tile_map.set_cells_terrain_connect(0, map, 0, 0)
	return map
