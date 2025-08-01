class_name PlayerManager
extends Node

var has_unlocked_dash:bool
var is_in_cutscene:bool

func _ready() -> void:
	has_unlocked_dash = false
	is_in_cutscene = false

func unlock_dash() -> void:
	has_unlocked_dash = true

func enter_cutscene() -> void:
	is_in_cutscene = true

func leave_cutscene() -> void:
	is_in_cutscene = false
