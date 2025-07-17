extends CharacterBody2D

@export var patrol_points:Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer

const GRAVITY:int = 900
const SPEED:int = 9000

enum State {IDLE, RUN}

var current_state:State
var direction: Vector2 = Vector2.LEFT
var number_of_points:int
var point_positions:Array[Vector2]
var current_point:Vector2
var current_point_position:int
var can_walk:bool

func _ready() -> void:
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	can_walk = false
	current_state = State.IDLE

func _physics_process(delta) -> void:
	enemy_gravity(delta)
	enemy_idle()
	enemy_walk(delta)
	move_and_slide()
	enemy_animation()

func enemy_gravity(delta) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func enemy_idle() -> void:
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		current_state = State.IDLE

func enemy_walk(delta) -> void:
	if !can_walk:
		return
	
	if abs(position.x - current_point.x) > 2:
		velocity.x = direction.x * SPEED * delta
		current_state = State.RUN
	else:
		current_point_position += 1
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = point_positions[current_point_position]
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		can_walk = false
		idle_timer.start()
		
	if idle_timer.is_stopped():
		animated_sprite_2d.flip_h = direction.x > 0

func enemy_animation() -> void:
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")


func _on_idle_timer_timeout():
	can_walk = true
