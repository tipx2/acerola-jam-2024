extends Effect

func _on_backpack_compile():
	extra_bullet_speed = 0.0
	for item in item_adjacents:
		if item.item_type == "Card":
			extra_bullet_speed += 0.05
