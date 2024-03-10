extends Node

var current_floor = 0
var money = 1000: set = _on_money_changed

@onready var player := get_tree().get_first_node_in_group("player")
@onready var end_portal := get_tree().get_first_node_in_group("end_portal")
@onready var shop := get_tree().get_first_node_in_group("shop")
@onready var inventory := get_tree().get_first_node_in_group("inventory")

var level_time := 0.0

func _on_money_changed(m):
	get_tree().call_group("enemy", "_on_coins_gained", m - money) # provides the difference
	money = m
	player.update_money()
	shop.update_money_label()
