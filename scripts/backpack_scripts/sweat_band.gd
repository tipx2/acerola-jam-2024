extends Effect

func _on_backpack_compile():
	extra_attack_damage = 0
	
	var items := []
	for slot in Globals.inventory.grid_array:
		var i = slot.item_stored
		if i and i not in items:
			items.append(i)
	
	if len(items) <= 3:
		extra_attack_damage = 3
