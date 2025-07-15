extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_idle = $Collision_IDLE
@onready var collision_fall = $Collision_FALL
@onready var collision_jump = $Collision_JUMP
@onready var collision_run = $Collision_RUN

const GRAVITY:int = 1000
const SPEED:int = 10000
const JUMP_HEIGHT:int = 15000

enum State {IDLE, RUN, JUMP, FALL}

var current_state:State
var is_facing_right:bool = true

func _ready():
	set_state(State.IDLE)

func _physics_process(delta):
	Engine.time_scale = 0.2
	print(collision_idle.disabled)
	print(collision_fall.disabled)
	print(collision_jump.disabled)
	print(collision_run.disabled)
	player_falling(delta)
	player_idle()
	player_run(delta)
	player_animation()
	player_jump(delta)
	
	move_and_slide()

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle():
	if is_on_floor() and Input.get_axis("move_left", "move_right") == 0 and current_state != State.IDLE:
		set_state(State.IDLE)

func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		if direction > 0 && !is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		elif direction < 0 && is_facing_right :
			is_facing_right = !is_facing_right
			scale.x *= -1
		if current_state != State.JUMP:
			set_state(State.RUN)
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func player_jump(delta):
	if Input.is_action_pressed("jump") and is_on_floor():
		set_state(State.JUMP)
		velocity.y -= JUMP_HEIGHT * delta

func player_animation():
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.JUMP:
		animated_sprite_2d.play("jump")
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")

func disable_hitbox(state:State):
	match state:
		State.RUN:
			collision_run.disabled = true
		State.IDLE:
			collision_idle.disabled = true
		State.JUMP:
			collision_jump.disabled = true
		State.FALL:
			collision_fall.disabled = true

func enable_hitbox(state:State):
	match state:
		State.RUN:
			collision_run.disabled = false
		State.IDLE:
			collision_idle.disabled = false
		State.JUMP:
			collision_jump.disabled = false
		State.FALL:
			collision_fall.disabled = false

func set_state(new_state:State):
	if new_state == current_state:
		return
	if current_state:
		disable_hitbox(current_state)
	current_state = new_state
	enable_hitbox(current_state)
	
