extends Spatial
class_name CameraInstance

const LERP_SPEED = .1

onready var _camera:Camera = $Camera

var target = null
var zoom_level = 0

##
# @override
##
func _ready():
	_camera.translation = Vector3(0, 26, 26)
	_camera.look_at(Vector3.ZERO, Vector3.UP);
	rotation.y = .7

##
# @override
##
func _physics_process(delta):
	if target != null:
		translation = lerp(translation, target.translation, LERP_SPEED)
		