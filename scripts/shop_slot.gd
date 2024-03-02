extends CenterContainer

signal passed_mouse(s)
signal buy_button_pressed(s)

func _on_mouse_entered():
	passed_mouse.emit(self)

func _on_buy_button_pressed():
	buy_button_pressed.emit(self)
