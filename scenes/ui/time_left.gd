extends Node2D

@onready var label = $Label

func _process(delta):
	if GameManager.get_current_world() < 1 or GameManager.get_is_in_shop():
		label.text = ""
	else:
		label.text = GameManager.get_run_remaining_time()
