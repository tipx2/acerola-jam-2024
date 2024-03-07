extends Node

var current_floor = 0
var money = 10: set = _on_money_changed

@onready var player := get_tree().get_first_node_in_group("player")
@onready var end_portal := get_tree().get_first_node_in_group("end_portal")

func _on_money_changed(m):
	player.update_money()
	get_tree().call_group("enemy", "_on_coins_gained", m - money) # provides the difference
	money = m
