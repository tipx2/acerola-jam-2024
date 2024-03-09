extends Effect

func _on_player_damage(_amount : int):
	Globals.money += 1
	_on_self_money_gain()
