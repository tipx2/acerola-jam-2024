extends Effect

func _on_player_damage(_amount : int):
	var cas_count = 0
	for item in item_adjacents:
		if item.item_type == "Combat":
			cas_count += 1
	
	if randf() <= 0.08 * cas_count:
		Globals.player.heal(1)
