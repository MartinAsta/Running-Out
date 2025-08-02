class_name Checkpoint
extends Area2D

var has_been_reached:bool

func _ready() -> void:
	has_been_reached = false

func _on_body_exited(body):
	if body.is_in_group("Player") and !has_been_reached:
		has_been_reached = true
		GameManager.set_latest_checkpoint(global_position)
