extends Node2D

@onready var label = $Label

func _process(delta):
	if GameManager.get_current_world() == -1 or GameManager.get_is_in_shop() or GameManager.get_is_in_resting_area():
		label.text = PlayerStateManager.get_seconds_currency()
	else:
		label.text = ""
