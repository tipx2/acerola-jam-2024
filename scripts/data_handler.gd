extends Node

var item_data := {}
var item_grid_data := {}
var item_adj_grid_data := {}

@onready var item_data_path = "res://data/backpack_items.json"

func _ready() -> void:
	load_data(item_data_path)
	set_grid_data()
	set_adj_grid_data()

func load_data(a_path) -> void:
	if not FileAccess.file_exists(a_path):
		print("item data file not found")
	var item_data_file = FileAccess.open(a_path, FileAccess.READ)
	item_data = JSON.parse_string(item_data_file.get_as_text())["Sheet1"]
	item_data_file.close()
	# print(item_data)

func set_grid_data():
	for item in item_data.keys():
		var temp_grid_array := []
		for point in item_data[item]["Grid"].split("/"):
			temp_grid_array.push_back(point.split(","))
		item_grid_data[item] = temp_grid_array
	# print(item_grid_data)

func set_adj_grid_data():
	for item in item_data.keys():
		if item_data[item]["Adj_grid"] == "":
			item_adj_grid_data[item] = []
			continue
		var temp_grid_array := []
		for point in item_data[item]["Adj_grid"].split("/"):
			temp_grid_array.push_back(point.split(","))
		item_adj_grid_data[item] = temp_grid_array
