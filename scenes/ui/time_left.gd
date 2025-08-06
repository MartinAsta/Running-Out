extends Node2D

@onready var label = $Label

func _process(delta):
	if GameManager.get_current_world() < 1:
		label.text = ""
	else:
		label.text = GameManager.get_remaining_time()
