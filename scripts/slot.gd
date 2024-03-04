extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

signal try_unlock_slot(slot)

@onready var status_filter := $StatusFilter as ColorRect
@onready var lock_screen = $LockScreen
@onready var money_label = $money_label
@onready var unlock_button = $LockScreen/unlock_button

var slot_ID
var is_hovering := false
enum States {DEFAULT, TAKEN, FREE}
var state := States.DEFAULT
var item_stored = null

var locked = false

func set_color(a_state = States.DEFAULT) -> void:
	match a_state:
		States.DEFAULT:
			status_filter.color = Color(0.0, 0.0, 0.0, 0.0)
		States.TAKEN:
			status_filter.color = Color(Color.RED, 0.5)
		States.FREE:
			status_filter.color = Color(Color.GREEN, 0.5)

func _process(delta):
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	elif is_hovering:
		is_hovering = false
		slot_exited.emit(self)


func update_money_label(value : int):
	money_label.text = "£%d" % value

func lock_slot():
	unlock_button.disabled = false
	lock_screen.self_modulate = Color("#592f14FF")
	money_label.visible = true
	locked = true

func unlock_slot():
	unlock_button.disabled = true
	lock_screen.self_modulate = Color("#592f1400")
	money_label.visible = false
	locked = false

func _on_unlock_button_pressed():
	try_unlock_slot.emit(self)
