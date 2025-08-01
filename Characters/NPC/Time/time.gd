class_name TimeNpc
extends Node2D

@onready var animated_sprite_2d:AnimatedSprite2D = $AnimatedSprite2D

var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

func _ready() -> void:
	animated_sprite_2d.play("idle")
	TimeStateManager.trigger_dialogue.connect(on_trigger_dialogue)

func appear() -> void:
	animated_sprite_2d.play("appear")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")

func disappear() -> void:
	animated_sprite_2d.play("disappear")
	await animated_sprite_2d.animation_finished
	queue_free()

func _on_interaction_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.enable_interaction_label()
		player.set_can_initiate_dialogue(true)

func _on_interaction_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.disable_interaction_label()
		player.set_can_initiate_dialogue(false)

func on_trigger_dialogue() -> void:
	var balloon:GameDialogueBalloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load("res://Dialogue/conversations/lobby_introduction.dialogue"), "start")
