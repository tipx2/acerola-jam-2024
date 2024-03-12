extends Node2D

var basic_enemy_scene = preload("res://scenes/basic_enemy.tscn")
var turret_enemy_scene = preload("res://scenes/turret_enemy.tscn")
var burst_enemy_scene = preload("res://scenes/burst_enemy.tscn")

@onready var square_room = $SquareRoom
@onready var portal_notice_anim = $CanvasLayer/portal_notice/AnimationPlayer
@onready var start_notice_anim = $CanvasLayer/start_notice/AnimationPlayer
@onready var start_notice_2 = $CanvasLayer/start_notice2

@onready var camera_player = $player/camera_player

@onready var win_screen = $CanvasLayer/win_screen
@onready var confetti = $CanvasLayer/win_screen/confetti
@onready var win_sound = $CanvasLayer/win_screen/win_sound

@onready var lose_screen = $CanvasLayer/lose_screen

@onready var music = $music
var current_music : AudioStreamPlayer

@onready var floor_timer = $floor_timer
var timer_counter = 0

var ENEMY_DISTANCE := 500.0

var tile_map_ref : TileMap
var tile_list_ref : Array
var player_ref : Node2D
var portal_ref : Node2D

var enemy_count = 2
var step_count = 220
var enemy_additional_health = 0

var current_level = -1
var percent_difficulty := 30.0

enum {
	LEFT,
	RIGHT,
	BOTTOM,
	TOP
}
# keep this order - enum vars are ints
var round_directions = [LEFT, RIGHT, BOTTOM, TOP]
var corresponding_directions = [RIGHT, LEFT, TOP, BOTTOM]

var debug_names = ["left", "right", "bottom", "top"]

var taken_enemy_spots := []

func _on_square_room_map_generated(tile_list, tile_map) -> void:
	tile_map_ref = tile_map
	tile_list_ref = tile_list
	player_ref = Globals.player
	portal_ref = Globals.end_portal
	round_start()

func round_start() -> void:
	# set difficulty
	current_level += 1
	
	percent_difficulty += 20.0
	if percent_difficulty >= 100.0:
		percent_difficulty = 100.0
	# print("level: ", current_level, " difficulty:", percent_difficulty)
	enemy_count += 2
	step_count += 30
	enemy_additional_health += 1
	
	# move player
	var round_direction = round_directions.pick_random()
	player_ref.global_position = get_tile_global_pos(get_superlative_tile(round_direction))
	print("round_direction: " + debug_names[round_direction])
	
	# move portal
	var corresponding_direction = corresponding_directions[round_direction]
	portal_ref.global_position = get_tile_global_pos(get_superlative_tile(corresponding_direction))
	portal_ref.visible = false
	portal_ref.enabled = false
	
	# spawn enemies
	taken_enemy_spots = []
	for _x in range(enemy_count):
		var r = randf() 
		if r <= 0.3:
			taken_enemy_spots.append(spawn_enemy_pos_random(turret_enemy_scene))
		elif r > 0.3 && r <= 0.5:
			taken_enemy_spots.append(spawn_enemy_pos_random(burst_enemy_scene))
		else:
			taken_enemy_spots.append(spawn_enemy_pos_random(basic_enemy_scene))
	
	%transition_animation.play("uncover")
	
	current_music = music.get_children().pick_random()
	tween_battle_music_volume(current_music, 0, 0.5, true)
	
	# await %transition_animation.animation_finished
	if current_level != 0:
		start_notice_2.visible = false
	start_notice_anim.play("fade_in")
	await start_notice_anim.animation_finished
	start_notice_anim.play("fade_out")

func win_game():
	tween_battle_music_volume(current_music, -80, 2, false)
	%transition_animation.play("uncover")
	win_sound.play()
	win_screen.visible = true
	for p in confetti.get_children():
		p.emitting = true

func get_tile_map_pos(tile : Vector2) -> Vector2:
	return tile_map_ref.local_to_map(tile_map_ref.to_local(tile))

func get_tile_global_pos(tile : Vector2) -> Vector2:
	return tile_map_ref.to_global(tile_map_ref.map_to_local(tile))

func sort_by_first(a : Vector2, b : Vector2):
	if a.x < b.x:
		return true
	return false

func sort_by_second(a : Vector2, b : Vector2):
	if a.y < b.y:
		return true
	return false

func get_superlative_tile(round_direction):
	var sorted_tile_list := tile_list_ref.duplicate()
	if round_direction == TOP or round_direction == BOTTOM:
		sorted_tile_list.sort_custom(sort_by_second)
		if round_direction == TOP:
			return sorted_tile_list[0]
		elif round_direction == BOTTOM:
			return sorted_tile_list[-1]
	elif round_direction == LEFT or round_direction == RIGHT:
		sorted_tile_list.sort_custom(sort_by_first)
		if round_direction == LEFT:
			return sorted_tile_list[0]
		elif round_direction == RIGHT:
			return sorted_tile_list[-1]

func spawn_enemy_pos_random(enemy_scene : PackedScene) -> Vector2:
	var enemy_instance = enemy_scene.instantiate()
	call_deferred("add_child", enemy_instance)
	enemy_instance.set_as_top_level(true)
	
	# in case by chance it's a small map
	var loop_count = 0
	
	var picked_tile = tile_list_ref.pick_random()
	while picked_tile in taken_enemy_spots or get_tile_global_pos(picked_tile).distance_to(player_ref.global_position) < ENEMY_DISTANCE:
		picked_tile = tile_list_ref.pick_random()
		loop_count += 1
		if loop_count > 5000:
			break
	
	enemy_instance.global_position = get_tile_global_pos(picked_tile)
	enemy_instance.enemy_died.connect(_on_enemy_died)
	enemy_instance.set_health(enemy_additional_health)
	
	return picked_tile
	# print(enemy_instance," ", get_tile_map_pos(enemy_instance.global_position))

func _on_end_portal_level_ended():
	Globals.level_time = timer_counter * 0.05
	get_tree().call_group("effect", "_on_level_ended")
	
	Globals.player.set_intangible(true)
	Globals.player.hud_visible(false)
	get_tree().call_group("enemy", "set_intangible", true)
	camera_player.play("zoom")
	%transition_animation.play("cover")
	await %transition_animation.animation_finished
	
	if current_level == 8:
		win_game()
		return
	
	camera_player.play("RESET")
	%ShopScreen.visible = true
	%portal_bg.visible = true
	%continue_button.visible = true
	%ShopScreen.start_shop()
	tween_battle_music_volume(current_music, -80, 2, false)
	%ShopScreen.tween_music_volume(0, 0.01, true)
	%transition_animation.play("uncover")
	get_tree().call_group("enemy", "queue_free")
	
	if Globals.show_shop_tutorial:
		Globals.show_shop_tutorial = false
		%ShopScreen.show_tutorial()

func _on_continue_button_pressed():
	if %ShopScreen.inventory.item_held:
		return
	aggregate_static_effects()
	square_room.generate_level(step_count)
	square_room.set_tilemap(current_level)
	Globals.player.set_intangible(false)
	Globals.player.hud_visible(true)
	%transition_animation.play("cover")
	await %transition_animation.animation_finished
	
	# aberration
	if randf() <= percent_difficulty/100.0:
		%ShopScreen.aberrate_random()
	
	%ShopScreen.visible = false
	%ShopScreen.stop_shop()
	%ShopScreen.tween_music_volume(-80, 2, false)
	%portal_bg.visible = false
	%continue_button.visible = false
	%transition_animation.play("uncover")
	
	floor_timer.start()

func aggregate_static_effects():
	Globals.player.extra_max_hp = 0
	Globals.player.extra_attack_damage = 0
	Globals.player.extra_attack_speed = 0.0
	Globals.player.extra_move_speed = 0.0
	Globals.player.extra_crit_chance = 0.0
	Globals.player.extra_bullet_speed = 0.0
	
	for node in get_tree().get_nodes_in_group("effect"):
		node.backpack_prepass()
	
	for node in get_tree().get_nodes_in_group("effect"):
		node._on_backpack_compile()
		Globals.player.extra_max_hp += node.extra_max_hp
		Globals.player.extra_attack_damage += node.extra_attack_damage
		Globals.player.extra_attack_speed += node.extra_attack_speed
		Globals.player.extra_move_speed += node.extra_move_speed
		Globals.player.extra_crit_chance += node.extra_crit_chance
		Globals.player.extra_bullet_speed += node.extra_bullet_speed
	
	Globals.player.update_max_hp()

func _on_enemy_died(e : Node):
	Globals.money += e.reward
	# print(len(get_tree().get_nodes_in_group("enemy")))
	get_tree().call_group("effect", "_on_enemy_killed", e)
	print(len(get_tree().get_nodes_in_group("enemy")))
	if len(get_tree().get_nodes_in_group("enemy")) == 1:
		portal_ref.enabled = true
		portal_ref.visible = true
		portal_notice_anim.play("fade_in")
		await portal_notice_anim.animation_finished
		portal_notice_anim.play("fade_out")


func _on_floor_timer_timeout():
	timer_counter += 1

func _on_again_pressed():
	%transition_animation.play("cover")
	await %transition_animation.animation_finished
	Globals.start_again()

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_player_player_died():
	tween_battle_music_volume(current_music, -80, 2, false)
	Globals.player.set_intangible(true)
	Globals.player.hud_visible(false)
	get_tree().call_group("enemy", "set_intangible", true)
	camera_player.play("zoom")
	%transition_animation.play("cover")
	await %transition_animation.animation_finished
	%transition_animation.play("uncover")
	lose_screen.visible = true
	

func tween_battle_music_volume(_music : AudioStreamPlayer, target : float, time : float, restart : bool):
	if restart:
		_music.playing = false
		_music.playing = true
	var tween = get_tree().create_tween()
	tween.tween_property(_music, "volume_db", target, time).set_trans(Tween.TRANS_QUAD)
