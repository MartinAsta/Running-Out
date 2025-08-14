extends Node

var portal_scene = preload("res://Characters/NPC/Portal/portal.tscn")
var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var current_world:int
var current_level:int
var latest_checkpoint:Vector2
var remaining_time:float
var max_remaining_time:float
var is_in_resting_area:bool
var has_crossed_finish_line:bool
var is_in_shop:bool
var has_lost:bool
var completed_levels:Array[int]
var score_multiplicator:float
var upgrade_cost:Dictionary
var shop_odds:int

var first_loss_flag:bool
var first_win_flag:bool

signal player_takes_damage

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.8,0.95,0.99))
	current_world = 0
	current_level = 0
	max_remaining_time = 45
	remaining_time = max_remaining_time
	is_in_resting_area = false
	has_crossed_finish_line = false
	is_in_shop = false
	has_lost = false
	completed_levels = []
	score_multiplicator = 1
	first_loss_flag = false
	first_win_flag = false
	shop_odds = 10
	upgrade_cost = {
		"speed_cost" : 100,
		"dash_cooldown_cost" : 250
	}

func _process(delta):
	if has_crossed_finish_line and remaining_time > 0:
		remaining_time -= 0.5
		PlayerStateManager.modify_seconds_currency_count(0.5 * score_multiplicator)
		return
	if current_world < 1 or is_in_resting_area:
		return
	remaining_time -= delta
	if remaining_time < 0 and !has_lost and !is_in_shop:
		has_lost = true
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/game_over.dialogue"), "start")

func spawn_portal() -> void:
	var portal:Portal = portal_scene.instantiate()
	var scene = get_tree().get_current_scene()
	scene.add_child(portal)
	portal.global_position.x = (PlayerStateManager.get_player_position().x - 60)
	portal.global_position.y = PlayerStateManager.get_player_position().y

func player_takes_portal() -> void:
	if (current_world == -1 and !TimeStateManager.get_introduction_flag()) or (current_world == -1 and first_loss_flag and !TimeStateManager.get_introduction_to_bonus_flag()):
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/ignoring_time.dialogue"), "start")
		return
	
	if current_world == 0 and current_level == 0:
		get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
		current_world = -1
	elif current_world == -1 or (current_world == 1 and current_level <= 5):
		start_run()
		var picked_level = pick_level()
		if picked_level == 1:
			get_tree().change_scene_to_file("res://levels/World1/W1_map1.tscn")
			start_level()
			current_level += 1
		elif picked_level == 2:
			get_tree().change_scene_to_file("res://levels/World1/W1_map2.tscn")
			start_level()
			current_level += 1
		elif picked_level == 3:
			get_tree().change_scene_to_file("res://levels/World1/W1_map3.tscn")
			start_level()
			current_level += 1
		elif picked_level == 4:
			get_tree().change_scene_to_file("res://levels/World1/W1_map4.tscn")
			start_level()
			current_level += 1
		elif picked_level == 5:
			get_tree().change_scene_to_file("res://levels/World1/W1_map5.tscn")
			start_level()
			current_level += 1
		elif picked_level == 6:
			get_tree().change_scene_to_file("res://levels/World1/W1_map6.tscn")
			start_level()
			current_level += 1
	has_crossed_finish_line = false
	is_in_shop = false
	PlayerStateManager.set_can_dash(true)

func player_takes_shop_portal() -> void:
	is_in_shop = true
	current_level += 1
	get_tree().change_scene_to_file("res://levels/Peaceful_Levels/shop.tscn")

func pick_level() -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var level = rng.randi_range(1,6)
	if completed_levels.has(level):
		return pick_level()
	completed_levels.append(level)
	return level

func increase_upgrade_cost(upgrade:String) -> void:
	upgrade_cost[upgrade] = upgrade_cost[upgrade] * 2

func start_run() -> void:
	current_world = 1
	has_lost = false

func start_level() -> void:
	reset_timer()

func player_deal_damage() -> void:
	player_takes_damage.emit()
	remaining_time -= 5.0

func reset_timer() -> void:
	remaining_time = max_remaining_time

func game_over() -> void:
	if !first_loss_flag:
		first_loss_flag = true
	get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
	current_world = -1
	current_level = 0
	completed_levels
	PlayerStateManager.set_can_dash(true)

func increase_shop_odds(odds:int) -> void:
	shop_odds += odds

func reset_shop_odds() -> void:
	shop_odds = 10

func set_is_in_resting_area(b:bool) -> void:
	is_in_resting_area = b

func set_latest_checkpoint(checkpoint:Vector2):
	latest_checkpoint = checkpoint

func set_has_crossed_finish_line(b:bool) -> void:
	has_crossed_finish_line = b

func get_latest_checkpoint() -> Vector2:
	return latest_checkpoint

func get_remaining_time() -> String:
	return str(int(remaining_time)) if int(remaining_time) >= 0 else str(0)

func get_current_world() -> int:
	return current_world

func get_current_level() -> int:
	return current_level

func get_is_in_resting_area() -> bool:
	return is_in_resting_area

func get_is_in_shop() -> bool:
	return is_in_shop

func get_first_loss_flag() -> bool:
	return first_loss_flag

func get_first_win_flag() -> bool:
	return first_win_flag

func get_upgrade_cost(upgrade:String) -> int:
	return upgrade_cost[upgrade]

func get_shop_odds() -> int:
	return shop_odds
