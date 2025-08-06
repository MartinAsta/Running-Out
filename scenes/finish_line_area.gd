extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.set_has_crossed_finish_line(true)
