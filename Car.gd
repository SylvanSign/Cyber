extends KinematicBody2D

export(int) var ACCELERATION := 300
export(int) var MAX_SPEED := 100
export(int) var FRICTION := 200
enum {
	EMPTY,
	IDLE,
	RUN,
}

onready var animation_tree := $AnimationTree
onready var animation_machine: AnimationNodeStateMachinePlayback = animation_tree['parameters/playback']
onready var entry := $Entry

var velocity: Vector2
var state := EMPTY


func _physics_process(delta: float) -> void:
	match state:
		EMPTY:
			pass
		IDLE:
			if move(delta):
				animation_machine.travel('run')
				state = RUN
		RUN:
			if !move(delta):
				animation_machine.travel('idle')
				state = IDLE

func move(delta: float) -> bool:
	var input := get_input_vector()
	update_animation(input)
	apply_forces(delta, input)
	velocity = move_and_slide(velocity)
	return velocity != Vector2.ZERO

func get_input_vector() -> Vector2:
	var input := Vector2(
		Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left'),
		Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	)
	if input.length() > 1:
		input = input.normalized()
	return input

func apply_forces(delta: float, input: Vector2) -> void:
	velocity += input * ACCELERATION * delta
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = velocity.clamped(MAX_SPEED)

func update_animation(input: Vector2) -> void:
	if input != Vector2.ZERO:
		animation_tree['parameters/idle/blend_position'] = input
		animation_tree['parameters/run/blend_position'] = input
