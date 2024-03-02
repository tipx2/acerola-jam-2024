extends PanelContainer

func set_title(t : String) -> void:
	%tooltip_title.text = t

func set_description(t : String) -> void:
	%tooltip_description.text = "[center]%s[/center]" % t

func set_type(t : String) -> void:
	%tooltip_type.text = "[center]Type: %s[/center]" % t
