extends Node2D

var basic_enemy_scene = preload("res://scenes/basic_enemy.tscn")
@onready var square_room = $SquareRoom

var tile_map_ref : TileMap
var tile_list_ref : Array
var player_ref : Node2D
var portal_ref : Node2D

enum {
	LEFT,
	RIGHT,
	BOTTOM,
	TOP
}
# keep this order - enum vars are ints
var round_directions = [LEFT, RIGHT, BOTTOM, TOP]
var corresponding_directions = [RIGHT, LEFT, TOP, BOTTOM]

var debug_names = ["left", "right", "bottom", "top"]

func _on_square_room_map_generated(tile_list, tile_map) -> void:
	tile_map_ref = tile_map
	tile_list_ref = tile_list
	player_ref = Globals.player
	portal_ref = Globals.end_portal
	round_start()

func round_start() -> void:
	# move player
	var round_direction = round_directions.pick_random()
	player_ref.global_position = get_tile_global_pos(get_superlative_tile(round_direction))
	print("round_direction: " + debug_names[round_direction])
	
	# move portal
	var corresponding_direction = corresponding_directions[round_direction]
	portal_ref.global_position = get_tile_global_pos(get_superlative_tile(corresponding_direction))

func get_tile_global_pos(tile : Vector2) -> Vector2:
	return tile_map_ref.to_global(tile_map_ref.map_to_local(tile))

func sort_by_first(a : Vector2, b : Vector2):
	if a.x < b.x:
		return true
	return false

func sort_by_second(a : Vector2, b : Vector2):
	if a.y < b.y:
		return true
	return false

func get_superlative_tile(round_direction):
	var sorted_tile_list := tile_list_ref.duplicate()
	if round_direction == TOP or round_direction == BOTTOM:
		sorted_tile_list.sort_custom(sort_by_second)
		if round_direction == TOP:
			return sorted_tile_list[0]
		elif round_direction == BOTTOM:
			return sorted_tile_list[-1]
	elif round_direction == LEFT or round_direction == RIGHT:
		sorted_tile_list.sort_custom(sort_by_first)
		if round_direction == LEFT:
			return sorted_tile_list[0]
		elif round_direction == RIGHT:
			return sorted_tile_list[-1]

func spawn_enemy_pos_random(enemy_scene : PackedScene) -> void:
	var enemy_instance = enemy_scene.instantiate()
	call_deferred("add_child", enemy_instance)
	enemy_instance.set_as_top_level(true)
	# enemy_instance.global_position = get_random_tile_pos()


func _on_end_portal_level_ended():
	square_room.generate_level()
