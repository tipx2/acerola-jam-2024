extends Effect

func _on_item_sold(_item : Node):
	Globals.money += 1
	_on_self_money_gain()
