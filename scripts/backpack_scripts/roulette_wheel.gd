extends Effect

func _on_enemy_killed(_e : Node):
	var adj_cards = 0
	for item in item_adjacents:
		if item.item_type == "Card":
			adj_cards += 1
	
	if randf() <= 0.05:
		Globals.money += 5 * adj_cards
