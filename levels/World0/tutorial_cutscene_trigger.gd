class_name Cutscene
extends Area2D

var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

var player:Player

func _ready() -> void:
	DialogueManager.dialogue_has_ended.connect(on_dialogue_ended)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		var balloon:GameDialogueBalloon = balloon_scene.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load("res://Dialogue/conversations/tutorial.dialogue"), "start")

func on_dialogue_ended() -> void:
	var balloon:GameDialogueBalloon = balloon_scene.instantiate()
	await get_tree().create_timer(3.0).timeout
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://Dialogue/conversations/time_indtroduction.dialogue"), "start")
	queue_free()
