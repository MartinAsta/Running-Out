extends Node

var portal_scene = preload("res://Characters/NPC/Portal/portal.tscn")

var current_world:int
var current_level:int
var latest_checkpoint:Vector2

signal player_fell

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.8,0.95,0.99))
	current_world = 0
	current_level = 0

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
	if current_world == 0 and current_level == 0:
		get_tree().change_scene_to_file("res://levels/Peaceful_Levels/lobby.tscn")
		current_world = -1

func player_falls() -> void:
	player_fell.emit()

func set_latest_checkpoint(checkpoint:Vector2):
	latest_checkpoint = checkpoint

func get_latest_checkpoint() -> Vector2:
	return latest_checkpoint
