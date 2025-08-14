class_name Spike
extends Node2D

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.player_deal_damage()
