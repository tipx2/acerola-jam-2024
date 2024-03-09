extends Effect

const REWARD = 5

func _on_enemy_killed(_e : Node):
	var adj_cards = 0
	for item in item_adjacents:
		if item.item_type == "Card":
			adj_cards += 1
	
	if randf() <= 0.05 * adj_cards:
		Globals.money += REWARD
		_on_self_money_gain()
