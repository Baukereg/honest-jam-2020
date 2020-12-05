extends Spatial
class_name CameraInstance

const LERP_SPEED = .1

var target = null

##
# @override
##
func _ready():
	$Camera.translation = Vector3(0, 26, 26)
	$Camera.look_at(Vector3.ZERO, Vector3.UP);
	rotation.y = deg2rad(45)

##
# @override
##
func _physics_process(delta):
	if target != null:
		translation = lerp(translation, target.translation, LERP_SPEED)