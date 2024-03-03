extends Control

@onready var shop = $Shop
@onready var shop_music = $shop_music

func load_items():
	shop.load_items()

func tween_music_volume(target : float, time : float):
	var tween = get_tree().create_tween()
	tween.tween_property(shop_music, "volume_db", target, time).set_trans(Tween.TRANS_QUAD)
