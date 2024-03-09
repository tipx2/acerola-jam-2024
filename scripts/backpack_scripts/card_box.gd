extends Effect

func _on_backpack_compile():
	for item in item_adjacents:
		if item.item_type == "Card":
			extra_bullet_speed += 0.05
