extends Node

var nullify_death_item = preload("res://scenes/Items/nullify_death.tscn")
var additional_time = preload("res://scenes/Items/additional_time.tscn")

var number_of_items:int
var items_displayed:Array

func _ready() -> void:
	number_of_items = PlayerStateManager.get_number_of_shop_items()
	fill_slots()

func fill_slots() -> void:
	var children = get_children()
	
	for i in range(number_of_items):
		var slot = children[i]
		for c in slot.get_children():
			c.queue_free()
			
		var picked_item = pick_item()
		
		if picked_item == 1:
			var item = nullify_death_item.instantiate()
			slot.add_child(item)
			item.position = Vector2.ZERO
		elif picked_item == 2:
			var item = additional_time.instantiate()
			slot.add_child(item)
			item.position = Vector2.ZERO

func pick_item() -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var item = rng.randi_range(1,2)
	if items_displayed.has(item):
		return pick_item()
	items_displayed.append(item)
	return item
