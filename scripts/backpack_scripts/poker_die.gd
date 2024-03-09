extends Effect

func _on_player_damage(_amount : int):
	if randf() <= 0.1:
		Globals.money += 1
		_on_self_money_gain()

func _on_player_heal(_amount : int):
	if randf() <= 0.1:
		Globals.money += 1
		_on_self_money_gain()

func _on_item_sold(_item : Node):
	if randf() <= 0.1:
		Globals.money += 1
		_on_self_money_gain()
