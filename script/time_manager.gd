class_name TimeManager
extends Node

var time_npc_scene = preload("res://Characters/NPC/Time/time.tscn")
var introduction_flag:bool

signal tutorial_appearance()
signal trigger_dialogue()

func _ready() -> void:
	connect("tutorial_appearance", on_tutorial_appear)
	introduction_flag = false

func tutorial_appear() -> void:
	tutorial_appearance.emit()

func on_tutorial_appear() -> void:
	var npc:TimeNpc = time_npc_scene.instantiate()
	var player:Player
	var player_position:Vector2
	var scene = get_tree().get_current_scene()
	
	for node in scene.get_children():
		if node.is_in_group("Player"):
			player = node
			player_position = player.position
			
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

func set_flag() -> void:
	if !introduction_flag:
		introduction_flag = true
