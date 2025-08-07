extends Node

var portal_scene = preload("res://Characters/NPC/Portal/portal.tscn")
var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var current_world:int
var current_level:int
var latest_checkpoint:Vector2
var remaining_time:float
var is_in_resting_area:bool
var has_crossed_finish_line:bool
var is_in_shop:bool
var has_lost:bool

signal player_fell

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.8,0.95,0.99))
	current_world = 0
	current_level = 0
	remaining_time = 60
	is_in_resting_area = false
	has_crossed_finish_line = false
	is_in_shop = false
	has_lost = false

func _process(delta):
	if has_crossed_finish_line and remaining_time > 0:
		remaining_time -= 0.5
		PlayerStateManager.modify_seconds_currency_count(0.5)
		return
	if current_world < 1 or is_in_resting_area:
		return
	remaining_time -= delta
	if remaining_time < 0 and !has_lost:
		has_lost = true
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/game_over.dialogue"), "start")

func spawn_portal() -> void:
	var portal:Portal = portal_scene.instantiate()
	var player:Player
	var player_position:Vector2
	var scene = get_tree().get_current_scene()
	
	for node in scene.get_children():
		if node.is_in_group("Player"):
			player = node
			player_position = player.position
	
	scene.add_child(portal)
	portal.global_position.x = (player_position.x - 60)
	portal.global_position.y = player_position.y

func player_takes_portal() -> void:
	if current_world == -1 and !TimeStateManager.introduction_flag:
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/ignoring_time.dialogue"), "start")
		return
	
	if current_world == 0 and current_level == 0:
		get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
		current_world = -1
	elif current_world == -1:
		get_tree().change_scene_to_file("res://levels/World1/W1_map1.tscn")
		start_run()
		start_level()
		current_world = 1
		current_level = 1
	elif current_world == 1:
		get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
		current_world = -1
	has_crossed_finish_line = false

func start_run() -> void:
	has_lost = false

func start_level() -> void:
	reset_timer()

func player_falls() -> void:
	player_fell.emit()
	remaining_time -= 5.0

func reset_timer() -> void:
	remaining_time = 60

func game_over() -> void:
	get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
	current_world = -1

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
