extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_height_variation_timer = $JumpHeightVariationTimer
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var wall_jump_height_variation_timer = $WallJumpHeightVariationTimer
@onready var coyote_walljump_timer = $CoyoteWalljumpTimer
@onready var dash_cool_down_timer = $DashCoolDownTimer
@onready var dash_duration_timer = $DashDurationTimer

const GRAVITY:int = 900
const SPEED:int = 10000
const JUMP_HEIGHT:int = 14000
const DASH_SPEED:int = 25000

enum State {IDLE, RUN, JUMP, FALL, WALL, WALLWALK, DASH}

var current_state:State
var is_facing_right:bool = true
var last_wall_grabbed_on_right:bool
var can_go_higher:bool
var can_go_higher_wall:bool
var was_on_floor:bool
var was_on_wall:bool
var can_dash:bool = true
var is_dashing:bool = false
var dash_direction:Vector2

func _ready() -> void:
	current_state = State.IDLE

func _physics_process(delta) -> void:
	player_falling(delta)
	player_idle()
	player_run(delta)
	player_jump(delta)
	player_slide_wall(delta)
	player_wall_jump(delta)
	player_dash(delta)
	
	was_on_floor = is_on_floor()
	was_on_wall = is_on_wall()
	move_and_slide()
	if !is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump_timer.start()
	if !is_on_wall() and was_on_wall and velocity.y >= 0:
		coyote_walljump_timer.start()
	player_animation()

func player_falling(delta) -> void:
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
		if direction > 0 && !is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		elif direction < 0 && is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		if is_on_floor():
			current_state = State.RUN
		if(!wall_jump_height_variation_timer.is_stopped()):
			velocity.x += direction * SPEED * delta / 15
		else:
			velocity.x += direction * SPEED * delta
			velocity.x = clamp(velocity.x, -(direction * SPEED * delta), direction * SPEED * delta)
		if is_on_wall() and is_on_floor():
			current_state = State.WALLWALK
			last_wall_grabbed_on_right = is_facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func player_jump(delta) -> void:
	if Input.is_action_pressed("jump"):
		if is_on_floor() or !coyote_jump_timer.is_stopped():
			velocity.y = 0
			coyote_jump_timer.stop()
			jump_height_variation_timer.start()
			can_go_higher = true
			current_state = State.JUMP
			velocity.y -= JUMP_HEIGHT * delta
		elif can_go_higher:
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
	if !can_dash and !is_dashing:
		return
	if is_dashing:
		velocity.x += dash_direction.x * DASH_SPEED * delta / 2
		velocity.y += dash_direction.y * DASH_SPEED * delta / 2
		current_state = State.DASH
	elif Input.is_action_just_pressed("dash"):
		velocity.x = 0
		velocity.y = 0
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
		elif is_facing_right:
			dash_direction = Vector2(1,0)
		elif !is_facing_right:
			dash_direction = Vector2(-1,0)
		velocity.x += dash_direction.x * DASH_SPEED * delta
		velocity.y += dash_direction.y * DASH_SPEED * delta
		can_dash = false
		is_dashing = true
		dash_cool_down_timer.start()
		dash_duration_timer.start()
		current_state = State.DASH

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

func _on_dash_cool_down_timer_timeout():
	can_dash = true

func _on_dash_duration_timer_timeout():
	is_dashing = false
	dash_direction = Vector2(0,0)
