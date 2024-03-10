extends Effect

func _on_level_ended():
	print(Globals.level_time)
	if Globals.level_time <= 30.0:
		Globals.player.heal(Globals.player.MAX_HP + Globals.player.extra_max_hp)
