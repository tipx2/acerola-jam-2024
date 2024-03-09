extends Effect

func _on_backpack_compile():
	for item in item_adjacents:
		if item.item_type == "Casino":
			extra_attack_damage += 1
			return
