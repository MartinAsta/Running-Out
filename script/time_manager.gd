class_name TimeManager
extends Node

var time_npc_scene = preload("res://Characters/NPC/Time/time.tscn")
var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var introduction_flag:bool
var introduction_to_bonus_flag:bool

signal tutorial_appearance()
signal trigger_dialogue()

func _ready() -> void:
	connect("tutorial_appearance", on_tutorial_appear)
	introduction_flag = false
	introduction_to_bonus_flag = false

func tutorial_appear() -> void:
	tutorial_appearance.emit()

func on_tutorial_appear() -> void:
	var npc:TimeNpc = time_npc_scene.instantiate()
	var player_position:Vector2 = PlayerStateManager.get_player_position()
	var scene = get_tree().get_current_scene()
			
	scene.add_child(npc)
	npc.global_position = player_position
	npc.appear()

func on_tutorial_disappear() -> void:
	var scene = get_tree().get_current_scene()
	var npc:TimeNpc
	for node in scene.get_children():
		if node.is_in_group("TimeNPC"):
			npc = node
	npc.disappear()

func start_dialogue() -> void:
	trigger_dialogue.emit()

func start_upgrade_dialogue() -> void:
	var balloon:GameDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://Dialogue/conversations/upgrade_player.dialogue"), "start")

func speed_upgrade() -> void:
	PlayerStateManager.modify_seconds_currency_count(-(GameManager.get_upgrade_cost("speed_cost")))
	GameManager.increase_speed_upgrade_cost()
	PlayerStateManager.increase_speed()

func dash_cooldown_upgrade() -> void:
	PlayerStateManager.modify_seconds_currency_count(-(GameManager.get_upgrade_cost("dash_cooldown_cost")))
	GameManager.increase_dash_cooldown_upgrade_cost()
	PlayerStateManager.decrease_dash_cooldown()

func bonus_time_upgrade() -> void:
	PlayerStateManager.modify_seconds_currency_count(-(GameManager.get_upgrade_cost("bonus_time_cost")))
	GameManager.increase_bonus_time_upgrade_cost()
	PlayerStateManager.increase_bonus_time()

func shop_items_ugrade() -> void:
	PlayerStateManager.modify_seconds_currency_count(-(GameManager.get_upgrade_cost("shop_items")))
	GameManager.increase_shop_items_upgrade_costs()
	PlayerStateManager.increase_shop_items_pool()

func set_flag() -> void:
	if !introduction_flag:
		introduction_flag = true
	elif !introduction_to_bonus_flag:
		introduction_to_bonus_flag = true

func get_introduction_flag() -> bool:
	return introduction_flag

func get_introduction_to_bonus_flag() -> bool:
	return introduction_to_bonus_flag
