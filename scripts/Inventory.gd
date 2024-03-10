extends Control

@onready var slot_scene = preload("res://scenes/slot.tscn")
@onready var grid_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://scenes/item.tscn")
@onready var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer
@onready var column_count = grid_container.columns
@onready var shop = $"../Shop"

@onready var tooltip = $tooltip
@onready var cost_tooltip = $cost_tooltip

var grid_array := []
var items_slots_held := []

var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

var in_round = true
var slot_cost = 10

func _ready():
	for i in range(49):
		# locks: left column, right column, first two rows, last two rows
		create_slot(!(i % 7 && (i+1) % 7) || i < 14 || i > 35)
	get_tree().call_group("inv_slot", "update_money_label", slot_cost)
	clear_grid()

func _process(delta):
	if item_held:
		if Input.is_action_just_pressed("mouse_right_click"):
			rotate_item()
		if Input.is_action_just_pressed("shoot") and scroll_container.get_global_rect().has_point(get_global_mouse_position()):
			place_item()
	elif Input.is_action_just_pressed("shoot"):
		if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
			pick_item()
	
	if tooltip.visible:
		tooltip.global_position = lerp(tooltip.global_position, get_global_mouse_position(), 20 * delta)
		cost_tooltip.global_position = lerp(cost_tooltip.global_position, get_global_mouse_position() + Vector2(0, tooltip.size.y), 20 * delta)
		if !grid_container.get_global_rect().has_point(get_global_mouse_position()):
			tooltip.visible = false
			cost_tooltip.visible = false
			

func create_slot(lock : bool):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	grid_container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
	new_slot.try_unlock_slot.connect(_try_unlock_slot)
	
	if lock:
		new_slot.lock_slot()
	else:
		new_slot.unlock_slot()

func _try_unlock_slot(a_Slot):
	if Globals.money >= slot_cost:
		a_Slot.unlock_slot()
		Globals.money -= slot_cost
		slot_cost += 1
		get_tree().call_group("inv_slot", "update_money_label", slot_cost)
		
		shop.money_animation("item_buy")
	else:
		shop.money_animation("cant_afford")

func _on_slot_mouse_entered(a_Slot):
	
	# TODO: CHECK IF TOOLTIP GOES OFF SCREEN, AND CHANGE
	# THE ORIGIN IF SO, DON'T NEED TO DO THIS IN SHOP AS IT'S ON THE
	# LEFT
	
	icon_anchor = Vector2(10000, 10000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
	elif a_Slot.item_stored:
		tooltip.visible = true
		cost_tooltip.visible = true
		fill_tooltip(a_Slot.item_stored)
	else:
		tooltip.visible = false
		cost_tooltip.visible = false

func _on_slot_mouse_exited(_a_Slot):
	clear_grid()

func fill_tooltip(item : Node):
	var id = item.item_ID
	var tooltip_info = DataHandler.item_data[str(id)]
	tooltip.set_title(tooltip_info["DisplayName"])
	tooltip.set_description(tooltip_info["Description"])
	tooltip.set_type(tooltip_info["Type"])
	tooltip.size = Vector2(0,0)
	cost_tooltip.set_price_sell(int(tooltip_info["Sell_price"]))
	
	tooltip.set_aberrated(item.aberrated)

func check_slot_availability(a_Slot) -> void:
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * column_count # maths to convert an x,y into an index for the array of slots
		var line_switch_check = a_Slot.slot_ID % column_count + grid[0] # checks for wraparound to ensure items can't be places over edges
		if line_switch_check < 0 or line_switch_check >= column_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
		if grid_array[grid_to_check].locked:
			can_place = false
			return
	can_place = true

func set_grids(a_Slot):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = a_Slot.slot_ID % column_count + grid[0]
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if line_switch_check < 0 or line_switch_check >= column_count:
			continue
		
		if grid_container.get_global_rect().has_point(get_global_mouse_position()):
			if can_place:
				grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
				
				if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
				if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
			else:
				grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func rotate_item():
	item_held.rotate_item()
	clear_grid()
	if current_slot:
		_on_slot_mouse_entered(current_slot)

func place_item():
	if not can_place or not current_slot:
		# TODO visual "can't place it here" cue
		return
		
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	item_held._snap_to(grid_array[calculated_grid_id].global_position)
	
	item_held.get_parent().remove_child(item_held)
	grid_container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].item_stored = item_held
	
	update_adj_all()
	
	tooltip.visible = true
	cost_tooltip.visible = true
	fill_tooltip(item_held)
	
	items_slots_held.append(item_held)
	
	# TODO show aberration in tooltip
	# item_held.set_aberrated(true)
	
	item_held.selected = false
	item_held = null
	clear_grid()

func update_adj_all():
	for item in get_tree().get_nodes_in_group("item"):
		if item.in_shop:
			continue
		
		var adj_items_temp := []
		for grid in item.item_adj_grids:
			
			var grid_to_check = item.grid_anchor.slot_ID + grid[0] + grid[1] * column_count # maths to convert an x,y into an index for the array of slots
			var line_switch_check = item.grid_anchor.slot_ID % column_count + grid[0] # checks for wraparound to ensure items can't be places over edges
			
			if line_switch_check < 0 or line_switch_check >= column_count:
				continue
				
			if grid_to_check < 0 or grid_to_check >= grid_array.size():
				continue
			
			if grid_array[grid_to_check].item_stored != null:
				adj_items_temp.push_back(grid_array[grid_to_check].item_stored)
		
		item.update_adjacent_items(adj_items_temp)
		
		print(item.adjacent_items)

func pick_item():
	if !in_round:
		return
	
	if not current_slot or not current_slot.item_stored:
		return
	
	if current_slot.item_stored.aberrated:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	items_slots_held.erase(item_held)
	
	tooltip.visible = false
	cost_tooltip.visible = false
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)

func hold_new_item(item_ID : int) -> bool:
	if item_held:
		# TODO make this clear with visuals
		print("already holding item")
		return false
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.global_position = get_global_mouse_position()
	new_item.load_item(item_ID)
	new_item.selected = true
	new_item.in_shop = false
	item_held = new_item
	return true

func sell_item():
	if !item_held:
		return
	
	var tooltip_info = DataHandler.item_data[str(item_held.item_ID)]
	Globals.money += tooltip_info["Sell_price"]
	
	item_held.queue_free.call_deferred()
	item_held = null
	
	get_tree().call_group("effect", "_on_item_sold", item_held)
	shop.money_animation("item_sell")

func aberrate_random():
	print(items_slots_held)
	if items_slots_held.size() == 0:
		return
	items_slots_held.pick_random().set_aberrated(true)

func _on_button_spawner_pressed():
	hold_new_item(randi_range(1, 6))
