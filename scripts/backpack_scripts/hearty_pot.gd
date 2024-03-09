extends Effect

func _on_player_damage(_amount : int):
	var heal_for = 0
	
	for item in item_adjacents:
		if item.item_type == "Food":
			heal_for += 1
	
	Globals.player.heal(heal_for)
