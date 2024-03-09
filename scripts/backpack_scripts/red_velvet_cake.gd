extends Effect

func _on_backpack_compile():
	extra_max_hp = 0
	for item in item_adjacents:
		if item.item_type == "Combat":
			extra_max_hp += 1
