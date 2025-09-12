extends Node2D

@onready var audio_stream_player:AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio_stream_player.connect("finished", Callable(self,"_on_loop_sound").bind(audio_stream_player))

func _on_loop_sound(player):
	audio_stream_player.play()
