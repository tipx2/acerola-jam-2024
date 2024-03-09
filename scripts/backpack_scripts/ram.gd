extends Effect

func _on_backpack_compile():
	extra_attack_speed = 0.0
	for item in item_adjacents:
		if item.item_type == "Computer":
			extra_attack_speed += 0.1
		else:
			print(item.item_type)
			extra_attack_speed = 0.0
			return
	
