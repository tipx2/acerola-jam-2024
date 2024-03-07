extends Node
class_name Effect

var extra_max_hp := 0
var extra_attack_damage := 0
var extra_attack_speed := 0.0
var extra_move_speed := 0.0
var extra_crit_chance := 0.0

func _enter_tree():
	self.add_to_group("effect")

func _on_player_attack():
	pass

func _on_enemy_killed(e : Node):
	pass

func _on_player_damage(amount : int):
	pass

func _on_coins_gained(amount : int):
	pass

func _on_backpack_compile():
	pass
