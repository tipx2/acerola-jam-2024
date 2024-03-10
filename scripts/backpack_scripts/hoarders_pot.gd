extends Effect

func _on_enemy_killed(_e : Node):
	if Globals.money >= 50:
		Globals.player.heal(1)
