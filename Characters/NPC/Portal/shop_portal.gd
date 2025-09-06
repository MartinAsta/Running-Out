class_name ShopPortal
extends Node2D

@onready var collision_shape_2d = $InteractionArea2D/CollisionShape2D

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var portal_appear = rng.randi_range(1, 100)
	if portal_appear <= GameManager.get_shop_odds() or GameManager.get_current_level() == 10:
		GameManager.reset_shop_odds()
		visible = true
		collision_shape_2d.disabled = false
	else:
		GameManager.increase_shop_odds(5)
		visible = false
		collision_shape_2d.disabled = true

func _on_interaction_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.disable_interaction_label()
		player.set_can_take_shop_portal(false)

func _on_interaction_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		var player:Player = body
		player.enable_interaction_label()
		player.set_can_take_shop_portal(true)
