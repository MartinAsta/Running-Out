extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var jump_height_variation_timer = $JumpHeightVariationTimer
@onready var coyote_jump_timer = $CoyoteJumpTimer

const GRAVITY:int = 900
const SPEED:int = 10000
const JUMP_HEIGHT:int = 14000

enum State {IDLE, RUN, JUMP, FALL}

var current_state:State
var is_facing_right:bool = true
var can_go_higher:bool
var was_on_floor:bool

func _ready() -> void:
	current_state = State.IDLE

func _physics_process(delta) -> void:
	player_falling(delta)
	player_idle()
	player_run(delta)
	player_jump(delta)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	if !is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump_timer.start()
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
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		if direction > 0 && !is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		elif direction < 0 && is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		if is_on_floor():
			current_state = State.RUN
		velocity.x = direction * SPEED * delta
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

func player_animation() -> void:
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.JUMP:
		animated_sprite_2d.play("jump")
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
	elif current_state == State.FALL:
		animated_sprite_2d.play("fall")

func _on_jump_height_variation_timer_timeout() -> void:
	can_go_higher = false
