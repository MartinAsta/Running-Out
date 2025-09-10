class_name Game
extends Node

var portal_scene = preload("res://Characters/NPC/Portal/portal.tscn")
var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var current_world:int
var current_level:int
var latest_checkpoint:Vector2
var max_remaining_time:float
var remaining_time:float
var max_run_remaining_time:float
var run_remaining_time:float
var is_in_resting_area:bool
var has_crossed_finish_line:bool
var is_in_shop:bool
var has_lost:bool
var completed_levels:Array[int]
var score_multiplicator:float
var upgrade_cost:Dictionary
var shop_item_cost:Dictionary
var shop_odds:int
var speed_upgrade_costs:Array[int]
var speed_upgrade_costs_index:int
var dash_upgrade_costs:Array[int]
var dash_upgrade_costs_index:int
var bonus_time_upgrade_costs:Array[int]
var bonus_time_upgrade_costs_index:int
var shop_items_upgrade_costs:Array[int]
var shop_items_upgrade_costs_index:int
var damage:int
var price_multiplicator:float
var cheat_death:int

var first_loss_flag:bool
var first_win_flag:bool
var speed_maxed_flag:bool
var dash_maxed_flag:bool
var bonus_time_maxed_flag:bool
var shop_items_maxed_flag:bool

signal player_takes_damage
signal update_cheat_death_count
signal item_bought

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.8,0.95,0.99))
	current_world = 0
	current_level = 0
	latest_checkpoint = Vector2(0,0)
	max_remaining_time = 45
	remaining_time = max_remaining_time
	max_run_remaining_time = 300
	run_remaining_time = max_run_remaining_time
	is_in_resting_area = false
	has_crossed_finish_line = false
	is_in_shop = false
	has_lost = false
	completed_levels = []
	score_multiplicator = 1
	speed_maxed_flag = false
	dash_maxed_flag = false
	bonus_time_maxed_flag = false
	shop_items_maxed_flag = false
	first_loss_flag = false
	first_win_flag = false
	shop_odds = 10
	speed_upgrade_costs = [100,200,300,400,500,600,700,800,900,1000,1200,1400,1600,1800,2000,2500,3000,3500,4000,5000]
	speed_upgrade_costs_index = 0
	dash_upgrade_costs = [200,400,600,800,1000,1200,1400,1600,1800,2000,2400,2800,3200,3600,4000,5000,6000,7000,8000,1000]
	dash_upgrade_costs_index = 0
	bonus_time_upgrade_costs = [100,1000,3000,10000]
	bonus_time_upgrade_costs_index = 0
	shop_items_upgrade_costs = [100,500]
	shop_items_upgrade_costs_index = 0
	upgrade_cost = {
		"speed_cost" : speed_upgrade_costs[0],
		"dash_cooldown_cost" : dash_upgrade_costs[0],
		"bonus_time_cost": bonus_time_upgrade_costs[0],
		"shop_items": shop_items_upgrade_costs[0]
	}
	shop_item_cost = {
		"nullify_death" : 50,
		"bonus_time" : 35
	}
	damage = 10
	price_multiplicator = 1
	cheat_death = 0

func _process(delta):
	if has_crossed_finish_line and remaining_time > 0:
		remaining_time -= 0.5
		PlayerStateManager.modify_seconds_currency_count(0.5 * score_multiplicator)
		return
	if current_world < 1 or is_in_resting_area:
		return
	remaining_time -= delta
	run_remaining_time -= delta
	if run_remaining_time < 0 and !has_lost and !is_in_shop:
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
	elif current_world == -1 or (current_world == 1 and current_level <= 10):
		if(current_level == 0):
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
		elif picked_level == 7:
			get_tree().change_scene_to_file("res://levels/World1/W1_map7.tscn")
			start_level()
			current_level += 1
		elif picked_level == 8:
			get_tree().change_scene_to_file("res://levels/World1/W1_map8.tscn")
			start_level()
			current_level += 1
		elif picked_level == 9:
			get_tree().change_scene_to_file("res://levels/World1/W1_map9.tscn")
			start_level()
			current_level += 1
	has_crossed_finish_line = false
	is_in_shop = false
	PlayerStateManager.set_can_dash(true)

func player_takes_shop_portal() -> void:
	is_in_shop = true
	get_tree().change_scene_to_file("res://levels/Peaceful_Levels/shop.tscn")
	PlayerStateManager.set_can_dash(true)

func pick_level() -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var level = rng.randi_range(1,9)
	if completed_levels.has(level):
		return pick_level()
	completed_levels.append(level)
	return level

func increase_speed_upgrade_cost() -> void:
	if speed_maxed_flag:
		return
	speed_upgrade_costs_index += 1
	if speed_upgrade_costs_index == len(speed_upgrade_costs):
		speed_maxed_flag = true
	else:
		upgrade_cost["speed_cost"] = speed_upgrade_costs[speed_upgrade_costs_index]

func increase_dash_cooldown_upgrade_cost() -> void:
	if dash_maxed_flag:
		return
	dash_upgrade_costs_index += 1
	if dash_upgrade_costs_index == len(dash_upgrade_costs):
		dash_maxed_flag = true
	else:
		upgrade_cost["dash_cooldown_cost"] = dash_upgrade_costs[dash_upgrade_costs_index]

func increase_bonus_time_upgrade_cost() -> void:
	if bonus_time_maxed_flag:
		return
	bonus_time_upgrade_costs_index += 1
	if bonus_time_upgrade_costs_index == len(bonus_time_upgrade_costs):
		bonus_time_maxed_flag = true
	else:
		upgrade_cost["bonus_time_cost"] = bonus_time_upgrade_costs[bonus_time_upgrade_costs_index]

func increase_shop_items_upgrade_costs() -> void:
	if shop_items_maxed_flag:
		return
	shop_items_upgrade_costs_index += 1
	if shop_items_upgrade_costs_index == len(shop_items_upgrade_costs):
		shop_items_maxed_flag = true
	else:
		upgrade_cost["shop_items"] = shop_items_upgrade_costs[shop_items_upgrade_costs_index]

func start_run() -> void:
	current_world = 1
	has_lost = false
	run_remaining_time = max_run_remaining_time + PlayerStateManager.get_bonus_time()

func start_level() -> void:
	reset_timer()

func player_deal_damage() -> void:
	player_takes_damage.emit()

func deduce_time() -> void:
	if cheat_death > 0:
		cheat_death -= 1
		update_cheat_death_count.emit()
	else:
		run_remaining_time -= damage

func reset_timer() -> void:
	remaining_time = max_remaining_time

func game_over() -> void:
	if !first_loss_flag:
		first_loss_flag = true
	get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
	current_world = -1
	current_level = 0
	completed_levels = []
	PlayerStateManager.set_can_dash(true)

func increase_shop_odds(odds:int) -> void:
	shop_odds += odds

func reset_shop_odds() -> void:
	shop_odds = 10

func player_buys_item() -> void:
	var shop_item:String = PlayerStateManager.get_currently_hovered_shop_item()
	if PlayerStateManager.get_sand() < (get_shop_item_cost(shop_item) * price_multiplicator):
		print("Too expensive")
		return
	
	PlayerStateManager.modify_seconds_currency_count(-(get_shop_item_cost(shop_item) * price_multiplicator))
	
	if shop_item == "nullify_death":
		cheat_death += 1
		update_cheat_death_count.emit()
	elif shop_item == "bonus_time":
		run_remaining_time += 30
	item_bought.emit()

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

func get_shop_item_cost(item:String) -> int:
	return shop_item_cost[item]

func get_shop_odds() -> int:
	return shop_odds

func get_run_remaining_time() -> String:
	return str(int(run_remaining_time)) if int(run_remaining_time) >= 0 else str(0)

func get_speed_maxed_flag() -> bool:
	return speed_maxed_flag

func get_dash_maxed_flag() -> bool:
	return dash_maxed_flag

func get_bonus_time_maxed_flag() -> bool:
	return bonus_time_maxed_flag

func get_shop_items_maxed_flag() -> bool:
	return shop_items_maxed_flag

func get_cheat_death() -> int:
	return cheat_death
