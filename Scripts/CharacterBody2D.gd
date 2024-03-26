extends CharacterBody2D

var wheel_base = 70
var steering_angle = 15
var engine_power = 1200
var friction = -30
var drag = -0.06
var braking = -450
var max_speed_reverse = 250
var slip_speed = 650
var traction_fast = 3
var traction_slow = 18

var acceleration = Vector2.ZERO
var steer_direction

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	particles()
	velocity += acceleration * delta
	move_and_slide()
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
func get_input():
	var turn = Input.get_axis("a", "d")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("w"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("s"):
		acceleration = transform.x * braking
	
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow
	
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
#	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()

func particles():
	var l = preload("res://Scenes/drift_line.tscn").instantiate()
	var r = l.duplicate()
	if velocity.length() > slip_speed and steer_direction:
		l.position = $Rear_Left_Wheel.global_position
		l.rotation = rotation
		$Rear_Left_Wheel.add_child(l)
		r.position = $Rear_Right_Wheel.global_position
		r.rotation = rotation
		$Rear_Right_Wheel.add_child(r)
