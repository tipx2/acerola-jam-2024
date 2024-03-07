extends Effect

func _on_backpack_compile():
	extra_max_hp = 0
	if !item_adjacents:
		return
	for item in item_adjacents:
		if item.item_type == "Fighting":
			extra_max_hp += 1
