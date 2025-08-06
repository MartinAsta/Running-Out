extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.set_is_in_resting_area(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		GameManager.set_is_in_resting_area(false)
