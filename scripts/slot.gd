extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var status_filter := $StatusFilter as ColorRect
@onready var lock_screen = $LockScreen

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


# **********************************************************
# TODO: ADD LOCK FUNCTIONALITY!! ADD FUNCTIONALITY FOR LOCKING AND UNLOCKING SLOTS!!
# TODO: ADD ABILITY TO BUY SLOTS!! ADD ABIILTY TO BUY SLOTS!!!
# **********************************************************

func lock_slot():
	lock_screen.self_modulate = Color("#592f14FF")
	locked = true

func unlock_slot():
	lock_screen.self_modulate = Color("#592f1400")
	locked = false
