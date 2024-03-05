extends PanelContainer

func set_price_sell(p : int):
	%price_label.text = "[center][color=cyan]Sell:[/color] £%d[/center]" % p

func set_price_buy(p : int):
	%price_label.text = "[center][color=yellow]Buy:[/color] £%d[/center]" % p
