extends CharacterBody2D

# Car configuration parameters
var wheel_base = 70
var steering_angle = 8.0
var engine_power = 1400
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
var max_zoom = 1.5

# Main physics process function, called every frame
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input() # Handle player input
	apply_friction(delta) # Apply friction to the car's velocity
	calculate_steering(delta) # Calculate the car's steering
	particles() # Generate particle effects
	velocity += acceleration * delta # Update velocity based on acceleration
	move_and_slide() # Move the car based on its updated velocity

# Apply friction and drag to slow down the car
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func get_input():
	acceleration = transform.x * engine_power
	
	# Calculate the distances from the current position to the collision points of the rays
	var L_dist = $Rays/L.get_collision_point().distance_to(position)
	var R_dist = $Rays/R.get_collision_point().distance_to(position)
	var L_col = $Rays/L.is_colliding()
	var R_col = $Rays/R.is_colliding()
	var turn = 0.0
	var turning_strength = 2
	# For going backwards
	"""if L_col and R_col and F_col:
			acceleration = transform.x * -100"""
	
	if L_col and R_col:
		# Obstacles on both sides, turn based on the closer obstacle
		if L_dist < R_dist:
			turn = 1.0 - (L_dist / max(L_dist, R_dist))
		else:
			turn = (R_dist / max(L_dist, R_dist)) - 1.0
	elif L_col:
		# Obstacle on the left, turn right
		turn = 1.0 
	elif R_col:
		# Obstacle on the right, turn left
		turn =  - 1.0 
	else:
		# No obstacles detected, go straight
		turn = 0.0
	
	# Clamp the turn value to ensure it stays within the range -1 to 1
	turn = clamp(turn, -1, 1)
	
	# Update the target steering direction based on the turn value
	target_steer_direction = turn * turning_strength * deg_to_rad(steering_angle)


	
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
