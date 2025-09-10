extends Control

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	hide()

func _process(delta) -> void:
	testEsc()

func resume() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	hide()

func pause() -> void:
	get_tree().paused = true
	animation_player.play("blur")
	show()

func testEsc() -> void:
	if Input.is_action_just_pressed("Menu") and get_tree().paused == false and !PlayerStateManager.is_in_cutscene:
		pause()
	elif Input.is_action_just_pressed("Menu") and get_tree().paused == true:
		resume()

func _on_main_menu_pressed():
	resume()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_resume_pressed():
	resume()

func _on_save_pressed():
	SaveManager.quick_save()
