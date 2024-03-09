extends Effect

func _on_player_damage(_amount : int):
	if randf() <= 0.08:
		Globals.player.heal(1)
