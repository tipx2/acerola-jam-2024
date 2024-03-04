extends Control

var shop_item_count = 5

@onready var money_label := %money_label as Label

@onready var inventory_db := %InventoryDB as InventoryGrid
@onready var shop_db := %ShopDB as InventoryGrid

var protoset = load("res://assets/gloot/backpack_items.tres") as ItemProtoset
var inv_items = ["ExampleItem", "SuperDuperItem", "Acerola"]

@onready var tooltip := $tooltip as Control
@onready var cost_tooltip = $cost_tooltip as Control

var trans_shop_to_inv = false
var trans_inv_to_shop = false
var trans_snapback = false

func open_shop():
	update_money_label()
	
	# spawn items into shop
	while shop_db.get_item_count() < shop_item_count:
		shop_db.create_and_add_item_at(inv_items.pick_random(), Vector2(randi_range(0, 7), randi_range(0, 7)))

func update_money_label():
	money_label.text = "Cash Money: £%d" % Globals.money

func _physics_process(delta):
	if tooltip.visible:
		tooltip.size = Vector2.ZERO # bit annoying but doesn't seem to work with mouse on/off
		tooltip.global_position = get_global_mouse_position()
		cost_tooltip.global_position = get_global_mouse_position() + Vector2(0, -60)

func mouse_over(item : InventoryItem):
	tooltip.visible = true
	%tooltip_title.text = item.get_title()
	%tooltip_description.text = "[center]%s[/center]" % item.get_property("description", "no description")
	%tooltip_type.text = "[center]Type: %s[/center]" % item.get_property("type", "no type")

func _on_inventory_ctrl_item_mouse_entered(item : InventoryItem):
	mouse_over(item)

func _on_inventory_ctrl_item_mouse_exited(item):
	tooltip.visible = false

func _on_shop_ctrl_item_mouse_entered(item):
	cost_tooltip.visible = true
	%price_label.text = "£%d" % item.get_property("price", 0)
	mouse_over(item)

func _on_shop_ctrl_item_mouse_exited(item):
	tooltip.visible = false
	cost_tooltip.visible = false


func _on_shop_db_item_removed(item):
	trans_shop_to_inv = true

func _on_inventory_db_item_added(item):
	if trans_shop_to_inv:
		trans_shop_to_inv = false
		if Globals.money < item.get_property("price"):
			%money_label.get_node("AnimationPlayer").play("flash")
			trans_snapback = true
			inventory_db.transfer_to(item, shop_db, shop_db.find_free_place(item)["position"])
		else:
			Globals.money -= item.get_property("price")
	
	if trans_inv_to_shop:
		trans_inv_to_shop = false
	update_money_label()

func _on_inventory_db_item_removed(item):
	if !trans_snapback:
		trans_inv_to_shop = true

func _on_shop_db_item_added(item):
	trans_snapback = false
	if trans_inv_to_shop:
		trans_inv_to_shop = false
		Globals.money += item.get_property("price")
	
	if trans_shop_to_inv:
		trans_shop_to_inv = false
	update_money_label()


func _on_inventory_ctrl_inventory_item_context_activated(item):
	item.set_property("rotation", (item.get_property("rotation") + 1)%4)

func _on_shop_ctrl_inventory_item_context_activated(item):
	item.set_property("rotation", (item.get_property("rotation") + 1)%4)
