class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_height_variation_timer:Timer = $JumpHeightVariationTimer
@onready var coyote_jump_timer:Timer = $CoyoteJumpTimer
@onready var wall_jump_height_variation_timer:Timer = $WallJumpHeightVariationTimer
@onready var coyote_walljump_timer:Timer = $CoyoteWalljumpTimer
@onready var dash_duration_timer:Timer = $DashDurationTimer
@onready var interaction_label = $InteractionLabel
@onready var lost_time_cd_timer = $LostTimeCDTimer

var dash_after_image_right = preload("res://Characters/Player/dash_after_image_right.tscn")
var dash_after_image_left = preload("res://Characters/Player/dash_after_image_left.tscn")

const GRAVITY:int = 900
const NORMAL_SPEED = 10000
var SPEED:float
const JUMP_HEIGHT:int = 14000
const DASH_SPEED_X:int = 13000
const DASH_SPEED_Y:int = 10000

enum State {IDLE, RUN, JUMP, FALL, WALL, WALLWALK, DASH}

var current_state:State
var last_wall_grabbed_on_right:bool
var can_go_higher:bool
var can_go_higher_wall:bool
var was_on_floor:bool
var was_on_wall:bool
var is_dashing:bool
var dash_direction:Vector2
var can_take_portal:bool
var can_take_shop_portal:bool
var can_take_boss_portal:bool
var can_initiate_dialogue:bool
var can_take_damage:bool
var can_buy_item:bool

func _ready() -> void:
	current_state = State.IDLE
	GameManager.player_takes_damage.connect(on_player_takes_damage)
	can_take_damage = true
	can_buy_item = false
	can_initiate_dialogue = false
	can_take_shop_portal = false
	can_take_portal = false
	is_dashing = false
	can_take_boss_portal = false

func _physics_process(delta) -> void:
	SPEED = NORMAL_SPEED * PlayerStateManager.player_speed_multiplicator
	player_falling(delta)
	player_idle()
	if !PlayerStateManager.is_in_cutscene:
		player_run(delta)
		player_jump(delta)
		player_slide_wall(delta)
		player_wall_jump(delta)
		player_dash(delta)
		take_portal()
		take_shop_portal()
		initiate_dialogue()
		buy_shop_item()
	else:
		velocity.x = 0
		current_state = State.IDLE
	
	was_on_floor = is_on_floor()
	was_on_wall = is_on_wall()
	move_and_slide()
	if !is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump_timer.start()
	if !is_on_wall() and was_on_wall and velocity.y >= 0:
		coyote_walljump_timer.start()
	player_animation()
	PlayerStateManager.set_position(global_position)

func player_falling(delta) -> void:
	if is_dashing:
		return
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > 0:
			current_state = State.FALL

func player_idle() -> void:
	if is_on_floor() and Input.get_axis("move_left", "move_right") == 0 and current_state != State.IDLE:
		current_state = State.IDLE

func player_run(delta) -> void:
	if is_dashing:
		return
		
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0 or !wall_jump_height_variation_timer.is_stopped():
		if direction > 0 && !PlayerStateManager.get_is_facing_right() :
			PlayerStateManager.set_is_facing_right(!PlayerStateManager.get_is_facing_right())
		elif direction < 0 && PlayerStateManager.get_is_facing_right() :
			PlayerStateManager.set_is_facing_right(!PlayerStateManager.get_is_facing_right())
		animated_sprite_2d.flip_h = true if !PlayerStateManager.get_is_facing_right() else false
		if is_on_floor():
			current_state = State.RUN
		if(!wall_jump_height_variation_timer.is_stopped()):
			velocity.x += direction * SPEED * delta / 15
		else:
			velocity.x += direction * SPEED * delta
			velocity.x = clamp(velocity.x, -(direction * SPEED * delta), direction * SPEED * delta)
		if is_on_wall() and is_on_floor():
			current_state = State.WALLWALK
			last_wall_grabbed_on_right = PlayerStateManager.get_is_facing_right()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func player_jump(delta) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or !coyote_jump_timer.is_stopped():
			velocity.y = 0
			coyote_jump_timer.stop()
			jump_height_variation_timer.start()
			can_go_higher = true
			current_state = State.JUMP
			velocity.y -= JUMP_HEIGHT * delta
	elif Input.is_action_pressed("jump") and can_go_higher:
			velocity.y -= JUMP_HEIGHT/22 * delta
			
func player_slide_wall(delta) -> void:
	if !is_on_wall() or is_on_floor():
		return
	var col = get_last_slide_collision()
	if col == null:
		return
	var wall_normal: Vector2 = col.get_normal()
	var wall_on_right = wall_normal.x < 0
	var dir = Input.get_axis("move_left", "move_right")
	if wall_on_right and dir <= 0:
		return
	if not wall_on_right and dir >= 0:
		return
	current_state = State.WALL
	last_wall_grabbed_on_right = wall_on_right
	velocity.y = 0
	velocity.y = min(velocity.y + GRAVITY * delta * 0.5, 200)
	
func player_wall_jump(delta) -> void:
	if (!is_on_wall() and !can_go_higher_wall and coyote_walljump_timer.is_stopped()) or is_dashing:
		return
	if Input.is_action_just_pressed("jump"):
		if current_state == State.WALL or is_on_wall() or !coyote_walljump_timer.is_stopped():
			velocity.y = 0
			velocity.x = 0
			coyote_walljump_timer.stop()
			wall_jump_height_variation_timer.start()
			can_go_higher_wall = true
			current_state = State.JUMP
			velocity.y -= JUMP_HEIGHT * delta
			if last_wall_grabbed_on_right:
				velocity.x -= SPEED * delta * 1.5
			else:
				velocity.x += SPEED * delta
		elif can_go_higher_wall:
			velocity.y -= JUMP_HEIGHT/22 * delta

func player_dash(delta) -> void:
	if (!PlayerStateManager.get_can_dash() and !is_dashing) or !PlayerStateManager.has_unlocked_dash:
		return
	if is_dashing:
		if dash_direction.x != 0 and dash_direction.y != 0:
			velocity.x += (dash_direction.x * DASH_SPEED_X * delta / 4)*0.8
			velocity.y += (dash_direction.y * DASH_SPEED_Y * delta / 4)*0.8
		else:
			velocity.x += dash_direction.x * DASH_SPEED_X * delta / 4
			velocity.y += dash_direction.y * DASH_SPEED_Y * delta / 4
		current_state = State.DASH
	elif Input.is_action_just_pressed("dash"):
		if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
			dash_direction = Vector2(1,-1)
		elif Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
			dash_direction = Vector2(1,1)
		elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
			dash_direction = Vector2(-1,-1)
		elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
			dash_direction = Vector2(-1,1)
		elif Input.is_action_pressed("move_up"):
			dash_direction = Vector2(0,-1)
		elif Input.is_action_pressed("move_down"):
			dash_direction = Vector2(0,1)
		elif Input.is_action_pressed("move_right"):
			dash_direction = Vector2(1,0)
		elif Input.is_action_pressed("move_left"):
			dash_direction = Vector2(-1,0)
		elif PlayerStateManager.get_is_facing_right():
			dash_direction = Vector2(1,0)
		elif !PlayerStateManager.get_is_facing_right():
			dash_direction = Vector2(-1,0)
		var after_image = dash_after_image_right.instantiate() if PlayerStateManager.get_is_facing_right() else dash_after_image_left.instantiate()
		get_tree().current_scene.add_child(after_image)
		after_image.global_position = global_position
		velocity.x = dash_direction.x * DASH_SPEED_X * delta if dash_direction.y == 0 else (dash_direction.x * DASH_SPEED_X * delta)*0.8
		velocity.y = dash_direction.y * DASH_SPEED_Y * delta if dash_direction.x == 0 else (dash_direction.y * DASH_SPEED_Y * delta)*0.8
		is_dashing = true
		dash_duration_timer.start()
		current_state = State.DASH

func take_portal() -> void:
	if !can_take_portal:
		return
	if Input.is_action_just_pressed("interact"):
		GameManager.player_takes_portal()

func take_shop_portal() -> void:
	if !can_take_shop_portal:
		return
	if Input.is_action_just_pressed("interact"):
		GameManager.player_takes_shop_portal()

func take_boss_portal() -> void:
	if !can_take_boss_portal:
		return
	if Input.is_action_just_pressed("interact"):
		GameManager.player_takes_boss_portal()

func buy_shop_item() -> void:
	if !can_buy_item:
		return
	if Input.is_action_just_pressed("interact"):
		GameManager.player_buys_item()

func initiate_dialogue() -> void:
	if !can_initiate_dialogue:
		return
	if Input.is_action_just_pressed("interact"):
		TimeStateManager.start_dialogue()

func player_animation() -> void:
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.JUMP:
		animated_sprite_2d.play("jump")
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
	elif current_state == State.FALL:
		animated_sprite_2d.play("fall")
	elif current_state == State.WALL:
		animated_sprite_2d.play("wall")
	elif current_state == State.WALLWALK:
		animated_sprite_2d.play("wall_walk")
	elif current_state == State.DASH:
		animated_sprite_2d.play("dash")

func _on_jump_height_variation_timer_timeout() -> void:
	can_go_higher = false

func _on_wall_jump_height_variation_timer_timeout() -> void:
	can_go_higher_wall = false

func _on_dash_duration_timer_timeout():
	is_dashing = false
	dash_direction = Vector2(0,0)
	velocity.y = move_toward(velocity.y, 0, 500)

func enable_interaction_label() -> void:
	if PlayerStateManager.is_in_cutscene:
		return
	interaction_label.visible = true

func disable_interaction_label() -> void:
	interaction_label.visible = false

func set_can_take_portal(b:bool) -> void:
	can_take_portal = b

func set_can_take_shop_portal(b:bool) -> void:
	can_take_shop_portal = b

func set_can_take_boss_portal(b:bool) -> void:
	can_take_boss_portal = b

func set_can_initiate_dialogue(b:bool) -> void:
	can_initiate_dialogue = b

func set_can_buy_item(b:bool) -> void:
	can_buy_item = b

func on_player_takes_damage() -> void:
	if can_take_damage:
		global_position = GameManager.get_latest_checkpoint()
		GameManager.deduce_time()
		is_dashing = false
		lost_time_cd_timer.start()
		can_take_damage = false

func _on_lost_time_cd_timer_timeout():
	can_take_damage = true
