extends Area2D

@export var collision_shape_2d:CollisionShape2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.player_falls()
