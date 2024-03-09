extends Effect

const COUNTDOWN_MAX = 15
const REWARD = 20
var countdown = COUNTDOWN_MAX

func _on_enemy_killed(_e : Node):
	countdown -= 1
	if countdown <= 0:
		Globals.money += REWARD
		_on_self_money_gain()
		countdown = COUNTDOWN_MAX
