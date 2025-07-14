extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const GRAVITY:int = 1000
const SPEED:int = 10000

enum State {IDLE, RUN, JUMP, FALL}

var current_state:State

func _ready():
	current_state = State.IDLE

func _physics_process(delta):
	player_falling(delta)
	player_idle()
	player_run(delta)
	player_animation()
	
	move_and_slide()

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle():
	if is_on_floor():
		current_state = State.IDLE

func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		animated_sprite_2d.flip_h = false if direction > 0 else true
		current_state = State.RUN
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func player_animation():
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	if current_state == State.RUN:
		animated_sprite_2d.play("run")
