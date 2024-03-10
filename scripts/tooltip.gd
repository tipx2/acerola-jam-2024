extends PanelContainer

@onready var ab_container = $MarginContainer/CenterContainer/VBoxContainer/ab_container

func set_title(t : String) -> void:
	%tooltip_title.text = t

func set_description(t : String) -> void:
	%tooltip_description.text = "[center]%s[/center]" % t

func set_type(t : String) -> void:
	%tooltip_type.text = "[center]Type: %s[/center]" % t

func set_aberrated(shown : bool):
	ab_container.visible = shown
	if shown:
		self_modulate = Color("823ebdd2")
	else:
		self_modulate = Color("d7cfd2d2")
