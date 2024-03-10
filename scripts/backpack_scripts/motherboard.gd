extends Effect

func _on_backpack_compile():
	var item_adj_ids := []
	for item in item_adjacents:
		item_adj_ids.append(item.item_ID)
	
	if 20 in item_adj_ids and 21 in item_adj_ids and 22 in item_adj_ids:
		extra_attack_speed = 1.0
	else:
		extra_attack_speed = 0.0
