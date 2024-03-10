extends Node

var current_floor = 0
var money = 10: set = _on_money_changed

var resetting := false

var player
var end_portal
var shop
var inventory
var world

func start_again():
	load("res://data/tileset.tres").get_source(1).texture = load("res://assets/visuals/tileset_4.png")
	get_tree().change_scene_to_file.call_deferred("res://scenes/world.tscn")
	
	await get_tree().create_timer(0.05).timeout
	
	resetting = true
	money = 10
	world = get_tree().get_first_node_in_group("world")
	player = get_tree().get_first_node_in_group("player")
	end_portal = get_tree().get_first_node_in_group("end_portal")
	shop = get_tree().get_first_node_in_group("shop")
	inventory = get_tree().get_first_node_in_group("inventory")
	resetting = false
	
	
	world.square_room.generate_level(world.step_count)

var level_time := 0.0

func _on_money_changed(m):
	if resetting:
		return
	get_tree().call_group("effect", "_on_coins_gained", m - money) # provides the difference
	money = m
	player.update_money()
	shop.update_money_label()
