extends Effect

func _on_backpack_compile():
	for item in item_adjacents:
		match item.item_type:
			"Food":
				continue
			_:
				extra_attack_damage = 0
				return
	extra_attack_damage = 3
