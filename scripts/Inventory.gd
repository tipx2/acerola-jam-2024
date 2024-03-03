extends Control

@onready var slot_scene = preload("res://scenes/slot.tscn")
@onready var grid_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://scenes/item.tscn")
@onready var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer
@onready var column_count = grid_container.columns

@onready var tooltip = $tooltip

var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

func _ready():
	for i in range(42):
		create_slot()
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
		if !grid_container.get_global_rect().has_point(get_global_mouse_position()):
			tooltip.visible = false

func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_array.push_back(new_slot)
	grid_container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000, 10000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	
	elif a_Slot.item_stored:
		tooltip.visible = true
		fill_tooltip(a_Slot.item_stored.item_ID)
	else:
		tooltip.visible = false

func _on_slot_mouse_exited(a_Slot):
	clear_grid()

func fill_tooltip(id : int):
	var tooltip_info = DataHandler.item_data[str(id)]
	tooltip.set_title(tooltip_info["DisplayName"])
	tooltip.set_description(tooltip_info["Description"])
	tooltip.set_type(tooltip_info["Type"])

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
		
	tooltip.visible = true
	fill_tooltip(item_held.item_ID)
	
	item_held.selected = false
	item_held = null
	clear_grid()

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	tooltip.visible = false
	
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
	item_held = new_item
	return true

func _on_button_spawner_pressed():
	hold_new_item(randi_range(1, 6))
