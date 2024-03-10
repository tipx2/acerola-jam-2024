extends Node
class_name Effect

@onready var item_parent : Node
var item_adjacents : Array

# item.item_type
# item.item_id

var extra_max_hp := 0
var extra_attack_damage := 0
var extra_attack_speed := 0.0
var extra_bullet_speed := 0.0
var extra_move_speed := 0.0
var extra_crit_chance := 0.0

func _enter_tree():
	self.add_to_group("effect")

func _on_player_attack(_bullet : Node):
	pass

func _on_enemy_killed(_e : Node):
	pass

func _on_player_damage(_amount : int):
	pass

func _on_player_heal(_amount : int):
	pass

func _on_coins_gained(_amount : int):
	pass

func _on_item_sold(_item : Node):
	pass

func _on_backpack_compile():
	pass

func _on_other_item_gain_money(_item : Node):
	pass

func _on_level_ended():
	pass

func _on_self_money_gain():
	for item in get_tree().get_nodes_in_group("effect"):
		item._on_other_item_gain_money(item_parent)

func backpack_prepass():
	item_parent = get_parent()
	item_adjacents = get_parent().adjacent_items
