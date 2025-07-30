class_name Cutscene
extends Area2D

var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var player:Player

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		PlayerStateManager.enter_cutscene()
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/tutorial.dialogue"), "start")
		queue_free()
