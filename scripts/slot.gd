extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var status_filter := $StatusFilter as ColorRect

var slot_ID
var is_hovering := false
enum States {DEFAULT, TAKEN, FREE}
var state := States.DEFAULT
var item_stored = null

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
