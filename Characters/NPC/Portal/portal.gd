class_name Portal
extends Node2D

@onready var collision_shape_2d = $InteractionArea2D/CollisionShape2D

func _ready() -> void:
	if GameManager.get_current_level() == 10:
		visible = false
		collision_shape_2d.disabled = true

func _on_interaction_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.disable_interaction_label()
		player.set_can_take_portal(false)

func _on_interaction_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.enable_interaction_label()
		player.set_can_take_portal(true)
