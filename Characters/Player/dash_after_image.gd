extends CharacterBody2D

const SPEED:int = 750

var dash_cooldown:float

func _ready() -> void:
	dash_cooldown = PlayerStateManager.get_dash_cooldown()
	PlayerStateManager.set_can_dash(false)

func _process(delta) -> void:
	if dash_cooldown >= 0:
		dash_cooldown -= delta
	else:
		var target: Vector2 = PlayerStateManager.get_player_position()
		global_position = global_position.move_toward(target, SPEED * delta)
		
		if global_position.distance_to(target) <= 5:
			PlayerStateManager.set_can_dash(true)
			queue_free()
