extends Control

@onready var shop = $Shop
@onready var shop_music = $shop_music
@onready var inventory = $Inventory
@onready var tutorial = $tutorial

func start_shop():
	load_items()
	inventory.in_round = true

func stop_shop():
	shop.unload_items()
	# inventory.update_adj_all()
	inventory.in_round = false

func load_items():
	shop.load_items()

func aberrate_random():
	inventory.aberrate_random()

func tween_music_volume(target : float, time : float, restart : bool):
	if restart:
		shop_music.playing = false
		shop_music.playing = true
	var tween = get_tree().create_tween()
	tween.tween_property(shop_music, "volume_db", target, time).set_trans(Tween.TRANS_QUAD)

func show_tutorial():
	tutorial.on_screen()
	# delete_tutorial()
