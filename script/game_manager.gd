extends Node

var portal_scene = preload("res://Characters/NPC/Portal/portal.tscn")

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.8,0.95,0.99))

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
