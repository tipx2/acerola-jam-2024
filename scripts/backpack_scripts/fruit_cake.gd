extends Effect

func _on_backpack_compile():
	extra_max_hp = 0
	for item in item_adjacents:
		if item.item_type == "Food":
			extra_max_hp += 1
