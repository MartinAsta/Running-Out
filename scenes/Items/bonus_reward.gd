extends Sprite2D

@onready var label = $Label
@onready var label_2 = $Label2

func _ready():
	label_2.text = "Cost : "+(str(GameManager.get_shop_item_cost("bonus_reward")))
	GameManager.item_bought.connect(on_item_bought)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		label.visible = true
		label_2.visible = true
		var player:Player = body
		player.enable_interaction_label()
		player.set_can_buy_item(true)
		PlayerStateManager.set_currently_hovered_shop_item("bonus_reward")

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		label.visible = false
		label_2.visible = false
		var player:Player = body
		player.disable_interaction_label()
		player.set_can_buy_item(false)
		PlayerStateManager.set_currently_hovered_shop_item("")

func on_item_bought() -> void:
	if PlayerStateManager.get_currently_hovered_shop_item() == "bonus_reward":
		PlayerStateManager.set_currently_hovered_shop_item("")
		queue_free()
