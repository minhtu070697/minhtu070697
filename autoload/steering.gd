extends Node

const DEFAULT_MASS = 2.0
const DEFAULT_MAX_SPEED = 100
const DEFAULT_STOP_THRESHOLD = 1
const DEFAULT_SLOW_RADIUS = 25


###
### THESE FUNCTIONS RETURN THE `STEERING` vector to be applied to
### the source velocity
###
# Go toward a location
static func seek(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	mass = DEFAULT_MASS
) -> Vector2:
	var desired_velocity = source_position.direction_to(target_position) * max_speed
	return (desired_velocity - velocity) / mass

# Go toward a location and gradually slow down upon arrive
static func arrive_to(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	slow_radius = DEFAULT_SLOW_RADIUS,
	mass = DEFAULT_MASS
) -> Vector2:
	var distance_to_target = source_position.distance_to(target_position)
	var desired_velocity = source_position.direction_to(target_position) * max_speed
	if distance_to_target < slow_radius:
		desired_velocity *= (distance_to_target / slow_radius) * 0.8 + 0.2
	var steering = (desired_velocity - velocity) / mass
	return steering


# Flee away from a location
static func flee(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	mass = DEFAULT_MASS
) -> Vector2:
	var desired_velocity = target_position.direction_to(source_position) * max_speed 
	var steering = (desired_velocity - velocity) / mass
	return steering
	
#Stuck avoid, like flee but it calculates the position ahead of time a little bit
# position = position + velocity * T
# T = distance / max_speed
static func stuck_avoid(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	mass = DEFAULT_MASS
) -> Vector2:
	var angle_to_target = velocity.angle_to(target_position - source_position)
	var desired_velocity = target_position.direction_to(source_position) * max_speed
	var avoid_angle = -60 if angle_to_target <= 0 else 60
	var desired_velocity2 = desired_velocity.rotated(deg2rad(avoid_angle))
	var steering = (desired_velocity2 - velocity) / mass
	return steering


# Similar to seek, but it calculates the position ahead of time a little bit
# position = position + velocity * T
# T = distance / max_speed
static func pursue(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	target_velocity: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	mass = DEFAULT_MASS
) -> Vector2:
	var distance = source_position.distance_to(target_position)
	var t = distance / max_speed
	var future_position = target_position + target_velocity * t
	return seek(velocity, source_position, future_position, max_speed, mass)


static func evade(
	velocity: Vector2,
	source_position: Vector2,
	target_position: Vector2,
	target_velocity: Vector2,
	max_speed = DEFAULT_MAX_SPEED,
	mass = DEFAULT_MASS
) -> Vector2:
	var distance = source_position.distance_to(target_position)
	var t = distance / max_speed
	var future_position = target_position + target_velocity * t
	return flee(velocity, source_position, future_position, max_speed, mass)
