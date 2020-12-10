extends Node

const GRAVITY = Vector3.DOWN * 60
const ROTATION_LERP = .2
	
##
# @method _move_towards
# @param {float} delta
# @param {Spatial} source
# @param {Vector3} velocity
# @param {Vector2} target
# @param {float} speed
##
func _move_towards(delta:float, source:Spatial, velocity:Vector3, target:Vector2, speed:float):
	var position = Vector2(source.translation.x, source.translation.z)
	
	# Get the angle to the next node.
	var angle = position.angle_to_point(target) * -1
	var target_direction = Vector2(-cos(angle), sin(angle))
	
	# Rotate mesh.
	var towards = Utils.normalize_rotate_towards(source.rotation_degrees.y, rad2deg(angle) + 180) 
	source.rotation_degrees.y = lerp(source.rotation_degrees.y, towards, ROTATION_LERP)
	
	# Apply velocity.
	velocity += GRAVITY * delta
	velocity.x = target_direction.x * speed
	velocity.z = target_direction.y * speed
	velocity = source.move_and_slide(velocity, Vector3.UP)
	
	var dist_to_target = position.distance_to(target)
	
	return {
		"velocity": velocity,
		"dist_to_target": dist_to_target
	}
	