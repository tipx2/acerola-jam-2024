extends CenterContainer

@onready var inventory = $"../Inventory"
@onready var animation_player = $HBoxContainer/VBoxContainer/AnimationPlayer

@onready var bin_open = $bin_open
@onready var bin_close = $bin_close

var opened = false

func _on_mouse_entered():
	if inventory.item_held and !opened:
		opened = true
		bin_open.play()
		animation_player.play("open")


func _on_mouse_exited():
	if opened:
		opened = false
		bin_close.play()
		animation_player.play("close")
	pass


func _on_sell_button_pressed():
	inventory.sell_item()
