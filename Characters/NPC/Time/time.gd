class_name TimeNpc
extends Node2D

@onready var animated_sprite_2d:AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.play("idle")

func appear() -> void:
	animated_sprite_2d.play("appear")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")

func disappear() -> void:
	animated_sprite_2d.play("disappear")
