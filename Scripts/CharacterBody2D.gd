extends CharacterBody2D

# Car configuration parameters
var wheel_base = 70
var steering_angle = 8.0
var engine_power = 1800
var friction = -15.0
var drag = -0.03
var braking = -1800
var max_speed_reverse = 250
var slip_speed = 650
var traction_fast = 3.0
var traction_slow = 18.0

# Variables for handling car dynamics
var acceleration = Vector2.ZERO
var steer_direction = 0.0
var target_steer_direction = 0.0
var responsiveness = 6.0 # lower is smoother, higher is more responsive

# Camera zoom parameters
var zoom_speed = 0.1
var min_zoom = 0.5
var max_zoom = 2.0

# Main physics process function, called every frame
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input() # Handle player input
	apply_friction(delta) # Apply friction to the car's velocity
	calculate_steering(delta) # Calculate the car's steering
	particles() # Generate particle effects
	velocity += acceleration * delta # Update velocity based on acceleration
	move_and_slide() # Move the car based on its updated velocity
	adjust_camera_zoom(delta) # Adjust the camera zoom based on speed

# Apply friction and drag to slow down the car
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

# Handle player input for acceleration and steering
func get_input():
	var turn = Input.get_axis("a", "d")
	target_steer_direction = turn * deg_to_rad(steering_angle) # Update target steering direction based on input
	if Input.is_action_pressed("s"):
		acceleration = transform.x * braking # Apply braking force
	elif Input.is_action_pressed("w"):
		acceleration = transform.x * engine_power # Apply engine power
		$AudioStreamPlayer2D.play() # Play engine sound

# Adjust the camera zoom based on the car's speed
func adjust_camera_zoom(delta):
	var zoom_factor = $Camera2D.zoom.x
	if velocity.length() < 200 and acceleration == Vector2.ZERO: # Car is moving slowly and no acceleration
		zoom_factor = min(max_zoom, zoom_factor + zoom_speed * delta)
	else:
		zoom_factor = max(min_zoom, zoom_factor - zoom_speed * delta)
	$Camera2D.zoom = Vector2(zoom_factor, zoom_factor)

# Calculate the car's steering and handling
func calculate_steering(delta):
	# Smoothly adjust the steering direction towards the target
	steer_direction = lerp(steer_direction, target_steer_direction, responsiveness * delta) # Smooth steering transition
	
	# Adjust the steering angle based on speed for cornering
	var target_steering_angle = 8.0
	if velocity.length() <= 850:
		target_steering_angle = 12.0
	steering_angle = lerp(steering_angle, target_steering_angle, 0.2)
	
	# Calculate new wheel positions and heading direction
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_slow

	if velocity.length() > slip_speed:
		traction = traction_fast

	# Adjust the car's velocity based on the new heading and traction
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	# Update the car's rotation to match the new heading
	rotation = new_heading.angle()

# Generate particle effects for drifting
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
