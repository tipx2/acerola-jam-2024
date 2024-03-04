extends Node

var current_floor = 0
var money = 100000

@onready var player := get_tree().get_first_node_in_group("player")
@onready var end_portal := get_tree().get_first_node_in_group("end_portal")
