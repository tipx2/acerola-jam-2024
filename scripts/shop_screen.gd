extends Control

@onready var shop = $Shop
@onready var shop_music = $shop_music
@onready var inventory = $Inventory

func start_shop():
	load_items()
	inventory.in_round = true

func stop_shop():
	inventory.in_round = false

func load_items():
	shop.load_items()

func tween_music_volume(target : float, time : float, restart : bool):
	if restart:
		shop_music.playing = false
		shop_music.playing = true
	var tween = get_tree().create_tween()
	tween.tween_property(shop_music, "volume_db", target, time).set_trans(Tween.TRANS_QUAD)
