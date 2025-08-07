class_name PlayerManager
extends Node

var has_unlocked_dash:bool
var is_in_cutscene:bool
var seconds_currency:float

func _ready() -> void:
	has_unlocked_dash = false
	is_in_cutscene = false
	seconds_currency = 0

func unlock_dash() -> void:
	has_unlocked_dash = true

func enter_cutscene() -> void:
	is_in_cutscene = true

func leave_cutscene() -> void:
	is_in_cutscene = false

func modify_seconds_currency_count(seconds:float) -> void:
	seconds_currency += seconds

func get_seconds_currency() -> String:
	return str(int(seconds_currency))
