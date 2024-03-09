extends Effect

func _on_other_item_gain_money(_item : Node):
	# print(_item, " ", item_adjacents)
	if _item in item_adjacents:
		Globals.money += 5
