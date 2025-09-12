class_name PlayerManager
extends Node

var has_unlocked_dash:bool
var is_in_cutscene:bool
var seconds_currency:float
var player_speed_multiplicator:float
var player_position:Vector2
var is_facing_right:bool
var dash_cooldown:float
var can_dash:bool
var bonus_time:int
var number_of_shop_items:int
var currently_hovered_shop_item:String

func _ready() -> void:
	has_unlocked_dash = false
	is_in_cutscene = false
	seconds_currency = 0
	player_speed_multiplicator = 1
	player_position = Vector2(0,0)
	is_facing_right = true
	dash_cooldown = 2.5
	can_dash = true
	bonus_time = 0
	number_of_shop_items = 1
	currently_hovered_shop_item = ""

func unlock_dash() -> void:
	has_unlocked_dash = true

func enter_cutscene() -> void:
	is_in_cutscene = true

func leave_cutscene() -> void:
	is_in_cutscene = false

func modify_seconds_currency_count(seconds:float) -> void:
	seconds_currency += seconds

func increase_speed() -> void:
	player_speed_multiplicator += 0.01

func decrease_dash_cooldown() -> void:
	dash_cooldown -= 0.1

func increase_bonus_time() -> void:
	bonus_time += 30

func increase_shop_items_pool() -> void:
	number_of_shop_items += 1

func set_position(new_player_position:Vector2) -> void:
	player_position = new_player_position

func set_is_facing_right(b:bool) -> void:
	is_facing_right = b

func set_can_dash(b:bool) -> void:
	can_dash = b

func set_currently_hovered_shop_item(s:String) -> void:
	currently_hovered_shop_item = s

func get_seconds_currency() -> String:
	return str(int(seconds_currency))

func get_sand() -> int:
	return int(seconds_currency)

func get_player_position() -> Vector2:
	return player_position

func get_is_facing_right() -> bool:
	return is_facing_right

func get_dash_cooldown() -> float:
	return dash_cooldown

func get_can_dash() -> bool:
	return can_dash

func get_bonus_time() -> int:
	return bonus_time

func get_number_of_shop_items() -> int:
	return number_of_shop_items

func get_currently_hovered_shop_item() -> String:
	return currently_hovered_shop_item
