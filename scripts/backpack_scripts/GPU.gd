extends Effect

func _on_backpack_compile():
	for item in item_adjacents:
		if item.item_type == "Computer":
			extra_attack_speed += 0.05
			# TODO: TEST THIS!!
