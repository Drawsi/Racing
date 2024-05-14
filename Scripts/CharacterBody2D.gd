extends CharacterBody2D

var wheel_base = 70
var steering_angle = 8
var engine_power = 1800
var friction = -30
var drag = -0.06
var braking = -1800
var max_speed_reverse = 250
var slip_speed = 650
var traction_fast = 3
var traction_slow = 18

var acceleration = Vector2.ZERO
var steer_direction

var zoom_speed = 0.05
var min_zoom = 0.5
var max_zoom = 1.0

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	particles()
	velocity += acceleration * delta
	move_and_slide()
	adjust_camera_zoom(delta)

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func get_input():
	var turn = Input.get_axis("a", "d")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("s"):
		acceleration = transform.x * braking 
	elif Input.is_action_pressed("w"):
		acceleration = transform.x * engine_power
		$AudioStreamPlayer2D.play()

func adjust_camera_zoom(delta):
	var zoom_factor = $Camera2D.zoom.x
	if velocity.length() < 200 and acceleration == Vector2.ZERO:  # Car is moving slowly and no acceleration
		zoom_factor = min(max_zoom, zoom_factor + zoom_speed * delta)
	else:
		zoom_factor = max(min_zoom, zoom_factor - zoom_speed * delta)
	$Camera2D.zoom = Vector2(zoom_factor, zoom_factor)

func calculate_steering(delta):
	var target_steering_angle = steering_angle
	
	if velocity.length() > 500:
		target_steering_angle = max_steering_angle
	else:
		target_steering_angle = steering_angle
		
	steering_angle = lerp(float(steering_angle), float(target_steering_angle), 0.2)
	
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
