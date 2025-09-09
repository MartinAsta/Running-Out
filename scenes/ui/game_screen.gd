extends CanvasLayer

@onready var label = $Label

func _ready() -> void:
	label.text = str(GameManager.get_cheat_death())
	GameManager.update_cheat_death_count.connect(on_update_cheat_death_count)

func on_update_cheat_death_count() -> void:
	label.text = str(GameManager.get_cheat_death())
