extends Node2D

func _on_square_room_map_generated(tile_list, tile_map):
	var r_tile = tile_list.pick_random()
	$player.global_transform.origin = tile_map.to_global(tile_map.map_to_local(r_tile))
