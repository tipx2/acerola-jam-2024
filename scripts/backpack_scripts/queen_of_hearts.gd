extends Effect

func _on_player_heal(_amount : int):
	Globals.money += 1
	_on_self_money_gain()
