extends Node

@export var tuto_text:String

@onready var label = $Label

func _ready():
	label.text = tuto_text

func _on_body_entered(body):
	if body.is_in_group("Player"):
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		label.visible = false
