extends Area2D

var balloon_scene = preload("res://Dialogue/tutorial_dialogue_balloon.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.set_has_crossed_finish_line(true)
		if GameManager.get_current_level() == 11:
			var balloon:GameDialogueBalloon = balloon_scene.instantiate()
			get_tree().current_scene.add_child(balloon)
			balloon.start(load("res://Dialogue/conversations/end_of_demo.dialogue"), "start")
