extends TextureRect

@onready var inventory = $"../Inventory"
@onready var tooltip = $tooltip
@onready var cost_tooltip = $cost_tooltip
@onready var item_scene = preload("res://scenes/item.tscn")
@onready var money_label = $MoneyLabel

@onready var margin_container = $MarginContainer
@onready var shop_container = $MarginContainer/HBoxContainer/ShopContainer

var held_items := {}

func _ready():
	update_money_label()
	load_items()


func _process(delta):
	if tooltip.visible:
		tooltip.global_position = lerp(tooltip.global_position, get_global_mouse_position(), 20 * delta)
		cost_tooltip.global_position = lerp(cost_tooltip.global_position, get_global_mouse_position() + Vector2(0, -64), 20 * delta)
		if !margin_container.get_global_rect().has_point(get_global_mouse_position()):
			tooltip.visible = false

func load_items():
	var slot_n = 0
	for shop_slot in shop_container.get_children():
		var new_item = item_scene.instantiate()
		shop_slot.get_node("Control").add_child(new_item)
		var item_held_id = randi_range(1, 6)
		new_item.load_item(item_held_id)
		held_items[str(slot_n)] = item_held_id
		slot_n += 1

func _on_slot_mouse_entered(s):
	if !inventory.item_held:
		tooltip.visible = true
		cost_tooltip.visible = true
		
		var item_held_id = held_items[str(s.get_index())]
		var tooltip_info = DataHandler.item_data[str(item_held_id)]
		
		tooltip.set_title(tooltip_info["DisplayName"])
		tooltip.set_description(tooltip_info["Description"])
		tooltip.set_type(tooltip_info["Type"])
		
		cost_tooltip.set_price(int(tooltip_info["Buy_price"]))

func _on_slot_mouse_exited():
	tooltip.visible = false
	cost_tooltip.visible = false

func buy_button_pressed(s):
	var item_held_id = held_items[str(s.get_index())]
	var tooltip_info = DataHandler.item_data[str(item_held_id)]
	if Globals.money < tooltip_info["Buy_price"]:
		money_label.get_node("AnimationPlayer").play("flash")
	else:
		if inventory.hold_new_item(item_held_id):
			Globals.money -= tooltip_info["Buy_price"]
	update_money_label()


func update_money_label():
	money_label.text = "[center][wave amp=20.0 freq=5.0 connected=0]Cash Money: £%d[/wave][/center]" % Globals.money
